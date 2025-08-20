#!/usr/bin/env bash

# Script for listing and selecting Tmux sessions using fzf-tmux in a pop-up
# window (requires Tmux version 3.2 or above).
#
# Usage:
#   `tmux-find-sessions.sh`
#
# Example keybind in `tmux.conf`:
#   `bind-key f run-shell tmux-find-sessions.sh`

# ------------------- Colour scheme, feel free to change ----------------------

# Solarized light colours
HIGHLIGHT="#268BD2"           # Highlight: blue
FOREGROUND="#93A1A1"          # Foreground: light grey
BACKGROUND="#FDF6E3"          # Background: white
SELECTED_FOREGROUND="#586E75" # Selected foreground: grey
SELECTED_BACKGROUND="#EEE8D5" # Selected background: dark white
SELECTED_HIGHLIGHT="#2AA198"  # Selected highlight: cyan
PROMPT="#268BD2"              # Prompt: blue
POINTER="#2AA198"             # Pointer: cyan
INFO="#93A1A1"                # Info elements: light grey
BORDER="#657B83"              # Border: grey

# ----------------------- Main script; DO NOT CHANGE --------------------------

# List Tmux session names
SESSIONS=$(tmux list-sessions -F "#S: #{session_name}" | cut -d ':' -f 1)

# Calculate the fzf window height based on the number of Tmux sessions plus
# the four lines coming from fzf-tmux elements, with a minimum height, without
# exceeding the terminal's height
MIN_HEIGHT=7
SESSION_COUNT=$(printf "%s\n" "$SESSIONS" | wc -l)
FZF_HEIGHT=$((SESSION_COUNT + 4 < MIN_HEIGHT ? MIN_HEIGHT : SESSION_COUNT + 4))
FZF_HEIGHT=$((FZF_HEIGHT > $(tput lines) ? $(tput lines) : FZF_HEIGHT))

# Calculate the fzf window width based on the length of the longest session name
# plus the six lines coming from fzf-tmux elements, with a minimum width
MIN_WIDTH=25
MAX_LENGTH=$(printf "%s\n" "$SESSIONS" | wc -L)
FZF_WIDTH=$((MAX_LENGTH + 6 < MIN_WIDTH ? MIN_WIDTH : MAX_LENGTH + 6))

# Build colour scheme
COLOURS="hl:$HIGHLIGHT"
COLOURS="$COLOURS,fg:$FOREGROUND"
COLOURS="$COLOURS,bg:$BACKGROUND"
COLOURS="$COLOURS,fg+:$SELECTED_FOREGROUND"
COLOURS="$COLOURS,bg+:$SELECTED_BACKGROUND"
COLOURS="$COLOURS,hl+:$SELECTED_HIGHLIGHT"
COLOURS="$COLOURS,prompt:$PROMPT"
COLOURS="$COLOURS,pointer:$POINTER"
COLOURS="$COLOURS,info:$INFO"
COLOURS="$COLOURS,border:$BORDER"

# Run fzf-tmux with appropriate settings
TARGET_SESSION=$(echo "$SESSIONS" | fzf-tmux \
    -p "$FZF_WIDTH","$FZF_HEIGHT" \
    --color="$COLOURS" \
    --reverse
)

# Switch to the selected session if selection was completed
if [ -n "$TARGET_SESSION" ]; then
    tmux switch-client -t "$TARGET_SESSION"
fi

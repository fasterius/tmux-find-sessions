#!/usr/bin/env bash

# Script for listing and selecting Tmux sessions using fzf-tmux in a pop-up
# window (requires Tmux version 3.2 or above).
#
# Usage:
#   $ tmux-find-sessions.sh [COLOUR_SCHEME]
#
# Example keybind in `tmux.conf`:
#   $ bind-key f run-shell tmux-find-sessions.sh -c solarized_light

# --------------------------- Argument parsing --------------------------------

# Help function
help() {
    echo "Usage: $0 [-c COLOUR_SCHEME]"
    echo
    echo "  -c   Colour scheme (available: 'solarized_light', 'everforest_dark_hard)"
    echo "  -h   Show this help"
    exit 1
}

# Default configuration
COLOUR_SCHEME=""

# Parse options
while getopts ":c:h" opt; do
    case ${opt} in
        c ) COLOUR_SCHEME="$OPTARG" ;;
        h ) help ;;
        \? ) echo "Invalid option: -$OPTARG" >&2; help ;;
        : ) echo "Option -$OPTARG requires an argument." >&2; help ;;
    esac
done

# Validate the colour scheme argument
if [ -n "$COLOUR_SCHEME" ] && \
   [ "$COLOUR_SCHEME" != "solarized_light" ] && \
   [ "$COLOUR_SCHEME" != "everforest_dark_hard" ]; then
    echo "Error: Invalid colour scheme \`$COLOUR_SCHEME\`" >&2
    exit 1
fi

# _---------------------------- Colour schemes --------------------------------

if [ "$COLOUR_SCHEME" == "everforest_dark_hard" ]; then
    HIGHLIGHT="#83c092"           # Highlight: green
    FOREGROUND="#d3c6aa"          # Foreground: white
    BACKGROUND="#272e33"          # Background: dark grey
    SELECTED_FOREGROUND="#d3c6aa" # Selected foreground: white
    SELECTED_BACKGROUND="#475258" # Selected background: grey
    SELECTED_HIGHLIGHT="#83c092"  # Selected highlight: green
    PROMPT="#83c092"              # Prompt: green
    POINTER="#83c092"             # Pointer: green
    INFO="#d3c6aa"                # Info elements: white
    BORDER="#475258"              # Border: grey
elif [ "$COLOUR_SCHEME" == "solarized_light" ]; then
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
fi

# ------------------------------ Main script ----------------------------------

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

# `tmux-fzf-session.sh`

A Bash script for listing and selecting Tmux sessions using
[`fzf-tmux`](https://github.com/junegunn/fzf) in a pop-up window. Requires
**Tmux 3.2+** for native pop-up support.

## Features

- Lists all available Tmux sessions and displays them in an interactive
  `fzf-tmux` pop-up for selection.
- Dynamically adjusts the pop-up's height and width.

## Dependencies

- `bash`
- `tmux >= v3.2`
- `fzf-tmux`

## Installation

Clone this repository in a location of your choosing _e.g._ `~/opt`:

```bash
git clone git@github.com:fasterius/tmux-fzf-session.git ~/opt/tmux-fzf-session
```

## Usage

Bind the script in your `~/.tmux.conf`:

```tmux
bind-key f run-shell ~/opt/tmux-find-sessions/tmux-find-sessions.sh
```

Then press the bound key (_e.g._ `prefix + f`) to bring up the fzf-powered
session picker.

## Colours

The [Solarized light](https://ethanschoonover.com/solarized/) colours are used
by default, but they can be changed inside the script as desired.

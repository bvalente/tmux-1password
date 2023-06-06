#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
  || exit 1

# ------------------------------------------------------------------------------

source "./scripts/utils/cmd.sh"
source "./scripts/utils/tmux.sh"

source "./scripts/options.sh"

# ------------------------------------------------------------------------------

declare -r CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

declare -a REQUIRED_COMMANDS=(
  'op'
  'jq'
  'fzf'
)

# ------------------------------------------------------------------------------

main() {
  for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if ! cmd::exists "$cmd"; then
      tmux::display_message "command '$cmd' not found"
      return 1
    fi
  done

  # check for a session named op, if there is none, create one
  op=0
  if ! $(tmux has-session -t op 2> /dev/null)
  then
    op=$(tmux new-session -s op -n op -d -P -F '#{pane_id}')
  else
    op=$(tmux list-panes -s -t op -F '#{pane_id}')
  fi

  # this only works if you only have two sessions
  tmux bind-key "$(options::keybinding)" \
    run "tmux send-keys -t $op \"$CURRENT_DIR/scripts/main.sh '#{pane_id}'; tmux switch-client -l\" ENTER; tmux switch-client -t op"
}

main "$@"

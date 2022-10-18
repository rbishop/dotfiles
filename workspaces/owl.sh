#1 /bin/zsh

if tmux has-session -t owl  2> /dev/null; then
  echo 'attaching'
  tmux attach-session -t owl
  exit 0
fi

function send_command() {
  local window=$1
  local cmd=$2

  tmux send-keys -t "=owl:=${window}" "${cmd}" Enter
}

function new_window() {
  local name=$1

  tmux new-window -d -t '=owl' -n $name
  send_command $name "nix develop --no-update-lock-file"
}

ssh-add ~/.ssh/crunchy

tmux new-session -d -s owl -c ~/code/owl-deps -n vim
send_command "vim" "nix develop --no-update-lock-file"
send_command "vim" "vim ."

new_window "pry"
tmux split-window -t '=owl:=pry' -h
send_command "pry" "nix develop --no-update-lock-file"

new_window "debug"

tmux attach -t owl

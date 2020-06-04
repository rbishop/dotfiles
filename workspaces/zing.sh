#! /bin/sh

# Make sure xhyve is running
if [[ $(pgrep -q xhyve) -ne "0" ]]
then
  echo "xhyve isn't running" 1>&2
  exit 1
fi

if  tmux has-session -t zing 2> /dev/null
then
  echo 'attaching'
  tmux attach-session -t zing
  exit 0
fi

# Add the private key to our Linux virtual machine
ssh-add ~/.ssh/dev

tmux new-session -d -s zing -n vim
tmux send-keys -t '=zing:=vim' 'ssh vm' Enter
tmux send-keys -t '=zing:=vim' 'cd ~/code/zing; vim .' Enter

tmux new-window -d -t '=zing' -n build
tmux send-keys -t '=zing:=build' 'ssh vm' Enter
tmux send-keys -t '=zing:=build' 'cd ~/code/zing' Enter

tmux new-window -d -t '=zing' -n liburing
tmux send-keys -t '=zing:=liburing' 'ssh vm' Enter
tmux send-keys -t '=zing:=liburing' 'cd ~/code/liburing' Enter

tmux new-window -d -t '=zing' -n zig-std
tmux send-keys -t '=zing:=zig-std' 'ssh vm' Enter
tmux send-keys -t '=zing:=zig-std' 'cd ~/code/zig' Enter

tmux new-window -d -t '=zing' -n netcat
tmux send-keys -t '=zing:=netcat' 'ssh vm' Enter
tmux send-keys -t '=zing:=netcat' './sleep_listen.sh' Enter

tmux attach-session -t zing

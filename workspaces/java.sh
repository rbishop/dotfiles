#! /bin/sh

# Make sure xhyve is running
if [[ $(pgrep -q xhyve) -ne "0" ]]
then
  echo "xhyve isn't running" 1>&2
  exit 1
fi

if  tmux has-session -t java 2> /dev/null
then
  echo 'attaching'
  tmux attach-session -t java
  exit 0
fi

# Add the private key to our Linux virtual machine
ssh-add ~/.ssh/dev

tmux new-session -d -s java -n vim
tmux send-keys -t '=java:=vim' 'ssh vm' Enter
tmux send-keys -t '=java:=vim' 'cd ~/code/java; vim .' Enter

tmux new-window -d -t '=java' -n build
tmux send-keys -t '=java:=build' 'ssh vm' Enter
tmux send-keys -t '=java:=build' 'cd ~/code/java' Enter

tmux attach-session -t java

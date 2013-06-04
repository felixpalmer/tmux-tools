#/bin/sh
# dbux.sh
usage()
{
cat << EOF
usage: $0 options

Sets up a tmux session with the specified config

OPTIONS:
   -d      Directories to open
   -l      Log files to tail
   -n      Session name
   -p      Ports to watch
EOF
}

DIRECTORIES=
LOG_FILES=
PORTS=
NAME=
while getopts "h:d:l:p:" OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         d)
             DIRECTORIES=$OPTARG
             ;;
         l)
             LOG_FILES=$OPTARG
             ;;
         n)
             NAME=$OPTARG
             ;;
         p)
             PORTS=$OPTARG
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

echo Directories: $DIRECTORIES
echo Log files: $LOG_FILES
echo Ports: $PORTS
echo Launching tmux...

# Start up tmux session (in detached state)
if [[ -z $NAME ]]
then
  NAME=debug
fi
tmux kill-session -t $NAME
tmux new-session -d -s $NAME
tmux set-option -t $NAME set-remain-on-exit on

# Start tailing log files
if [[ -n $LOG_FILES ]]
then
  tmux rename-window -t $NAME:0 -n logs
  echo $LOG_FILES | sed -n 1'p' | tr ',' '\n' | while read f; do
    echo "Tailing log file: $f"
    tmux splitw -t $NAME "tail -f -n 1000 $f"
  done
  tmux kill-pane -t 0
  tmux select-layout -t $NAME even-horizontal
fi

# Start watching ports
if [[ -n $PORTS ]]
then
  tmux new-window -t $NAME:1 -n ports
  echo $PORTS | sed -n 1'p' | tr ',' '\n' | while read p; do
    echo "Watching port: $p"
    tmux splitw -t $NAME "watch 'sudo netstat -planet | grep $p'"
  done
  tmux kill-pane -t 0
  tmux select-layout -t $NAME even-horizontal
fi

# Open directories
if [[ -n $DIRECTORIES ]]
then
  tmux new-window -t $NAME:2 -n browse
  echo $DIRECTORIES | sed -n 1'p' | tr ',' '\n' | while read d; do
    echo "Opening directory: $d"
    tmux splitw -t $NAME "cd $d;bash -i"
  done
  tmux kill-pane -t 0
  tmux select-layout -t $NAME even-horizontal
fi

# Attach to session
tmux -2 attach-session -t $NAME

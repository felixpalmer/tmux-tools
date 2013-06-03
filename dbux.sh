#/bin/sh
# dbux.sh
usage()
{
cat << EOF
usage: $0 options

Sets up a tmux session with the specified config

OPTIONS:
   -l      Log files to tail
   -n      Session name
   -p      Processes to watch
EOF
}

LOG_FILES=
PROCESSES=
NAME=
while getopts "h:l:p:" OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         l)
             LOG_FILES=$OPTARG
             ;;
         n)
             NAME=$OPTARG
             ;;
         p)
             PROCESSES=$OPTARG
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

echo Log files: $LOG_FILES
echo Processes: $PROCESSES
echo Launching tmux...

# Start up tmux session (in detached state)
if [[ -z $NAME ]]
then
  NAME=debug
fi
tmux kill-session -t $NAME
tmux new-session -d -s $NAME

# Start tailing log files
echo $LOG_FILES | sed -n 1'p' | tr ',' '\n' | while read f; do
  echo "Tailing log file: $f"
  tmux splitw -t $NAME "tail -f -n 1000 $f"
done
tmux kill-pane -t 0
tmux select-layout -t $NAME even-horizontal

# Attach to session
tmux -2 attach-session -t $NAME

#/bin/sh
# dbux.sh
usage()
{
cat << EOF
usage: $0 options

Sets up a tmux session with the specified config

OPTIONS:
   -l      Log files to tail
   -p      Processes to watch
EOF
}

LOG_FILES=
PROCESSES=
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

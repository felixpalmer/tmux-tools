#!/bin/bash
DIR="$( cd "$( dirname "$0" )" && pwd )"
echo "Creating symlink for .tmux.conf in home directory"
ln -s $DIR/.tmux.conf ~/.tmux.conf
echo "Done!"

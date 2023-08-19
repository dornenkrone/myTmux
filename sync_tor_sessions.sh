#!/bin/sh
cwd=${PWD}
mkdirIfNeeded() {
	if [ ! -d $1 ]; then
		mkdir $1
	fi
}

dialog() {
	echo "$1"
}
# Backup existing tmux configs (if needed)

dialog "current working dir ${PWD}"
bakupDir=~/.config/.terminator-backup
bakupDate=$(date +"%Y-%m-%d(%T)")

if [ -d ~/.config/terminator ]; then
	dialog "backing up ~/.config/terminator to ${backupDir}/${bakupDate}/tmuxinator..."
	mkdirIfNeeded $bakupDir
	mkdirIfNeeded $bakupDir/$bakupDate/
	mv ~/.config/terminator $bakupDir/$bakupDate/tmux/
fi

dialog "coping sessions to target folder"

cp -r $cwd/tor_sessions/* ~/.config/tmuxinator/

dialog "finished"

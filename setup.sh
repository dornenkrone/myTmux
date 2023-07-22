#! /bin/sh

dialog() {
	echo "\033[32m$1\033[34m"
}

clone() {
	dialog "\nInstalling $1..."
	git clone $2 $3
}

mkdirIfNeeded() {
	if [ ! -d $1 ]; then
		mkdir $1
	fi
}

echo "\033[33m\n... Is now installing"

# Backup existing tmux configs (if needed)
bakupDir=~/.tmux-config-bakups
bakupDate=$(date +"%Y-%m-%d(%T)")
if [ -d ~/.tmux/ ]; then
	dialog "backing up ~/.tmux to ${backupDir}/${bakupDate}/tmux..."
	mkdirIfNeeded $bakupDir
	mkdirIfNeeded $bakupDir/$bakupDate/
	mv ~/.tmux $bakupDir/$bakupDate/tmux/
fi
if [ -f ~/.tmux.conf ]; then
	dialog "backing up ~/.tmux.conf to ${bakupDir}${bakupDate}/tmux.conf..."
	mkdirIfNeeded $bakupDir
	mkdirIfNeeded $bakupDir/$bakupDate/
	mv ~/.tmux.conf $bakupDir/$bakupDate/tmux.conf
fi

# download files...
dialog "\nfetching tmux.conf..."
touch ~/.tmux.conf
# curl -s https://github.com/dornenkrone/myTmux/blob/master/tmux.conf -o ~/.tmux.conf
bash ./update_config.sh
clone "Tmux Plugin Manager (TPM)" https://github.com/tmux-plugins/tpm.git ~/.tmux/plugins/tpm
# clone "tmux-battery" https://github.com/tmux-plugins/tmux-battery.git ~/.tmux/plugins/tmux-battery
# clone "tmux-cpu" https://github.com/tmux-plugins/tmux-cpu.git ~/.tmux/plugins/tmux-cpu
clone "tmux-mem-cpu-load" https://github.com/dornenkrone/tmux-mem-cpu-load.git ~/.tmux/plugins/tmux-mem-cpu-load
clone "tmux-prefix-highlight" https://github.com/tmux-plugins/tmux-prefix-highlight.git ~/.tmux/plugins/tmux-prefix-highlight
clone "tmux-autoreload" "https://github.com/b0o/tmux-autoreload.git" ~/.tmux/plugins/tmux-autoreload
clone "tmux-mode-indicator" "https://github.com/MunifTanjim/tmux-mode-indicator.git" ~/.tmux/plugins/tmux-mode-indicator

# compile files
cd ~/.tmux/plugins/tmux-mem-cpu-load
/bin/sh compile.sh

# reload tmux config
tmux source-file ~/.tmux.conf

dialog "magicTmux installation Finished"

# tell user to launch tmux if needed
if -f $TMUX; then
	echo "Use command \"tmux\" to launch tmux"
fi

echo "\033[34mMore about the custumized magicTmux, visit: \033[0m https://github.com/dornenkrone/magicTmux"
echo "\n\033[0m"

#! /bin/sh

# install pre requirements
dialog() {
  echo "$1"
}

clone() {
  dialog "Installing $1..."
  git clone $2 $3
}

mkdirIfNeeded() {
  if [ ! -d $1 ]; then
    mkdir $1
  fi
}

cwd=${PWD}
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

# clone repos...
PLUGIN_DIR="/home/$(logname)/.tmux/plugins"
mkdir -p $PLUGIN_DIR
dialog "\nfetching tmux.conf..."
clone "Tmux Plugin Manager (TPM)" https://github.com/tmux-plugins/tpm.git $PLUGIN_DIR/tpm

clone "tmux2k" "https://github.com/2KAbhishek/tmux2k" $PLUGIN_DIR/tmux2k
clone "tmux-yank" "https://github.com/tmux-plugins/tmux-yank.git" $PLUGIN_DIR/tmux-yank
clone "tmux-fuzzback" "https://github.com/roosta/tmux-fuzzback.git" $PLUGIN_DIR/tmux-fuzzback
clone "tmux-resurrect" "https://github.com/tmux-plugins/tmux-resurrect.git" $PLUGIN_DIR/tmux-resurrect
clone "tmux-continuum" "https://github.com/tmux-plugins/tmux-continuum.git" $PLUGIN_DIR/tmux-continuum
clone "tmux-network-speed" "https://github.com/minhdanh/tmux-network-speed.git" $PLUGIN_DIR/tmux-network-speed
clone "tmux-mem-cpu-load" "https://github.com/dornenkrone/tmux-mem-cpu-load.git" $PLUGIN_DIR/tmux-mem-cpu-load
clone "tmux-fzf-pane-switch" "https://github.com/Kristijan/tmux-fzf-pane-switch.git" $PLUGIN_DIR/tmux-fzf-pane-switch
clone "tmux-mode-indicator" "https://github.com/MunifTanjim/tmux-mode-indicator.git" $PLUGIN_DIR/tmux-mode-indicator
clone "tmux-prefix-highlight" "https://github.com/tmux-plugins/tmux-prefix-highlight.git" $PLUGIN_DIR/tmux-prefix-highlight
clone "tmux-current-pane-hostname" "https://github.com/dornenkrone/my_currentpanehostname.tmux.git" $PLUGIN_DIR/tmux-current-pane-hostname

# clone "tmux-battery" https://github.com/tmux-plugins/tmux-battery.git ~/.tmux/plugins/tmux-battery
# clone "tmux-cpu" https://github.com/tmux-plugins/tmux-cpu.git ~/.tmux/plugins/tmux-cpu
# clone "tmux-autoreload" "https://github.com/b0o/tmux-autoreload.git" ~/.tmux/plugins/tmux-autoreload
# clone "tmux-sessionist" "https://github.com/tmux-plugins/tmux-sessionist.git" ~/.tmux/plugins/tmux-sessionist

# compile files
cd ~/.tmux/plugins/tmux-mem-cpu-load
/bin/sh compile.sh

# reload tmux config
tmux source-file ~/.tmux.conf

dialog "magicTmux installation Finished"

# tell user to launch tmux if needed
if -f $TMUX; then
  echo "Tmux installed: (version: $(tmux -V))"
fi

echo "More about the custumized magicTmux, visit: https://github.com/dornenkrone/magicTmux"

echo "Creating link ~/.tmux.conf"
cd $cwd
# cp ./tmux.conf ~/.tmux.conf
ln -s $PWD/config/tmux.conf ~/.tmux.conf
echo "Config Updated"

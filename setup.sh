#! /bin/sh
# installation folder ~/.config/tmux
CWD=${PWD}

TMUX_CONFIG_DIR="/home/$(logname)/.config/tmux"
echo $TMUX_CONFIG_DIR
PLUGIN_DIR="$TMUX_CONFIG_DIR/plugins"
mkdir -p $PLUGIN_DIR
sudo ln -s $CWD/config "$TMUX_CONFIG_DIR/config"
sudo ln -s $TMUX_CONFIG_DIR/config/tmux.conf ~/.tmux.conf

# clone repos...
echo "\nfetching plugins..."
git clone https://github.com/tmux-plugins/tpm.git $PLUGIN_DIR/tpm                                               # "Tmux Plugin Manager (TPM)"
git clone https://github.com/2KAbhishek/tmux2k $PLUGIN_DIR/tmux2k                                               # "tmux2k"
git clone https://github.com/tmux-plugins/tmux-yank.git $PLUGIN_DIR/tmux-yank                                   # "tmux-yank"
git clone https://github.com/roosta/tmux-fuzzback.git $PLUGIN_DIR/tmux-fuzzback                                 # "tmux-fuzzback"
git clone https://github.com/tmux-plugins/tmux-resurrect.git $PLUGIN_DIR/tmux-resurrect                         # "tmux-resurrect"
git clone https://github.com/tmux-plugins/tmux-continuum.git $PLUGIN_DIR/tmux-continuum                         # "tmux-continuum"
git clone https://github.com/minhdanh/tmux-network-speed.git $PLUGIN_DIR/tmux-network-speed                     # "tmux-network-speed"
git clone https://github.com/dornenkrone/tmux-mem-cpu-load.git $PLUGIN_DIR/tmux-mem-cpu-load                    # "tmux-mem-cpu-load"
git clone https://github.com/Kristijan/tmux-fzf-pane-switch.git $PLUGIN_DIR/tmux-fzf-pane-switch                # "tmux-fzf-pane-switch"
git clone https://github.com/MunifTanjim/tmux-mode-indicator.git $PLUGIN_DIR/tmux-mode-indicator                # "tmux-mode-indicator"
git clone https://github.com/tmux-plugins/tmux-prefix-highlight.git $PLUGIN_DIR/tmux-prefix-highlight           # "tmux-prefix-highlight"
git clone https://github.com/dornenkrone/my_currentpanehostname.tmux.git $PLUGIN_DIR/tmux-current-pane-hostname # "tmux-current-pane-hostname"

# git clone https://github.com/tmux-plugins/tmux-battery.git ~/.tmux/plugins/tmux-battery # "tmux-battery"
# git clone https://github.com/tmux-plugins/tmux-cpu.git ~/.tmux/plugins/tmux-cpu # "tmux-cpu"
# git clone "https://github.com/b0o/tmux-autoreload.git" ~/.tmux/plugins/tmux-autoreload # "tmux-autoreload"
# git clone "https://github.com/tmux-plugins/tmux-sessionist.git" ~/.tmux/plugins/tmux-sessionist # "tmux-sessionist"

# compile files
cd $PLUGIN_DIR/tmux-mem-cpu-load
/bin/sh compile.sh

# reload tmux config
tmux source-file ~/.tmux.conf

echo "magicTmux installation Finished"

echo "More about the custumized tmuxconfig, visit: https://github.com/dornenkrone/magicTmux"

echo "Config Updated"

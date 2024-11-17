WORKDIR=$HOME/Projects


# tmux
TPMDIR=$HOME/.tmux/plugins/tpm
TMUXDIR=$HOME/.config/tmux
if [[ ! -d "$TPMDIR" ]]; then
	echo "download tpm..."
	git clone https://github.com/tmux-plugins/tpm $TPMDIR
fi
mkdir -p $TMUXDIR
ln ./tmux/tmux.conf $TMUXDIR


WORKDIR=$HOME/Projects

# nerd font
NERDDIR=$WORKDIR/nerd-fonts
if [[ ! -d "${WORKDIR}/nerd-fonts" ]]; then
	echo "download nerd fonts..."
	git clone --depth=1 https://github.com/ryanoasis/nerd-fonts.git $NERDDIR
	$NERDDIR/install.sh JetBrainsMono
fi

# tmux
TPMDIR=$HOME/.tmux/plugins/tpm
TMUXDIR=$HOME/.config/tmux
if [[ ! -d "$TPMDIR" ]]; then
	echo "download tpm..."
	git clone https://github.com/tmux-plugins/tpm $TPMDIR
fi
mkdir -p $TMUXDIR
ln ./tmux/tmux.conf $TMUXDIR

# lazyvim
NVIMDIR=$HOME/.config/nvim
if [[ ! -d "$NVIMDIR" ]]; then
	echo "download lazyvim starter..."
	git clone --depth=1 https://github.com/LazyVim/starter.git $NVIMDIR
fi
ln ./lazyvim/{lazy-lock.json,lazyvim.json} $NVIMDIR
ln ./lazyvim/plugins.lua $NVIMDIR/lua/plugins

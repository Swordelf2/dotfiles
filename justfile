alias git := dotfiles-git

# git with the dotfiles bare repo
dotfiles-git +command:
	git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME {{command}}

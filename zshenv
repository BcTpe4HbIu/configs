
which gpg-agent >/dev/null 2>&1
if [ $? -eq 0 ] ; then
  # Set GPG TTY
  export GPG_TTY=$(tty)

  # Refresh gpg-agent tty in case user switches into an X session
  gpg-connect-agent updatestartuptty /bye >/dev/null
  export SSH_AUTH_SOCK=${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent.ssh
fi

typeset -U fpath
fpath=( ~/.dotfiles/zfunc ~/.dotfiles/compdefs $fpath )

export EDITOR='vim'

autoload -Uz ~/.dotfiles/zfunc/*

which go 2>&1 >/dev/null
if [ $? -eq 0 ] ; then
    [ -d ~/go ] || mkdir ~/go ;
    export GOPATH=~/go ;
fi

autoload -Uz compinit
compinit

test -f $HOME/.dotfiles/aliases && source $HOME/.dotfiles/aliases
test -f $HOME/.dotfiles/path.zsh && source $HOME/.dotfiles/path.zsh
test -f $HOME/.dotfiles/local.zsh && source $HOME/.dotfiles/local.zsh

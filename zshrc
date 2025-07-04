zmodload zsh/zprof
HISTFILE=~/.histfile
HISTSIZE=50000
SAVEHIST=$HISTSIZE
bindkey -e

typeset -U fpath
fpath=( ~/.dotfiles/zfunc ~/.dotfiles/compdefs $fpath )
autoload -Uz ~/.dotfiles/zfunc/*

autoload -Uz compinit && compinit

autoload -U colors && colors

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]} m:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' verbose true
zstyle :compinstall filename '~/.zshrc'

autoload -U edit-command-line && (
zle -N  edit-command-line ;
bindkey -M emacs "^X^E" edit-command-line ;
)

rationalise-dot() {
  if [[ $LBUFFER = *.. ]]; then
    LBUFFER+=/..
  else
    LBUFFER+=.
  fi
}
zle -N rationalise-dot
bindkey . rationalise-dot

autoload zkbd

if [ -f ~/.zkbd/$TERM-${${DISPLAY:t}:-$VENDOR-$OSTYPE} ]; then
    source ~/.zkbd/$TERM-${${DISPLAY:t}:-$VENDOR-$OSTYPE}
else
    source ~/.zkbd/$TERM
fi

[[ -n ${key[Backspace]} ]] && bindkey "${key[Backspace]}" backward-delete-char
[[ -n ${key[Insert]} ]] && bindkey "${key[Insert]}" overwrite-mode
[[ -n ${key[Home]} ]] && bindkey "${key[Home]}" beginning-of-line
[[ -n ${key[PageUp]} ]] && bindkey "${key[PageUp]}" up-line-or-history
[[ -n ${key[Delete]} ]] && bindkey "${key[Delete]}" delete-char
[[ -n ${key[End]} ]] && bindkey "${key[End]}" end-of-line
[[ -n ${key[PageDown]} ]] && bindkey "${key[PageDown]}" down-line-or-history
[[ -n ${key[Up]} ]] && bindkey "${key[Up]}" up-line-or-search
[[ -n ${key[Left]} ]] && bindkey "${key[Left]}" backward-char
[[ -n ${key[Down]} ]] && bindkey "${key[Down]}" down-line-or-search
[[ -n ${key[Right]} ]] && bindkey "${key[Right]}" forward-char


bindkey ';5D' emacs-backward-word
bindkey ';5C' emacs-forward-word


if [ "$TERM"=="xterm" ] ; then
    export TERM=xterm-256color
fi

setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY


if [ -d $HOME/.dotfiles/oh-my-zsh ]; then
  export ZSH=$HOME/.dotfiles/oh-my-zsh
  export ZSH_CUSTOM=$HOME/.dotfiles/oh-my-zsh-extra
  export DISABLE_UPDATE_PROMPT=true
  export DISABLE_AUTO_UPDATE=true
  export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

  export ZSH_THEME="powerlevel10k/powerlevel10k"
  plugins=(web-search git archlinux tmux extract \
          npm yarn pip \
          zsh-autosuggestions \
          fzf \
          helm terraform \
          podman docker docker-compose \
          direnv httpie \
          )
  export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
  source $ZSH/oh-my-zsh.sh
  bindkey '`' autosuggest-accept
  source $HOME/.dotfiles/p10k.zsh
fi

compdef _pass workpass
zstyle ':completion::complete:workpass::' prefix "$HOME/.workpass"

_fzf_complete_pass() {
  _fzf_complete +m -- "$@" < <(
    local prefix
    prefix="${PASSWORD_STORE_DIR:-$HOME/.password-store}"
    command find -L "$prefix" \
      -name "*.gpg" -type f | \
      sed -e "s#${prefix}/\{0,1\}##" -e 's#\.gpg##' -e 's#\\#\\\\#' | sort
  )
}

_fzf_complete_workpass() {
  _fzf_complete +m -- "$@" < <(
    local prefix
    prefix="${PASSWORD_STORE_DIR:-$HOME/.workpass}"
    command find -L "$prefix" \
      -name "*.gpg" -type f | \
      sed -e "s#${prefix}/\{0,1\}##" -e 's#\.gpg##' -e 's#\\#\\\\#' | sort
  )
}

if which zoxide >/dev/null 2>&1 ; then
  eval "$(zoxide init zsh)"
fi


which go 2>&1 >/dev/null
if [ $? -eq 0 ] ; then
    [ -d ~/go ] || mkdir ~/go ;
    export GOPATH=~/go ;
fi

export EDITOR='vim'


test -f $HOME/.dotfiles/aliases && source $HOME/.dotfiles/aliases
test -f $HOME/.dotfiles/path.zsh && source $HOME/.dotfiles/path.zsh
test -f $HOME/.dotfiles/local.zsh && source $HOME/.dotfiles/local.zsh

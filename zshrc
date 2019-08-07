HISTFILE=~/.histfile
HISTSIZE=50000
SAVEHIST=100000
bindkey -e

autoload -U colors && colors

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]} m:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' verbose true
zstyle :compinstall filename '~/.zshrc'

autoload -Uz compinit && compinit

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

which go >/dev/null 2>&1
if [ $? -eq 0 ] ; then
    [ -d ~/go ] || mkdir ~/go ;
    export GOPATH=~/go ;
fi

export EDITOR='vim'

if [ "$TERM"=="xterm" ] ; then
    export TERM=xterm-256color
fi

setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY


if [ -d $HOME/.dotfiles/oh-my-zsh ]; then
    export ZSH=$HOME/.dotfiles/oh-my-zsh
    export DISABLE_UPDATE_PROMPT=true
    export DISABLE_AUTO_UPDATE=true
    #ZSH_THEME="robbyrussell"
    #ZSH_THEME="bira"
    ZSH_THEME="candy"
    plugins=(git archlinux docker npm pip tmux web-search zsh-autosuggestions fzf-zsh clbin)
    ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
    source $ZSH/oh-my-zsh.sh
    bindkey '`' autosuggest-accept
fi

typeset -U fpath
fpath=( ~/.dotfiles/zfunc $fpath )

autoload -Uz ssh-clean

autoload -Uz _pass
compdef _pass  pass
compdef _pass workpass
zstyle ':completion::complete:workpass::' prefix "$HOME/.workpass"
workpass() {
    PASSWORD_STORE_DIR=$HOME/.workpass pass $@
}

autoload -Uz weather
autoload -Uz iwatch
autoload -Uz kapplydir
autoload -Uz klsapply

test -f $HOME/.dotfiles/aliases && source $HOME/.dotfiles/aliases
test -f $HOME/.dotfiles/path.zsh && source $HOME/.dotfiles/path.zsh
test -f $HOME/.dotfiles/local.zsh && source $HOME/.dotfiles/local.zsh


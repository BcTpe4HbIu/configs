HISTFILE=~/.histfile
HISTSIZE=50000
SAVEHIST=100000
bindkey -e

typeset -U fpath
fpath=( ~/.dotfiles/zfunc ~/.dotfiles/compdefs $fpath )

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

autoload -Uz ~/.dotfiles/zfunc/*

if [ -d $HOME/.dotfiles/oh-my-zsh ]; then
  export ZSH=$HOME/.dotfiles/oh-my-zsh
  export ZSH_CUSTOM=$HOME/.dotfiles/oh-my-zsh-extra
  export DISABLE_UPDATE_PROMPT=true
  export DISABLE_AUTO_UPDATE=true
  #ZSH_THEME="robbyrussell"
  #ZSH_THEME="bira"
  ZSH_THEME="powerlevel10k/powerlevel10k"
  plugins=(web-search git archlinux docker npm yarn pip tmux \
          zsh-autosuggestions fzf helm terraform aws heroku \
          taskwarrior \
          transfer django httpie docker docker-compose zsh_reload)
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
  source $ZSH/oh-my-zsh.sh
  bindkey '`' autosuggest-accept
  source $HOME/.dotfiles/p10k.zsh
fi

compdef _pass pass
compdef _pass workpass
zstyle ':completion::complete:workpass::' prefix "$HOME/.workpass"

which go 2>&1 >/dev/null
if [ $? -eq 0 ] ; then
    [ -d ~/go ] || mkdir ~/go ;
    export GOPATH=~/go ;
fi

test -f $HOME/.dotfiles/aliases && source $HOME/.dotfiles/aliases
test -f $HOME/.dotfiles/path.zsh && source $HOME/.dotfiles/path.zsh
test -f $HOME/.dotfiles/local.zsh && source $HOME/.dotfiles/local.zsh

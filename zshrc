# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '~/.zshrc'

# End of lines added by compinstall

autoload -U colors && colors

#PROMPT="%{$fg[red]%}%n%{$reset_color%}@%{$fg[cyan]%}%m %{$fg_no_bold[yellow]%}%1~ %{$reset_color%}%# "
#RPROMPT="[%{$fg_no_bold[yellow]%}%T%{$reset_color%}]"

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]} m:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' verbose true
zstyle :compinstall filename '~/.zshrc'

autoload -Uz compinit && compinit

autoload -U predict-on && (
zle -N predict-on ;
zle -N predict-off ;
bindkey -M emacs "^X^Z" predict-on ;
bindkey -M emacs "^Z" predict-off ;
)


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

which go > /dev/null 2>&1 && (
    [ -d ~/go ] || mkdir ~/go ;
    export GOPATH=~/go ;
)

export EDITOR='vim'

alias tm="tmux a"

if [ -d $HOME/.dotfiles/oh-my-zsh ]; then
    export ZSH=$HOME/.dotfiles/oh-my-zsh
    #ZSH_THEME="robbyrussell"
    #ZSH_THEME="bira"
    ZSH_THEME="candy"
    plugins=(git archlinux dockeri npm pip history-substring-search tmux web-search zsh-autosuggestions fzf-zsh)
    ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
    source $ZSH/oh-my-zsh.sh
    bindkey '`' autosuggest-accept
fi

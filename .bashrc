# bash color
if [ $UID -eq 0 ]; then
    PS1="\n\[\033[1;31m\]\u@\h\[\033[1;00m\]: \[\033[1;01m\]\w\[\033[0;00m\]\n # "
else
    PS1="\n\[\033[1;36m\]\u@\h\[\033[1;00m\]: \[\033[1;01m\]\w\[\033[0;00m\]\n $ "
fi

# settings og pyenv
export PYENV_ROOT="${HOME}/.pyenv"
if [ -d "${PYENV_ROOT}" ]; then
    export PATH=${PYENV_ROOT}/bin:$PATH
    eval "$(pyenv init -)"
fi

# default python
#pyenv shell anaconda3-5.3.1

# ls setting
export LSCOLORS=exfxcxdxbxegedabagacad

# alias
alias ls="ls -G"
alias ll="ls -alFG"
alias v="vim"
alias e="emacs"
alias tpython="/System/Library/Frameworks/Python.framework/Versions/2.7/bin/python2"

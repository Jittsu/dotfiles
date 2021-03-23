#
# Executes commands at the start of an interactive session.
#

# PROMPT COLOR
case ${USERNAME} in
    'root')
    PROMPT='
    %F{red}%B%n@MacBookPro%b%f%F{white}:%f %F{110}%B%~%b%f
 %F{red}%B#%b%f%F{white}%B>%b%f '
    ;;
    *)
    PROMPT='
%F{110}%BMacBookPro%b%f%F{white}:%f %F{110}%B%~%b%f
 %F{110}%B$%b%f%F{white}%B>%b%f '
    ;;
esac

# --------------------------------------------------
#  git branch状態を表示（右）
# --------------------------------------------------
#--以下動かない--
#autoload -Uz vcs_info
#setopt prompt_subst

# true | false
# trueで作業ブランチの状態に応じて表示を変える
#zstyle ':vcs_info:*' check-for-changes true
# addしてない場合の表示
#zstyle ':vcs_info:*' unstagedstr "%F{red}%B＋%b%f"
# commitしてない場合の表示
#zstyle ':vcs_info:*' stagedstr "%F{yellow}★ %f"
# デフォルトの状態の表示
#zstyle ':vcs_info:*' formats "%F{green}%c%u【 %b 】%f"
# コンフリクトが起きたり特別な状態になるとformatsの代わりに表示
#zstyle ':vcs_info:*' actionformats '【%b | %a】'
#
#precmd () { vcs_info }

#RPROMPT=$RPROMPT'${vcs_info_msg_0_}'
#--以上--

#--以下動く--
#--https://suwaru.tokyo/1%E7%AE%87%E6%89%80%E3%82%B3%E3%83%94%E3%83%9A%E3%81%99%E3%82%8B%E3%81%A0%E3%81%91%E3%81%A7git%E3%83%96%E3%83%A9%E3%83%B3%E3%83%81%E5%90%8D%E3%82%92%E5%B8%B8%E3%81%AB%E8%A1%A8%E7%A4%BA%E3%80%90-zshrc/
# git ブランチ名を色付きで表示させるメソッド
function rprompt-git-current-branch {
    local branch_name st branch_status

    #if [ ! -e  ".git" ]; then
        # git 管理されていないディレクトリは何も返さない
        #return
    #fi
    git rev-parse --is-inside-work-tree > /dev/null 2>&1
    if [ $? = 0 ]; then
        branch_name=`git rev-parse --abbrev-ref HEAD 2> /dev/null`
        st=`git status 2> /dev/null`
        if [[ -n `echo "$st" | grep "^nothing to"` ]]; then
            # 全て commit されてクリーンな状態
            branch_status="%F{green}【 "
        elif [[ -n `echo "$st" | grep "^Untracked files"` ]]; then
            # git 管理されていないファイルがある状態
            branch_status="%F{red}?【 "
        elif [[ -n `echo "$st" | grep "^Changes not staged for commit"` ]]; then
            # git add されていないファイルがある状態
            branch_status="%F{red}+【 "
        elif [[ -n `echo "$st" | grep "^Changes to be committed"` ]]; then
            # git commit されていないファイルがある状態
            branch_status="%F{yellow}☆【 "
        elif [[ -n `echo "$st" | grep "^Unmerged paths"` ]]; then
            # コンフリクトが起こった状態
            branch_status="%F{red}!【 conflict | "
        elif [[ -n `echo "$st" | grep "^All conflicts fixed but you are still merging."` ]]; then
            # コンフリクト解消
            branch_status="%F{blue}☆【 fixed | "
        else
            # 上記以外の状態の場合
            branch_status="%F{blue}【 "
        fi
        # ブランチ名を色付きで表示する
        echo "${branch_status}$branch_name 】"
    else
        return
    fi
}
 
# プロンプトが表示されるたびにプロンプト文字列を評価、置換する
setopt prompt_subst
 
# プロンプトの右側にメソッドの結果を表示させる
RPROMPT='`rprompt-git-current-branch`'

# --------------------------------------------------
#  gitコマンド補完機能セット
# --------------------------------------------------

# autoloadの文より前に記述
fpath=(~/.zsh/completion $fpath)

# --------------------------------------------------
#  コマンド入力補完
# --------------------------------------------------

# 補完機能有効にする
autoload -U compinit
compinit -u

# 補完候補に色つける
autoload -U colors
colors
zstyle ':completion:*' list-colors "${LS_COLORS}"

# 単語の入力途中でもTab補完を有効化
setopt complete_in_word
# 補完候補をハイライト
zstyle ':completion:*:default' menu select=1
# キャッシュの利用による補完の高速化
zstyle ':completion::complete:*' use-cache true
# 大文字、小文字を区別せず補完する
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# 補完リストの表示間隔を狭くする
setopt list_packed

# コマンドの打ち間違いを指摘してくれる
setopt correct
SPROMPT="correct: $RED%R$DEFAULT -> $GREEN%r$DEFAULT ? [Yes/No/Abort/Edit] => "

# ディレクトリ名を補完すると、末尾がスラッシュになる
setopt AUTO_PARAM_SLASH

# 語の途中でもカーソル位置で補完
setopt COMPLETE_IN_WORD

# 補完候補のメニュー選択で、矢印キーの代わりにhjklで移動出来るようにする。
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char

# --------------------------------------------------
#  $ cd 機能拡張
# --------------------------------------------------

# cdを使わずにディレクトリを移動できる
setopt auto_cd
# $ cd - でTabを押すと、ディレクトリの履歴が見れる
setopt auto_pushd

# --------------------------------------------------
#  $ tree でディレクトリ構成表示
# --------------------------------------------------

alias tree="pwd;find . | sort | sed '1d;s/^\.//;s/\/\([^/]*\)$/|--\1/;s/\/[^/|]*/| /g'"

# History
HISTSIZE=50000
HISTTIMEFORMAT='%Y/%m/%d %H:%M:%S '
setopt hist_ignore_dups

# Language
export LANG=ja_JP.UTF-8

# Show ssh username and hostname
SSH_CONNECTION=1

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
    . "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...
if [ -f ~/.zsh_aliases ]; then
    . ~/.zsh_aliases
fi

# Customize to your needs...
if [ -f ~/.zsh_functions ]; then
    . ~/.zsh_functions
fi

# less
if type "source-highlight" > /dev/null 2>&1; then
    export LESS='-R'
    export LESSOPEN='| /usr/local/bin/src-hilite-lesspipe.sh %s'
fi

# nodebrew
if type "nodebrew" > /dev/null 2>&1; then
    export PATH=$HOME/.nodebrew/current/bin:$PATH
fi

# npm global path
if [ -e $HOME/.npm/bin ]; then
    export PATH=$HOME/.npm/bin:$PATH
fi

# composer
if [ -e $HOME/.composer/vendor/bin ]; then
    export PATH=$HOME/.composer/vendor/bin:$PATH
fi

# --------------------------------------------------
#  git エイリアス
# --------------------------------------------------

alias g='git'
compdef g=git

alias gis='git status --short --branch'
alias gal='git add -A'
alias gc='git commit -m'
alias gps='git push'
alias gpsu='git push -u origin'
alias gp='git push origin'
alias gpl='git pull'
alias gf='git fetch'
alias gfp='git fetch -p'

# logを見やすく
alias gl='git log --abbrev-commit --no-merges --date=short --date=iso'
# grep
alias glg='git log --abbrev-commit --no-merges --date=short --date=iso --grep'
# ローカルコミットを表示
alias glc='git log --abbrev-commit --no-merges --date=short --date=iso origin/html..html'

alias gd='git diff'
alias gco='git checkout'
alias gcob='git checkout -b'
alias gb='git branch'
alias gba='git branch -a'
alias gbr='git branch -r'

alias gm='git merge'
alias gr='git reset'

##
# alias
#
# plz add aliases to file ~/.zsh_aliases
# do not add here

##
# function
# 
# plz add user functions to file ~/.zsh_functions
# do not add here

# Override auto-title when static titles are desired ($ title My new title)
function title() { export TITLE_OVERRIDDEN=1; echo -en "\e]0;$*\a"}
# Turn off static titles ($ autotitle)
function autotitle() { export TITLE_OVERRIDDEN=0 }; autotitle
# Condition checking if title is overridden
function overridden() { [[ $TITLE_OVERRIDDEN == 1 ]]; }
# Echo asterisk if git state is dirty
function gitDirty() { [[ $(git status 2> /dev/null | grep -o '\w\+' | tail -n1) != ("clean"|"") ]] && echo "*" }

# Show cwd when shell prompts for input.
function tabtitle_precmd() {
    if overridden; then return; fi
    pwd=$(pwd) # Store full path as variable
    cwd=${pwd##*/} # Extract current working dir only
    print -Pn "\e]0;$cwd$(gitDirty)\a" # Replace with $pwd to show full path
}
[[ -z $precmd_functions ]] && precmd_functions=()
precmd_functions=($precmd_functions tabtitle_precmd)

# Prepend command (w/o arguments) to cwd while waiting for command to complete.
function tabtitle_preexec() {
    if overridden; then return; fi
    printf "\033]0;%s\a" "${1%% *} | $cwd$(gitDirty)" # Omit construct from $1 to show args
}
[[ -z $preexec_functions ]] && preexec_functions=()
preexec_functions=($preexec_functions tabtitle_preexec)

## double added path remove
typeset -U path PATH

# コミット 3行用
function git_commit() {
	BUFFER='git commit -m "#'
	CURSOR=$#BUFFER
	BUFFER=$BUFFER'" -m "" -m ""'
}
zle -N git_commit
bindkey '^[git_commit' git_commit

# タブに名前を付ける
function tab_rename() {
	BUFFER="echo -ne \"\e]1;"
	CURSOR=$#BUFFER
	BUFFER=$BUFFER\\a\"
}
zle -N tab_rename
bindkey '^[tab_rename' tab_rename

# 単語単位で削除（前後）
# 前：option ,
# 後：option .
bindkey '^[word-remove-right' kill-word
bindkey '^[word-remove-left' backward-kill-word

# pyenv setting
export PYENV_ROOT=${HOME}/.pyenv
if [ -d "${PYENV_ROOT}" ]; then
    export PATH=${PYENV_ROOT}/bin:$PATH
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

## golang path
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH
export GOBIN=/Users/jitsuzaki/go/bin

# do not desplay virtual environment name
# export PYENV_VIRTUALENV_DISABLE_PROMPT=1

## bunsansystemtokuron geta
GETAROOT=/usr/local/geta
export GETAROOT
export PATH=$PATH:$GETAROOT/sbin

# settings of postgresql
export PATH="/usr/local/opt/postgresql@11/bin:$PATH"
export PGDATA="/usr/local/var/postgres"

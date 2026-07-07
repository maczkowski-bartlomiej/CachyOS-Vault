# Managed by CachyOS-Vault.
# Powerlevel10k is intentionally not sourced; Oh My Posh owns the prompt.

export ZSH="${ZSH:-/usr/share/oh-my-zsh}"
export FZF_BASE="${FZF_BASE:-/usr/share/fzf}"

DISABLE_MAGIC_FUNCTIONS="true"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
ZSH_THEME=""

if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
    plugins=(git fzf extract)
    source "$ZSH/oh-my-zsh.sh"
fi

setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt share_history
setopt inc_append_history
setopt prompt_subst

export HISTORY_IGNORE="(&|[bf]g|c|clear|history|exit|q|pwd|* --help)"
export LESS_TERMCAP_md="$(tput bold 2> /dev/null; tput setaf 2 2> /dev/null)"
export LESS_TERMCAP_me="$(tput sgr0 2> /dev/null)"

alias nano='micro'
alias make="make -j$(nproc)"
alias ninja="ninja -j$(nproc)"
alias n="ninja"
alias c="clear"
alias rmpkg="sudo pacman -Rsn"
alias cleanch="sudo pacman -Scc"
alias fixpacman="sudo rm /var/lib/pacman/db.lck"
alias update="sudo pacman -Syu"
alias apt="man pacman"
alias apt-get="man pacman"
alias please="sudo"
alias tb="nc termbin.com 9999"
alias jctl="journalctl -p 3 -xb"
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"

alias picomc='micro ~/.config/picom/picom.conf'
alias i3c='micro ~/.config/i3/config'
alias rofic='micro ~/.config/rofi/config.rasi'
alias zshc='micro ~/.zshrc'
alias polybarc='micro ~/.config/polybar/config.ini'
alias ompc='micro ~/.config/oh-my-posh/cachyos-compact.omp.json'

unalias cleanup 2> /dev/null || true
cleanup() {
    local orphans

    orphans="$(pacman -Qtdq 2> /dev/null || true)"
    if [[ -z "$orphans" ]]; then
        print "No orphan packages."
        return 0
    fi

    sudo pacman -Rsn ${(f)orphans}
}

if command -v zoxide > /dev/null 2>&1; then
    eval "$(zoxide init zsh --cmd cd)"
fi

[[ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -r /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]] &&
    source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
[[ -r /usr/share/doc/pkgfile/command-not-found.zsh ]] &&
    source /usr/share/doc/pkgfile/command-not-found.zsh
[[ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] &&
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

vault_fallback_prompt() {
    autoload -Uz colors vcs_info add-zsh-hook
    colors

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:git:*' formats ' %K{green}%F{black}  %b %k%F{green}%f'
    zstyle ':vcs_info:git:*' actionformats ' %K{green}%F{black}  %b:%a %k%F{green}%f'

    vault_update_vcs_info() {
        vcs_info
    }

    add-zsh-hook precmd vault_update_vcs_info
    PROMPT='%K{white}%F{black}  %k%F{white}%K{blue}%F{white} %~ %k%F{blue}%f${vcs_info_msg_0_} '
}

OMP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/oh-my-posh/cachyos-compact.omp.json"
if command -v oh-my-posh > /dev/null 2>&1 && [[ -r "$OMP_CONFIG" ]]; then
    eval "$(oh-my-posh init zsh --config "$OMP_CONFIG")"
else
    vault_fallback_prompt
fi

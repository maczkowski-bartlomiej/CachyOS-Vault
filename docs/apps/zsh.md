# Zsh And Oh My Posh

## Files

```text
Repo zshrc: custom-configs/Zsh/.zshrc
Target zshrc: ~/.zshrc
Repo prompt: custom-configs/Zsh/oh-my-posh/cachyos-compact.omp.json
Target prompt: ~/.config/oh-my-posh/cachyos-compact.omp.json
```

## Behavior

```text
Prompt engine: oh-my-posh
Layout: compact single-line powerline prompt with OS, path, and Git branch segments
Fallback: if oh-my-posh is missing, zsh uses a simpler local prompt with the same segment shape
Powerlevel10k: not sourced
CachyOS zsh wrapper: not sourced, because it loads Powerlevel10k
```

## Dependencies

```text
Core: zsh, oh-my-zsh-git, zsh-autosuggestions, zsh-history-substring-search, zsh-syntax-highlighting, fzf, pkgfile, zoxide
AUR: oh-my-posh-bin
```

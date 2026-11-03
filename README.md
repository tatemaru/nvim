# nvim

LazyVim-based Neovim config (shared across machines).

## Install

### With dotfiles (stow + submodule)

```bash
git clone --recurse-submodules git@github.com:tatemaru/dotfiles.git ~/workspace/dotfiles
cd ~/workspace/dotfiles && make link
```

### Standalone

```bash
mv ~/.config/nvim{,.bak} 2>/dev/null || true
git clone git@github.com:tatemaru/nvim.git ~/.config/nvim
nvim
```

## Notes

- PHP: system `phpactor` (`brew` / mise 等で別途入れる）
- IME: `brew install laishulu/homebrew/macism`（InsertLeave → ABC）
- Theme: kanagawa

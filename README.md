# nvim

LazyVim-based Neovim config (shared across machines).

## Install

```bash
# backup existing config if any
mv ~/.config/nvim{,.bak} 2>/dev/null || true
mv ~/.local/share/nvim{,.bak} 2>/dev/null || true

git clone git@github.com:tatemaru/nvim.git ~/.config/nvim
nvim
```

## Notes

- PHP: system `phpactor` (`brew` / mise 等で別途入れる）
- IME: `brew install laishulu/homebrew/macism`（InsertLeave → ABC）
- Theme: kanagawa

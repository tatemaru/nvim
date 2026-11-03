-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- Leave insert/cmdline → force ABC (requires: brew install laishulu/homebrew/macism)
vim.api.nvim_create_autocmd({ "InsertLeave", "CmdlineLeave" }, {
  group = vim.api.nvim_create_augroup("ime_macism", { clear = true }),
  callback = function()
    if vim.fn.executable("macism") == 0 then
      return
    end
    vim.fn.jobstart({ "macism", "com.apple.keylayout.ABC" }, { detach = true })
  end,
})

-- Auto-hover on CursorHold for phpactor (DocBlock-aware).
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("phpactor_auto_hover", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or client.name ~= "phpactor" then
      return
    end
    vim.api.nvim_create_autocmd("CursorHold", {
      buffer = args.buf,
      group = vim.api.nvim_create_augroup("phpactor_auto_hover_" .. args.buf, { clear = true }),
      callback = function()
        if vim.api.nvim_win_get_config(0).relative ~= "" then
          return
        end
        -- Don't stack on existing floats (explorer UI is ok; hover/diagnostic floats skip).
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local cfg = vim.api.nvim_win_get_config(win)
          if cfg.relative ~= "" and cfg.focusable == false then
            return
          end
        end
        local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
        if #vim.diagnostic.get(args.buf, { lnum = lnum }) > 0 then
          vim.diagnostic.open_float({ scope = "line", focusable = false })
          return
        end
        require("config.phpactor_hover").hover({ focusable = false })
      end,
    })
  end,
})

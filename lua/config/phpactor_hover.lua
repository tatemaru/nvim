-- phpactor returns useless "ClassMembersNode" for DocBlock type names.
-- Fall back to hover at the definition location (buffer must be loaded).

local M = {}

local function contents_value(contents)
  if not contents then
    return nil
  end
  if type(contents) == "string" then
    return contents
  end
  if contents.value then
    return contents.value
  end
  if contents[1] then
    return contents[1].value or contents[1]
  end
end

local function is_junk(value)
  return type(value) == "string" and value:match("^%s*ClassMembersNode%s*$")
end

local function show(contents, opts, client_id, bufnr)
  local value = contents_value(contents)
  if not value or value == "" or is_junk(value) then
    return false
  end
  local result = { contents = contents }
  local ctx = {
    bufnr = bufnr,
    method = "textDocument/hover",
    client_id = client_id,
  }
  -- Prefer the active hover handler (noice overrides this in LazyVim).
  local handler = vim.lsp.handlers["textDocument/hover"] or vim.lsp.handlers.hover
  if handler then
    handler(nil, result, ctx, opts)
    return true
  end
  local lines = vim.lsp.util.convert_input_to_markdown_lines(contents)
  if vim.tbl_isempty(lines) then
    return false
  end
  vim.lsp.util.open_floating_preview(lines, "markdown", opts)
  return true
end

---@param opts? vim.lsp.buf.hover.Opts
function M.hover(opts)
  opts = vim.tbl_deep_extend("force", { border = "rounded" }, opts or {})
  local src_bufnr = vim.api.nvim_get_current_buf()
  local client = vim.lsp.get_clients({ bufnr = src_bufnr, method = "textDocument/hover", name = "phpactor" })[1]
  if not client then
    return vim.lsp.buf.hover(opts)
  end

  local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
  client:request("textDocument/hover", params, function(_, result)
    if vim.api.nvim_get_current_buf() ~= src_bufnr then
      return
    end
    local value = contents_value(result and result.contents)
    if value and value ~= "" and not is_junk(value) then
      show(result.contents, opts, client.id, src_bufnr)
      return
    end

    client:request("textDocument/definition", params, function(_, def)
      if vim.api.nvim_get_current_buf() ~= src_bufnr then
        return
      end
      local loc = def and (vim.islist(def) and def[1] or def)
      if not loc then
        return
      end
      local uri = loc.uri or loc.targetUri
      local range = loc.targetSelectionRange or loc.targetRange or loc.range
      if not uri or not range then
        return
      end

      local def_bufnr = vim.uri_to_bufnr(uri)
      vim.fn.bufload(def_bufnr)
      if vim.bo[def_bufnr].filetype == "" then
        vim.bo[def_bufnr].filetype = "php"
      end
      if not vim.lsp.buf_is_attached(def_bufnr, client.id) then
        vim.lsp.buf_attach_client(def_bufnr, client.id)
      end

      local col = range.start.character + 6
      if range["end"] and range["end"].character > range.start.character then
        col = math.min(col, range["end"].character - 1)
      end

      vim.defer_fn(function()
        if vim.api.nvim_get_current_buf() ~= src_bufnr then
          return
        end
        client:request("textDocument/hover", {
          textDocument = { uri = uri },
          position = { line = range.start.line, character = col },
        }, function(_, hres)
          if vim.api.nvim_get_current_buf() ~= src_bufnr then
            return
          end
          if hres then
            show(hres.contents, opts, client.id, src_bufnr)
          end
        end, def_bufnr)
      end, 50)
    end, src_bufnr)
  end, src_bufnr)
end

return M

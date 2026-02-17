-- lua/cmp_lsp_hash_symbols.lua
local source = {}
source.__index = source

function source.new()
  return setmetatable({}, source)
end

function source.get_trigger_characters()
  return { "@" }
end

function source.is_available()
  return vim.fn.getcmdtype() == "/"
end

local function flatten_document_symbols(out, symbols)
  for _, sym in ipairs(symbols or {}) do
    table.insert(out, sym)
    if sym.children then
      flatten_document_symbols(out, sym.children)
    end
  end
end

function source.complete(self, params, callback)
  if vim.fn.getcmdtype() ~= "/" then
    return callback({ items = {}, isIncomplete = true })
  end

  local line = vim.fn.getcmdline()
  -- Only start offering LSP symbols if the user has typed a '#'
  -- (so you can still search normally for anything else)
  if not line:find("@", 1, true) then
    return callback({ items = {}, isIncomplete = true })
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local req_params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }

  local res = vim.lsp.buf_request_sync(bufnr, "textDocument/documentSymbol", req_params, 800)
  if not res then
    return callback({ items = {}, isIncomplete = true })
  end

  local all = {}
  for _, r in pairs(res) do
    local syms = r.result
    if type(syms) == "table" then
      -- Some servers return nested DocumentSymbol; flatten it.
      flatten_document_symbols(all, syms)
    end
  end

  local items = {}
  local SK = vim.lsp.protocol.SymbolKind
  for _, sym in ipairs(all) do
    if sym.kind == SK.Function or sym.kind == SK.Method then
      -- Keep location info so we can jump on confirm
      table.insert(items, {
        label = "@" .. sym.name,
        kind = vim.lsp.protocol.CompletionItemKind.Function,
        data = { sym = sym, bufnr = bufnr },
        dup = 0,
      })
    end
  end

  callback({ items = items, isIncomplete = true })
end

return source


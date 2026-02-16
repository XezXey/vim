local M = {}

local state_file = vim.fn.stdpath("data") .. "/grep_filetype_selection.json"
local fzf_by_friendly_filetype -- forward declaration

local function load_last_selected()
  if vim.fn.filereadable(state_file) == 1 then
    local content = table.concat(vim.fn.readfile(state_file), "\n")
    local ok, decoded = pcall(vim.fn.json_decode, content)
    if ok and type(decoded) == "table" and #decoded > 0 then
      return decoded
    end
  end
  return nil
end

local function save_last_selected(selected)
  local encoded = vim.fn.json_encode(selected)
  vim.fn.writefile({ encoded }, state_file)
end

local function clear_last_selected()
  if vim.fn.filereadable(state_file) == 1 then
    vim.fn.delete(state_file)
  end
end

local filetype_map = {
  ["all files"] = {},
  ["python"] = { ".py" },
  ["c / cpp"] = { ".c", ".cc", ".cpp", ".h", ".hpp" },
  ["text"] = { ".txt" },
  ["lua"] = { ".lua" },
  ["markdown"] = { ".md" },
  ["json"] = { ".json" },
  ["html"] = { ".html", ".htm" },
  ["javascript"] = { ".js", ".jsx", ".ts", ".tsx" },
  ["web"] = { ".html", ".htm", ".css", ".scss", ".sass", ".less", ".js", ".jsx", ".ts", ".tsx", ".vue", ".svelte" },
  ["shell"] = { ".sh", ".bash", ".zsh", ".fish" },
  ["php"] = { ".php" },
}

local display_names = {
  "all files",
  "python",
  "c / cpp",
  "lua",
  "javascript",
  "web",
  "html",
  "json",
  "markdown",
  "text",
  "shell",
  "php",
}

local function run_fzf(mode, selected)
  local fzf = require("fzf-lua")
  local is_grep = mode == "grep"
  local mode_label = is_grep and "Grep" or "Files"

  local opts = {
    winopts = {
      title = string.format(" %s: all files ", mode_label),
      height = 0.9,
      width = 0.9,
      row = 0.5,
    },
    actions = {
      ["ctrl-f"] = {
        fn = function()
          clear_last_selected()
          fzf_by_friendly_filetype(mode)
        end,
        desc = "change filetype",
        header = "filetype",
      },
    },
    formatter = "path.filename_first",
  }

  if not vim.tbl_contains(selected, "all files") then
    local exts = {}
    for _, name in ipairs(selected) do
      for _, ext in ipairs(filetype_map[name] or {}) do
        table.insert(exts, ext)
      end
    end

    local title = string.format(" %s: %s ", mode_label, table.concat(selected, ", "))
    opts.winopts.title = title

    if is_grep then
      local rg_g = ""
      for _, ext in ipairs(exts) do
        rg_g = rg_g .. string.format(" -g '*%s'", ext)
      end
      opts.rg_opts = rg_g .. " --column --line-number --no-heading --color=always --smart-case"
    else
      local fd_e = ""
      for _, ext in ipairs(exts) do
        fd_e = fd_e .. string.format(" -e '%s'", ext:sub(2)) -- remove leading dot
      end
      opts.fd_opts = "--type f --hidden --follow --exclude .git" .. fd_e
    end
  end

  if is_grep then
    fzf.grep_project(opts)
  else
    fzf.files(opts)
  end
end

fzf_by_friendly_filetype = function(mode)
  mode = mode or "grep"
  local fzf = require("fzf-lua")
  local last_selected = load_last_selected()

  -- If we have a saved selection, skip the picker and go directly
  if last_selected then
    run_fzf(mode, last_selected)
    return
  end

  -- No saved selection, show the filetype picker
  fzf.fzf_exec(display_names, {
    prompt = "Types > ",
    winopts = {
      height = 0.2,
      -- width = 40,
    },
    fzf_opts = {
      ["--multi"] = true,
      ["--bind"] = "tab:toggle+down",
    },
    actions = {
      ["default"] = function(selected)
        if #selected == 0 then return end
        -- Save the selection for next time
        save_last_selected(selected)
        run_fzf(mode, selected)
      end,
    },
  })
end

-- Public API
function M.grep()
  fzf_by_friendly_filetype("grep")
end

function M.files()
  fzf_by_friendly_filetype("files")
end

return M

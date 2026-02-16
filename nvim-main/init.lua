local fn = vim.fn
local map = require("utils").map
local opt = vim.opt
Myleader = '<tab>'

local lazypath = fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua;"
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua;"

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    vim.b.lualine_disable = true
  end
})

vim.opt.rtp:prepend(lazypath)

opt.termguicolors = true
opt.mouse = "a"
opt.eb = false
opt.swapfile = false
opt.smartindent = true
opt.autoindent = true
opt.cindent = true
opt.smarttab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.number = true
opt.ignorecase = true
opt.smartcase = true
opt.gdefault = true
opt.wildmenu = true
opt.wildmode = "list:longest,full"
opt.incsearch = true
opt.display = "lastline"
opt.scrolloff = 3
opt.autoread = true
opt.encoding = "utf-8"
opt.winblend = 0
opt.cursorline = true
opt.cursorlineopt = "number"
opt.signcolumn = "yes"
vim.g.python_recommended_style = 0
opt.foldcolumn = '0'
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true
-- opt.title = true
-- opt.laststatus = 3
-- vim.g.mapleader = " "
-- opt.foldmethod = "expr"
-- opt.foldexpr = "nvim_treesitter#foldexpr()"

require("lazy").setup("plugins", {
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- Disable Diagnostcs globally
-- vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end

map("v", "<", "<gv")
map("v", ">", ">gv")

-- vnoremap // y/\V<c-r>=escape(@",'/\')<cr><cr>
map("v", "/s", '//<esc>:%s//', { remap = true })

map({ "o", "x" }, "ia", 'Ia', { remap = true })

-- used with supasorn/targets.vim to repeat ci" in the next / previous text object in insert mode
map("i", "<c-l>", '<esc>u@r')
map("i", "<c-h>", '<esc>g-i')
map("n", "cina", 'cIna', { remap = true })

map("n", "<c-q>", ':q<CR>')
-- map("n", "zz", "za")

map("n", "gD", vim.lsp.buf.definition, {desc="buf.definition"})
map("n", "gs", vim.lsp.buf.hover, {desc="buf.hover"})

-- this is used with autocmd InsertLeave, every word under cursor is copy when
-- leaving insert mode and can be pasted with "W
map("n", '"W', '"wsiw', { remap = true })
map("n", '"P', 'siw', { remap = true })

map("n", "=<space>", "i <ESC>la <ESC>h")
-- Swap two words surrouding an operator
map("n", ">W", "WvhdBPli<space><esc>hhvEEldEPxBBB")

map("n", "\\[", ":cp<cr>")
map("n", "\\]", ":cn<cr>")
map('n', "'P", function() vim.cmd('edit +1 ' .. vim.fn.stdpath('config') .. '/lua/plugins.lua') end, {desc="Open plugins.lua"})
map('n', "'V", function() vim.cmd('edit +1 ' .. vim.fn.stdpath('config') .. '/init.lua') end, {desc="Open init.lua"})

local diagnostics_active = true
local function toggle_diagnostics()
  diagnostics_active = not diagnostics_active

  if diagnostics_active then
    vim.api.nvim_echo({ { "Diagnostics enabled", "ModeMsg" } }, false, {})
    vim.diagnostic.enable(true)  -- <-- enable globally
  else
    vim.api.nvim_echo({ { "Diagnostics disabled", "WarningMsg" } }, false, {})
    vim.diagnostic.enable(false) -- <-- disable globally
  end
end

map("n", "\\dd", toggle_diagnostics, {desc="disable diagnostics"}) -- ":lua vim.diagnostic.disable()<cr>")
map('n', '\\D', ':diffthis<CR>', { noremap = true, silent = true })

vim.diagnostic.config({
  signs = {
    active = true,
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN]  = "",
      [vim.diagnostic.severity.HINT]  = "",
      [vim.diagnostic.severity.INFO]  = "",
    },
  },
  -- other settings …
})

function LaunchHttpServerHere(directory)
  local port = 5555
  local cmd = string.format("cd %s && python3 -m http.server %d", directory, port)
  -- local cmd = string.format("python3 -m http.server %d", port)
  -- vim.fn.termopen(cmd)
  vim.api.nvim_command("tabnew")
  vim.fn.termopen(cmd)
  -- vim.cmd(":tab")

  -- Print a message to the user
  print(string.format("Started HTTP server on port %d serving directory %s", port, directory))
end

function LaunchHttpServerPwd()
  LaunchHttpServerHere(vim.fn.getcwd())
end

vim.api.nvim_create_user_command("Restart", function()
  local session = vim.fn.stdpath("state") .. "/restart_session.vim"
  vim.cmd("set sessionoptions+=globals,tabpages,winsize,folds,help")
  vim.cmd("wall")

  vim.cmd("mksession! " .. vim.fn.fnameescape(session))
  vim.cmd("restart")
end, {})

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    local session = vim.fn.stdpath("state") .. "/restart_session.vim"

    if vim.fn.filereadable(session) == 1 then
      vim.cmd("silent! source " .. vim.fn.fnameescape(session))
      vim.fn.delete(session)

      -- vim.schedule(function()
        -- vim.cmd("bufdo e!")
      -- end)
      vim.schedule(function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.api.nvim_buf_is_loaded(buf)
             and vim.api.nvim_buf_get_option(buf, "buftype") == ""
             and vim.api.nvim_buf_get_name(buf) ~= "" then
            vim.api.nvim_buf_call(buf, function()
              vim.cmd("edit!")
            end)
          end
        end
      end)
    end
  end,
})

-- local color_schemes = {'onedark', 'tokyonight', 'tokyonight-night' }
-- function RotateColorScheme()
  -- local current_scheme = vim.g.colors_name
  -- local current_index
  -- for i, scheme in ipairs(color_schemes) do
    -- if scheme == current_scheme then
      -- current_index = i
      -- break
    -- end
  -- end
  -- local next_index = (current_index % #color_schemes) + 1
  -- vim.cmd('colorscheme ' .. color_schemes[next_index])
  -- vim.api.nvim_echo({ { tostring(next_index) } }, true, {})
  -- vim.api.nvim_echo({ { 'colorscheme - ' .. color_schemes[next_index] } }, true, {})
  -- vim.api.nvim_echo({ { 'colorscheme ' } }, false, {})
  -- vim.notify({ 'colorscheme ' .. color_schemes[next_index] }, "info")
-- end

-- map("n", "\\s", RotateColorScheme)

vim.cmd("source " .. vim.fn.stdpath("config") .. "/extra.vim")

vim.cmd [[
set shm+=I

nnoremap gf :call RgCwd(expand("<cword>"))<CR>

nnoremap <silent> \m :write<CR>:call FirstLineCompile()<CR>
nnoremap <silent> \r :write<CR>:call FirstLineCompile(2)<CR>

nmap <silent> ( :call JumpThroughParameter(-1)<CR>
nmap <silent> ) :call JumpThroughParameter(1)<CR>

command! W write
command! Q quit

vnoremap // y/\V\<<c-r>=escape(@",'/\')<cr>\><cr>
" nnoremap // /\V\<C-R>=expand('<cword>')<CR>\><CR>

" command! -nargs=+ H lua LaunchHttpServerHere(<f-args>)
command! H lua LaunchHttpServerPwd()

" command! Vscode execute '!' . "ssh $(echo $SSH_CLIENT | awk '\{ print $1 \}') '/usr/local/bin/code --folder-uri \"vscode-remote://ssh-remote+'$(hostname -I | awk '{print $1}')''$(pwd)'\"'"
" command! Vscode execute '!' . "ssh -o StrictHostKeyChecking=no $(if [ -s ~/ssh_client_info.txt ]; then cat ~/ssh_client_info.txt | awk '\{ print $1 \}'; else echo $SSH_CLIENT | awk '\{ print $1 \}'; fi) '/usr/local/bin/code --folder-uri \"vscode-remote://ssh-remote+'$(hostname -I | tr \' \' \'\\n\' | grep '^10\.204\.100\.' | head -n 1)''$(pwd)'\"'" 

command! Vsc :!zsh -i -c "vsc"
command! Finder :!zsh -i -c "finder"


command! To2spaces %s;^\(\s\+\);\=repeat(' ', len(submatch(0))/2);g
command! To4spaces %s/^\s*/&&/g

let g:fzf_layout = { 'window': {'width': 1, 'height': 0.25, 'yoffset': 1} }
" let $FZF_DEFAULT_OPTS="--layout reverse --info inline"
let $FZF_DEFAULT_OPTS="--info inline"

" Fold all "use { }" in plugins.lua
" au BufReadPost plugins.lua :%g/\(use\_.\{-}\)\@<={/ normal! f{zf%
au BufReadPost plugins.lua :%g/^  {/ normal! f{zf% 

" " This beauty remembers where you were the last time you edited the file, and returns to the same position.
" au BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif

function! CustomHighlight()
  " hi clear CursorLineNr
  " hi CursorLineNr guifg=#e5c07b
  " hi MatchParen guibg=orange guifg=black 
  hi MatchParen gui=underline guibg=NONE guifg=red
  hi TreesitterContextBottom gui=underline guisp=Grey
  hi HighlightCurrentSearch guibg=#ed6623 guifg=black

  hi BookmarksNvimLine guibg=NONE
endfunction

augroup CustomHighlightGroup
  autocmd!
  autocmd ColorScheme * call CustomHighlight()
augroup END
call CustomHighlight()

augroup highlight_yank
  autocmd!
  au TextYankPost * silent! lua vim.highlight.on_yank { higroup='IncSearch', timeout=1000 }
augroup END

au BufNewFile,BufRead *.ejs set filetype=html


augroup MyAutocmds
  autocmd!
  autocmd BufWinEnter * if &filetype == 'MiniFiles' | setlocal cursorline cursorlineopt=line | endif
  highlight MiniFilesCursorLine guifg=NONE guibg=#1c1c1c
augroup END

" The below produces a bug with nvim-dap-view where its windows closes immedietely
" augroup AutoSaveGroup
  " autocmd!
  " https://vi.stackexchange.com/questions/13864/bufwinleave-mkview-with-unnamed-file-error-32
  " autocmd BufWinLeave,BufLeave,BufWritePost,BufHidden,QuitPre ?* nested silent! mkview!
  " autocmd BufWinEnter ?* if &filetype != 'lua' | silent! loadview | endif
" augroup end

" augroup TitleString
  " autocmd!
  " autocmd BufEnter,FileReadPost * let &titlestring = 'pwd: %{expand("%:p:h")}'
" augroup END
]]


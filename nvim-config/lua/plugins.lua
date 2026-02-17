local utils = require("utils")
local map = utils.map
local in_singularity = vim.env.SINGULARITY_NAME ~= nil or vim.env.SINGULARITY_CONTAINER ~= nil

return {
  -- ### System's plugin
  { 'navarasu/onedark.nvim', -- Colorscheme
    lazy = false,
    priority = 1000,
    config = function()
      local style = 'cool'
      local util = require("onedark.util")
      local colors = require("onedark.palette")[style]
      require('onedark').setup {
        -- Main options --
        style = style, -- Default theme style. Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
        transparent = false, -- Show/hide background
        term_colors = true, -- Change terminal color as per the selected theme style
        ending_tildes = false, -- Show the end-of-buffer tildes. By default they are hidden
        cmp_itemkind_reverse = false, -- reverse item kind highlights in cmp menu

        -- toggle theme style ---
        toggle_style_key = "<leader><leader>s", -- keybind to toggle theme style. Leave it nil to disable it, or set it to a string, for example "<leader>ts"
        toggle_style_list = { 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer', 'light' }, -- List of styles to toggle between

        -- Change code style ---
        -- Options are italic, bold, underline, none
        -- You can configure multiple style with comma seperated, For e.g., keywords = 'italic,bold'
        code_style = {
          comments = 'italic',
          keywords = 'none',
          functions = 'none',
          strings = 'none',
          variables = 'none'
        },

        -- Custom Highlights --
        colors = {}, -- Override default colors
        highlights = {
          ["HopNextKey1"] = {fg = '$yellow'},
          ["HopNextKey2"] = {fg = util.darken(colors.yellow, 0.8)},
          ["IndentBlanklineContextChar"] = { fg = '$purple' },
          ["IndentBlanklineContextStart"] = { fmt = 'underline' },
          -- 🔥 Disable Treesitter spell highlighting
          ["@spell"] = { fg = 'none', undercurl = false, underline = false },
          ["@nospell"] = { fg = "none" },

        }, -- Override highlight groupscluster pixels into segments

        -- Plugins Config --
        diagnostics = {
          darker = true, -- darker colors for diagnostic
          undercurl = true, -- use undercurl instead of underline for diagnostics
          background = true, -- use background color for virtual text
        },
      }
      vim.cmd [[ colorscheme onedark ]]
    end
  },
  { 'catppuccin/nvim',
    lazy = true,
  },
  { 'folke/tokyonight.nvim',
    lazy = true,
  },
  { 'nvim-tree/nvim-web-devicons', -- Icons!
    lazy = true
  },
  -- ### Textobjects
  { 'Matt-A-Bennett/vim-surround-funk', -- af, if function objects
    lazy = false,
    init = function()
      vim.g.surround_funk_create_mappings = 0
    end,
    keys = {
      { "af",  "<Plug>(SelectWholeFUNCTION)", mode = { "o", "x" } },
      { "iF",  "<Plug>(SelectFunctionName)",  mode = { "o", "x" } },
      { "if",  "<Plug>(SelectFunctionNAME)",  mode = { "o", "x" } },
    },
  },
  { 'PeterRincker/vim-argumentative', -- argument textobject, and swapping
    event = "VeryLazy"
  },
  { 'michaeljsmith/vim-indent-object', -- indent object
    event = "VeryLazy"
  },
  { 'kana/vim-textobj-user', -- Custom textobject. = i=
    event = "VeryLazy",
    config = function()
      vim.cmd [[
        function! AfterEquationObject()
          normal! ^f=w
          let head_pos = getpos('.')
          normal! $
          let tail_pos = getpos('.')
          echom head_pos
          return ['v', head_pos, tail_pos]
        endfunction 

        function! BeforeEquationObject()
          normal! ^
          let head_pos = getpos('.')
          normal! f=ge
          let tail_pos = getpos('.')
          return ['v', head_pos, tail_pos]
        endfunction 

        call textobj#user#plugin('function', {
        \   'equation': {
        \     'select-i-function': 'AfterEquationObject',
        \     'select-i': '=',
        \     'select-a-function': 'BeforeEquationObject',
        \     'select-a': 'i=',
        \   },
        \ })
      ]]

    end,
  },
  { 'supasorn/targets.vim', -- Many more textobjects
    event = "VeryLazy"
  },
  -- ### Text edit / motion
  { 'gbprod/substitute.nvim', -- subversive + exchange: quick substitutions and exchange.
    keys = {
      { "s", "<cmd>lua require('substitute').operator()<cr>" },
      { "ss", "<cmd>lua require('substitute').line()<cr>" },
      { "S", "<cmd>lua require('substitute').eol()<cr>" },
      { "s", "<cmd>lua require('substitute').visual()<cr>", mode = "x" },
      { "sx", "<cmd>lua require('substitute.exchange').operator()<cr>" },
      { "sxx", "<cmd>lua require('substitute.exchange').line()<cr>" },
      { "X", "<cmd>lua require('substitute.exchange').visual()<cr>", mode = "x" },
    },
    opts = {
      on_substitute = function()
        vim.cmd("call yoink#startUndoRepeatSwap()")
      end,
      exchange = {
        motion = false,
        use_esc_to_cancel = true,
      },
    },
  },
  { 'tpope/vim-repeat', -- expanding dot repeat for more functions
    event = "VeryLazy",
  },
  { "kylechui/nvim-surround", -- Changes surrounding quote, e.g.
    event = "VeryLazy",
    config = true,
  },
  { 'numToStr/Comment.nvim', -- <c-c> to comment line
    dependencies = "nvim-treesitter",
    keys = {
      { "<c-c>", "gccj", remap = true },
      { "<c-c>", "gc", mode = "v", remap = true }
    },
    config = true,
  },
  { 'supasorn/hop.nvim', -- My hop with yank phrase, yank line
    keys = {
      { "<c-j>", mode = { "n", "v" }, desc="Jump to lines downward" },
      { "<c-k>", mode = { "n", "v" }, desc="Jump to lines upward" },
      { "<space>", mode = { "n", "v" }, desc="Hop to any character" },
      { "p", mode = { "o" } },
      { "L", mode = { "o", "v" } },
    },
    config = function()
      -- you can configure Hop the way you like here; see :h hop-config
      require 'hop'.setup { keys = 'cvbnmtyghqweruiopasldkfj' }
      local rwt = require("utils").run_without_TSContext

      map({ "n", "v" }, "<c-j>",
        rwt(require 'hop'.hint_lines_skip_whitespace, { direction = require 'hop.hint'.HintDirection.AFTER_CURSOR }))
      map({ "n", "v" }, "<c-k>",
        rwt(require 'hop'.hint_lines_skip_whitespace, { direction = require 'hop.hint'.HintDirection.BEFORE_CURSOR }))

      -- map({ "o" }, "p", rwt(require 'hop'.hint_phrase, { ["postcmd"] = "p" }))
      map({ "o" }, "p", rwt(require 'hop'.hint_phrase))
      map({ "o", "v" }, "L", rwt(require 'hop'.hint_2lines))

      map({ "n", "v" }, "<space>", rwt(require 'hop'.hint_char1))
    end
  },
  { 'kevinhwang91/nvim-fFHighlight', -- highlight fF
    opts = {
      disable_keymap = false,
      disable_words_hl = false,
      number_hint_threshold = 3,
      prompt_sign_define = { text = '✹' }
    },
    keys = {{'f', mode = {"n", "v"}}, {'f', mode = {"n", "v"}}}
  },
  { 'monaqa/dial.nvim', -- enhanced increment/decrement
    keys = {
      { "<C-a>", "<Plug>(dial-increment)", mode = { "n", "v" } },
      { "<C-x>", "<Plug>(dial-decrement)", mode = { "n", "v" } },
      { "g<C-a>", "g<Plug>(dial-increment)", mode = "v" },
      { "g<C-x>", "g<Plug>(dial-decrement)", mode = "v" },
    },
    config = function()
      local augend = require("dial.augend")
      require("dial.config").augends:register_group {
        default = {
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          augend.constant.alias.bool,
          augend.date.alias["%Y/%m/%d"],
          augend.constant.new {
            elements = { "and", "or" },
            word = true, -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
            cyclic = true, -- "or" is incremented into "and".
          },
          augend.constant.new {
            elements = { "&&", "||" },
            word = false,
            cyclic = true,
          },
          augend.constant.new {
            elements = { "True", "False" },
            word = true,
            cyclic = true,
          },
        },
      }
    end,
  },
  { 'Wansmer/treesj', -- splitting/joining blocks of code like arrays
    cmd = { "TSJToggle", "TSJSplit", "TSJJoin" },
    keys = {
      { "\\l", ":TSJToggle<cr>", desc="list to single/multiple lines"},
    },
    config = true,
  },
  -- ### Yank Paste plugins
  { "AckslD/nvim-neoclip.lua", -- \p shows yank registers with fzf
    event = "VeryLazy",
    dependencies = "fzf-lua",
    keys = { { "\\p", ":lua require('neoclip.fzf')()<cr>", desc="show yank list"} },
    config = true,
  },
  { 'ojroques/vim-oscyank', -- \c to copy to system's clipboard. works inside tmux inside ssh
    keys = { { "\\c", ":OSCYankVisual<cr>", mode = "v", desc="yank to system's clipboard" } }
  },
  { 'svermeulen/vim-yoink', -- <c-p> to cycle through previous yank register
    event = "VeryLazy",
    keys = {
      { "<c-p>", "<plug>(YoinkPostPasteSwapBack)" },
      { "<c-n>", "<plug>(YoinkPostPasteSwapForward)" },
      { "p", "<plug>(YoinkPaste_p)" },
      { "P", "<plug>(YoinkPaste_P)" },
    },
  },
  { 'svban/YankAssassin.vim', -- make the cursor not move when yank
    event = "VeryLazy",
  },
  -- ### Text Interface
  { 'kevinhwang91/nvim-ufo', -- for modern folds
    event = "BufReadPost",
    dependencies = 'kevinhwang91/promise-async',
    config = function()
      local handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = ('  %d '):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, 'MoreMsg' })
        return newVirtText
      end

      require('ufo').setup({
        provider_selector = function(bufnr, filetype, buftype)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t')
          if filename == 'plugins.lua' then
            return ''
          else
            return { 'treesitter', 'indent' }
          end
        end,
        fold_virt_text_handler = handler
      })
      map('n', 'zR', require('ufo').openAllFolds)
      map('n', 'zM', require('ufo').closeAllFolds)
    end
  },
  { 'catgoose/nvim-colorizer.lua', -- Shows color blocks when see hex code
    event = "BufReadPre",
    config = function()
      require 'colorizer'.setup({ 'lua', 'css', 'javascript', 'html' }, {
        mode = "virtualtext"
      })
    end
  },
  { 'uga-rosa/ccc.nvim', -- Color picker
    keys = { {
      "<m-c>", "<cmd>CccPick<CR>", mode = { "n", "i", "v" }, desc = "Edit color under cursor" }
    },
    -- keys = { { "<c-c>", mode = "i" }, { '\\\\c', ':CccPick<cr>' } },
    cmd = { "CccPick", "CccHighlighterToggle", "CccHighlighterEnable", "CccHighlighterDisable" },
    config = function()
      require('ccc').setup {
        inputs = {
          require('ccc_multiple_color')
        }
      }
      -- map('i', '<c-c>', '<Plug>(ccc-insert)')
    end
  },
  { 'romainl/vim-cool', -- Automatically disable highlights when search
    event = "VeryLazy",
  },
  { 'airblade/vim-current-search-match', -- Highlight current search text differently
    event = "VeryLazy",
    config = function()
      vim.g.current_search_match = 'HighlightCurrentSearch'
    end
  },
  { "folke/snacks.nvim",
    enabled = true,
    opts = {
      indent = {
        enabled = false,
        hl = {
          "SnacksIndent1",
          "SnacksIndent2",
        },
      },
      -- explorer = {
      -- }
    },
    config = function(_, opts)
      vim.cmd [[
        function! IndentBlanklineColor()
          highlight SnacksIndent1 guifg=#707070 gui=nocombine
          highlight SnacksIndent2 guifg=#444444 gui=nocombine
        endfunction

        augroup IndentBlanklineCustomHighlight
          autocmd!
          autocmd ColorScheme * call IndentBlanklineColor()
        augroup END
        call IndentBlanklineColor()
      ]]
      require("snacks").setup(opts)
    end,
  },
  { "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    ---@module "ibl"
    ---@type ibl.config
    config = function(_, opts)
      local highlight = {
        "LineNr",
        -- "IndentBlanklineChar",
        "WinSeparator",
      }

      local hooks = require "ibl.hooks"
      -- create the highlight groups in the highlight setup hook, so they are reset
      -- every time the colorscheme changes
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "Indent1", { fg = "#707070" })
        vim.api.nvim_set_hl(0, "Indent2", { fg = "#444444" })
      end)

      require("ibl").setup {
        indent = {
          -- char = "│",
          highlight = highlight,
        },
      }
    end,
  },
  { 'nvim-treesitter/nvim-treesitter-context', -- Show context at the top. Cool!
    event = "VeryLazy",
    opts = {
      enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
      max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
      trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
      patterns = { -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
        -- For all filetypes
        -- Note that setting an entry here replaces all other patterns for this entry.
        -- By setting the 'default' entry below, you can control which nodes you want to
        -- appear in the context window.
        default = {
          'class',
          'function',
          'method',
          'for', -- These won't appear in the context
          'while',
          'if',
          -- 'switch',
          -- 'case',
        },
        lua = {
          'table',
        },
        -- Example for a specific filetype.
        -- If a pattern is missing, *open a PR* so everyone can benefit.
        --   rust = {
        --       'impl_item',
        --   },
      },
      exact_patterns = {
      },

      -- [!] The options below are exposed but shouldn't require your attention,
      --     you can safely ignore them.

      zindex = 20, -- The Z-index of the context window
      mode = 'topline', -- Line used to calculate context. Choices: 'cursor', 'topline'
      multiline_threshold = 1,
      -- separator = "─",
      -- separator = "-",
    },
  },
  { 'dstein64/nvim-scrollview', -- Scrollbar
    enabled = false,
    event = "VeryLazy",
    config = function()
      require('scrollview').setup({
        excluded_filetypes = { 'nerdtree' },
        current_only = true,
        -- scrollview_winblend_gui = 90,
        base = 'right',
        signs_on_startup = {''},
        column = 1
      })
    end
  },
  { 'nmac427/guess-indent.nvim', -- set the indent size automatically
    config = true,
  },
  { 'MeanderingProgrammer/render-markdown.nvim', -- markdown preview for code companion
    ft = { "markdown", "codecompanion" },
    config = function()
      vim.api.nvim_set_hl(0, "RenderMarkdownH2Bg", { bg = "#4a1e51" })
    end,
  },
  { 'rachartier/tiny-inline-diagnostic.nvim', -- show diagnostic message as inline virtual text
    event = "VeryLazy",
    priority = 1000,
    config = function()
        require('tiny-inline-diagnostic').setup()
        vim.diagnostic.config({ virtual_text = false }) -- Disable default virtual text
    end
  },
  { "SmiteshP/nvim-navic", -- show current code context
    event = "VeryLazy",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    config = function()
      require('nvim-navic').setup({
        icons = {
          File          = " ",
          Module        = " ",
          Namespace     = " ",
          Package       = " ",
          Class         = " ",
          Method        = " ",
          Property      = " ",
          Field         = " ",
          Constructor   = " ",
          Enum          = "練",
          Interface     = "練",
          Function      = " ",
          Variable      = " ",
          Constant      = " ",
          String        = " ",
          Number        = " ",
          Boolean       = "◩ ",
          Array         = " ",
          Object        = " ",
          Key           = " ",
          Null          = "ﳠ ",
          EnumMember    = " ",
          Struct        = " ",
          Event         = " ",
          Operator      = " ",
          TypeParameter = " ",
        },
        lsp = {
          auto_attach = true,
          preference = {
            "pyright", "basedpyright",
            "lua_ls",
            "clangd",
            "tsserver",
            "html",
            "cssls",
            "jsonls",
            "copilot",
          },
    
        },
        highlight = true,
        separator = " ",
        -- separator = " ⏵ ",
        -- separator = " 》 ",
        depth_limit = 0,
        depth_limit_indicator = "..",
        safe_output = true
      })
      vim.cmd [[
        function! NavicColor()
          highlight NavicSeparator guifg=#4e5876 
        endfunction

        augroup NavicColorGroup
            autocmd!
            autocmd ColorScheme * call NavicColor() 
        augroup END
        call NavicColor() 
      ]]
    end,
  },
  -- ### Bookmarks and mark column
  { 'chentoast/marks.nvim', -- show mark column
    enabled = true,
    event = "VeryLazy",
    opts = {
      -- whether to map keybinds or not. default true
      default_mappings = true,
      -- which builtin marks to show. default {}
      -- builtin_marks = { ".", "<", ">", "^" },
      builtin_marks = {},
      -- whether movements cycle back to the beginning/end of buffer. default true
      cyclic = true,
      -- whether the shada file is updated after modifying uppercase marks. default false
      force_write_shada = true,
      -- how often (in ms) to redraw signs/recompute mark positions.
      -- higher values will have better performance but may cause visual lag,
      -- while lower values may cause performance penalties. default 150.
      refresh_interval = 250,
      -- sign priorities for each type of mark - builtin marks, uppercase marks, lowercase
      -- marks, and bookmarks.
      -- can be either a table with all/none of the keys, or a single number, in which case
      -- the priority applies to all marks.
      -- default 10.
      sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
      -- disables mark tracking for specific filetypes. default {}
      excluded_filetypes = {
        "help",
        "terminal",
        "packer",
        "lspinfo",
        "TelescopePrompt",
        "TelescopeResults",
        "mason",
        "",
        "fzf"
      },
      -- marks.nvim allows you to configure up to 10 bookmark groups, each with its own
      -- sign/virttext. Bookmarks can be used to group together positions and quickly move
      -- across multiple buffers. default sign is '!@#$%^&*()' (from 0 to 9), and
      -- default virt_text is "".
      bookmark_0 = {
        sign = "⚑",
        virt_text = "<<<<<<<<",
        -- explicitly prompt for a virtual line annotation when setting a bookmark from this group.
        -- defaults to false.
        annotate = true,
      },
      mappings = {}
    },
  },
  { "LintaoAmons/bookmarks.nvim", -- bookmark that allows naming
    enabled = false,
    event = "VeryLazy",
    keys = {
      {"mm", "<cmd>BookmarksMark<cr>", mode = {"n", "v"}},
      {"'o", "<cmd>BookmarksGoto<cr>", mode = {"n", "v"}},
      {"'t", "<cmd>BookmarksTree<cr>", mode = {"n", "v"}}
    },
    dependencies = {
      {"supasorn/sqlite.lua"},
      {"nvim-telescope/telescope.nvim"},
      {"stevearc/dressing.nvim"} -- optional: better UI
    },
    config = function()
      require('bookmarks').setup {
        keymap = {
          delete = {"dd"}
        },
        db_dir = vim.fs.joinpath(vim.fn.stdpath("config"), "data", "bookmarks", vim.loop.os_gethostname()),
      }
      vim.cmd [[
        function! BookmarkColor()
          hi BookmarksNvimLine guibg=NONE
        endfunction

        augroup BookmarkCustomHighlight
          autocmd!
          autocmd ColorScheme * call BookmarkColor()
        augroup END
        call BookmarkColor()
      ]]
    end,
  },
  { "TheNoeTrevino/haunt.nvim",
    enabled = true,
    -- default config: change to your liking, or remove it to use defaults
    ---@class HauntConfig
    opts = {
      sign = "󱙝",
      sign_hl = "DiagnosticInfo",
      virt_text_hl = "HauntAnnotation", -- links to DiagnosticVirtualTextHint
      annotation_prefix = " 󰆉 ",
      line_hl = nil,
      virt_text_pos = "eol",
      data_dir = nil,
      per_branch_bookmarks = true,
      picker = "snacks", -- "auto", "snacks", "telescope", or "fzf"
      picker_keys = { -- picker agnostic, we got you covered
        delete = { key = "d", mode = { "n" } },
        edit_annotation = { key = "a", mode = { "n" } },
      },
    },
    -- recommended keymaps, with a helpful prefix alias
    init = function()
      local haunt = require("haunt.api")
      local haunt_picker = require("haunt.picker")
      local map = vim.keymap.set
      local prefix = "<leader>h"

      -- My own shortcuts
      map("n", "mm", function()
        haunt.annotate()
      end, { desc = "Annotate" })
      map("n", "'o", function()
        haunt_picker.show()
      end, { desc = "Show Picker" })

      -- annotations
      map("n", prefix .. "a", function()
        haunt.annotate()
      end, { desc = "Annotate" })
      map("n", prefix .. "t", function()
        haunt.toggle_annotation()
      end, { desc = "Toggle annotation" })

      map("n", prefix .. "T", function()
        haunt.toggle_all_lines()
      end, { desc = "Toggle all annotations" })

      map("n", prefix .. "d", function()
        haunt.delete()
      end, { desc = "Delete bookmark" })

      map("n", prefix .. "C", function()
        haunt.clear_all()
      end, { desc = "Delete all bookmarks" })

      -- move
      map("n", prefix .. "p", function()
        haunt.prev()
      end, { desc = "Previous bookmark" })

      map("n", prefix .. "n", function()
        haunt.next()
      end, { desc = "Next bookmark" })

      -- picker
      map("n", prefix .. "l", function()
        haunt_picker.show()
      end, { desc = "Show Picker" })

      -- quickfix 
      map("n", prefix .. "q", function()
         haunt.to_quickfix()
      end, { desc = "Send Hauntings to QF Lix (buffer)" })

      map("n", prefix .. "Q", function()
        haunt.to_quickfix({ current_buffer = true })
      end, { desc = "Send Hauntings to QF Lix (all)" })

      -- yank
      map("n", prefix .. "y", function()
        haunt.yank_locations({current_buffer = true})
      end, { desc = "Send Hauntings to Clipboard (buffer)" })

      map("n", prefix .. "Y", function()
        haunt.yank_locations()
      end, { desc = "Send Hauntings to Clipboard (all)" })

    end,
  },
  -- ### UI Interface
  { 'akinsho/bufferline.nvim', -- Bufferline
    enabled = false,
    config = function()
      for i = 1, 9 do
        map("n", "<leader>" .. i, ":BufferLineGoToBuffer " .. i .. "<cr>", { silent = true })
      end
      local function get_color(group, attr)
        return vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(group)), attr)
      end

      -- local deffg = '#8a919d'
      -- dark -> bright
      local g0bg = get_color("LineNr", "bg#")
      local g1bg = get_color("StatusLineNc", "bg#")
      local g2bg = get_color("StatusLine", "bg#")
      local deffg = get_color("StatusLine", "fg#")

      local fontcolor = get_color("Function", "fg#")
      local hnormal = {
        -- bg = '#31353f',
        bg = g1bg,
        fg = deffg,
      }
      local hselected = {
        fg = fontcolor,
        bold = false,
        italic = false,
      }
      local hvisible = {
        -- fg = '#7ca8cf',
        fg = get_color("Constant", "fg#"),
        bg = g1bg,
      }
      local separator = {
        fg = g0bg,
        bg = g0bg,
      }
      require("bufferline").setup {
        options = {
          tab_size = 15,
          color_icons = false,
          show_buffer_icons = false,
          sort_by = "none",
          -- sort_by = function(buffer_a, buffer_b)
          -- for _, buffer in ipairs(vim.fn.BufMRUList()) do
          -- if buffer == buffer_a.id then
          -- return true
          -- elseif buffer == buffer_b.id then
          -- return false
          -- end
          -- end
          -- return false
          -- end,
          numbers = function(opts)
            return string.format('%s.', opts.ordinal)
          end,
          -- numbers = 'ordinal'
          offsets = {
            {
              -- filetype = "NvimTree",
              -- text = "File Explorer",
              -- text_align = "left",
              separator = false
            }
          },
          indicator = {
            -- icon = ' ',
            style = 'none'
          },
          separator_style = "thin",
          -- separator_style = { "", "" },
        },

        highlights = {
          numbers = hnormal,
          close_button = hnormal,
          duplicate = hnormal,
          modified = hnormal,
          separator = separator,
          buffer_selected = hselected,
          numbers_selected = hselected,
          close_button_selected = hselected,
          duplicate_selected = hselected,
          modified_selected = hselected,
          indicator_selected = hselected,
          separator_selected = separator,
          buffer_visible = hvisible,
          numbers_visible = hvisible,
          close_button_visible = hvisible,
          duplicate_visible = hvisible,
          modified_visible = hvisible,
          indicator_visible = hvisible,
          separator_visible = separator,
          background = {
            bg = g1bg,
            fg = deffg
          },
          fill = {
            bg = g1bg,
            fg = g1bg
          },

        }
      }
    end
  },
  { 'nvim-lualine/lualine.nvim', -- Statusline
    event = "VeryLazy",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local colors = {
        bg       = '#202328',
        fg       = '#bbc2cf',
        yellow   = '#ECBE7B',
        cyan     = '#008080',
        darkblue = '#081633',
        green    = '#98be65',
        orange   = '#FF8800',
        violet   = '#a9a1e1',
        magenta  = '#c678dd',
        blue     = '#51afef',
        red      = '#ec5f67',
      }

      local navic_ok, navic = pcall(require, 'nvim-navic')
      local winbar_cfg = {}
      local inactive_winbar_cfg = {}

      local navic_context = {
        function()
          if navic.is_available() then
            local l = navic.get_location()
            if l ~= '' then
              return l
            end
            return ' '
          else
            return ' '
          end
        end,
        draw_empty = true,
        -- navic.get_location,
        -- cond = navic.is_available,
        padding = { left = 1, right = 0 },
      }
      local filepath = require('filepath')

      local my_filename = require('lualine.components.filename'):extend()
      my_filename.apply_icon = require('lualine.components.filetype').apply_icon
      my_filename.icon_hl_cache = {}
      my_filename.update_status = function(self)
        local super = getmetatable(getmetatable(self).__index)
        if vim.bo.filetype == 'oil' then
          self.options.path = 1
        end
        return super.update_status(self)
      end

      local util = require("onedark.util")

      -- local custom_theme = require'lualine.themes.onedark'
      -- local custom_theme = require'onedark.lualine.themes.onedark'
      -- local c = require('onedark.colors')
      -- local lighterB = 
      -- custom_theme.normal.b.bg = util.lighten(c.bg3, 0.95)
      --
      local function not_in_filetypes(ft_list)
        return function()
          return not vim.tbl_contains(ft_list, vim.bo.filetype)
        end
      end

      require('lualine').setup {

        options = {
          icons_enabled = true,
          -- theme = 'onedark2',
          theme = 'auto',
          -- theme = custom_theme,
          -- component_separators = { left = '', right = '' },
          component_separators = { left = '|', right = '|' },
          -- component_separators = { left = '', right = '' },
          --section_separators = { left = '', right = ''},
          section_separators = { left = '', right = '' },
          disabled_filetypes = {
            statusline = {},
            winbar = {'Avante', 'AvanteInput', 'AvanteTodos', 'AvanteSelectedFiles', 'dap-view', 'dap-repl'},
            -- winbar = {},
          },
          ignore_focus = {},
          always_divide_middle = true,
          globalstatus = true,
          refresh = {
            statusline = 50,
            tabline = 1000,
            winbar = 1000,
          }
        },
        sections = {
          lualine_a = {
            { function()
              if vim.bo.modified then
                return ' ●'
              end
              return ' '
            end,
            padding = {left = 0, right = 0 }, -- We don't need space before this
            },
          },
          --[[
          lualine_b = {
            { 'filename',
              file_status = false,
              symbols = {
                modified = '',    -- Text to show when the file is modified.
                readonly = '[-]',    -- Text to show when the file is non-modifiable or readonly.
                unnamed = '[No Name]', -- Text to show for unnamed buffers.
                newfile = '[New]',   -- Text to show for newly created file before first write
              }
            }
          },
          --]]
          lualine_c = {
            -- { 'diff', separator = {} },
            navic_context,

          },
          lualine_b = {
            {
              'branch',
              separator = "",
            }, 
            -- {
            -- 'diff', -- git diff status
            -- }
          },
          lualine_x = {
            -- {
              -- filepath.get_path,
              -- padding = { left = 0, right = 0 },
              -- separator = ''
            -- },
            --
            {
              -- 'lsp_progress',
              -- display_components = { { 'title', 'percentage', 'message' } },
              -- spinner_symbols = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏', },
              -- separator = {},
              function()
                -- invoke `progress` here.
                return require('lsp-progress').progress()
              end,
            },
            {
              'diagnostics',
              sources = { 'nvim_diagnostic' },
              symbols = { error = ' ', warn = ' ', info = ' ', hint = '' },
              diagnostics_color = {
                color_error = { fg = colors.red },
                color_warn = { fg = colors.yellow },
                color_info = { fg = colors.cyan },
              },
              separator = {},
              padding = {right = 0, left = 1},
            },
            {
              function()
                -- return '⌂ ' .. vim.fn.getcwd()
                return ' ' .. vim.fn.getcwd(-1, -1) .. ' '
              end,
              separator = {},
              padding = {right = 0, left = 1},
            },
            -- { require("lsp-progress").progress, },
            -- { require('lsp_spinner').status },
          },
          lualine_y = {
            { 'filetype',
              separator = "",
              padding = {left = 0, right = 0}, -- We don't need space before this
            },
            {
              function()
                -- local msg = 'no lsp'
                local msg = '-'
                local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
                local clients = vim.lsp.get_clients()
                if next(clients) == nil then
                  return msg
                end
                for _, client in ipairs(clients) do
                  local filetypes = client.config.filetypes
                  if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                    -- return ' ' -- client.name
                    return '⛩' -- client.name
                  end
                end
                return msg
              end,
              -- icon = ' ',
              separator = "",
              padding = {left = 1, right = 1 }, -- We don't need space before this
              -- color = { fg = '#ffffff', gui = 'bold' },
            },
          },
          lualine_z = {
            {
              function()
                local hn = vim.loop.os_gethostname()
                local out = ''
                if hn == 'Supasorns-MacBook-Pro.local' then
                  out = 'MBP'
                elseif hn == 'ssmb.local' then
                  -- return '⌂'
                  -- return '🛖'
                  out = '⌘'
                else
                  out = hn:gsub("vision", "v")
                end

                local dap_exists, dap = pcall(require, "dap")
                if dap_exists and dap.session() then
                  out = out .. ' Debug  '
                elseif vim.b.building then
                  out = out .. ' Compiling ' .. require('spinner').spinner_component()
                end
                return out
              end,
              padding = {left = 0, right = 1 }, -- We don't need space before this
              color = function()
                local dap_exists, dap = pcall(require, "dap")
                if dap_exists and dap.session() then
                  -- return { bg = '#ff9e64', fg = '#000000', gui = 'bold' } 
                  return { bg = '#ff9e64', fg = '#000000' } 
                elseif vim.b.building then
                  return { bg = '#ca72e4', fg = '#000000' } 
                end
                -- Returning nil tells lualine to use the theme's default color
                return nil
              end,
            },
          }
        },
        -- tabline = { lualine_c = {navic_context} },
        tabline = {},

        winbar = {
          lualine_a = {},
          lualine_b = {
            -- {
              -- my_filename, colored = true,
              -- cond = function() return vim.bo.filetype == 'oil' end
            -- },
          },
          lualine_c = {
            -- navic_context
          },
          lualine_x = {
            -- filepath.get_path,
            -- { function() return ' ' end,
              -- separator = {}
            -- } 

            { 
              filepath.get_path,
              padding = { left = 0, right = 0 },
              color = {fg = util.darken(string.format("#%06x", utils.getHl("Comment").foreground), 1.0) },
              cond = not_in_filetypes({ 'oil' })
            }
          },
          lualine_y = {
            {
              my_filename, colored = true,
              color = {fg = util.lighten(string.format("#%06x", utils.getHl("Function").foreground), 0.8)},
              -- color = {fg = string.format("#%06x", utils.getHl("Function").foreground) }
              separator = {left = '' },
              -- separator = {},
              -- padding = { left = 1, right = 1 },
              cond = not_in_filetypes({ 'oil' })
            },
          },
          lualine_z = {}
        },
        inactive_winbar = {
          lualine_a = {},
          lualine_b = {
            -- {
              -- my_filename, colored = true,
              -- cond = not_in_filetypes({ 'oil' })
            -- },
          },
          lualine_c = {},
          lualine_x = {
            { 
              filepath.get_path,
              padding = { left = 0, right = 0 },
              color = {fg = util.darken(string.format("#%06x", utils.getHl("Comment").foreground), 1.0) },
              cond = not_in_filetypes({ 'oil' })
            }
          },
          lualine_y = {
            {
              my_filename, colored = true,
              -- color = {fg = 'Normal' }
              color = {fg = util.darken(string.format("#%06x", utils.getHl("Normal").foreground), 0.8) }
            }
          },
          lualine_z = {}
        },
        -- inactive_winbar = {},
        extensions = {}
      }

      local hl_groups = vim.fn.getcompletion('Navic*', 'highlight')
      local bgcolor = vim.api.nvim_get_hl_by_name('lualine_c_normal', true).background

      for _, group in ipairs(hl_groups) do
        local hl = vim.api.nvim_get_hl_by_name(group, true)
        hl.background = bgcolor
        vim.api.nvim_set_hl(0, group, hl)
      end
      -- vim.api.nvim_set_hl(0, "lualine_b_normal", { bg = 'red'})
      -- vim.api.nvim_set_hl(0, "WinBarPath", { fg = f.getHl("LineNR").fg, bg = bgcolor })


    end,
  },
  { 'rcarriga/nvim-notify', -- Notification window
    event = 'VeryLazy',
    config = function()
      local notify = require("notify")
      notify.setup {
        -- top_down = false,
        -- render = "minimal"
        stages = "static"
      }
      vim.notify = notify
    end
  },
  { 'linrongbin16/lsp-progress.nvim',
    -- lazy = true,
    config = function()
      require('lsp-progress').setup {
        client_format = function(client_name, spinner, series_messages)
          if #series_messages == 0 then
            return nil
          end
          return {
            name = client_name,
            body = spinner .. " " .. table.concat(series_messages, ", "),
          }
        end,
        format = function(client_messages)
          --- @param name string
          --- @param msg string?
          --- @return string
          local function stringify(name, msg)
            return msg and string.format("%s %s", name, msg) or name
          end

          local sign = "" -- nf-fa-gear \uf013
          local lsp_clients = vim.lsp.get_clients()
          local messages_map = {}
          for _, climsg in ipairs(client_messages) do
            messages_map[climsg.name] = climsg.body
          end

          if #lsp_clients > 0 then
            table.sort(lsp_clients, function(a, b)
              return a.name < b.name
            end)
            local builder = {}
            for _, cli in ipairs(lsp_clients) do
              if
                type(cli) == "table"
                and type(cli.name) == "string"
                and string.len(cli.name) > 0
              then
                if messages_map[cli.name] then
                  table.insert(builder, stringify(cli.name, messages_map[cli.name]))
                -- else
                  -- table.insert(builder, stringify(cli.name))
                  -- table.insert(builder, '')
                end
              end
            end
            if #builder > 0 then
              -- return sign .. " " .. table.concat(builder, ", ")
              return table.concat(builder, ", ")
            end
          end
          return ""
        end,
      }
    end,
  },
  { 'lewis6991/gitsigns.nvim', -- Show git diff, etc.
    event = "VeryLazy",
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = { { "<leader>gg", ":Gitsigns toggle_signs<cr>" } },
    cmd = "Gitsigns",
    opts = {
      signcolumn = true,
    },
  },
  { 'folke/which-key.nvim', -- Show keymaps
    event = "VeryLazy",
    opts = {
      preset = "helix",
      delay = 1000,
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      spec = {
        {"<leader>d", group = "Debug & Diagnostics"},
        {"<leader>g", group = "Git"},
        {"<leader>s", group = "Session"},
      },
    },
    cmd = "WhichKey",
  },
  -- ### File browser, FZF, Telescope
  { 'stevearc/oil.nvim', -- file explorer as vim buffer. support ssh
    keys = {
      { "<f3>", ":Oil<CR>", mode = { "n", "v" } },
      { "<f3>", "<esc>:Oil<CR>", mode = { "i" } },
    },
    opts = {
      columns = {
        "icon",
        -- "permissions",
        -- "size",
        -- "mtime",
      },
    },
  },
  { 'kyazdani42/nvim-tree.lua', -- Directory browser
    keys = {
      { Myleader .. "t", ":NvimTreeToggle %:p:h<cr>", desc="NvimTreeToggle" }
    },
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    config = function()
      require 'nvim-tree'.setup({
        sort_by = "case_sensitive",
        view = {
          adaptive_size = false,
          -- mappings = {
            -- list = {
              -- { key = "u", action = "dir_up" },
            -- },
          -- },
        },
        renderer = {
          group_empty = true,
          indent_markers = {
            enable = true
          },
          icons = {
            git_placement = "after",
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
            glyphs = {
              git = {
                untracked = "-",
              },
            },
          },
        },
        filters = {
          dotfiles = false,
        },
        actions = {
          open_file = {
            resize_window = false,
          }
        }
      })

      vim.cmd [[
        function! NvimTreeColor()
          highlight NvimTreeIndentMarker guifg=#58606d gui=nocombine
          highlight NvimTreeImageFile guifg=#58606d gui=nocombine
          highlight NvimTreeExecFile guifg=#58606d gui=nocombine
        endfunction

        augroup NvimTreeCustomHighlight
            autocmd!
            autocmd ColorScheme * call NvimTreeColor() 
        augroup END
        call NvimTreeColor() 
      ]]
    end,
  },
  { 'junegunn/fzf', -- fzf!
    event = "VeryLazy",
    -- lazy = true,
    build = './install --bin'
  },
  { 'supasorn/fzf-mru.vim', -- F4 fzf MRU
    enabled = true,
    lazy = false, -- otherwise, it won't remember any files
    dependencies = "fzf",
    cmd = "FZFMru",
    -- keys = { { "<f4>", ":FZFMru --no-sort<CR>" } },
    keys = { { Myleader .. "p", ":FZFMru --no-sort<CR>", mode = "n" } },
  },
  { 'ibhagwan/fzf-lua', -- fzf with native preview, etc
    cmd = { "FzfLua" },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      { "?", ':lua require("fzf-lua").blines({prompt=" > "})<cr>' },
      { "<s-r>", ':lua require("fzf-lua").command_history({prompt=" > "})<cr>' },
      { Myleader .. "o", ':lua require("fzf-lua").buffers({prompt=" > "})<cr>', mode = "n", desc="buffers"},
      -- { Myleader .. "f", ':lua require("fzf-lua").files()<cr>', mode = "n", desc="find files"},
      -- { Myleader .. "/", ':lua require("fzf-lua").grep_project()<cr>', mode = "n", desc="search"},
      { Myleader .. "f", function() require("files_and_grep_with_filetypes").files() end, mode = "n", desc = "find files" },
      { Myleader .. "/", function() require("files_and_grep_with_filetypes").grep() end, mode = "n", desc = "search" },
      { Myleader .. "d", ':lua require("extra").fzf_change_dir()<cr>', mode = "n", desc="change current directory"},
      { "g/", ':lua require("fzf-lua").grep_visual()<cr>', mode = "v", desc="grep current selection"},
      -- { Myleader .. "/", ':lua require("fzf-lua").grep({rg_opts=vim.g.rgmode_rgopt, cwd=vim.fn.getcwd(), search="", fzf_cli_args=""})<cr>', mode = "n", desc="search"},

    },
    opts = {
      winopts = {
        height = 0.25,
        width = 1,
        row = 1,
        border = 'rounded',
        -- hl = { border = 'FloatBorder', }
        preview = {
          -- layout = 'horizontal',
        },
      },
      keymap = {
        fzf = {
          ["ctrl-q"] = "toggle-all",
        }
      },
      fzf_opts = {
        ['--layout'] = false,
      },
      buffers = {
        previewer = false,
        headers = {},
        fzf_opts={
          ["--delimiter"] = ' ',
          ["--with-nth"] = "-1..",
          ["--header-lines"] = false,
          ["--info"] = 'inline',
        },
        formatter = "path.filename_first",
      },
      oldfiles = {
        previewer = false,
      },
      fzf_colors = {
        ["fg"] = { "fg", "Normal" },
        ["bg"] = { "bg", "Normal" },
      },
      grep = {
        rg_opts = "-g '!tags' --column --line-number --no-heading --color=always --smart-case",
      },
    },
    -- " nmap <f4> :lua require('fzf-lua').oldfiles({prompt="> "})<cr>
  },
  { 'elanmed/fzf-lua-frecency.nvim', -- fzf-lua MRU
    enabled = false,
    lazy = false,
    keys = { { Myleader .. "p", function() require("fzf-lua-frecency").frecency() end, mode = "n" } },
    opts = {
      formatter = "path.filename_first",
      display_score = false,
      previewer = false,
      -- db_dir = vim.fs.joinpath(vim.fn.stdpath "data", "fzf-lua-frecency"),
      db_dir = vim.fs.joinpath(vim.fn.stdpath("config"), "data", "fzf-lua-frecency", vim.loop.os_gethostname()),
      fzf_opts = {
        ["--info"] = 'inline',
      },
    },
  },
  { 'nvim-telescope/telescope.nvim', -- Telescope
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
      { 'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make'
      },
      { 'supasorn/telescope-file-browser.nvim' },
      -- { 'nvim-telescope/telescope-file-browser.nvim' },
      { 'marcuscaisey/olddirs.nvim' },
      { 'junegunn/fzf' },
    },
    cmd = { "Telescope" },
    -- keys = { "<f2>", "gr", "<leader>od" },
    keys = {
      {Myleader .. "i", desc="file browser"},
      {Myleader .. "I", desc="file browser (cwd)"}, -- <-- Add this line
      -- {Myleader .. "d", desc="old directories"},
    },

    config = function()
      local actions = require("telescope.actions")
      require("telescope").setup({
        defaults = {
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
          },
          -- prompt_prefix = "   ",
          selection_caret = "  ",
          entry_prefix = "  ",
          initial_mode = "insert",
          selection_strategy = "reset",
          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
              results_width = 0.8,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          -- file_ignore_patterns = { "node_modules" },
          -- file_sorter = require("telescope.sorters").get_fuzzy_file,
          -- generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
          path_display = { "truncate" },
          winblend = 0,
          border = true,
          borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          color_devicons = true,
          set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,

          mappings = {
            i = { ["<esc>"] = actions.close, },
          },
          extensions = {
            file_browser = {
              theme = "ivy",
              hijack_netrw = false,
            },
            fzf = {
              fuzzy = true, -- false will only do exact matching
              override_generic_sorter = true, -- override the generic sorter
              override_file_sorter = true, -- override the file sorter
              case_mode = "smart_case", -- or "ignore_case" or "respect_case"
              -- the default case_mode is "smart_case"
            },
            olddirs = {
              selected_dir_callback = vim.cmd.lcd,
            }
          },
        },
      })
      require("telescope").load_extension "fzf"
      require("telescope").load_extension "file_browser"
      require("telescope").load_extension "olddirs"

      map({ 'n' }, Myleader .. "i",
        function() require "telescope".extensions.file_browser.file_browser({
            path = '%:p:h',
            -- previewer = true,
            hidden = true,
            hide_parent_dir = true, grouped = true,
            display_stat = false,
            preview = {
              ls_short = true,
            }
          })
        end)

      map({ 'n' }, Myleader .. "I",
        function() require "telescope".extensions.file_browser.file_browser({
            path = vim.fn.getcwd(-1, -1),
            hidden = true,
            hide_parent_dir = true, grouped = true,
            display_stat = false,
            preview = {
              ls_short = true,
            }
          })
        end)
      -- map({ 'n' }, Myleader .. "d", require "telescope".extensions.olddirs.picker, {desc = "old directories"})

      vim.cmd [[

    function! TelescopeColor()
      highlight TelescopeNormal guibg=#202329
      highlight TelescopeResultsBorder guifg=#202329 guibg=#202329 
      highlight TelescopeResultsTitle guifg=#61afef guibg=#202329
      
      highlight TelescopePreviewBorder guifg=#202329 guibg=#202329 
      highlight TelescopePreviewTitle guifg=#181a1f guibg=#e86671
      
      highlight TelescopePromptNormal guibg=#1c1f24
      highlight TelescopePromptBorder guifg=#1c1f24 guibg=#1c1f24 
      highlight TelescopePromptTitle guifg=#1c1f24 guibg=#1c1f24 
    endfunction

    augroup TelescopeCustomHighlight
        autocmd!
        autocmd ColorScheme * call TelescopeColor()
    augroup END
    call TelescopeColor()

    ]]
    end
  },
  { 'echasnovski/mini.files',
    keys = {
      { "<f2>", ":lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>", mode = { "n", "v" } },
      { "<f2>", "<esc>:lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>", mode = { "i" } },
    },
    version = '*',
    config = true,
    opts = {
      mappings = {
        go_in_plus = '<enter>',
      },
    },
  },
  -- ### LSP, Treesitter, Tags
  { "jose-elias-alvarez/null-ls.nvim", -- For adding format() to lsp, etc
    keys = {
      { "<leader>f", vim.lsp.buf.format, mode = { "n", "v" }, desc="format code" }
    },
    config = function()
      -- local map = require("utils").map
      -- map(, "<leader>f", vim.lsp.buf.format)
      require("null-ls").setup({
        sources = {
          -- require("null-ls").builtins.formatting.stylua,
          require("null-ls").builtins.formatting.autopep8.with({
            extra_args = {
              "--indent-size", "2"
            }
          }),
        },
      })
    end
  },
  { 'rmagatti/goto-preview', -- Goto preview with nested!
    -- event = "VeryLazy",
    keys = {
      { "gp", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>" },
      { "gP", "<cmd>lua require('goto-preview').close_all_win()<CR>" },
      -- { "gr", "<cmd>lua require('goto-preview').goto_preview_references()<CR>" }
      { "gr", "<cmd>lua vim.lsp.buf.references()<CR>" }
    },
    opts = {
      -- width = 150,
    },
    dependencies = { 'rmagatti/logger.nvim' },

  },
  { "williamboman/mason.nvim", -- Lsp Installer
    cmd = { "Mason", "MasonLog", "MasonInstall", "MasonUninstall" },
    config = true,
  },
  { 'williamboman/mason-lspconfig.nvim', -- Mason-Lsp interface
    event = "VeryLazy",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed       = { "pyright", "html", "cssls", "eslint", "lua_ls", "clangd" },
    },
  },
  { 'neovim/nvim-lspconfig', -- Lspconfig
    event = "VeryLazy",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "SmiteshP/nvim-navic",    -- you already use this in on_attach
      "hrsh7th/cmp-nvim-lsp",   -- for capabilities
    },
    config = function()
      local lspconfig    = require("lspconfig")
      local navic        = require("nvim-navic")
      -- local capabilities = require("cmp_nvim_lsp")
                           -- .default_capabilities(vim.lsp.protocol
                           -- .make_client_capabilities())
      -- local blink     = require("blink.cmp")

      local function on_attach(client, bufnr)
        if client.server_capabilities.documentSymbolProvider then
          navic.attach(client, bufnr)
        end
        client.server_capabilities.semanticTokensProvider = nil
      end

      -- Default config for all servers
      vim.lsp.config("*", {
        -- capabilities = require("blink.cmp").get_lsp_capabilities(),
        capabilities = require("cmp_nvim_lsp")
                           .default_capabilities(vim.lsp.protocol
                           .make_client_capabilities()),
        on_attach = on_attach,
      })

      -- Language-specific configs

      -- 𝗟𝗨𝗔 (lua_ls)
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = {
              -- library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            completion = { callSnippet = "Replace" },
            telemetry = { enable = false },
          },
        },
      })

      -- 𝗣𝗬𝗥𝗜𝗚𝗛𝗧
      vim.lsp.config("pyright", {
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              diagnosticMode = "openFilesOnly",
              useLibraryCodeForTypes = true,
              typeCheckingMode = "off",
            },
          },
        },
      })

      for _, server in ipairs({ "html", "cssls", "eslint", "clangd" }) do
        vim.lsp.enable(server)
      end
    end,
  },
  { 'majutsushi/tagbar', -- Tagbar! Show code tags
    dependencies = { 'ludovicchabant/vim-gutentags' },
    cmd = "TagbarToggle",
    keys = { { "<f8>", ":TagbarToggle<CR>" } },
  },
  { 'nvim-treesitter/nvim-treesitter',
    lazy = false,
    branch = "main",
    build = ':TSUpdate',
    config = function()
      local ts = require("nvim-treesitter")
      ts.install({ 
        "c", "python", "css", "cpp", "go", "html", "java", "javascript", 
        "json", "lua", "make", "php", "vim", "typescript", "vimdoc", 
        "markdown", "markdown_inline", "yaml", "query" 
      })
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          -- Check if a parser exists for the current filetype
          local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
          if lang then
            pcall(vim.treesitter.start, args.buf, lang)
          end
        end,
      })
    end,
  },
  { "nvim-treesitter/nvim-treesitter-textobjects", -- treesitter textobjects
    enabled = true,
    branch = "main",
    init = function()
      vim.g.no_plugin_maps = true
    end,

    opts = {
      move = {
        set_jumps = true,
      },
      select = {
        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,
        -- You can choose the select mode (default is charwise 'v')
        --
        -- Can also be a function which gets passed a table with the keys
        -- * query_string: eg '@function.inner'
        -- * method: eg 'v' or 'o'
        -- and should return the mode ('v', 'V', or '<c-v>') or a table
        -- mapping query_strings to modes.
        selection_modes = {
          ['@parameter.outer'] = 'v', -- charwise
          ['@function.outer'] = 'V', -- linewise
          -- ['@class.outer'] = '<c-v>', -- blockwise
        },
        -- If you set this to `true` (default is `false`) then any textobject is
        -- extended to include preceding or succeeding whitespace. Succeeding
        -- whitespace has priority in order to act similarly to eg the built-in
        -- `ap`.
        --
        -- Can also be a function which gets passed a table with the keys
        -- * query_string: eg '@function.inner'
        -- * selection_mode: eg 'v'
        -- and should return true of false
        include_surrounding_whitespace = false,
      },
    },
    keys = {
      { "]]", function() require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects") end,
        mode = { "n", "x", "o" },
        desc = "Go to next function start (treesitter textobjects)"
      },
      { "][",
        function() require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer", "textobjects") end,
        mode = { "n", "x", "o" },
        desc = "Go to next function end (treesitter textobjects)"
      },
      { "[[",
        function() require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects") end,
        mode = { "n", "x", "o" },
        desc = "Go to previous function start (treesitter textobjects)"
      },
      { "[]",
        function() require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer", "textobjects") end,
        mode = { "n", "x", "o" },
        desc = "Go to previous function end (treesitter textobjects)"
      },
      { "am",
        function() require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects") end,
        mode = { "x", "o" },
        desc = "Select around function (treesitter textobjects)"
      },
      { "im",
        function() require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects") end,
        mode = { "x", "o" },
        desc = "Select inside function (treesitter textobjects)"
      },
      { "ac",
        function() require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects") end,
        mode = { "x", "o" },
        desc = "Select around class (treesitter textobjects)"
      },
      { "ic",
        function() require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects") end,
        mode = { "x", "o" },
        desc = "Select inside class (treesitter textobjects)"
      },
    },
  },
  { 'daliusd/incr.nvim', -- Treesitter incremental selection
    opts = {
        incr_key = '<CR>', -- increment selection key
        decr_key = '<BS>', -- decrement selection key
    },
  },
  { 'nvim-treesitter/playground', -- Treesitter playground
    cmd = { "TSPlaygroundToggle", "TSHighlightCapturesUnderCursor" }
  },
  { 'folke/trouble.nvim', -- A pretty list for showing diagnostics, refs, quickfix and location lists.
    cmd = { "Trouble", "TroubleToggle", "TroubleClose", "TrobleRefresh" },
    keys = {
      { "<f9>", "<cmd>TroubleToggle document_diagnostics<cr>" }
    },
    opts = {
      position = "right",
      signs = {
        error = "",
        warning = "",
        hint = "",
        information = "",
        other = "﫠"
      },
    }
  },
  { 'kevinhwang91/nvim-bqf', -- make quickfix list fancy, preview, fzf
    event = "VeryLazy",
    opts = {
    }
  },
  -- ### Debugger (DAP) & Compiler
  { 'igorlfs/nvim-dap-view', -- UI for nvim-dap
    lazy = true,
    opts = {
      winbar = {
        controls = {
          enabled = true,
          buttons = {
            "step_out",
            "play",
            "step_over",
            "step_into",
            "terminate",
          },
          custom_buttons = {},
        },
      },
      icons = {
        disabled = "",
        disconnect = "",
        enabled = "",
        filter = "󰈲",
        negate = " ",
        pause = "",
        play = " 5",
        run_last = "",
        step_back = "",
        step_into = " 7",
        step_out = " 4",
        step_over = " 6",
        terminate = "",
      },
    },
  },
  { 'mfussenegger/nvim-dap', -- debugger
    dependencies = {
      'rcarriga/nvim-dap-ui', -- (Optional: for a nice UI)
      'nvim-neotest/nvim-nio',
      'igorlfs/nvim-dap-view'
    },
    keys = {
      { "<leader>b", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      -- { "<leader>r", function() require("extra").RunDebugFromComment() end,         desc = "Start/Continue Debugging" },
      { "<F4>", function() require("dap").step_out() end, desc = "Step Out" },
      -- { "<F5>", function() require("dap").continue() require("dapui").open() end,         desc = "Start/Continue Debugging" },
      -- { "<F5>", "<cmd>DapContinue<CR><cmd>DapViewOpen<CR>",         desc = "Start/Continue Debugging" },
      { "<F5>", function() require("dap").continue() vim.cmd("DapViewOpen") end, desc = "Start/Continue Debugging" },
      { "<leader>t", function() require("dap").terminate() end, desc = "Terminate Debugging" },
      { "<F6>", function() require("dap").step_over() end,        desc = "Step Over" },
      { "<F7>", function() require("dap").step_into() end,        desc = "Step Into" },
      -- { "<leader>du", function() require("dapui").toggle() end,         desc = "toggle dapui" },
      { "<leader>du", "<cmd>DapViewToggle<CR>",         desc = "Toggle Debug UI" },
      { "<leader>de", function() require("dapui").eval() end,         desc = "Evaluate" },
    },
    init = function() 
      local grp = vim.api.nvim_create_augroup("dap_colors", { clear = true })
      vim.fn.sign_define('DapBreakpoint',          { text='', texthl='DapBreakpoint',          linehl='DapBreakpoint',          numhl='DapBreakpoint' })
      vim.fn.sign_define('DapBreakpointCondition', { text='ﳁ', texthl='DapBreakpoint',          linehl='DapBreakpoint',          numhl='DapBreakpoint' })
      vim.fn.sign_define('DapBreakpointRejected',  { text='', texthl='DapBreakpointRejected',  linehl='DapBreakpointRejected',  numhl='DapBreakpointRejected' })
      vim.fn.sign_define('DapLogPoint',            { text='', texthl='DapLogPoint',            linehl='DapLogPoint',            numhl='DapLogPoint' })
      vim.fn.sign_define('DapStopped',             { text='', texthl='DapStopped',             linehl='DapStoppedLine',         numhl='DapStopped' })


      vim.api.nvim_create_autocmd("ColorScheme", {
        group = grp,
        pattern = "*",
        desc = "Set DAP marker colors and prevent theme from resetting them",
        -- nested + schedule makes this run *after* theme's own ColorScheme logic
        nested = true,
        callback = function()
          vim.schedule(function()
            local sign_column_hl = vim.api.nvim_get_hl(0, { name = 'SignColumn' })
            local sign_column_bg = (sign_column_hl.bg ~= nil) and ('#%06x'):format(sign_column_hl.bg) or 'bg'
            local sign_column_ctermbg = (sign_column_hl.ctermbg ~= nil) and sign_column_hl.ctermbg or 'Black'
            vim.api.nvim_set_hl(0, 'DapStopped',             { fg = '#00ff00', bg = sign_column_bg, ctermbg = sign_column_ctermbg })
            vim.api.nvim_set_hl(0, 'DapStoppedLine',         { bg = '#2e4d3d', ctermbg = 'Green' })
            vim.api.nvim_set_hl(0, 'DapBreakpoint',          { fg = '#c23127', bg = sign_column_bg, ctermbg = sign_column_ctermbg })
            vim.api.nvim_set_hl(0, 'DapBreakpointRejected',  { fg = '#888ca6', bg = sign_column_bg, ctermbg = sign_column_ctermbg })
            vim.api.nvim_set_hl(0, 'DapLogPoint',            { fg = '#61afef', bg = sign_column_bg, ctermbg = sign_column_ctermbg })
          end)
        end,
      })

      -- executing the settings explicitly for the first time
      vim.api.nvim_exec_autocmds("ColorScheme", { group = "dap_colors" })
    end,
    config = function()
      local dap = require("dap")

      -- Python adapter
      dap.adapters.python = {
        type = "server",
        host = "127.0.0.1",
        port = 5678,
      }

      -- Debugpy attach configuration
      dap.configurations.python = {
        {
          type = "python",
          request = "attach",
          name = "Attach to remote debugpy",
          connect = {
            host = "127.0.0.1",
            port = 5678,
          },
          pathMappings = {
            {
              localRoot = function() return vim.fn.getcwd(-1, -1) end,
              remoteRoot = "." -- remote path
            },
          },
        },
      }

      dap.adapters.lldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = vim.fn.stdpath("data")
            .. "/mason/packages/codelldb/extension/adapter/codelldb",
          args = { "--port", "${port}" },
        },
      }

      require("dapui").setup({
        layouts = {
          {
            elements = {
              "repl",
              "breakpoints",
              "stacks",
              "watches",
            },
            size = 40, position = "right",
          },
        },
        controls = {
          enabled = true,     -- allowed because "repl" exists
          element = "repl",   -- default; could omit
        },
      })

      -- local dapui = require("dapui")
        -- local eval_timer = nil

      -- local function show_hover_value()
          -- if not dap.session() then return end
          -- dapui.eval(nil, { enter = false })
      -- end

      -- vim.o.updatetime = 500  -- makes CursorHold trigger faster
      -- vim.api.nvim_create_autocmd("CursorHold", {
        -- pattern = "*",
        -- callback = function()
          -- if eval_timer then
            -- eval_timer:stop()
            -- eval_timer:close()
          -- end
          -- eval_timer = vim.loop.new_timer()
          -- eval_timer:start(100, 0, vim.schedule_wrap(show_hover_value))
        -- end,
      -- })

    end,
  },
  -- ### All things cmp-related (autocomplete)
  { "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lsp",
      { "onsails/lspkind.nvim"},
    },
    config = function()
      local has_words_before = function()
        table.unpack = table.unpack or unpack
        local line, col = table.unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end
      local cmp = require 'cmp'

      cmp.register_source("lsp_symbols_cmdline", require("cmp_lsp_symbols").new())
      cmp.setup({
        formatting = {
          fields = { "kind", "abbr", "menu" }, -- "abbr" is the actual text

          format = function(entry, vim_item)
            local item = require("lspkind").cmp_format({
              mode = "symbol_text",
              maxwidth = 50,
              ellipsis_char = "...",
            })(entry, vim_item)

            local icon = item.icon or ""
            local kind_text = item.kind or ""

            item.kind = " " .. icon
            item.menu = " (" .. kind_text .. ")"

            -- avoid showing a separate "icon" column if cmp decides to render it
            item.icon = nil
            return item
          end,

        },
        window = {
          completion = cmp.config.window.bordered({
            winhighlight = "Normal:Normal,FloatBorder:CmpItemAbbrMatch,Search:None",
            col_offset = -3,
            side_padding = 0,

            -- col_offset = -2,
            -- border = "none",
            -- winhighlight = "Normal:Pmenu",
            border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
            -- border = { "", "", "", "│", "╯", "─", "╰", "│" },
          }),
          documentation = cmp.config.window.bordered({
            winhighlight = "Normal:Normal,FloatBorder:Directory,Search:None",
            border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
          }),
        },
        mapping = {
          -- ["<cr>"] = cmp.mapping.confirm({ select = false }),

          ["<CR>"] = cmp.mapping(function(fallback)
            local cmp = require("cmp")

            if not cmp.visible() then
              return fallback()
            end

            local entry = cmp.get_selected_entry()
            if not entry or entry.source.name ~= "lsp_symbols_cmdline" then
              return fallback()
            end

            local item = entry:get_completion_item()
            local sym = item and item.data and item.data.sym
            if not sym then
              return fallback()
            end

            local r = sym.selectionRange or sym.range

            -- close cmp menu
            cmp.close()

            -- abort the / search
            vim.api.nvim_feedkeys(
              vim.api.nvim_replace_termcodes("<C-c>", true, false, true),
              "n",
              true
            )

            -- defer jump until cmdline fully exits
            vim.schedule(function()
              vim.api.nvim_win_set_cursor(0, {
                r.start.line + 1,
                r.start.character,
              })
              vim.cmd("normal! zz")
            end)
          end, { "c" }),



          -- ["<s-tab>"] = cmp.mapping.select_prev_item(),
          -- ["<tab>"] = cmp.mapping.select_next_item(),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { "i", "s" }),
          ['<C-e>'] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
          }),
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp', max_item_count = 15 },
          { name = 'buffer', max_item_count = 15 },
          { name = 'path' },
        })
      })

      cmp.setup.filetype('gitcommit', {
        sources = cmp.config.sources({
          { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
        }, {
          { name = 'buffer' },
        })
      })

      -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline('/', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer', max_item_count = 5 },
          { name = "lsp_symbols_cmdline" },
        },
        formatting = {
          -- fields = { "abbr" },
          fields = { "abbr", "kind", "menu" }, -- "abbr" is the actual text
        },
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'cmdline', max_item_count = 10 },
          -- { name = 'path'}
        }),
        formatting = {
          fields = { 'abbr' },
        },
      })

      vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#61afef", bg = "NONE" })

    end,
  },
  { 'Saghen/blink.cmp', -- completion engine. right now has this bug where searching "bqf" in "nvim-bqf" doesn't work
    enabled = false,
    version = '1.*',
    opts = {
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer', 'codecompanion' },
        providers = {
          codecompanion = {
            name = "CodeCompanion",
            module = "codecompanion.providers.completion.blink",
            enabled = true,
            -- Force blink to show the menu immediately when these are typed
            score_offset = 100, -- Give it higher priority
            transform_items = function(ctx, items)
              for _, item in ipairs(items) do
                -- If the menu was triggered by # or @, prepend it to the label
                if ctx.trigger.initial_character == "#" or ctx.trigger.initial_character == "@" then
                  item.label = ctx.trigger.initial_character .. item.label
                end
              end
              return items
            end,
          },
        },
      },
      keymap = {
        preset = 'none',
        ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
        ['<CR>'] = { 'select_and_accept', 'fallback' },
      },
      completion = { 
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 500,
        },
      },
      cmdline = {
        keymap = {
          ['<CR>'] = { 'accept_and_enter', 'fallback' },
        },
        sources = function()
          local type = vim.fn.getcmdtype()
          -- Search mode: use 'buffer' to find your plugin strings
          if type == '/' or type == '?' then return { 'buffer' } end
          -- Command mode: use 'cmdline' for commands
          if type == ':' then return { 'cmdline' } end
          return {}
        end,
        completion = {
          list = {
            selection = {
              preselect = false,
              auto_insert = true,
            },
          },
          menu = { auto_show = true },
        },
      },
    },
    config = function(_, opts)
      local function set_blink_highlights()
        local visual_hl = vim.api.nvim_get_hl(0, { name = 'Visual' })
        vim.api.nvim_set_hl(0, 'BlinkCmpMenuSelection', {
          bg = visual_hl.bg,
          fg = 'NONE',
          bold = true
        })
        -- -- Optional: Ensure the fuzzy match is linked to a bright color (like Keyword)
        -- vim.api.nvim_set_hl(0, 'BlinkCmpLabelMatch', { link = 'Keyword', bold = true })
      end

      set_blink_highlights()

      vim.api.nvim_create_autocmd('ColorScheme', {
        callback = set_blink_highlights,
      })
      require('blink.cmp').setup(opts)
    end,
  },
  -- ### Utilities
  { 'dstein64/vim-startuptime', -- Profiles startup time
    cmd = "StartupTime"
  },
  { 'tpope/vim-eunuch', -- :Rename :Delete :SudoWrite
    cmd = { "Remove", "Delete", "Move", "SudoWrite", "SudoEdit", "Chmod", "Mkdir", "Rename" }
  },
  { 'lambdalisue/vim-suda',
    cmd = { "SudaWrite" }
  },
  { 'wesQ3/vim-windowswap', -- \ww swap two windows
    keys = {{"<leader>ww", desc="swap two windows"}}
  },
  { 'tpope/vim-fugitive', -- For git
    keys = {
      { "<leader>gs", ":Git<cr>", desc="git" },
      { "<leader>gc", ':Git commit -m "auto commit"<cr>', desc="git auto commit" },
      { "<leader>gp", ":Git push<cr>", desc="git push" },
      { "<leader>gq", 'gq :Git commit -m "auto commit" | Git push<cr>', remap = true, desc="git commit + push"},
    },
    cmd = { "Git" },
  },
  { 'sindrets/diffview.nvim', -- for git diff
    cmd = {'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles', 'DiffviewFocusFiles', 'DiffviewRefresh'},
  },
  { "gennaro-tedesco/nvim-possession", -- save session
    event = "VeryLazy",
    dependencies = {
        "ibhagwan/fzf-lua",
    },
    keys = {
      { "<leader>sl", function() require("nvim-possession").list() end, desc = "📌List sessions", },
        { "<leader>ss", function() require("nvim-possession").new() end, desc = "📌Save a new session", },
        { "<leader>su", function() require("nvim-possession").update() end, desc = "📌Update current session", },
        { "<leader>sd", function() require("nvim-possession").delete() end, desc = "📌Delete selected session"},
    },
    opts = {
      fzf_winopts = {
        -- any valid fzf-lua winopts options, for instance
        -- width = 30,
        width = 1,
        height = 0.25,
        preview = {
          horizontal = "right:30%"
        }
      }
    },
    config = function(_, opts)
      local session_dir = vim.fn.stdpath("data") .. "/sessions"
      if vim.fn.isdirectory(session_dir) == 0 then
        vim.fn.mkdir(session_dir, "p")
      end
      require("nvim-possession").setup(opts)
    end,

  },
  -- ### AI coding
  { 'github/copilot.vim',
    enabled = false and not in_singularity,
    keys = { { "<f10>", "<esc>:Copilot<cr>", mode = { "i" } }, { "<f10>", ":Copilot<cr>", mode = { "n", "v" } } },
    config = function()
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true
      -- vim.g.copilot_filetypes = {
        -- ['*'] = false,
      -- }
      -- vim.g.copilot_tab_fallback = ""
      vim.cmd [[
        imap <silent><script><expr> <c-n> copilot#Accept("\<CR>")
      ]]
    end,
  },
  { 'zbirenbaum/copilot.lua',
    enabled = true and not in_singularity,
    cmd = "Copilot",
    event = "InsertEnter",
    cond = not vim.g.vscode,
    opts = {
      panel = {
        enabled = true,
        auto_refresh = false,
        keymap = {
          jump_prev = "[[",
          jump_next = "]]",
          accept = "<CR>",
          refresh = "gr",
          open = "<M-CR>"
        },
        layout = {
          position = "bottom", -- | top | left | right
          ratio = 0.4
        },
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
        keymap = {
          accept = "<c-n>",
          accept_word = false,
          accept_line = false,
          next = "<c-,>",
          prev = "<c-.>",
          dismiss = "<c-m>",
        },
      },
      filetypes = {
        yaml = false,
        markdown = false,
        help = false,
        gitcommit = false,
        gitrebase = false,
        hgcommit = false,
        svn = false,
        cvs = false,
        ["."] = false,
      },
      copilot_node_command = 'node', -- Node.js version must be > 18.x
      server_opts_overrides = {},
    },
  },
  { 'olimorris/codecompanion.nvim',
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "ravitemer/codecompanion-history.nvim"
    },
    enabled=true and not in_singularity,
    opts = {
      ignore_warnings = true,
      extensions = {
        history = {
          enabled = true,
          opts = {
            keymap = "gh",
            save_chat_keymap = "sc",
            auto_save = false,
          },
        }
      }
    },
    keys = {
      { Myleader .. "c", "<cmd>CodeCompanionChat toggle<CR>", mode = "n", desc = "Code Companion" },
      { Myleader .. "c", ":CodeCompanionChat add<CR>", mode = "v", desc = "Code Companion (visual)" },
    },
  },
  { "yetone/avante.nvim",
    enabled=false and not in_singularity,
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    -- ⚠️ must add this setting! ! !
    build = function()
      -- conditionally use the correct build system for the current OS
      if vim.fn.has("win32") == 1 then
        return "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      else
        return "make"
      end
    end,
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    ---@module 'avante'
    ---@type avante.Config
    opts = {
      provider = "copilot",
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "echasnovski/mini.pick", -- for file_selector provider mini.pick
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "stevearc/dressing.nvim", -- for input provider dressing
      "folke/snacks.nvim", -- for input provider snacks
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
  { "folke/sidekick.nvim", -- next edit suggestions and AI CLI
    enabled = false,
    opts = {
      -- add any options here
      cli = {
        mux = {
          backend = "tmux",
          enabled = true,
        },
      },
    },
    keys = {
      {
        "<tab>",
        function()
          -- if there is a next edit, jump to it, otherwise apply it if any
          if not require("sidekick").nes_jump_or_apply() then
            return "<Tab>" -- fallback to normal tab
          end
        end,
        expr = true,
        desc = "Goto/Apply Next Edit Suggestion",
      },
      {
        "<c-.>",
        function()
          require("sidekick.cli").focus()
        end,
        mode = { "n", "x", "i", "t" },
        desc = "Sidekick Switch Focus",
      },
      {
        "<leader>aa",
        function()
          require("sidekick.cli").toggle({ focus = true })
        end,
        desc = "Sidekick Toggle CLI",
        mode = { "n", "v" },
      },
      {
        "<leader>ac",
        function()
          require("sidekick.cli").toggle({ name = "claude", focus = true })
        end,
        desc = "Sidekick Claude Toggle",
        mode = { "n", "v" },
      },
      {
        "<leader>ag",
        function()
          require("sidekick.cli").toggle({ name = "grok", focus = true })
        end,
        desc = "Sidekick Grok Toggle",
        mode = { "n", "v" },
      },
      {
        "<leader>ap",
        function()
          require("sidekick.cli").select_prompt()
        end,
        desc = "Sidekick Ask Prompt",
        mode = { "n", "v" },
      },
    },
  },
}

set nocompatible
filetype off
let mapleader=","
set t_Co=256

call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')
Plug 'nvim-lualine/lualine.nvim' 
Plug 'majutsushi/tagbar'
Plug 'preservim/nerdtree'
Plug 'simnalamburt/vim-mundo'
Plug 'scrooloose/nerdcommenter'
Plug 'godlygeek/tabular'
Plug 'junegunn/vim-easy-align'
Plug 'kien/ctrlp.vim'
Plug 'tpope/vim-fugitive'


" Colors
Plug 'ayu-theme/ayu-vim'
Plug 'dadgar/vim-luna'
Plug 'chriskempson/tomorrow-theme', {'rtp': 'vim/'}
Plug 'sainnhe/edge'
Plug 'sainnhe/sonokai'
Plug 'Mofiqul/dracula.nvim'

" Completion
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

" For vsnip users.
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

Plug 'akinsho/bufferline.nvim'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'ryanoasis/vim-devicons'

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

Plug 'simrat39/rust-tools.nvim'
call plug#end()



" Light colorscheme
let ayucolor="light"
"colorscheme ayu

" Colorscheme
set termguicolors
let g:sonokai_style = 'maia'
let g:sonokai_enable_italic = 1
" colorscheme sonokai
colorscheme dracula

" NerdTree
map <C-e> :NERDTreeToggle<CR>:NERDTreeMirror<CR>
map <leader>e :NERDTreeFind<CR>
nmap <leader>nt :NERDTreeFind<CR>
let NERDTreeIgnore=['\.class', '\.pyc', '\~$', '\.swo$', '\.swp$', '\.git', '\.hg', '\.svn', '\.bzr', '\.o']
let NERDTreeQuitOnOpen=1

set completeopt=menu,menuone,noselect
set shortmess+=c

" Line num and position
set relativenumber
set number
set ruler
set scrolloff=5 " Number of lines above or bellow the current line

" Highlighting
set hlsearch
set incsearch
set ignorecase

"Indents
set smartindent
set smarttab
set smartcase
set autoindent
set expandtab
set tabstop=4

" Keep selection after tab adjust
vnoremap < <gv
vnoremap > >gv

" Syntax
syntax on
filetype plugin indent on
set showmatch

" Wrapping
set textwidth=80
set fo+=t
set nowrap

" Buffer navigation
map <Leader>bn :bn<cr>
map <Leader>bp :bp<cr>
map <Leader>bd :Bdelete<cr>

" List navigation
map <Leader>ll :lfirst<cr>
map <Leader>ln :lnext<cr>
map <Leader>lp :lprevious<cr>

" MISC
set shortmess+=filmnrxoOtT " Abbreviate and avoid hit enter
set virtualedit=onemore    " Allow for cursor beyond last character
imap jj <Esc>
set wildmenu
set wildignore+=*.o,*.so,*.swp,*.zip,*.class,*.pyc
set autowriteall " Automatically writes when switching buffers
set updatetime=4000
set backspace=2
set ttyfast
set lazyredraw

" Use system clipboard
set clipboard=unnamed

" Configure LSP through rust-tools.nvim plugin.
" rust-tools will configure and enable certain LSP features for us.
" See https://github.com/simrat39/rust-tools.nvim#configuration
lua <<EOF
local nvim_lsp = require'lspconfig'

local opts = {
    tools = { -- rust-tools options
        autoSetHints = true,
        hover_with_actions = true,
        inlay_hints = {
            show_parameter_hints = false,
            parameter_hints_prefix = "",
            other_hints_prefix = "",
        },
    },

    -- all the opts to send to nvim-lspconfig
    -- these override the defaults set by rust-tools.nvim
    -- see https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rust_analyzer
    server = {
        -- on_attach is a callback called when the language server attachs to the buffer
        -- on_attach = on_attach,
        settings = {
            -- to enable rust-analyzer settings visit:
            -- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
            ["rust-analyzer"] = {
                -- enable clippy on save
                checkOnSave = {
                    command = "clippy"
                },
            }
        }
    },
}

require('rust-tools').setup(opts)
EOF


lua <<EOF
  -- Setup nvim-cmp.
  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      end,
    },
    mapping = {
      ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
      ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
      ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
      ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
      ['<C-e>'] = cmp.mapping({
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
      }),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    },
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' }, -- For vsnip users.
      { name = 'path' }, -- For vsnip users.
      { name = 'buffer' },
    })
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline('/', {
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

EOF


" LuaLine
lua <<EOF
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'dracula-nvim',
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch'},
    lualine_c = {
      {
        'filename',
        file_status = true, -- displays file status (readonly status, modified status)
        path = 1 -- 0 = just filename, 1 = relative path, 2 = absolute path
      }
    },
    lualine_x = {
      {
        'diff',
        colored = true, -- displays diff status in color if set to true
        -- all colors are in format #rrggbb
        color_added = '#46c726', -- changes diff's added foreground color
        color_modified = nil, -- changes diff's modified foreground color
        color_removed = nil, -- changes diff's removed foreground color
        symbols = {added = '+', modified = '~', removed = '-'} -- changes diff symbols
      }
    },
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  extensions = {
    'nerdtree',
    'fugitive',
  },
}
EOF

" BufferLine
lua <<EOF
require("bufferline").setup{
  diagnostics = "nvim_lsp",
}
EOF

" NVIM Dev Icons
lua << EOF
  require'nvim-web-devicons'.setup {
    default = true;
  }
EOF


" Treesitter highligting
lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = {"rust"},
  highlight = {
    enable = true,
  },
  refactor = {
    highlight_definitions = { enable = true },
    highlight_current_scope = { enable = true },
  },
  indent = {
    enable = true
  },
}
EOF

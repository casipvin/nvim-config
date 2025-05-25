-- Instalacja Lazy.nvim jeśli nie jest zainstalowany
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "  -- Ustawia spację jako główny Leader
vim.g.maplocalleader = " "  -- Opcjonalnie: dla lokalnych mapowań

vim.opt.number = true -- Włącza numerację wierszy
-- vim.opt.relativenumber = true  Włącza numerację względną
vim.cmd("highlight CursorLineNr guifg=#ffffff gui=bold") -- Pogrubienie numeru aktualnego wiersza
vim.opt.cursorline = true -- Podświetlenie całego wiersza


-- Instalacja wtyczek
require("lazy").setup({
  { "neovim/nvim-lspconfig" }, -- LSP
  { "hrsh7th/nvim-cmp", dependencies = { "hrsh7th/cmp-nvim-lsp" } }, -- Silnik autouzupełniania
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } }, -- Telescop
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" }, -- Podświetlenie kodu
  { "rebelot/kanagawa.nvim" }, -- Motyw Kanagawa
  { "nvim-neo-tree/neo-tree.nvim", dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" }}, -- Drzewo katalogów
  { "MunifTanjim/nui.nvim" }, -- Interfejs, m.in. do drzewa
  { "akinsho/bufferline.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } }, -- Dodaje X d tab
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } }, -- Stylizowanie status bar
  {"tpope/vim-fugitive" }, -- Git Fugitive
  { "folke/noice.nvim", dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" } }, -- Ulepszenie paska poleceńd
  {"lukas-reineke/indent-blankline.nvim", -- Blok kodu
  main = "ibl",
  opts = {}
 },
 {
  "nvim-treesitter/nvim-treesitter-context", -- Funkcja u góry
  opts = {}
},
  -- Code Runner
  { "CRAG666/code_runner.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
       config = function()
       require("code_runner").setup({
           mode = "float",
           float = {
           border = "rounded", -- Zaokrąglone krawędzie okna
           height = 0.8, -- Wysokość okna (np. 80% ekranu)
           width = 0.8, -- Szerokość okna (np. 80% ekranu)
           x = 0.5, -- Pozycja X (środek ekranu)
           y = 0.5, -- Pozycja Y (środek ekranu)
                    },
           focus = true,
           filetype = {
             python = "python $file",
             cpp = "g++ $file -o $fileNameWithoutExt && ./$fileNameWithoutExt",
             lua = "lua $file",
                       },
                       })
                end,
  },
})

-- Skrót do Code Runner 
vim.api.nvim_set_keymap("n", "<F5>", ":w<CR>:RunCode<CR>", { noremap = true, silent = true })

-- Konfiguracja LSP
local lspconfig = require("lspconfig")

lspconfig.pyright.setup{}  -- Python
lspconfig.lua_ls.setup{}   -- Lua
lspconfig.clangd.setup{}   -- C/C++
lspconfig.html.setup{}     -- HTML
lspconfig.cssls.setup{}    -- CSS
lspconfig.ts_ls.setup{} -- JavaScript/TypeScript

-- Konfiguracja Treesitter
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "python", "lua", "c", "cpp", "html", "css", "javascript" },
  highlight = { enable = true },
}

-- Ustawienia Telescope
require("telescope").setup({
  defaults = {
    file_ignore_patterns = { "node_modules", ".git" }, -- Ignorowanie niepotrzebnych katalogów
    preview = {
      hide_on_startup = false, -- Podgląd plików od razu widoczny
    },
  },
})

-- Skrót klawiszowy do wyszukiwania plików w Telescope
vim.api.nvim_set_keymap("n", "<leader>f", ":Telescope find_files<CR>", { noremap = true, silent = true })


-- Ustawienie motywu Kanagawa
require("kanagawa").setup({
  theme = "wave",  -- Możesz zmienić na "dragon" lub "lotus"
  transparent = false,
  dimInactive = true,
})
vim.cmd.colorscheme "kanagawa"

-- Automatyczne zamykanie nawiasów i klamr
vim.api.nvim_set_keymap("i", "(", "()<Left>", { noremap = true })
vim.api.nvim_set_keymap("i", "[", "[]<Left>", { noremap = true })
vim.api.nvim_set_keymap("i", "{", "{}<Left>", { noremap = true })
vim.api.nvim_set_keymap("i", "'", "''<Left>", { noremap = true })
vim.api.nvim_set_keymap("i", "\"", "\"\"<Left>", { noremap = true })

-- Enter wewnątrz klamr dodaje nową linię z odpowiednim wcięciem
vim.api.nvim_set_keymap("i", "{<CR>", "{<CR>}<Esc>O", { noremap = true })

-- Autouzupełnianie
local cmp = require("cmp")
local cmp_nvim_lsp = require("cmp_nvim_lsp")

-- Konfiguracja nvim-cmp dla autouzupełniania
cmp.setup({
  mapping = {
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  },
  sources = {
    { name = "nvim_lsp" },  -- Autouzupełnianie z LSP
    { name = "buffer" },    -- Autouzupełnianie na podstawie zawartości pliku
    { name = "path" },      -- Autouzupełnianie ścieżek plików
  },
})

-- Funkcja do przypisania autouzupełniania do każdego LSP
local capabilities = cmp_nvim_lsp.default_capabilities()
local lspconfig = require("lspconfig")

local servers = { "pyright", "lua_ls", "clangd", "html", "cssls", "ts_ls" }
for _, server in ipairs(servers) do
  lspconfig[server].setup({
    capabilities = capabilities,
  })
end

-- Linia do bloku kodu
require("ibl").setup {
  indent = { char = "│" },
}

-- Funkcja u góry
require("treesitter-context").setup {
  enable = true, -- Włącz podgląd funkcji
  max_lines = 3, -- Liczba wyświetlanych linii kontekstu
  trim_scope = "outer", -- Przycinanie długich nazw
}

-- Ustawienia drzewa plików
require("neo-tree").setup({
  filesystem = {
    follow_current_file = {enabled = true}, -- Automatyczne podświetlanie aktualnego pliku
    hijack_netrw_behavior = "open_current", -- Zastępuje domyślne netrw
  },
})

-- Skrót klawiszowy do otwierania drzewa katalogów
vim.api.nvim_set_keymap("n", "<C-e>", ":Neotree toggle<CR>", { noremap = true, silent = true })


-- Ustawienia X przy tab
require("bufferline").setup({
  options = {
    close_command = "bdelete! %d",
    right_mouse_command = "bdelete! %d",
    show_close_icon = true,
    separator_style = "slant", -- Możesz zmienić na "thick", "thin"
  },
})

-- Nowy tab
vim.api.nvim_set_keymap("n", "<C-t>", ":tabnew<CR>", { noremap = true, silent = true })
-- Zamykanie tabu
vim.api.nvim_set_keymap("n", "<C-x>", ":bdelete!<CR>:tabnext<CR>", { noremap = true, silent = true })
-- Przechodzenie do poprzedniego taba
vim.api.nvim_set_keymap("n", "<C-z>", ":tabprevious<CR>", { noremap = true, silent = true })
 -- Przechodzenie do następnego taba
vim.api.nvim_set_keymap("n", "<C-c>", ":tabnext<CR>", { noremap = true, silent = true }) 

-- Ustawienia stylizacji status bar
require("lualine").setup({
  options = {
    theme = "kanagawa", -- Możesz zmienić na np. "tokyonight", "catppuccin", "onedark", "gruvbox"
    section_separators = { left = "", right = "" },
    component_separators = { left = "", right = "" },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff", "diagnostics" },
    lualine_c = { "filename" },
    lualine_x = { "encoding", "fileformat", "filetype" },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
})

-- Ustawienia paska poleceń
require("noice").setup({
  cmdline = {
    enabled = true, -- Włącza pasek poleceń
    view = "cmdline_popup", -- Wyświetla polecenia w środku ekranu
    format = {
      cmdline = { pattern = "^:", icon = "", lang = "vim" },
    },
  },
  messages = {
    enabled = true, -- Ulepszone wyświetlanie komunikatów
  },
  popupmenu = {
    enabled = true, -- Włącza menu podpowiedzi
  },
})

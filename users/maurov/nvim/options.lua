vim.opt.hlsearch = false                         -- incremental search
vim.opt.mouse = "a"                             -- enable mouse
--
-- do not sync with OS clipboard by default so we keep nvim
-- and system clipboard's separate
-- See keymaps for a way to yank to the system clipboard
-- vim.opt.clipboard = "unnamedplus"               -- use OS's clipboard
--
vim.opt.fileencoding = "utf-8"                  -- use utf-8 by default
vim.opt.splitright = true                       -- use utf-8 by default
vim.opt.diffopt:append("vertical")
vim.opt.termguicolors = true                    -- use utf-8 by default
vim.opt.swapfile = false                        -- use utf-8 by default
vim.opt.expandtab = true                        -- expand tabs to spaces
vim.opt.number = true                           -- expand tabs to spaces
vim.opt.relativenumber = true                   -- expand tabs to spaces
vim.opt.wrap = false                            -- expand tabs to spaces
vim.opt.conceallevel = 0                        -- make `` show in markdown
vim.opt.gdefault = true                         -- global search and replace by default
vim.opt.list = true                             -- show hidden characters
vim.opt.listchars = { tab ='› ', trail = '•', extends = '#', nbsp = '.' }
vim.opt.ignorecase = true                       -- case insensitive search

vim.opt.cursorcolumn = false
vim.opt.cursorline = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

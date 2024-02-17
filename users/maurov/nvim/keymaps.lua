local keymap = vim.keymap.set
local opts = { silent = true }

-- copilot
vim.cmd[[imap <silent><script><expr> <C-y> copilot#Accept("\<CR>")]]

keymap("", ",", "<Nop>", opts)
vim.g.mapleader = ","

keymap("", "<leader>q", ":q<cr>")                       -- Quit vim
keymap("", "<leader>d", ":bd<cr>")                      -- Delete buffer

-- clear trailing whitespace
keymap("n", "<leader>w", "mz:%s/\\s\\+$//<cr>:let @/=''<cr>`z")

-- window nav
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- split windows
keymap("n", "<leader>v", ":vsplit<cr>", opts)           -- split vertically
keymap("n", "<leader>-", ":split<cr>", opts)            -- split horizontally

-- Resize with arrows
keymap("n", "<S-Up>", ":resize -2<CR>", opts)
keymap("n", "<S-Down>", ":resize +2<CR>", opts)
keymap("n", "<S-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<S-Right>", ":vertical resize +2<CR>", opts)

keymap("n", "<leader><space>", ":noh<cr>", opts)              -- clear search highlight
keymap("n", "<leader>l", ":set list!<cr>", opts)              -- toggle showing / hiding hidden characters
keymap("n", "<leader>t", ":tabnew<cr>", opts)              -- toggle showing / hiding hidden characters

-- Telescope
keymap("n", "<leader>sf", ":Telescope find_files<cr>", opts)
keymap("n", "<leader>sg", ":Telescope live_grep<cr>", opts)
keymap("n", "<leader>sb", ":Telescope buffers<cr>", opts)
keymap("n", "<leader>sh", ":Telescope help_tags<cr>", opts)
keymap("n", "<leader>sd", ":Telescope lsp_document_symbols<cr>", opts)
keymap("n", "<leader>sw", ":Telescope lsp_dynamic_workspace_symbols<cr>", opts)
keymap("n", "<leader>cc", ":Telescope commands<cr>", opts)
keymap({"n", "v"}, "<leader>ca", ":lua vim.lsp.buf.code_action()<cr>", opts)
keymap("n", "<C-p>", ":Telescope find_files<cr>", opts)
keymap("n", "<leader>D", ":Telescope diagnostics<cr>", opts)

-- lsp trouble
keymap("n", "<leader>xx", ":TroubleToggle<cr>", opts)
keymap("n", "<leader>xw", ":TroubleToggle workspace_diagnostics<cr>", opts)
keymap("n", "<leader>xd", ":TroubleToggle document_diagnostics<cr>", opts)
keymap("n", "<leader>xq", ":TroubleToggle quickfix<cr>", opts)
keymap("n", "<leader>xl", ":TroubleToggle loclist<cr>", opts)
keymap("n", "gR", ":TroubleToggle lsp_references<cr>", opts)

keymap("n", "<leader>f", ":NvimTreeToggle<cr>", opts)

-- yank to system clipboard
keymap({"n", "v"}, "<leader>y", [["+y]])
keymap({"n", "v"}, "<leader>Y", [["+Y]])

-- formatting with null-ls
keymap("n", "<leader>lf", ":lua vim.lsp.buf.formatting_sync(nil, 10000)<cr>")
keymap("n", "<leader>lF", ":lua vim.lsp.buf.range_formatting()<cr>")

-- left-right tab navigation
keymap("n", "<s-h>", "gT")
keymap("n", "<s-l>", "gt")

-- git
-- theres Telescope git_status but I don't know how to use that yet and is still WIP
keymap("n", "<leader>gs", ":15split|0Git<cr>") -- limit split to 15 lines, see https://github.com/tpope/vim-fugitive/issues/1495
keymap("n", "<leader>gd", ":Gdiff<cr>")
keymap("n", "<leader>gb", ":Telescope git_branches<cr>", opts) -- list branches
keymap("n", "<leader>gc", ":Telescope git_commits<cr>", opts) -- list commits

-- keep cursor at the center of the screen
keymap("n", "n", "nzzzv")
keymap("n", "N", "Nzzzv")
keymap("n", "g;", "g;zz")
keymap("n", "g,", "g,zz")
keymap("n", "},", "}zz")
keymap("n", "{,", "{zz")
keymap("n", "g,", "g,zz")
keymap("n", "<c-f>", "<c-f>zz")
keymap("n", "<c-b>", "<c-b>zz")
keymap("n", "<c-o>", "<c-o>zz")
keymap("n", "<c-k>", "<cmd>cnext<cr>zz")
keymap("n", "<c-j>", "<cmd>cprev<cr>zz")
keymap("n", "<leader>k", "<cmd>lnext<cr>zz")
keymap("n", "<leader>j", "<cmd>lprev<cr>zz")
keymap("n", "G", "Gzz")

-- search and replace the current word
keymap("n", "<leader>ss", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- reselect pasted text
keymap("n", "<leader>gp", "`[v`]")

keymap("n", "<leader><leader>", function()
    vim.cmd("so")
    print("Reloaded neovim config")
end)


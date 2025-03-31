vim.keymap.set("n", "<leader>pv", ":Neotree action=focus position=left source=filesystem<CR>")
vim.keymap.set("n", "<leader>ls", ":Neotree action=focus position=float source=buffers<CR>")
vim.keymap.set("i", "jk", "<Esc>:w<CR>")
vim.keymap.set({"v", "n"}, "<C-v>", [["*p]])
vim.keymap.set({"v", "n"}, "<C-c>", [["*y]])
vim.keymap.set("n", "<C-h>", "<C-w>h") 
vim.keymap.set("n", "<C-j>", "<C-w>j") 
vim.keymap.set("n", "<C-k>", "<C-w>k") 
vim.keymap.set("n", "<C-l>", "<C-w>l") 

vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h") 
vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j") 
vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k") 
vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l") 

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fl', builtin.live_grep, {})

local term_map = require("terminal.mappings")
vim.keymap.set({ "n", "x" }, "<leader>ts", term_map.operator_send, { expr = true })
vim.keymap.set("n", "<leader>to", term_map.toggle)
vim.keymap.set("n", "<leader>tO", term_map.toggle({ open_cmd = "enew" }))
vim.keymap.set("n", "<leader>tr", term_map.run)
vim.keymap.set("n", "<leader>tR", term_map.run(nil, { layout = { open_cmd = "enew" } }))
vim.keymap.set("n", "<leader>tk", term_map.kill)
vim.keymap.set("n", "<leader>t]", term_map.cycle_next)
vim.keymap.set("n", "<leader>t[", term_map.cycle_prev)
vim.keymap.set("n", "<leader>tl", term_map.move({ open_cmd = "belowright vnew" }))
vim.keymap.set("n", "<leader>tL", term_map.move({ open_cmd = "botright vnew" }))
vim.keymap.set("n", "<leader>th", term_map.move({ open_cmd = "belowright new" }))
vim.keymap.set("n", "<leader>tH", term_map.move({ open_cmd = "botright new" }))
vim.keymap.set("n", "<leader>tf", term_map.move({ open_cmd = "float" }))

-- LSP actions
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(event)
    local opts = {buffer = event.buf}

    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
    vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
    vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
    vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
    vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
    vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
    vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
    vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
    vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
  end,
})

-- Enter debug
vim.keymap.set('n', "<leader>bb", "Obreakpoint()<Esc>")

local dbee = require("dbee")
vim.keymap.set('n', "<leader>db", dbee.toggle)


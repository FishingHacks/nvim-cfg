vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<right>", function() vim.cmd.tabnext() end)
vim.keymap.set("n", "<left>", function() vim.cmd.tabprev() end)

vim.keymap.set("n", "<down>", function() pcall(vim.cmd.tabclose) end)
vim.keymap.set("n", "<up>", function()
  vim.cmd.tabnew()
  vim.cmd("Oil")
end)

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Go multiple lines up" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Go multiple lines down" })

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function() vim.highlight.on_yank() end,
})

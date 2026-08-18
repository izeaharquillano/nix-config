-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.autoformat = false
-- vim.opt.wrap = true

if vim.fn.has('win32') == 1 then
  vim.opt.shell = "C:/PROGRA~1/PowerShell/7/pwsh.exe"
end

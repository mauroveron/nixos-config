local colorscheme = "tokyonight"

local ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not ok then
  print("** Failed to load colorscheme " .. colorscheme)
  return
end


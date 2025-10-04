local config = {
  root_markers = { "Makefile", ".git" },
}

---@return string
local function root()
  local root_dir = vim.fs.root(0, config.root_markers)

  if root_dir == nil then
    local filename = vim.api.nvim_buf_get_name(0)
    root_dir = vim.fs.dirname(filename)
  end

  return root_dir
end

local function rooter()
  local root_dir = root()
  vim.cmd.cd(root_dir)
  vim.notify("cwd: " .. root_dir)
end

local M = {}

function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})

  vim.api.nvim_create_autocmd({ "VimEnter", "BufEnter" }, {
    group = vim.api.nvim_create_augroup("autorooter.nvim", { clear = true }),
    callback = function()
      rooter()
    end,
  })
end

return M

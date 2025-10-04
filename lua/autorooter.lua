local config = {
  root_markers = { "Makefile", ".git" },
}

---@return string
local function root()
  local filename = vim.api.nvim_buf_get_name(0)
  local root_files = vim.fs.find(config.root_markers, { path = filename, upward = true })

  if #root_files ~= 0 then
    return vim.fs.dirname(root_files[1])
  else
    return vim.fs.dirname(filename)
  end
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

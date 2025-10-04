local config = {
  buftypes = { "", "nofile", "nowrite", "acwrite" },
  root_markers = { "Makefile", ".git" },
}

---@return boolean
local function contains(dir, file)
  local path = vim.fs.joinpath(dir, file)

  return vim.uv.fs_stat(path) ~= nil
end

---@return string
local function root()
  local filename = vim.api.nvim_buf_get_name(0)

  for _, root_marker in ipairs(config.root_markers) do
    for parent in vim.fs.parents(filename) do
      if contains(parent, root_marker) then
        return parent
      end
    end
  end

  return vim.fs.dirname(filename)
end

local function rooter()
  if vim.list_contains(config.buftypes, vim.bo.buftype) then
    local root_dir = root()
    vim.cmd.cd(root_dir)
    vim.notify("cwd: " .. root_dir)
  end
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

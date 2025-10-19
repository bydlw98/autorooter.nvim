---@type table<string, string>
local cache = {}

---@class autorooter.Config
local config = {
  ---Checks if we should change to buffer's root directory.
  ---@return boolean
  activate = function()
    return vim.bo.buftype == ""
  end,
  ---Filenames used to find buffer's root directory.
  ---@type string[]
  root_markers = { "Makefile", ".git" },
  ---Enables/disables notifications.
  ---@type boolean
  silent = false,
}

---Returns `true` if `dir` contains `file`.
---@return boolean
local function contains(dir, file)
  return vim.uv.fs_stat(vim.fs.joinpath(dir, file)) ~= nil
end

---Returns a list of parent directory paths.
---@param filename string
---@return string[]
local function parents(filename)
  local parent_dirs = { vim.fs.dirname(filename) }

  while true do
    local parent = vim.fs.dirname(parent_dirs[#parent_dirs])
    if parent == parent_dirs[#parent_dirs] then
      break
    end

    table.insert(parent_dirs, parent)
  end

  return parent_dirs
end

---Finds and returns the current buffer's root directory.
---@return string
local function root()
  local filename = vim.api.nvim_buf_get_name(0)
  local root_dir = cache[filename]
  if root_dir then
    return root_dir
  end

  local parent_dirs = parents(filename)
  for _, root_marker in ipairs(config.root_markers) do
    for _, parent in ipairs(parent_dirs) do
      if contains(parent, root_marker) then
        cache[filename] = parent
        return parent
      end
    end
  end

  root_dir = parent_dirs[1]
  cache[filename] = root_dir
  return root_dir
end

---Changes to the buffer's root directory.
local function rooter()
  if not config.activate() then
    return
  end
  local root_dir = root()
  vim.api.nvim_set_current_dir(root_dir)

  if config.silent then
    return
  end

  vim.cmd.redraw()
  vim.notify(("cwd: %s"):format(root_dir), vim.log.levels.INFO)
end

---@class autorooter
local M = {}

---@param opts? autorooter.Config
function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})

  if vim.o.autochdir then
    vim.o.autochdir = false
    vim.notify(
      "[autorooter.nvim]: `vim.o.autochdir` is turned off as it may interfere with this plugin",
      vim.log.levels.WARN
    )
    vim.notify(
      "[autorooter.nvim]: to prevent this warning, turn off `vim.o.autochdir` before loading this plugin",
      vim.log.levels.WARN
    )
  end

  vim.api.nvim_create_autocmd({ "VimEnter", "BufEnter" }, {
    group = vim.api.nvim_create_augroup("autorooter.nvim", { clear = true }),
    callback = function()
      rooter()
    end,
  })
end

return M
-- vim:ts=2:sts=2:sw=2:et:

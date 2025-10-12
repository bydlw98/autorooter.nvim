---@type table<string, string>
local cache = {}

---@class autorooter.Config
---@field activate? fun(): boolean Checks if we should change to buffer's root directory
---@field root_markers? string[] Filenames used to find buffer's root directory
---@field silent? boolean Enables/disables notifications

---@type autorooter.Config
local config = {
  activate = function()
    return vim.bo.buftype == ""
  end,
  root_markers = { "Makefile", ".git" },
  silent = false,
}

---Returns `true` if `dir` contains `file`.
---@return boolean
local function contains(dir, file)
  local path = vim.fs.joinpath(dir, file)

  return vim.uv.fs_stat(path) ~= nil
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
    else
      table.insert(parent_dirs, parent)
    end
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
  if config.activate() then
    local root_dir = root()
    vim.cmd.cd(root_dir)

    if not config.silent then
      vim.notify("cwd: " .. root_dir)
    end
  end
end

local M = {}

---@param opts? autorooter.Config
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

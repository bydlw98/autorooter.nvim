# autorooter.nvim

`autorooter.nvim` automatically finds and changes to buffer's root directory
for [Neovim](https://neovim.io).

Inspired by [vim-rooter](https://github.com/airblade/vim-rooter).

## Requirements

- Neovim >= 0.8.0

## Installation

### `lazy.nvim`

```lua
{
  "bydlw98/autorooter.nvim",
  ---@module "autorooter"
  ---@type autorooter.Config
  opts = {}
}
```

## Configuration

```lua
require("autorooter").setup({
  -- Checks if we should change to buffer's root directory
  activate = function()
    return vim.bo.buftype == ""
  end,

  -- Filenames used to find buffer's root directory
  root_markers = { "Makefile", ".git" },

  -- Enables/disables notifications
  silent = false,
})
```

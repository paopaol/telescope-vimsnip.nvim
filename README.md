<!-- @format -->

# telescope-vimsnip.nvim

An extension for [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) that allows you to list [snippets](https://github.com/hrsh7th/vim-vsnip) of current buffer

## Setup

```lua
paq 'nvim-telescope/telescope.nvim'
paq 'paopaol/telescope-vimsnip.nvim'
```

You can setup the extension by adding the following to your config:

```lua
require'telescope'.load_extension('vimsnip')
```

## Usage

```viml
:Telescope vimsnip
```

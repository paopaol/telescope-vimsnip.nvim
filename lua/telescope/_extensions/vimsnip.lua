local telescope_installed, telescope = pcall(require, 'telescope')

if not telescope_installed then
  error('This plugins requires nvim-telescope/telescope.nvim')
end

local actions = require('telescope.actions')
local actions_set = require 'telescope.actions.set'
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local conf = require('telescope.config').values
local previewers = require('telescope.previewers')
local entry_display = require('telescope.pickers.entry_display')
local utils = require('telescope.utils')
local putils = require('telescope.previewers.utils')
local action_state = require('telescope.actions.state')

function string:split(sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  self:gsub(pattern, function(c) fields[#fields + 1] = c end)
  return fields
end

local function vimsnip(opts)
  opts = opts or {}

  local snips = vim.call('vsnip#get_complete_items',
                         vim.api.nvim_get_current_buf())

  local objects = {}
  for _, v in pairs(snips) do
    table.insert(objects, {
      lang = vim.opt.filetype:get(),
      name = v['abbr'],
      content = vim.call('json_decode', v['user_data'])['vsnip']['snippet']
    })
  end

  local display_items = {{width = 6}, {width = 100}, {remaining = true}}
  local displayer = entry_display.create {
    separator = "  ",
    items = display_items
  }

  local make_display = function(entry)
    local basename, hl_group = utils.transform_devicons(entry.value.lang,
                                                        entry.value.lang, false)
    return displayer {{basename, hl_group}, entry.value.name}
  end

  pickers.new(opts, {
    prompt_title = 'vimsnip',
    finder = finders.new_table {
      results = objects,
      entry_maker = function(entry)
        return {value = entry, display = make_display, ordinal = entry.name}
      end
    },
    previewer = previewers.new_buffer_previewer {
      define_preview = function(self, entry)
        local text = table.concat(entry.value.content, '\n')
        text = text:gsub('${([%w_]+)}', '%1')
        local lines = vim.split(text, "\n", true)
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
        -- putils.highlighter(self.state.bufnr, entry.value.lang)
      end
    },
    sorter = conf.generic_sorter(opts),
    attach_mappings = function()
      actions.select_default:replace(function(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)

        local text = table.concat(selection.value.content, '\n')
        vim.call('vsnip#anonymous', text)
        vim.fn.feedkeys('li')
      end)
      return true
    end
  }):find()
end

return telescope.register_extension {exports = {vimsnip = vimsnip}}

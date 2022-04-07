-- telescope modules
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local finders = require("telescope.finders")
local actions_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local themes = require("telescope.themes")
local builtin_pickers = require("telescope.builtin")
local extensions_pickers = require("telescope._extensions")

local M = {}

M.setup = function(setup_config) end

local result_table = {}

local commands_list = vim.fn.getcompletion("", "cmdline")
for i, command in ipairs(commands_list) do
	table.insert(result_table, command)
end

M.running_commands = function(opts)
	opts = opts or themes.get_dropdown()

	pickers.new(opts or {}, {
		prompt_title = "Running Commands",
		results_title = "Commands",
		finder = finders.new_table({
			results = result_table,
		}),
		attach_mappings = function(prompt_bufnr, map)
			actions.select_default:replace(function()
				local selection = actions_state.get_selected_entry()
				local value = selection.value
				if value then
					vim.api.nvim_command(value)
				end
			end)
			return true
		end,
		sorter = conf.file_sorter(opts),
	}):find()
end

return M

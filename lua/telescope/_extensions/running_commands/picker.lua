local pickers = require("telescope.pickers")
local conf = require("telescope.config").values

local fb_finder = require("telescope._extensions.running_commands.finders")
local themes = require("telescope.themes")
local finders = require("telescope.finders")
local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local action_set = require("telescope.actions.set")

-- enclose in module for docgen
local fb_picker = {}

fb_picker.running_command = function(opts)
	opts = themes.get_dropdown(opts)

	opts.custom_prompt_title = opts.prompt_title ~= nil

	pickers.new(opts, {
		prompt_title = "Commands Avaiable",
		finder = fb_finder.finder(opts),
		sorter = conf.file_sorter(opts),
		attach_mappings = function(prompt_bufnr, _)
			action_set.select:replace(function()
				local entry = action_state.get_selected_entry()
				local current_picker = action_state.get_current_picker(prompt_bufnr)
				local finder = current_picker.finder
				local current_commands
				finder.files = true
				if entry == nil then
					current_commands = action_state.get_current_line()
				else
					current_commands = entry.value
				end

				local current_title = current_picker.prompt_border._border_win_options.title
				local data = vim.fn.getcompletion(current_commands .. " ", "cmdline")

				-- check last char is "!"
				if current_commands:sub(-1) == "!" then
					data = {}
				end
				if vim.tbl_isempty(data) then
					actions.close(prompt_bufnr)
					if current_title == "Commands Avaiable" then
						-- local cmd = finder.current_commands
						vim.api.nvim_command(current_commands)
					else
						vim.api.nvim_command(current_title .. " " .. current_commands)
					end
				else
					finder = finders.new_table({ results = data })
					local new_title
					if current_title == "Commands Avaiable" then
						new_title = current_commands
					else
						new_title = current_title .. " " .. current_commands
					end
					current_picker.prompt_border:change_title(new_title)
					current_picker:refresh(finder, { reset_prompt = true })
				end
			end)
			return true
		end,
	}):find()
end

return fb_picker.running_command

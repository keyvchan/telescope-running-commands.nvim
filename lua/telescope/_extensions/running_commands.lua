local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
	error("This extension requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)")
end

local fb_actions = require("telescope._extensions.running_commands.actions")
local fb_finders = require("telescope._extensions.running_commands.finders")
local fb_picker = require("telescope._extensions.running_commands.picker")
local fb_utils = require("telescope._extensions.running_commands.utils")

local finders = require("telescope.finders")
local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local action_set = require("telescope.actions.set")

local pconf = {
	mappings = {},
	attach_mappings = function(prompt_bufnr, _)
		action_set.select:replace(function()
			local entry = action_state.get_selected_entry()
			local current_picker = action_state.get_current_picker(prompt_bufnr)
			local finder = current_picker.finder
			finder.files = true
			finder.path = entry
			local data = vim.fn.getcompletion(entry.value .. " ", "cmdline")
			if vim.F.if_nil(data) then
				vim.notify(vim.inspect(current_picker.results_border._border_win_options.title))
				actions.close(prompt_bufnr)
			else
				finder = finders.new_table({ results = data })
				fb_utils.redraw_border_title(current_picker)
				current_picker:refresh(finder, { reset_prompt = true, multi = current_picker._multi })
			end
		end)
		return true
	end,
}

local fb_setup = function(opts)
	-- TODO maybe merge other keys as well from telescope.config
	pconf.mappings = vim.tbl_deep_extend("force", pconf.mappings, require("telescope.config").values.mappings)
	pconf = vim.tbl_deep_extend("force", pconf, opts)
end

local running_commands = function(opts)
	opts = opts or {}
	local defaults = (function()
		if pconf.theme then
			return require("telescope.themes")["get_" .. pconf.theme](pconf)
		end
		return vim.deepcopy(pconf)
	end)()

	if pconf.mappings then
		defaults.attach_mappings = function(prompt_bufnr, map)
			if pconf.attach_mappings then
				pconf.attach_mappings(prompt_bufnr, map)
			end
			for mode, tbl in pairs(pconf.mappings) do
				for key, action in pairs(tbl) do
					map(mode, key, action)
				end
			end
			return true
		end
	end

	if opts.attach_mappings then
		local opts_attach = opts.attach_mappings
		opts.attach_mappings = function(prompt_bufnr, map)
			defaults.attach_mappings(prompt_bufnr, map)
			return opts_attach(prompt_bufnr, map)
		end
	end
	local popts = vim.tbl_deep_extend("force", defaults, opts)
	fb_picker(popts)
end

return telescope.register_extension({
	setup = fb_setup,
	exports = {
		running_commands = running_commands,
		actions = fb_actions,
		finder = fb_finders,
		_picker = fb_picker,
	},
})

local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
	error("This extension requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)")
end

local fb_finders = require("telescope._extensions.running_commands.finders")
local fb_picker = require("telescope._extensions.running_commands.picker")

local fb_setup = function(opts) end

local running_commands = function(opts)
	opts = opts or {}

	fb_picker(opts)
end

return telescope.register_extension({
	setup = fb_setup,
	exports = {
		running_commands = running_commands,
		finder = fb_finders,
		_picker = fb_picker,
	},
})

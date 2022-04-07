local has_telescope, telescope = pcall(require, "telescope")
local main = require("telescope._extensions.running_commands.main")

if not has_telescope then
	error("telescope not found, this plugin requires it")
end

return telescope.register_extension({
	setup = main.setup,
	exports = { running_commands = main.running_commands },
})

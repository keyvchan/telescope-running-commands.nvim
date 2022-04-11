local pickers = require("telescope.pickers")
local conf = require("telescope.config").values

local fb_finder = require("telescope._extensions.running_commands.finders")

local Path = require("plenary.path")
local os_sep = Path.path.sep

-- enclose in module for docgen
local fb_picker = {}

-- try to get the index of entry of current buffer
local get_selection_index = function(opts, results)
	local buf_path = vim.api.nvim_buf_get_name(0)
	local current_dir = Path:new(buf_path):parent():absolute()

	if opts.path == current_dir then
		for i, path_entry in ipairs(results) do
			if path_entry.value == buf_path then
				return i
			end
		end
	end
	return vim.F.if_nil(opts.default_selection_index, 1)
end

fb_picker.running_command = function(opts)
	opts = opts or {}

	local cwd = vim.loop.cwd()
	opts.depth = vim.F.if_nil(opts.depth, 1)
	opts.cwd_to_path = vim.F.if_nil(opts.cwd_to_path, false)
	opts.cwd = opts.cwd and vim.fn.expand(opts.cwd) or cwd
	opts.path = opts.path and vim.fn.expand(opts.path) or opts.cwd
	opts.files = vim.F.if_nil(opts.files, true)
	opts.hide_parent_dir = vim.F.if_nil(opts.hide_parent_dir, false)
	opts.select_buffer = vim.F.if_nil(opts.select_buffer, false)
	opts.custom_prompt_title = opts.prompt_title ~= nil
	opts.custom_results_title = opts.results_title ~= nil

	local select_buffer = opts.select_buffer and opts.files
	-- handle case that current buffer is a hidden file
	opts.hidden = (select_buffer and vim.fn.expand("%:p:t"):sub(1, 1) == ".") and true or opts.hidden
	local finder = fb_finder.finder(opts)
	-- find index of current buffer in the results
	if select_buffer then
		finder._finder = finder:_browse_files()
		opts.default_selection_index = get_selection_index(opts, finder.results)
	end

	pickers.new(opts, {
		prompt_title = "Commands Avaiable",
		results_title = "Results",
		finder = finder,
		previewer = conf.file_previewer(opts),
		sorter = conf.file_sorter(opts),
	}):find()
end

return fb_picker.running_command

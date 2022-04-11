local fb_make_entry = require("telescope._extensions.running_commands.make_entry")

local finders = require("telescope.finders")

local scan = require("plenary.scandir")

local action_state = require("telescope.actions.state")
local fb_finders = {}
local has_fd = vim.fn.executable("fd") == 1

fb_finders.browse_commands = function(opts)
	local data = vim.fn.getcompletion(action_state.get_current_line(), "cmdline")
	return finders.new_table({ results = data })
end

fb_finders.finder = function(opts)
	opts = opts or {}
	-- cache entries such that multi selections are maintained across {file, folder}_browsers
	-- otherwise varying metatables misalign selections
	opts.entry_cache = {}
	return setmetatable({
		cwd_to_path = opts.cwd_to_path,
		cwd = opts.cwd_to_path and opts.path or opts.cwd, -- nvim cwd
		path = vim.F.if_nil(opts.path, opts.cwd), -- current path for file browser
		add_dirs = vim.F.if_nil(opts.add_dirs, true),
		hidden = vim.F.if_nil(opts.hidden, false),
		depth = vim.F.if_nil(opts.depth, 1), -- depth for file browser
		respect_gitignore = vim.F.if_nil(opts.respect_gitignore, has_fd),
		files = vim.F.if_nil(opts.files, true), -- file or folders mode
		grouped = vim.F.if_nil(opts.grouped, false),
		select_buffer = vim.F.if_nil(opts.select_buffer, false),
		hide_parent_dir = vim.F.if_nil(opts.hide_parent_dir, false),
		-- ensure we forward make_entry opts adequately
		entry_maker = vim.F.if_nil(opts.entry_maker, function(local_opts)
			return fb_make_entry(vim.tbl_extend("force", opts, local_opts))
		end),
		_browse_commands = vim.F.if_nil(opts.browse_commands, fb_finders.browse_commands),
		close = function(self)
			self._finder = nil
		end,
		prompt_title = opts.custom_prompt_title,
		results_title = opts.custom_results_title,
	}, {
		__call = function(self, ...)
			-- (re-)initialize finder on first start or refresh due to action
			if not self._finder then
				self._finder = self:_browse_commands()
			end
			self._finder(...)
		end,
		__index = function(self, k)
			-- finder pass through for e.g. results
			if rawget(self, "_finder") then
				local finder_val = self._finder[k]
				if finder_val ~= nil then
					return finder_val
				end
			end
		end,
	})
end

return fb_finders

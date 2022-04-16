local finders = require("telescope.finders")

local action_state = require("telescope.actions.state")
local fb_finders = {}

fb_finders.browse_commands = function(opts)
	local data = vim.fn.getcompletion("", "cmdline")
	return finders.new_table({ results = data })
end

fb_finders.finder = function(opts)
	opts = opts or {}
	return setmetatable({
		current_commands = vim.F.if_nil(opts.current_commands, ""),
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

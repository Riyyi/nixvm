local builtin
local telescope

local F = require("core.functions")

local M = {}

M.setup = function()
	-- Prevent dependency loop
	builtin = require("telescope.builtin")
	telescope = require("telescope")
end

-- Set which-key key section description
M.wk = function(keybind, description, bufnr)
	require("which-key").add({
		{ keybind, group = description, mode = { "n", "v" }, buffer = bufnr },
	})
end

M.buffer_close = function()
	-- Check if there are more than 2 buffers and alternate file is set
	local command = vim.fn.expand("#") ~= "" and #vim.fn.getbufinfo({ buflisted = 1 }) > 1
		and "e #|bd #|bwipeout #" -- see `:h c_#`
		or "bd"
	vim.api.nvim_command(command)
end

M.buffer_dashboard = function()
	vim.api.nvim_command("Dashboard")
end

M.file_config = function()
	builtin.find_files({
		prompt_title = "Nvim Config",
		cwd = vim.fn.stdpath("config"),
		hidden = true,
		no_ignore = true,
		-- path_display = { "shorten" },
	})
end

M.file_find = function()
	telescope.extensions.file_browser.file_browser({
		cwd = F.get_current_directory(),
		hidden = true,
		no_ignore = true,
	})
end

M.file_find_home = function()
	telescope.extensions.file_browser.file_browser({
		cwd = "~",
		hidden = true,
		no_ignore = true,
	})
end

M.file_find_recent = function()
	telescope.extensions.recent_files.pick()
end

M.file_save = function()
	vim.api.nvim_command("w")
end

M.find_other_file = function()
    local ext = vim.fn.expand("%:e")
	local targets = {}
	if ext == "h" or ext == "hpp" then
		targets = { "c", "cpp" }
	elseif ext == "c" or ext == "cpp" then
		targets = { "h", "hpp" }
	else return end

    local file = vim.fn.expand("%:t:r")

	local root, _ = F.find_project_root()
	if not root then return end

	local files = vim.fs.find(function(name, _)
		local find_file, find_ext = name:match("(.+)%.(.+)$")
		return find_file == file and (find_ext == targets[1] or find_ext == targets[2])
	end, { limit = math.huge, type = "file", path = root })
	if #files == 0 then return end

	vim.cmd("edit " .. vim.fn.fnameescape(files[1]))
end

M.goto_trouble = function()
	vim.api.nvim_command("Trouble")
end

M.goto_todos_telescope = function()
	vim.api.nvim_command("TodoTelescope")
end

M.goto_todos_trouble = function()
	vim.api.nvim_command("TodoTrouble")
end

-- Smart delete
M.hungry_delete = function()
	return function()
		local start_line = vim.fn.line(".")
		local start_col = vim.fn.col(".")
		local start_line_content = vim.fn.getline(start_line)
		local line_length = start_line_content:len()

		-- Check if there are multiple whitespace characters after the cursor
		local is_1_whitespace = start_line_content:sub(start_col, start_col):match("%s")
		local is_2_whitespace = start_line_content:sub(start_col + 1, start_col + 1):match("%s")
		if (start_col <= line_length - 1 and is_1_whitespace and is_2_whitespace)
			or (start_col == line_length and is_1_whitespace)
			or start_col - 1 == line_length then -- in insert mode, the column is 1 higher
			-- Hungry delete

			-- Iterate forwards through each line and character
			local last_line = vim.fn.line("$")
			for line = start_line, last_line do
				local line_content = (line == start_line) and start_line_content or vim.fn.getline(line)
				local col = (line == start_line) and start_col or 1

				for c = col, #line_content do
					local char = line_content:sub(c, c)

					-- Look until it hits a non-whitespace character
					if not vim.fn.strcharpart(char, 0, 1):match("%s") then
						-- Delete empty lines, from the starting line to the current line
						vim.api.nvim_buf_set_lines(0, start_line - 1, line - 1, false, {})

						-- Keep the content that was before the cursor at the start_line,
						-- plus the content from the current column to the end of the current line
						vim.fn.setline(start_line,
							start_line_content:sub(1, start_col - 1) .. line_content:sub(c))

						vim.fn.cursor({ start_line, start_col })
						return
					end
				end
			end

			-- Delete empty lines, if the end of the buffer was only whitespace
			vim.api.nvim_buf_set_lines(0, start_line - 1, last_line, false, {})

			-- Keep the content that was before the cursor
			vim.fn.setline(start_line, start_line_content:sub(1, start_col - 1))

			vim.fn.cursor({ start_line, start_col })
		else
			-- Normal delete
			vim.cmd("normal! x")
		end
	end
end

-- Smart backspace
M.hungry_delete_backspace = function()
	-- Cache some values
	local core = require("ultimate-autopair.core")
	local keycode = vim.api.nvim_replace_termcodes("<Plug>ultimate-autopair-BS", true, false, true)
	local fallback = vim.api.nvim_replace_termcodes("<C-h>", true, false, true) -- <BS> => <C-h>, \b

	return function()
		local start_line = vim.fn.line(".")
		local start_col = vim.fn.col(".")
		local start_line_content = vim.fn.getline(start_line)

		-- Check if there are multiple whitespace characters before the cursor
		local is_1_whitespace = start_line_content:sub(start_col - 1, start_col - 1):match("%s")
		local is_2_whitespace = start_line_content:sub(start_col - 2, start_col - 2):match("%s")
		if (start_col >= 3 and is_1_whitespace and is_2_whitespace)
			or (start_col == 2 and is_1_whitespace)
			or start_col == 1 then
			-- Hungry delete

			-- Iterate backwards through each line and character
			for line = start_line, 1, -1 do
				local line_content = (line == start_line) and start_line_content or vim.fn.getline(line)
				local col = (line == start_line) and (start_col - 1) or #line_content

				for c = col, 1, -1 do
					local char = line_content:sub(c, c)

					-- Look until it hits a non-whitespace character
					if not vim.fn.strcharpart(char, 0, 1):match("%s") then
						-- Delete empty lines, from the starting line to the current line
						vim.api.nvim_buf_set_lines(0, line - 1, start_line - 1, false, {})

						-- Keep the content from the start of the current line to the current column,
						-- plus the content that was after the cursor at the start_line
						vim.fn.setline(line, line_content:sub(1, c) .. (line == start_line
							and line_content:sub(start_col) -- found non-whitespace on the same line it started
							or start_line_content:sub(start_col))) -- jumped through empty lines

						vim.fn.cursor({ line, c + 1 })
						return
					end
				end
			end

			-- Delete empty lines, if the start of the buffer was only whitespace
			vim.api.nvim_buf_set_lines(0, 0, start_line - 1, false, {})

			-- Keep the content that was after the cursor
			vim.fn.setline(1, "" .. start_line_content:sub(start_col))
		else
			-- Normal backspace, prevent run_run recursive mapping via fallback to \b
			local actions = core.run_run(keycode)
			vim.api.nvim_feedkeys(actions ~= keycode and actions or fallback, "n", false) -- equivalent to { expr = true }
		end
	end
end

M.lsp_format_buffer = function()
	vim.lsp.buf.format({
		formatting_options = {
			tabSize = 4,
			insertSpaces = false,
		},
	})
end

M.project_file = function()
	local res, err = F.find_project_root()
	if res then
		builtin.git_files({ cwd = res })
	else -- fall-back to find_files, if current buffer isnt in a project
		builtin.find_files({ cwd = err })
	end
end

M.project_grep = function()
	local res, err = F.find_project_root()
	builtin.live_grep({ cwd = res or err })
end

M.project_list = function()
	telescope.extensions.projects.projects()
end

M.search_buffer = function()
	builtin.current_buffer_fuzzy_find({
		previewer = false,
		sorting_strategy = "ascending",
	})
end

M.toggle_term = function()
	vim.api.nvim_command("ToggleTerm")
end

M.vc_select_repo = function()
	-- local projects = require("project").get_recent_projects()

	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local conf = require("telescope.config").values
	-- local finders = require("telescope.finders")
	local pickers = require("telescope.pickers")
	local util = require("telescope._extensions.projects.util")
	pickers.new({}, {
		prompt_title = "Select Project",
		-- finder = create_finder(),
		finder = util.create_finder(),
		-- finder = finders.new_table {
		-- results = projects,
		-- },
		previewer = false,
		sorter = conf.generic_sorter({}),
		attach_mappings = function(prompt_bufnr)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)

				local selection = action_state.get_selected_entry()
				-- require("neogit").open({ cwd = selection[1] })
				require("neogit").open({ cwd = selection.value })
			end)

			return true
		end,
	}):find()
end

M.vc_status = function()
	if F.find_project_root() then
		-- Open the repository of the current file
		require("neogit").open({ cwd = "%:p:h" })
	else
		-- Pick a project to open
		M.vc_select_repo()
	end
end

return M

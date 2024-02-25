-- actuall logic for plugin here
local M = {}
Num = ""
CancelKey = ""

function M.setup(opts)
	opts = opts or {}
	CancelKey = opts.cancelKey
	Num = opts.num
	vim.keymap.set("n", opts.key, function()
		ConvertNums()
	end)
end

function ConvertNums()
	local input
	local continueListening = true
	local converted = ""

	vim.opt.cursorcolumn = true
	print(Num)
	while continueListening do
		input = vim.fn.getcharstr()
		if string.find(Num, input) then
			converted = converted .. (string.find(Num, input) - 1)
			print(converted .. input)
		else
			continueListening = false
		end
	end
	if input == CancelKey then
		print("canceled")
	else
		vim.api.nvim_feedkeys(converted, "t", true)
	end
	vim.opt.cursorcolumn = false
end

return M

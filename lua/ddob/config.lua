return {
	colorscheme = {
        name = "kanagawa",
        enable_all = true
    },
	lsp = {
		icon_sign = false, -- uses colored num column if false
		hover_diagnostic = true,
        skip_capability_check = true,
	},
	colors = {
		cmake_line = "#928374",
	},
	icons = {
		dap = {
			Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
			Breakpoint = { " " },
			BreakpointCondition = " ",
			BreakpointRejected = { " ", "DiagnosticError" },
			LogPoint = ".>",
		},
		diagnostics = {
			Error = " ",
			Warn = " ",
			Hint = " ",
			Info = " ",
		},
		cmake = {
			Build = "󱌣",
			Arch = "",
			Run = "",
			Gear = "",
		},
		git = {
			added = " ",
			modified = " ",
			removed = " ",
		},
	},
}

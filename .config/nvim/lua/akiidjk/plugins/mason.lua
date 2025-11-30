return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		local mason = require("mason")
		local mason_lspconfig = require("mason-lspconfig")
		local mason_tool_installer = require("mason-tool-installer")

		mason.setup({})

		-- Repo with all lsp server: https://github.com/williamboman/mason-lspconfig.nvim?tab=readme-ov-file#available-lsp-servers
		mason_lspconfig.setup({
			ensure_installed = {
				"lua_ls",
				"html",
				"cssls",
				"ruff_lsp",
				"svelte",
				"tsserver",
				"dockerls",
				"docker_compose_language_service",
				"rust_analyzer",
				"jsonls",
				"markdown_oxide",
				"tailwindcss",
			},
			automatic_installation = true,
		})

		mason_tool_installer.setup({
			ensure_installed = {
				"prettier",
				"stylua",
				"eslint_d",
				"prettierd",
			},
		})
	end,
}

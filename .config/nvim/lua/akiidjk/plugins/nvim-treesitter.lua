return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require('nvim-treesitter.configs').setup({
      ensure_installed = { "lua", "vim", "vimdoc", "python", "go", "typescript", "javascript" },
      sync_install = false,
      auto_install = true,

      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },

      indent = {
        enable = true
      }
    })
  end
}

require("config.opts")
require("config.keys")
require("config.lazy")
require("config.lsp")

local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.mira = {
  install_info = {
    -- Change this url to your grammar
    url = "~/rust/tree-sitter-mira",
    -- If you use an external scanner it needs to be included here
    files = { "src/parser.c", "src/scanner.c" },
    generate_reqires_npm = false,
    requires_generate_from_grammar = false,
  },
  -- The filetype you want it registered as
  filetype = "mr",
}
vim.treesitter.language.register("mira", "mira")
vim.filetype.add({ extension = { mr = "mira" } })

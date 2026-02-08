local set = vim.opt_local

set.commentstring = "// %s"
set.comments = "s0:/*!,s1:/*,mb:*,ex:*/,:///,://"
set.suffixesadd = ".mr"
set.cinwords = "fn,extern,if,else,while,for,struct,impl,trait"
set.formatoptions = "croqnlj"
set.include = "\\v^\\s*(pub\\s+)?use\\s+\\zs(\\f|:)+"
set.spelloptions = "noplainbuffer"

-- TODO: Proper Treesitter for mira
-- includeexpr=rust#IncludeExpr(v:fname)
-- indentexpr=nvim_treesitter#indent()

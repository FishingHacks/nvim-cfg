return {
    'folke/tokyonight.nvim',
    priority = 1000, -- start before other plugings
    init = function()
        vim.cmd.colorscheme('tokyonight')
        vim.cmd.hi('Comment gui=none')
    end
}

return {
    "stevenarc/oil.nvim",
    config = function()
        local oil = require('oil')
        oil.setup({
            columns = {
                'permissions',
                'size',
                'mtime',
                'icon',
            },
            view_options = {
                is_hidden_file = function(name, _)
                    if name == '.mira' then
                        return false
                    end
                    local m = name:match '^%.'
                    return m ~= nil
                end,
                is_always_hidden = function(name, _)
                    return name == '.' or name == '..'
                end,
            },
            keymaps = {
              ['q'] = 'actions.close',
            },
        })
        vim.keymap.set('n', '-', oil.toggle_float, { desc = 'Open parent directory' })
    end,
    dependencies = { { 'echasnovski/mini.icons', opts = {} } },
}

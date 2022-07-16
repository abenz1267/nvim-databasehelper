local functions = require('nvim-databasehelper.functions')

local M = {}

local default = {
    lsp       = {},
    databases = {},
    dadbod    = {
        enabled = false,
        var = 'prod'
    },
    docker    = {
        enabled = false,
        must_contain = {},
        defaults = {
            driver = 'postgresql',
            postgresql = {
                user = '',
                password = '',
                database = '',
            }
        }
    }
}

M.setup = function(opt)
    local config = vim.tbl_deep_extend('force', default, opt or {})

    vim.api.nvim_create_user_command('SwitchDatabase',
        function() functions.select_database(config) end,
        { nargs = '*' }
    )

    for k, v in pairs(config.lsp) do
        require('lspconfig')[k].setup(v)
    end
end

return M

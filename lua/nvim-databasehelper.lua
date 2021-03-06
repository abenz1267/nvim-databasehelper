local functions = require('nvim-databasehelper.functions')
local lsps = require('nvim-databasehelper.lsps.functions')
local dadbod = require('nvim-databasehelper.dadbod')

local M = {}

local default = {
    lsp                   = {},
    databases             = {},
    dadbod                = {
        enabled = false,
        var = 'prod'
    },
    docker                = {
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
    },
    initial_window_height = 10,
}

local setup_commands = function(config)
    vim.api.nvim_create_user_command('SwitchDatabaseConnection',
        function(...)
            functions.select_database_connection({ ... }, config)
        end,
        { nargs = '?', complete = function()
            local choices, _ = functions.get_database_connection_choices(config)

            return choices
        end }
    )

    vim.api.nvim_create_user_command('OpenDatabaseWindow',
        function()
            functions.open_database_window(config);
        end,
        { nargs = 0 }
    )

    vim.api.nvim_create_user_command('SwitchDatabase',
        function(...)
            functions.set_current_database({ ... }, config)
        end,
        { nargs = '?', complete = function()
            return functions.get_databases(config)
        end }
    )

    if config.dadbod.enabled then
        vim.api.nvim_create_user_command('ExecuteOnDatabaseConnection',
            function(...)
                functions.execute_on_database_connection({ ... }, config)
            end,
            { nargs = '?', range = true, complete = function()
                return functions.get_database_connection_choices(config)
            end }
        )

        vim.api.nvim_create_user_command('ExecuteOnDatabase',
            function(...)
                functions.execute_on_database({ ... }, config)
            end,
            { nargs = '?', range = true, complete = function()
                return functions.get_databases(config)
            end }
        )
    end
end

M.setup = function(opt)
    local config = vim.tbl_deep_extend('force', default, opt or {})

    for _, db in pairs(config.databases) do
        for k, v in pairs(db) do
            if k == 'initial' and v then
                functions.current = db
            end
        end
    end

    if config.dadbod.enabled then
        dadbod.set_global(config.dadbod, functions.current)
    end

    for k, v in pairs(config.lsp) do
        lsps[k](v, functions.current)
    end

    setup_commands(config)
end

return M

local functions = require('nvim-databasehelper.functions')
local lsps = require('nvim-databasehelper.lsps.functions')
local docker = require('nvim-databasehelper.docker')
local dadbod = require('nvim-databasehelper.dadbod')

local M = {}

local default = {
    lsp                   = {},
    connections           = {},
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
                initial_database = '',
            }
        }
    },
    initial_window_height = 10,
}

local setup_commands = function(dadbodconf, dockerconf)
    vim.api.nvim_create_user_command('OpenDatabaseWindow', functions.open_database_window, { nargs = 0 })

    vim.api.nvim_create_user_command('SwitchDatabase',
        function(...)
            functions.set_current_database({ ... })
        end,
        { nargs = '?', complete = functions.get_databases }
    )

    if dockerconf.enabled then
        vim.api.nvim_create_user_command('StartContainer',
            function(...)
                docker.handle_container({ ... }, 'start')
            end,
            { nargs = '?', range = true,
                complete = function() return docker.list_containers({ 'ps', '--filter', 'status=exited', '--format',
                        '{{.Names}}' })
                end }
        )

        vim.api.nvim_create_user_command('StopContainer',
            function(...)
                docker.handle_container({ ... }, 'stop')
            end,
            { nargs = '?', range = true,
                complete = function() return docker.list_containers({ 'ps', '--format', '{{.Names}}' }) end }
        )
    end

    if dadbodconf.enabled then
        vim.api.nvim_create_user_command('ExecuteOnConnection',
            function(...)
                functions.execute_on_connection({ ... })
            end,
            { nargs = '?', range = true, complete = functions.get_connections }
        )

        vim.api.nvim_create_user_command('ExecuteOnDatabase',
            function(...)
                functions.execute_on_database({ ... })
            end,
            { nargs = '?', range = true, complete = functions.get_databases }
        )
    end
end

M.setup = function(opt)
    local config = vim.tbl_deep_extend('force', default, opt or {})

    functions.config = config
    functions.connection = config.connections[config.initial_connection]
    functions.database = config.connections[config.initial_connection].initial_database

    if config.docker.enabled then
        docker.config = config.docker
    end

    if config.dadbod.enabled then
        dadbod.config = config.dadbod
        dadbod.set_global(functions.connection, functions.database)
    end

    for k, v in pairs(config.lsp) do
        lsps[k](v, functions.connection, functions.database)
    end

    setup_commands(config.dadbod, config.docker)
end

return M

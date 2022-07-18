local M = {}
M.current = nil

local docker = require('nvim-databasehelper.docker')
local lsp = require('nvim-databasehelper.lsp')
local lsps = require('nvim-databasehelper.lsps.functions')
local dadbod = require('nvim-databasehelper.dadbod')
local databases = require('nvim-databasehelper.databases.functions')

local get_config_databases = function(databases)
    local choices = {}

    for db, _ in pairs(databases) do
        table.insert(choices, db)
    end

    return choices
end

local get_config = function(config, containers, selection)
    local db_config = nil

    if config.docker.enabled then
        db_config = docker.handle_selection(containers, selection, config.docker.defaults)
    end

    if db_config == nil then
        for k, v in pairs(config.databases) do
            if k == selection then
                db_config = v
            end
        end
    end

    return db_config
end

local handle_database_connection_selection = function(selection, config, containers)
    local db_config = get_config(config, containers, selection)

    if config.dadbod.enabled then
        dadbod.set_global(config.dadbod, db_config)
    end

    lsp.start_clients(config.lsp, db_config)

    M.current = db_config
end

M.get_databases = function(config)
    return databases.get_databases(config, M.current)
end

local handle_database_change = function(database, config)
    M.current.database = database

    if config.dadbod.enabled then
        dadbod.set_global(config.dadbod, M.current)
    end

    lsp.stop_clients(config.lsp)

    for k, v in pairs(config.lsp) do
        lsps[k](v, M.current)
    end
end

M.set_current_database = function(args, config)
    local arg = args[1].args

    if arg == '' then
        vim.ui.select(
            M.get_databases(),
            { prompt = 'Select database:' },
            function(selection)
                handle_database_change(selection, config)
            end
        )
    else
        handle_database_change(arg, config)
    end
end

M.get_database_connection_choices = function(config)
    local choices = get_config_databases(config.databases)
    local containers = nil

    if config.docker.enabled then
        containers = docker.get_docker_containers(config.docker.must_contain)

        for _, value in pairs(containers) do
            for key, _ in pairs(value) do
                table.insert(choices, key)
            end
        end
    end

    return choices, containers
end

function M.select_database_connection(args, config)
    lsp.stop_clients(config.lsp)

    local choices, containers = M.get_database_connection_choices(config)

    if args[1].args == '' then
        vim.ui.select(
            choices,
            { prompt = 'Select database connection:' },
            function(selection)
                handle_database_connection_selection(selection, config, containers)
            end
        )
    else
        handle_database_connection_selection(args[1].args, config, containers)
    end
end

M.execute_on_database_connection = function(args, config)
    local choices, containers = M.get_database_connection_choices(config)
    local arg = args[1].args

    if arg == '' then
        vim.ui.select(
            choices,
            { prompt = 'Select database connection:' },
            function(selection)
                dadbod.execute(get_config(config, containers, selection), args)
            end
        )
    else
        dadbod.execute(get_config(config, containers, arg), args)
    end
end

M.execute_on_database = function(args, config)
    local arg = args[1].args

    local old = M.current.database

    if arg == '' then
        vim.ui.select(
            M.get_databases(config),
            { prompt = 'Select database connection:' },
            function(selection)
                M.current.database = selection
                dadbod.execute(M.current, args)
            end
        )
    else
        M.current.database = arg
        dadbod.execute(M.current, args)
    end

    M.current.database = old
end

return M

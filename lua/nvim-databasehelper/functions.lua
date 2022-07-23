local M = {}
M.database = nil
M.connection = nil
M.config = nil

local filetypes = {
    postgresql = 'sql'
}

local docker = require('nvim-databasehelper.docker')
local lsp = require('nvim-databasehelper.lsp')
local dadbod = require('nvim-databasehelper.dadbod')
local databases = require('nvim-databasehelper.databases.functions')

local get_databases = function(connections)
    local list = {}

    for name, connection in pairs(connections) do
        local result = databases.get_databases(connection)

        for _, v in pairs(result) do
            table.insert(list, name .. ': ' .. v)
        end
    end

    return list
end

M.get_databases = function()
    local list = {}

    for _, v in pairs(get_databases(M.config.connections)) do
        table.insert(list, v)
    end

    for _, v in pairs(get_databases(docker.cache)) do
        table.insert(list, v)
    end

    if M.config.docker.enabled then
        local result = docker.get_containers(false)

        for _, v in pairs(result) do
            for k, _ in pairs(v) do
                table.insert(list, 'docker: ' .. k)
            end
        end
    end

    return list
end

local set_database = function(connection, database)
    M.database = database
    M.connection = connection

    if M.config.dadbod.enabled then
        dadbod.set_global(M.connection, M.database)
    end

    lsp.restart_clients(M.config.lsp, M.connection, M.database)
end

local perform_with_database = function(input, action)
    local parts = vim.split(input, ' ')
    local connection = table.remove(parts, 1):gsub(':', '')
    local database_or_container = table.concat(parts, ' ')

    if M.config.docker.enabled then
        if connection == 'docker' then
            local container = table.concat(parts, ' ')
            local docker_connection = docker.handle_selection(container)

            local list = {}

            local result = databases.get_databases(docker_connection)

            for _, v in pairs(result) do
                table.insert(list, v)
            end

            if docker_connection ~= nil then
                vim.ui.select(
                    list,
                    { prompt = 'Select database:' },
                    function(selection)
                        action(docker_connection, selection)
                    end
                )
            end

            return
        end

        if docker.cache[connection] ~= nil then
            action(docker.cache[connection], database_or_container)
        end
    end

    action(M.config.connections[connection], database_or_container)
end

M.set_current_database = function(args)
    local arg = args[1].args

    if arg == '' then
        vim.ui.select(
            M.get_databases(),
            { prompt = 'Select database:' },
            function(selection)
                perform_with_database(selection, set_database)
            end
        )
    else
        perform_with_database(arg, set_database)
    end
end

M.open_database_window = function()
    local api = vim.api
    api.nvim_command('belowright split dbh.in')
    api.nvim_win_set_height(0, M.config.initial_window_height)
    api.nvim_command('set ft=' .. filetypes[M.connection.driver])
    api.nvim_command('setlocal bt=nofile')
end


M.get_connections = function()
    local list = {}

    for k, _ in pairs(M.config.connections) do
        table.insert(list, k)
    end

    if M.config.docker.enabled then
        for _, v in pairs(docker.get_containers(true)) do
            for container, _ in pairs(v) do
                table.insert(list, 'docker: ' .. container)
            end
        end
    end

    return list
end

local get_connection_data = function(connection)
    local parts = vim.split(connection, ' ')

    if #parts > 1 then
        table.remove(parts, 1)
    end

    connection = table.concat(parts, ' ')

    local res = nil

    if M.config.connections[connection] ~= nil then
        res = M.config.connections[connection]
    end

    if M.config.docker.enabled and res == nil then
        res = docker.handle_selection(connection)
    end

    return res
end

M.execute_on_connection = function(args)
    local connection = args[1].args

    if connection == '' then
        vim.ui.select(
            M.get_connections(),
            { prompt = 'Select connection:' },
            function(selection)
                dadbod.execute(get_connection_data(selection), '', args)
            end
        )
    else
        dadbod.execute(get_connection_data(connection), '', args)
    end
end

M.execute_on_database = function(args)
    local arg = args[1].args

    if arg == '' then
        vim.ui.select(
            M.get_databases(),
            { prompt = 'Select database:' },
            function(selection)
                perform_with_database(selection, function(connection, database)
                    dadbod.execute(connection, database, args)
                end)
            end
        )
    else
        perform_with_database(arg, function(connection, database)
            dadbod.execute(connection, database, args)
        end)
    end
end

return M

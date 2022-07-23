local M = {}
M.config = nil
M.cache = {}

local supported_drivers = { 'postgresql' }

local get_container_host = function(containers, input)
    for _, value in pairs(containers) do
        for key, host in pairs(value) do
            if input == key then
                return host
            end
        end
    end

    return nil
end

M.get_containers = function(ignore_cache)
    local Job = require 'plenary.job'
    local job = Job:new {
        command = 'docker',
        args = { 'ps', '--format', '{{.Names}};{{.Ports}}' }
    }

    job:sync()
    local result = job:result()

    local containers = {}

    for _, value in pairs(result) do
        local parts = vim.split(value, ';')
        local name = parts[1]

        local found = false

        if #M.config.must_contain ~= 0 then
            for _, filter in pairs(M.config.must_contain) do
                if string.find(name, filter) then
                    found = true
                end
            end
        else
            found = true
        end

        if found then
            local host = vim.split(parts[2], '-')[1]

            if M.cache[name] == nil or ignore_cache then
                table.insert(containers, { [name] = host })
            end
        end
    end

    return containers
end

M.handle_selection = function(selection)
    if M.cache[selection] ~= nil then
        return M.cache[selection]
    end

    local containers = M.get_containers()
    local config = {}
    local container_host = get_container_host(containers, selection)

    if container_host == nil then
        return nil
    end

    local host_port = vim.split(container_host, ':')
    config.host = host_port[1]
    config.port = host_port[2]

    vim.ui.input({ prompt = 'Driver (default = ' .. M.config.defaults.driver .. '): ' },
        function(input)
            config.driver = input or M.config.defaults.driver
        end)

    if not vim.tbl_contains(supported_drivers, config.driver) then
        print('Unsupported driver.')
        return nil;
    end

    local d = vim.tbl_get(M.config.defaults, config.driver)

    if d ~= nil then
        config = vim.tbl_deep_extend('force', config, d)
    end

    local user_prompt = 'Username: '
    if config.user ~= '' then
        user_prompt = 'Username (default = ' .. config.user .. '): '
    end

    local password_prompt = 'Password: '
    if config.password ~= '' then
        password_prompt = 'Password (default: <hidden>): '
    end

    local database_prompt = 'Initial Database: '
    if config.initial_database ~= '' then
        database_prompt = 'Initial Database (default = ' .. config.initial_database .. '): '
    end

    vim.ui.input({ prompt = user_prompt },
        function(input) config.user = input or config.user end)

    vim.ui.input({ prompt = password_prompt },
        function(input) config.password = input or config.password end)

    vim.ui.input({ prompt = database_prompt },
        function(input) config.initial_database = input or config.initial_database end)

    M.cache[selection] = config

    return config
end

return M

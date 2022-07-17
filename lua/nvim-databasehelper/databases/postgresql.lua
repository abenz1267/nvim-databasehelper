local M = {}

local to_ignore = { 'postgres', 'template0', 'template1', 'rows)', '' }

M.get_databases = function(config, current)
    vim.env.PGPASSWORD = current.password

    local Job = require 'plenary.job'

    local job = Job:new {
        command = 'psql',
        args = { '-h', current.host, '-p', current.port, '-U', current.user, '-c', '\\l' }
    }

    job:sync()
    local result = job:result()

    local databases = {}

    for k, value in pairs(result) do
        if k ~= 1 and k ~= 2 and k ~= 3 then
            local database = vim.split(value, ' ')[2]

            local ignore = false
            for _, i in pairs(to_ignore) do
                if database == i or database == nil then
                    ignore = true
                    break
                end
            end

            if ignore == false then
                print(database)
                table.insert(databases, database)
            end
        end
    end

    return databases
end

return M

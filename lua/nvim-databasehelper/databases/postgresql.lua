local M = {}

M.get_databases = function(connection)
    vim.env.PGPASSWORD = connection.password

    local Job = require 'plenary.job'

    local job = Job:new {
        command = 'psql',
        args = { '-h', connection.host, '-p', connection.port, '-U', connection.user, '-t', '-c',
            'SELECT datname FROM pg_database WHERE datname <> ALL (\'{template0,template1,postgres}\')' }
    }

    job:sync()
    local result = job:result()

    local databases = {}

    for _, value in pairs(result) do
        value = vim.trim(value)

        if value ~= '' then
            table.insert(databases, value)
        end
    end

    return databases
end

return M

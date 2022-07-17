local M = {}

local database_functions = {
    postgresql = require('nvim-databasehelper.databases.postgresql').get_databases
}

M.get_databases = function(config, current)
    return database_functions[current.driver](config, current)
end

return M

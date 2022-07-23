local M = {}

local database_functions = {
    postgresql = require('nvim-databasehelper.databases.postgresql').get_databases
}

M.get_databases = function(connection)
    return database_functions[connection.driver](connection)
end

return M

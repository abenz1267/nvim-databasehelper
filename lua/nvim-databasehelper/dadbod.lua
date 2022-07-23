local M = {}
M.config = nil

local drivers = {
    postgresql = 'postgres'
}

local get_string = function(connection, database)
    local user_string = connection.user

    if connection.password ~= '' then
        user_string = connection.user .. ':' .. connection.password
    end

    return drivers[connection.driver] ..
        '://' .. user_string .. '@' .. connection.host .. ':' .. connection.port .. '/' .. database
end

M.set_global = function(connection, database)
    vim.g[M.config.var] = get_string(connection, database)
end

M.execute = function(connection, database, args)
    local pre = ''

    if args[1].range > 0 and args[1].line1 ~= '' and args[1].line2 ~= '' then
        pre = tostring(args[1].line1) .. ',' .. tostring(args[1].line2)
    end

    local final = pre .. '%DB ' .. get_string(connection, database)

    vim.cmd(final)
end

return M

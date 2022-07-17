local M = {}

local drivers = {
    postgresql = 'postgres'
}

local get_string = function(config)
    local user_string = config.user

    if config.password ~= '' then
        user_string = config.user .. ':' .. config.password
    end

    return drivers[config.driver] ..
        '://' .. user_string .. '@' .. config.host .. ':' .. config.port .. '/' .. config.database
end

M.set_global = function(dadbodconfig, config)
    vim.g[dadbodconfig.var] = get_string(config)
end

M.execute = function(config, args)
    local pre = ''

    if args[1].range > 0 and args[1].line1 ~= '' and args[1].line2 ~= '' then
        pre = tostring(args[1].line1) .. ',' .. tostring(args[1].line2)
    end

    local final = pre .. '%DB ' .. get_string(config)

    vim.cmd(final)
end

return M

local M = {}

local drivers = {
    postgresql = 'postgres'
}

M.set_global = function(dadbodconfig, config)
    local user_string = config.user

    if config.password ~= '' then
        user_string = config.user .. ':' .. config.password
    end

    vim.g[dadbodconfig.var] = drivers[config.driver] ..
        '://' .. user_string .. '@' .. config.host .. ':' .. config.port .. '/' .. config.database
end

return M

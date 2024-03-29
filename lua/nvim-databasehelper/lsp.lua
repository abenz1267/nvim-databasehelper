local lsps = require('nvim-databasehelper.lsps.functions')

local M = {}

M.stop_clients = function(lsp)
    local clients = vim.lsp.get_active_clients()

    for k, _ in pairs(lsp) do
        local client = nil

        for _, c in pairs(clients) do
            if c.name == k then
                client = c
            end
        end

        if client ~= nil then
            vim.lsp.stop_client(client.id, true)
        end
    end
end

M.restart_clients = function(config, connection, database)
    M.stop_clients(config)

    for k, v in pairs(config) do
        lsps[k](v, connection, database)
    end
end

return M

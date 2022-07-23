local start = function(lsp_config, connection, database)
    local new_config = {
        settings = {
            sqlLanguageServer = {
                connections = {
                    {
                        adapter = connection.driver,
                        host = connection.host,
                        port = connection.port,
                        user = connection.user,
                        password = connection.password,
                        database = database
                    }
                }
            }
        }
    }

    local merged_config = vim.tbl_deep_extend('force', lsp_config, new_config)

    require('lspconfig')['sqlls'].setup(merged_config)
end

return start

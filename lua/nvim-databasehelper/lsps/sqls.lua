local start = function(lsp_config, connection, database)
    local dataSourceName = 'host=' ..
        connection.host ..
        ' port=' ..
        connection.port .. ' user=' ..
        connection.user .. ' password=' .. connection.password .. ' sslmode=disable dbname=' .. database

    local new_config = {
        settings = {
            sqls = {
                connections = {
                    {
                        driver = connection.driver,
                        dataSourceName = dataSourceName
                    }
                }
            }
        }
    }

    local merged_config = vim.tbl_deep_extend('force', lsp_config, new_config)

    require('lspconfig')['sqls'].setup(merged_config)
end

return start

local start = function(lsp_config, config)
    local dataSourceName = 'host=' ..
        config.host ..
        ' port=' ..
        config.port .. ' user=' ..
        config.user .. ' password=' .. config.password .. ' sslmode=disable dbname=' .. config.database

    local new_config = {
        settings = {
            sqls = {
                connections = {
                    {
                        driver = config.driver,
                        dataSourceName = dataSourceName
                    }
                }
            }
        }
    }

    local merged_config = vim.tbl_deep_extend('force', lsp_config, new_config)

    require("lspconfig")["sqls"].setup(merged_config)
end

return start

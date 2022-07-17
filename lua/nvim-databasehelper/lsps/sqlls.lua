local start = function(lsp_config, config)
    local new_config = {
        settings = {
            sqlLanguageServer = {
                connections = {
                    {
                        adapter = config.driver,
                        host = config.host,
                        port = config.port,
                        user = config.user,
                        password = config.password,
                        database = config.database
                    }
                }
            }
        }
    }

    local merged_config = vim.tbl_deep_extend('force', lsp_config, new_config)

    require('lspconfig')['sqlls'].setup(merged_config)
end

return start

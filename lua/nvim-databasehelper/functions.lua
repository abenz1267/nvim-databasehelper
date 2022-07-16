local M = {}
local docker = require("nvim-databasehelper.docker")
local lsp = require("nvim-databasehelper.lsp")
local dadbod = require("nvim-databasehelper.dadbod")

local get_config_databases = function(databases)
    local choices = {}

    for db, _ in pairs(databases) do
        table.insert(choices, db)
    end

    return choices
end

function M.select_database(config)
    lsp.stop_clients(config.lsp)

    local choices = get_config_databases(config.databases)
    local containers = nil

    if config.docker.enabled then
        containers = docker.get_docker_containers(config.docker.must_contain)

        for _, value in pairs(containers) do
            for key, _ in pairs(value) do
                table.insert(choices, key)
            end
        end
    end

    vim.ui.select(
        choices,
        { prompt = 'Select database:' },
        function(selection)
            local db_config = nil

            if config.docker.enabled then
                db_config = docker.handle_selection(containers, selection, config.docker.defaults)
            end

            if db_config == nil then
                for k, v in pairs(config.databases) do
                    if k == selection then
                        db_config = v
                    end
                end
            end

            if config.dadbod.enabled == true then
                dadbod.set_global(config.dadbod, db_config)
            end

            lsp.start_clients(config.lsp, db_config)
        end
    )
end

return M

# nvim-databasehelper

# Features

-   define various connections
-   discover Docker containers on demand
-   discover databases on connections/containers
-   change running database connection
    -   restart LSP with proper connection
    -   update [vim-dadbod](https://github.com/tpope/vim-dadbod) global connection string
-   execute statements (via vim-dadbod)
    -   execute for different database/connection
-   caches Docker information for repeated usage
-   start/stop docker containers

## Currently supported language servers

-   Postgres: sqls, sqlls is broken (see [here](https://github.com/joe-re/sql-language-server/issues/128))

## Requires

-   [nvim-plenary](https://github.com/nvim-lua/plenary.nvim) (for Docker containers)
-   [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
-   [vim-dadbod](https://github.com/tpope/vim-dadbod) (for statement execution)

## Example Setup

WARNING: don't setup your LSP server manually, as you'll end up with multiple active clients.

```lua
require('nvim-databasehelper').setup(
    {
        lsp = {
            sqls = config, -- config you'd pass to lspconfig["sqls"].setup(). Omit the connections!
        },
        docker = {
            enabled = true,
            must_contain = { 'some' }, -- only show Docker containers that contain one of the given strings
            defaults = { -- when selecting a Docker container you'll be prompted for various parameters, you can define default values here
                postgresql = {
                    user = 'postgres',
                    password = 'somePassword',
                    initial_database = 'testdb',
                }
            }
        },
        dadbod = {
            enabled = true,
            var = 'dadbodstring', -- global Vim variable to use for dadbod ":DB g:<thisvariable> ..."
        },
        connections = {
            system = {
                initial_database = 'benchmark',
                driver = 'postgresql',
                host = '127.0.0.1',
                port = '5432',
                user = 'postgres',
                password = '',
            }
        },
        initial_window_height = 10,
    }
)
```

## Commands

| Command             | Function                                                                                                       |
| ------------------- | -------------------------------------------------------------------------------------------------------------- |
| SwitchDatabase      | switch database. Autocomplete or select window.                                                                |
| ExecuteOnDatabase   | execute buffer or visual selection on specific database.                                                       |
| ExecuteOnConnection | execute buffer or visual selection on specific connection.                                                     |
| OpenDatabaseWindow  | opens a new buffer in the current window where you can write your query. Useful if you want LSP functionality. |
| StartContainer      | Starts the selected docker container                                                                           |
| StopContainer       | Stops the selected docker container                                                                            |

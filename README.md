# nvim-databasehelper

# Features

-   define various connections
-   discover Docker containers on demand
-   change running database connection
    -   restart LSP with proper connection
    -   update [vim-dadbod](https://github.com/tpope/vim-dadbod) global connection string
-   execute statements (via vim-dadbod)
    -   execute for different database/connection

You can choose between pre-defined servers as well as enable dynamic Docker container discovering.

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
                    database = 'testdb',
                }
            }
        },
        dadbod = {
            enabled = true,
            var = 'dadbodstring', -- global Vim variable to use for dadbod ":DB g:<thisvariable> ..."
        },
        initial_connection = initial_connection,
        databases = {
            benchmark = {
                initial = true,
                driver = 'postgresql',
                host = '127.0.0.1',
                port = '5432',
                user = 'postgres',
                password = '',
                database = 'benchmark',
            }
        }
    }
)
```

## Commands

| Command                     | Function                                                            |
| --------------------------- | ------------------------------------------------------------------- |
| SwitchDatabaseConnection    | switch connection. Autocomplete or select window.                   |
| SwitchDatabase              | switch database. Autocomplete or select window.                     |
| ExecuteOnDatabase           | Execute buffer or visual selection on specific database.            |
| ExecuteOnDatabaseConnection | Execute buffer or visual selection on specific database connection. |

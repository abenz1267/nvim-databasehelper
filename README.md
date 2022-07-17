# nvim-databasehelper

A plugin that lets you switch database connections and handle various things, as in:

-   [vim-dadbod](https://github.com/tpope/vim-dadbod) global connection string
-   restarts LSP with proper connection

You can choose between pre-defined servers as well as enable dynamic Docker container discovering.

## Requires

-   [nvim-plenary](https://github.com/nvim-lua/plenary.nvim) (for Docker containers)
-   [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)

## Example Setup

WARNING: don't setup your LSP server manually, as you'll end up with multiple active clients.

```lua
local initial_connection = {
    driver = 'postgresql',
    host = '127.0.0.1',
    port = '5432',
    user = 'postgres',
    password = '',
    database = 'benchmark',
}

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
            benchmark = initial_connection
        }
    }
)
```

## Commands

| Command                  | Function                                          |
| ------------------------ | ------------------------------------------------- |
| SwitchDatabaseConnection | switch connection. Autocomplete or select window. |
| SwitchDatabase           | switch database. Autocomplete or select window.   |

Simple run ":SwitchDatabaseConnection <database connection or enter for selection>", select the desired database.
If the database is a Docker container, you'll be prompted for various parameters.

## Current limitations

-   LSPs:
    -   only works with [sqls](https://github.com/lighttiger2505/sqls) at the moment

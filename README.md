# 📓📝 zeekay.nvim

Use zettelkasten easily in Neovim!

> [!NOTE]
> This plugin is a Work-In-Progress!
> Expect bugs at this stage in development!

## Installation

```lua
return {
  "teesh3rt/zeekay.nvim",
  opts = {}
}
```

## Usage

Zeekay provides either a Lua API or a command interface.

### The Lua API

```lua
local zk = require("zeekay")
zk.new_note("the Zettelkasten method") -- with a string for a name
zk.new_note() -- interactively picking a name
zk.pick_note() -- pick a note interactively
```

### The command interface

```vim
ZeekayNewNote the Zettelkasten method
ZeekayNewNote
ZeekayPickNote
```

## Contributing

This project is still WIP! Feel free to contribute!

# Aim
focus.nvim provides a quick way to highlight segments of text, allowing easy navigation
between screens while maintaining visual focus on important sections.

# Inspiration
In my studies into assembly code I constantly found myself reviewing two files side-
by-side whilst documenting my learning on a third screen. As I switched focus between
the two windows I frequently lost track of the segments I was looking at. I recently
stumbled accross [folke/twilight.nvim](https://github.com/folke/twilight.nvim) which
I thought was a really pretty and peaceful way to dim and focus segments of text. As
a result I created this plugin as an unobtrusive way to focus my attention on
specified areas of text.

# Installation:
### Lazy Install
To install using Lazy:
```lua
return {
    "hahaharry10/focus.nvim",
}
```

## Keymapping
To map the functions to the keys use the following:
```lua
require("focus"):focus_visual_selection() -- In Visual and Visual-Line mode.
require("focus"):unfocus()
```

`focus_visual_selection` can only works within Visual or Visual-Line mode. There is logic
within `focus_visual_selection` to distinguish between Visual and Visual-Line mode so
keymapping under Visual mode only is sufficient.

An example keymapping using which-key (used in my configuration) is as follows:
```lua
{
    mode = {"v"},
    {"<leader>l", function() require("focus"):focus_visual_selection() end, desc = "Focus Selection"},
},
{
    mode = {"n"},
    {"<leader>l", function() require("focus"):unfocus() end, desc = "Unfocus text" },
}
```

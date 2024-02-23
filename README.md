# easynums.nvim

With this plugin you can remap any key to a number.
Activation key -> your keys that should be "converted" -> any other key to confirm -> numbers get typed.
To abort the "conversion" just press the cancel key.

Especially useful for relative line navigation

```
--- Lazy
return {
  { "N4nid/easynums.nvim" },
  opts = {
    num = "basdfghjkl", -- the keys to remap to 0123456789, b would be in this case 0
    cancelKey = "c",
    key = "ö", -- the activation key. Currently no support for combinations like <C-n>
  },
}
```

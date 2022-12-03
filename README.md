# virtual.nvim

If you're tired of having a lot of diagnoses appearing on your screen at the same time,<br/>
you've come to the right place.<br/>
Virtual.nvim allows you to display only the virtual text on your current line for the severities you want

## Installation

To install, use your plugin manager, no need to call any setup function here.

```lua

use "vzytoi/virtual.nvim"

```

## Setup  

To set it up, simply call the grab function at the location shown below.<br/>
In this example, the virtual lines will always be displayed for errors<br/>
but virtual.nvim will take care of displaying errors of lower severity (hint, warning, info)

```lua
vim.diagnostic.config({
  virtual_text = {
      severity = require('virtual').grab {
          min = vim.diagnostic.severity.ERROR,
      }
  }  
})
```

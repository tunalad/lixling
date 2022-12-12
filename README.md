# Lixling
Minimalist-ish Lite XL plugin manager inspired by vim-plug.
Goal of this project was to write a small and simple plugin manager for [Lite XL](https://lite-xl.com/) that doesn't depend on any lua modules or programs (except git). 

# Table of contents
1. [Installation](#installation)
2. [Usage](#usage)
    1. [Configuration](#configuration)
    2. [Adding plugins](#adding-plugins)
    3. [Commands](#commands)
3. [Examples](#examples)
4. [Known issues](#known-issues)

# 1. Installation
Clone this repo to your `~/.config/lite-xl` directory (**NOT** in the `plugins`)
```sh
git clone https://github.com/tunalad/lixling.git ~/.config/lite-xl
```
# 2. Usage
## 2.1. Configuration
First, you have to import `lixling` to your `init.lua` config file and call the `plugins` function, giving it a table.
```lua
local lixling = require("lixling")

lixling.plugins({
    -- plugins go here
})
```

## 2.2. Adding plugins
**Note**: I will be writing keys as `["name"]`, but you can still write them simply as `name`.

[Jump right to the examples](#examples)

### 2.2.1. `.lua` and `.git` URLs
```lua
["name"] = "raw .lua or .git link",
-- OR
["name"] = { "raw .lua or .git link" },
```
You simply give the key a link of a raw `.lua` file or a valid `.git` repository. If it's a raw `.lua` link, it will `curl` to your `plugins` directory with the key as name. So if we called our plugin `banana`, it will download that plugin as `banana.lua`. Same goes with the git repo link, it will clone everything into `banana/` directory.

**IMPORTANT: DO NOT LIST PRIVATE REPOSITORIES.** When downloading & updating from repositories, it will freeze you Lite XL for until it finishes it's job. Cloning private repositories will ask you for a password, thus freezing your text editor COMPLETELY (I haven't tested that theory, but it should be the case). You have been warned.

### 2.2.2. Non-master branch
By default, Lixling will assume that we're cloning and pulling from a `master` branch. If we want to clone from a different repo, you'll have to specify it as the second array element:
```lua
["name"] = { "git link", "branch" }
```

### 2.2.3. Post-download hook
Some plugins require extra steps after downloading. In those cases, you can give the array a third element. 
```lua
["name"] = { "`.git` link", "branch", "post-download hook" }
```
Post-download hook is being executed inside the plugin's directory.

## 2.3. Commands
| Command               | Description                   |
|-----------------------|-------------------------------|
| Lixling: Install      | Installs listed plugins       |
| Lixling: Update       | Updates listed plugins        |
| Lixling: Upgrade      | Updates Lixling itself        | 
| Lixling: Clear        | "Exiles" unlisted plugins     |

"Exiled" plugins will be moved to `~/.config/lite-xl/lixling/exiled`. 
To whitelist a plugin, give it an empty url value:
```lua
["name"] = "",
-- OR 
["name"] = {""},
```

### 3. Examples:
```lua
lixling.plugins({
    -- Lixling will ignore this plugin when exiling files
    ["testplug"] = "",
    
    -- Lixling will download (curl) the linked file as "minimap.lua" 
    ["minimap"] = "https://raw.githubusercontent.com/lite-xl/lite-xl-plugins/master/plugins/minimap.lua",
    
    -- Lixling wll clone/pull the repository as "vibe/"
    ["vibe"] = "https://github.com/eugenpt/lite-xl-vibe.git",
    
    -- Lixling will download (curl) the linked file as "wordcount.lua" 
    ["wordcount"] = {"https://raw.githubusercontent.com/lite-xl/lite-xl-plugins/master/plugins/wordcount.lua"},
    
    -- Lixling will clone/pull the repository as "console/" from the "dev" branch
    ["console"] = {"https://github.com/lite-xl/console.git", "dev"},
    
    -- Lixling will clone/pull "terminal/" from the "master" and run the "make release" command
    ["terminal"] = { "https://github.com/benjcollins/lite-xl-terminal.git", "master", "make release" },
    
    -- Lixling will clone/pull "exter" from the "main" and run the "mv exterm.lua init.lua" command
    ["exterm"] = { "https://github.com/ShadiestGoat/lite-xl-exterm.git", "main", "mv exterm.lua init.lua" },
})
```

# 4. Known issues 
- Windows isn't supported.
- Exiling folders won't work if they're already in the `exiled` directory 
- Downloading & updating commands freeze Lite XL until they finish executing. I'm not even sure if multiprocessing is possible in pure lua.

Not that this is my first time ever coding something in lua. If there's any more problems, report them by open an issue. 

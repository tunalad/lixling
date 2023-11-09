# Lixling

Minimalist-ish [Lite XL](https://lite-xl.com/) plugin manager inspired by [ vim-plug](https://github.com/junegunn/vim-plug).
The goal of this project was to write a small and simple plugin manager for Lite XL that doesn't depend on any lua modules or programs (except git) that aren't included with the text editor already.

# Table of contents

1. [Installation](#1-installation)
2. [Usage](#2-usage)
    1. [Configuration](#21-configuration)
    2. [Adding plugins](#22-adding-plugins)
    3. [Commands](#23-commands)
3. [Examples](#3-examples)
4. [Known issues](#4-known-issues)

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

**Note**: Don't add private repositories to the list. When cloning, git will ask for your password, thus stopping the plugin from installing and updating the latter plugins in the list.

### 2.2.2. Non-master branch

By default, Lixling will assume that we're cloning and pulling from the `master` branch. If we want to clone from a different branch, you'll have to specify it as the second element:

```lua
["name"] = { "git link", "branch" }
```

### 2.2.3. Post-download hook

Some plugins require extra steps after downloading. In those cases, you can add a command as the third element.

```lua
["name"] = { "`.git` link", "branch", "post-download hook" }
```

Post-download hook is being executed inside the plugin's directory.

## 2.3. Commands

| Command          | Description               |
| ---------------- | ------------------------- |
| Lixling: Install | Installs listed plugins   |
| Lixling: Update  | Updates listed plugins    |
| Lixling: Upgrade | Updates Lixling itself    |
| Lixling: Clear   | "Exiles" unlisted plugins |

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
    -- Lixling will ignore this plugin when exiling
    ["testplug"] = "",

    -- Lixling will download (curl) the linked file as "minimap.lua"
    ["minimap"] = "https://raw.githubusercontent.com/lite-xl/lite-xl-plugins/master/plugins/minimap.lua",

    -- Lixling wll clone/pull the repository as "lite-xl-vibe/"
    ["lite-xl-vibe"] = "https://github.com/eugenpt/lite-xl-vibe.git",

    -- Lixling will download (curl) the linked file as "wordcount.lua"
    ["wordcount"] = {"https://raw.githubusercontent.com/lite-xl/lite-xl-plugins/master/plugins/wordcount.lua"},

    -- Lixling will clone/pull the repository as "console/" from the "dev" branch
    ["console"] = {"https://github.com/lite-xl/console.git", "dev"},

    -- Lixling will clone/pull "terminal/" from the "master" and run the "make release" command
    ["terminal"] = { "https://github.com/benjcollins/lite-xl-terminal.git", "master", "make release" },

    -- Lixling will clone/pull "exterm" from the "main" and run the "mv exterm.lua init.lua" command
    ["exterm"] = { "https://github.com/ShadiestGoat/lite-xl-exterm.git", "main", "mv exterm.lua init.lua" },
})
```

# 4. Known issues

-   Windows isn't supported.
-   Exiling folders won't work if they're already in the `exiled` directory

Note that this is my first time ever coding something in lua. If there's any more problems, report them by opening an issue.

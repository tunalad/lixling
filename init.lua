-- mod-version:3
-----------------------------------------------------------------------
local core = require "core"
local command = require "core.command"
local os = require "os"
--local io = require "io"

local utils = require "lixling/utils"

-----------------------------------------------------------------------
local plugins_list = {} -- list of the plugins found in the init.lua

-- test function
local function hello_world()-- {{{
    core.log("hello world ayy")
    local thing = os.execute("pwd")
end-- }}}
	
-- function gets the table from main config file and assigns it to the `plugins_list` in this file
local function get_plugins_list(plug_list)-- {{{
    plugins_list = plug_list
end-- }}}

-- logs out plugins list 
local function print_plugins_list()-- {{{
    for plug in pairs(plugins_list) do
        core.log(plug .. ": " .. plugins_list[plug])
    end
end-- }}}

-- looks for unlisted files in the plugins dir
local function clear_plugins()-- {{{
    local dir_plugs = utils.dir_lookup("plugins/")

    for f in ipairs(dir_plugs) do
        if(not plugins_list[dir_plugs[f]:sub(1, -5)]) then
            core.log("LIXLING: file '" .. dir_plugs[f] .. "' can be deleted")
        end
    end

    command.perform("core:open-log")
end-- }}}

-- Downloads the plugin (if it's not already installed)
local function download_plugins()-- {{{
    local dir_plugs = utils.dir_lookup("plugins/")

    for plug in pairs(plugins_list) do
        if not utils.array_has_value(dir_plugs, plug..".lua") then
            if utils.string_ends_with(plugins_list[plug], ".lua") then
                utils.curl(plug..".lua", plugins_list[plug])
                core.log("LIXLING: Downloaded '".. plug .. ".lua'")
            end
        else
                core.log("LIXLING: '".. plug .. " plugin' is already installed.")
        end
    end

    command.perform("core:open-log")
end-- }}}

-- Updates outdated plugins (atm it just informs you about that)
local function update_plugins()-- {{{
    for plug in pairs(plugins_list) do
        if utils.diff and utils.string_ends_with(plugins_list[plug], ".lua") then
            core.log("LIXLING: " .. (plug..".lua") .. " needs an updating")
        end
    end

    command.perform("core:open-log")
end-- }}}
-----------------------------------------------------------------------

command.add("core.docview", {["lixling:install"] = download_plugins})
command.add("core.docview", {["lixling:clear"] = clear_plugins})
command.add("core.docview", {["lixling:update"] = update_plugins})
--command.add("core.docview", {["lixling:upgrade"] = hello_world})

return { get_plugins_list = get_plugins_list }

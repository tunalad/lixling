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

-- looks for unlisted files in the plugins dir
local function clear_plugins()-- {{{
    core.log("---------------------------- LIXLING: CLEAR ----------------------------")
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
    core.log("--------------------------- LIXLING: INSTALL ---------------------------")
    local dir_plugs = utils.dir_lookup("plugins/")

    for plug in pairs(plugins_list) do
        -- RAW .LUA FILE
        if not utils.array_has_value(dir_plugs, plug..".lua") then
            if utils.string_ends_with(plugins_list[plug], ".lua") then
                utils.curl(plug..".lua", plugins_list[plug])
                core.log("LIXLING: Downloaded '".. plug .. ".lua'")
            end
        end

        -- GIT REPO CLONE
        if utils.string_ends_with(plugins_list[plug], ".git") then
            local status = utils.git_clone("plugins/"..plug, plugins_list[plug])

            if status then
                core.log("LIXLING: Downloaded '" .. plug .. "' ")
            end
        end
    end

    command.perform("core:open-log")
end-- }}}

-- Updates outdated plugins (atm it just informs you about that)
local function update_plugins()-- {{{
    core.log("--------------------------- LIXLING: UPDATE ----------------------------")

    command.perform("core:open-log")
    local dir_plugs = utils.dir_lookup("plugins/")

    for plug in pairs(plugins_list) do
        -- if IS_LISTED and IS_RAW_LUA_FILE_LINK and IS_DOWNLOADED
        if utils.diff("plugins/"..plug..".lua", "<(curl -s ".. plugins_list[plug]..")") and utils.string_ends_with(plugins_list[plug], ".lua") and utils.array_has_value(dir_plugs, plug..".lua") then
            utils.curl(plug..".lua", plugins_list[plug])
            core.log("LIXLING: Updated: '" .. (plug..".lua") .. "'.")
        end

        if utils.string_ends_with(plugins_list[plug], ".git") then
            local status = utils.git_pull("plugins/"..plug)

            if not status == "Already up to date." then
                core.log("LIXLING: '" .. plug .. "' repo updated")
            end
            --core.log("LIXLING: '".. plug.. "' - " .. status)
        end
    end
end-- }}}

local function upgrade_self()-- {{{
    local status = utils.git_pull("lixling/")

    if not status == "Already up to date." then
        core.log("LIXLING: Upgraded.")
    else
        core.log("LIXLING: Already up to date.")
    end
end-- }}}

-----------------------------------------------------------------------

command.add("core.docview", {["lixling:install"] = download_plugins})
command.add("core.docview", {["lixling:clear"] = clear_plugins})
command.add("core.docview", {["lixling:update"] = update_plugins})
command.add("core.docview", {["lixling:upgrade"] = upgrade_self})

return { get_plugins_list = get_plugins_list }

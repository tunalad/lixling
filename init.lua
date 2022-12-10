-- mod-version:3
-----------------------------------------------------------------------
local core = require "core"
local command = require "core.command"
local os = require "os"

local utils = require "lixling/utils"

-----------------------------------------------------------------------
local plugins_list = {} -- list of the plugins found in the init.lua

-- test function
local function hello_world()-- {{{
    core.log("hello world ayy")
    local thing = os.execute("pwd")
end-- }}}
	
-- function gets the table from main config file and assigns it to the `plugins_list` in this file
local function plugins(plug_list)-- {{{
    plugins_list = plug_list
end-- }}}

-- looks for unlisted files in the plugins dir
local function clear_plugins()-- {{{
    core.log("---------------------------- LIXLING: CLEAR ----------------------------")
    local dir_plugs = utils.dir_lookup("plugins/")

    local clear_list = {}
    local clear_size = 0

    for f in ipairs(dir_plugs) do
        if utils.string_ends_with(dir_plugs[f], ".lua") then
            if plugins_list[dir_plugs[f]:sub(1, -5)] == nil then
                table.insert(clear_list, dir_plugs[f])
                clear_size=clear_size+1

                core.log("LIXLING: File '"..dir_plugs[f].."' added to exile list.")
            end
        elseif utils.string_ends_with(dir_plugs[f], "/") then
            if plugins_list[dir_plugs[f]:sub(1, -2)] == nil then
                table.insert(clear_list, dir_plugs[f])
                clear_size=clear_size+1

                core.log("LIXLING: Folder '"..dir_plugs[f].."' added to exile list.")
            end
        end
    end

    command.perform("core:open-log")

    core.command_view:enter("LIXLING: Found ".. clear_size .." unlisted plugins, exile them? (y/N)", {
        submit = function(input)
            if(string.lower(input) == "y" or string.lower(input) == "yes" ) then
                for plug in ipairs(clear_list) do
                    core.log("moving: ".. clear_list[plug])
                    io.popen("mkdir lixling/exiled"):read()
                    os.rename("plugins/".. clear_list[plug], "lixling/exiled/".. clear_list[plug])
                end
                core.log("LIXLING: ".. clear_size .. " plugins exiled. You can find them in lixling/exiled") 
            end
        end
    })

end-- }}}

-- Downloads the plugin (if it's not already installed)
local function download_plugins()-- {{{
    core.log("--------------------------- LIXLING: INSTALL ---------------------------")
    local dir_plugs = utils.dir_lookup("plugins/")

    for plug in pairs(plugins_list) do
        -- If it's a table
        if type(plugins_list[plug]) == "table" then
            for i in pairs(plugins_list[plug]) do
                if i == "branch" then
                    local status = utils.git_clone("plugins/"..plug, plugins_list[plug]["url"], plugins_list[plug][i])

                    if status then
                        core.log("LIXLING: Downloaded '" .. plug .. "' ")
                    end
                end
            end

        -- If it's NOT a table
        else
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
    end

    command.perform("core:open-log")
end-- }}}

-- Updates outdated plugins
local function update_plugins()-- {{{
    core.log("--------------------------- LIXLING: UPDATE ----------------------------")

    command.perform("core:open-log")
    local dir_plugs = utils.dir_lookup("plugins/")

    for plug in pairs(plugins_list) do
        -- If it's a table
        if type(plugins_list[plug]) == "table" then
            for i in pairs(plugins_list[plug]) do
                local status = utils.git_pull("plugins/"..plug, plugins_list[plug][i])

                if not status == "Already up to date." then
                    core.log("LIXLING: '" .. plug .. "' repo updated")
                end
            end

        -- If it's NOT a table
        elseif plugins_list[plug] == "" then
            --core.log("LIXLING: '"..plug.."' doesn't have a URL.")
        else
            -- if IS_LISTED and IS_RAW_LUA_FILE_LINK and IS_DOWNLOADED
            if utils.diff("plugins/"..plug..".lua", "<(curl -s ".. plugins_list[plug]..")")
                and utils.string_ends_with(plugins_list[plug], ".lua") and utils.array_has_value(dir_plugs, plug..".lua") then
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
    end
end-- }}}

-- Upgrades self
local function upgrade_self()-- {{{
    local status = utils.git_pull("lixling/")

    if not status == "Already up to date." then
        core.log("LIXLING: Upgraded.")
    else
        core.log("LIXLING: Already up to date.")
    end
end-- }}}

-----------------------------------------------------------------------

command.add(nil, {["lixling:install"] = download_plugins})
command.add(nil, {["lixling:clear"] = clear_plugins})
command.add(nil, {["lixling:update"] = update_plugins})
command.add(nil, {["lixling:upgrade"] = upgrade_self})

return { plugins = plugins }

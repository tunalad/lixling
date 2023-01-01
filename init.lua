-- mod-version:3
-----------------------------------------------------------------------
local core = require "core"
local command = require "core.command"
local os = require "os"

local utils = require "lixling/utils"

-----------------------------------------------------------------------
local plugins_list = {} -- list of the plugins found in the init.lua

-- Function gets the table from main config file and assigns it to the `plugins_list` in this file
local function plugins(plug_list)-- {{{
    plugins_list = plug_list
end-- }}}

-- Looks for unlisted files in the plugins dir
local function clear_plugins()-- {{{
    core.log("LIXLING CLEAR: Running the clearing process. Please wait.")

    local dir_plugs = utils.dir_lookup("plugins/")

    local clear_list = {}
    local clear_size = 0

    for f in ipairs(dir_plugs) do
        -- If plugin ends with `.lua` AND is in list
        if utils.string_ends_with(dir_plugs[f], ".lua") and plugins_list[dir_plugs[f]:sub(1, -5)] == nil then
            table.insert(clear_list, dir_plugs[f])
            clear_size=clear_size+1

            core.log("LIXLING CLEAR: File '"..dir_plugs[f].."' added to exile list.")

        -- If plugin ends with `/` AND is in list
        elseif utils.string_ends_with(dir_plugs[f], "/") and plugins_list[dir_plugs[f]:sub(1, -2)] == nil then
            table.insert(clear_list, dir_plugs[f])
            clear_size=clear_size+1

            core.log("LIXLING CLEAR: Folder '"..dir_plugs[f].."' added to exile list.")
        end
    end

    -- Handles clearing user input
    if clear_size > 0 then
        core.command_view:enter("LIXLING CLEAR: Found ".. clear_size .." unlisted plugins, exile them? (y/N)", {
            submit = function(input)
                if(string.lower(input) == "y" or string.lower(input) == "yes" ) then
                    for plug in ipairs(clear_list) do
                        core.log("LIXLING CLEAR: Moving: '".. clear_list[plug].."'.")
                        io.popen("mkdir lixling/exiled"):read()
                        os.rename("plugins/".. clear_list[plug], "lixling/exiled/".. clear_list[plug])
                    end
                    core.log("LIXLING CLEAR: ".. clear_size .. " plugins exiled. You can find them in '~/.config/lite-xl/lixling/exiled'.") 
                end
            end
        })
        return 0
    end
    core.log("LIXLING CLEAR: No unlisted plugins found.")
end-- }}}

-----------------------------------------------------------------------
-- DOWNLOADING
-----------------------------------------------------------------------
-- RAW .LUA FILE
local function download_raw(dir_plugs, plugins_list, plug)-- {{{
    if not utils.array_has_value(dir_plugs, plug..".lua") then
        if utils.string_ends_with(plugins_list[plug][1], ".lua") then
            utils.curl(plug..".lua", plugins_list[plug][1])
            core.log("LIXLING ISNTALL: Downloaded '".. plug .. ".lua'")
        end
    end
end-- }}}

-- GIT REPO CLONE
local function download_repo(plugins_list, plug, branch)-- {{{
    branch = branch or "master"
    if utils.string_ends_with(plugins_list[plug][1], ".git") then
        local status = utils.git_clone("plugins/"..plug, plugins_list[plug][1], branch)

        if status then
            core.log("LIXLING INSTALL: Downloaded '" .. plug .. "'.")
            if plugins_list[plug][3] ~= nil then
                os.execute("cd plugins/".. plug .."; "..plugins_list[plug][3])
            end
        end
    end
end-- }}}

local function download_plugins()-- {{{
    core.log("LIXLING INSTALL: Running the install process. Please wait.")

    local dir_plugs = utils.dir_lookup("plugins/")

    core.add_thread(function()
        for plug in pairs(plugins_list) do
            -- single file + default git branch
            if (#plugins_list[plug] == 1) then
                download_raw(dir_plugs, plugins_list, plug)
                download_repo(plugins_list, plug)

            -- git branch handling
            elseif (#plugins_list[plug] == 2) then
                download_repo(plugins_list, plug, plugins_list[plug][2])

            -- git branch + hook handle
            elseif (#plugins_list[plug] == 3) and (#plugins_list[plug][2] ~= 0) then
                download_repo(plugins_list, plug, plugins_list[plug][2])
            
            -- if in old srting format
            elseif type(plugins_list[plug]) == "string" then
                local dummy = { [plug] = {plugins_list[plug]} }

                download_raw(dir_plugs, dummy , plug)
                download_repo(dummy, plug)
            end
        end
        core.log("LIXLING INSTALL: All plugins have been downloaded.")
    end)
end-- }}}


-----------------------------------------------------------------------
-- UPDATING
-----------------------------------------------------------------------
-- RAW .LUA FILE
local function update_raw(dir_plugs, plugins_list, plug)-- {{{
    -- if IS_LISTED and IS_RAW_LUA_FILE_LINK and IS_DOWNLOADED
    if utils.diff("plugins/"..plug..".lua", "<(curl -s ".. plugins_list[plug][1]..")")
            and utils.string_ends_with(plugins_list[plug][1], ".lua")and utils.array_has_value(dir_plugs, plug..".lua") then

        utils.curl(plug..".lua", plugins_list[plug][1])
        core.log("LIXLING UPDATE: '".. (plug..".lua") .."'.")
    end
end-- }}}

-- GIT REPO PULL
local function update_repo(plugins_list, plug, branch)-- {{{
    branch = branch or "master"
    if utils.string_ends_with(plugins_list[plug][1], ".git") then
        local status = utils.git_pull("plugins/"..plug, branch)

        if not status == "Already up to date." then
            core.log("LIXLING UPDATE: '".. plug .. "' repo updated.")

            if plugins_list[plug][3] ~= nil then
                os.execute("cd plugins/".. plug .."; "..plugins_list[plug][3])
            end
        end
    end
end-- }}}

local function update_plugins()-- {{{
    core.log("LIXLING UPDATE: Running the update process. Please wait.")

    local dir_plugs = utils.dir_lookup("plugins/")

    core.add_thread(function()
        for plug in pairs(plugins_list) do
            -- single file + default git branch
            if (#plugins_list[plug] == 1) then
                update_raw(dir_plugs, plugins_list, plug)
                update_repo(plugins_list, plug)

            -- git branch handling
            elseif (#plugins_list[plug] == 2) then
                update_repo(plugins_list, plug, plugins_list[plug] == 2)

            -- git branch + hook handle
            elseif (#plugins_list[plug] == 3) and (#plugins_list[plug][2] ~= 0) then
                update_repo(plugins_list, plug, plugins_list[plug][2])

            -- if in old srting format
            elseif type(plugins_list[plug]) == "string" then
                local dummy = { [plug] = {plugins_list[plug]} }

                update_raw(dir_plugs, dummy , plug)
                update_repo(dummy, plug)
            end
        end
        core.log("LIXLING UPDATE: All plugins are up to date.")
    end)

end-- }}}

-- Upgrades self
local function upgrade_self()-- {{{
    core.log("LIXLING UPGRADE: Running the upgrade process. Please wait.")

    core.add_thread(function()
        local status = utils.git_pull("lixling/")

        if not status == "Already up to date." then
            core.log("LIXLING UPGRADE: Upgraded to the latest version.")
            return 0
        end
        core.log("LIXLING UPGRADE: Already up to date.")
    end)
end-- }}}

-----------------------------------------------------------------------

command.add(nil, {
    ["lixling:install"] = download_plugins,
    ["lixling:update"] = update_plugins,
    ["lixling:upgrade"] = upgrade_self,
    ["lixling:clear"] = clear_plugins,
})

return { plugins = plugins }

-- mod-version:3
-----------------------------------------------------------------------
local core = require("core")
local command = require("core.command")
local os = require("os")

local utils = require("lixling/utils")
local lixlog = require("lixling/lixlog")

local USERDIR = USERDIR or {}

-----------------------------------------------------------------------
local plugins_list = {} -- list of the plugins found in the init.lua
local plugins_path = nil

local function plugins(...)
    local param_num = select("#", ...)

    -- single parameter
    if param_num == 1 then
        local param1 = ...
        if type(param1) ~= "table" then
            lixlog.err("Invalid parameter: expected table.")
            return
        end
        plugins_path = USERDIR .. "/plugins/"
        plugins_list = param1

    -- two parameters
    elseif param_num == 2 then
        local param1, param2 = ...
        if type(param1) ~= "string" or type(param2) ~= "table" then
            lixlog.err("Invalid parameters: expected (string, table).")
            return
        end
        plugins_path = param1
        plugins_list = param2
    else
        lixlog.err("Invalid number of parameters: expected 1 or 2.")
    end
end

-- Looks for unlisted files in the plugins dir
local function clear_plugins()
    lixlog.clear("Running the clearing process. Please wait.")

    local dir_plugs = utils.dir_lookup(plugins_path)
    local clear_list = {}
    local clear_size = 0

    for f in ipairs(dir_plugs) do
        -- If plugin ends with `.lua` AND is in list
        if utils.string_ends_with(dir_plugs[f], ".lua") and plugins_list[dir_plugs[f]:sub(1, -5)] == nil then
            table.insert(clear_list, dir_plugs[f])
            clear_size = clear_size + 1

            lixlog.clear("File '" .. dir_plugs[f] .. "' added to exile list.")

        -- If plugin ends with `/` AND is in list
        elseif utils.string_ends_with(dir_plugs[f], "/") and plugins_list[dir_plugs[f]:sub(1, -2)] == nil then
            table.insert(clear_list, dir_plugs[f])
            clear_size = clear_size + 1

            lixlog.clear("Folder '" .. dir_plugs[f] .. "' added to exile list.")
        end
    end

    -- Handles clearing user input
    if clear_size > 0 then
        core.command_view:enter("LIXLING CLEAR: Found " .. clear_size .. " unlisted plugins, exile them? (y/N)", {
            submit = function(input)
                if string.lower(input) == "y" or string.lower(input) == "yes" then
                    for plug in ipairs(clear_list) do
                        lixlog.clear("Moving: '" .. clear_list[plug] .. "'.")
                        io.popen("mkdir " .. USERDIR .. "/lixling/exiled"):read()
                        os.rename(plugins_path .. clear_list[plug], USERDIR .. "/lixling/exiled/" .. clear_list[plug])
                    end
                    lixlog.clear(
                        clear_size .. " plugins exiled. You can find them in '" .. USERDIR .. "/lixling/exiled'."
                    )
                end
            end,
        })
        return 0
    end
    lixlog.clear("No unlisted plugins found.")
end

-----------------------------------------------------------------------
-- DOWNLOADING
-----------------------------------------------------------------------

-- RAW .LUA FILE
local function download_raw(dir_plugs, plugs_list, plug)
    if not utils.array_has_value(dir_plugs, plug .. ".lua") then
        if utils.string_ends_with(plugs_list[plug][1], ".lua") then
            utils.curl(plugins_path .. "/" .. plug .. ".lua", plugs_list[plug][1])
            lixlog.install("raw", "Downloaded '" .. plug .. ".lua'")
        end
    end
end

-- GIT REPO CLONE
local function download_repo(plugs_list, plug, branch)
    branch = branch or "master"
    if utils.string_ends_with(plugs_list[plug][1], ".git") then
        local status = utils.git_clone(plugins_path .. plug, plugs_list[plug][1], branch)

        if status then
            lixlog.install("repo", "Downloaded '" .. plug .. ".lua'")
            if plugs_list[plug][3] ~= nil then
                os.execute("cd plugins/" .. plug .. "; " .. plugs_list[plug][3])
            end
        end
    end
end

local function download_plugins()
    lixlog.install("", "Running the install process. Please wait.")

    local dir_plugs = utils.dir_lookup(plugins_path)
    -- has to be done via popen, so the directory gets created before downloading anything
    io.popen("mkdir " .. USERDIR .. "/plugins/"):read()

    core.add_thread(function()
        for plug in pairs(plugins_list) do
            -- single file + default git branch
            if #plugins_list[plug] == 1 then
                download_raw(dir_plugs, plugins_list, plug)
                download_repo(plugins_list, plug)

            -- git branch handling
            elseif #plugins_list[plug] == 2 then
                download_repo(plugins_list, plug, plugins_list[plug][2])

            -- git branch + hook handle
            elseif (#plugins_list[plug] == 3) and (#plugins_list[plug][2] ~= 0) then
                download_repo(plugins_list, plug, plugins_list[plug][2])

            -- if in old srting format
            elseif type(plugins_list[plug]) == "string" then
                local dummy = { [plug] = { plugins_list[plug] } }

                download_raw(dir_plugs, dummy, plug)
                download_repo(dummy, plug)
            end
        end
        lixlog.install("", "All plugins have been downloaded.")
    end)
end

-----------------------------------------------------------------------
-- UPDATING
-----------------------------------------------------------------------

-- RAW .LUA FILE
local function update_raw(dir_plugs, plugs_list, plug)
    -- if IS_LISTED and IS_RAW_LUA_FILE_LINK and IS_DOWNLOADED
    if
        utils.diff(plugins_path .. plug .. ".lua", "<(curl -s " .. plugs_list[plug][1] .. ")")
        and utils.string_ends_with(plugs_list[plug][1], ".lua")
        and utils.array_has_value(dir_plugs, plug .. ".lua")
    then
        utils.curl(plugins_path .. "/" .. plug .. ".lua", plugs_list[plug][1])
        lixlog.update("raw", "'" .. (plug .. ".lua") .. "'.")
    end
end

-- GIT REPO PULL
local function update_repo(plugs_list, plug, branch, reset_hard)
    branch = branch or "master"
    if utils.string_ends_with(plugs_list[plug][1], ".git") then
        local status = utils.git_pull(plugins_path .. plug, branch, reset_hard)

        if status ~= "Already up to date." then
            lixlog.update("repo", "'" .. (plug .. ".lua") .. "'.")

            if plugs_list[plug][3] ~= nil then
                os.execute("cd plugins/" .. plug .. "; " .. plugs_list[plug][3])
            end
        end
    end
end

local function update_plugins()
    lixlog.update("", "Running the update process. Please wait.")

    local dir_plugs = utils.dir_lookup(plugins_path)

    core.add_thread(function()
        for plug in pairs(plugins_list) do
            -- single file + default git branch
            if #plugins_list[plug] == 1 then
                update_raw(dir_plugs, plugins_list, plug)
                update_repo(plugins_list, plug)

            -- git branch handling
            elseif #plugins_list[plug] == 2 then
                update_repo(plugins_list, plug, plugins_list[plug] == 2)

            -- git branch + hook handle
            elseif (#plugins_list[plug] == 3) and (#plugins_list[plug][2] ~= 0) then
                update_repo(plugins_list, plug, plugins_list[plug][2])

            -- if in old srting format
            elseif type(plugins_list[plug]) == "string" then
                local dummy = { [plug] = { plugins_list[plug] } }

                update_raw(dir_plugs, dummy, plug)
                update_repo(dummy, plug)
            end
        end
        lixlog.update("", "All plugins are up to date.")
    end)
end

-- Upgrades self
local function upgrade_self()
    lixlog.upgrade("Running the upgrade process. Please wait.")

    core.add_thread(function()
        local status = utils.git_pull(USERDIR .. "/lixling/")
        --core.log(status)

        if status ~= "Already up to date." then
            lixlog.upgrade("Upgraded to the latest version.")
            return 0
        end
        lixlog.upgrade("Already up to date.")
    end)
end

-----------------------------------------------------------------------

command.add(nil, {
    ["lixling:install"] = download_plugins,
    ["lixling:update"] = update_plugins,
    ["lixling:upgrade"] = upgrade_self,
    ["lixling:clear"] = clear_plugins,
})

return { plugins = plugins }

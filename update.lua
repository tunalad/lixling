local utils = require("lixling/utils")
local lixlog = require("lixling/lixlog")

local M = {}

local plugins_path = nil

function M.set_plugins_path(path)
    plugins_path = path
end

-----------------------------------------------------------------------
-- UPDATING
-----------------------------------------------------------------------

-- RAW .LUA FILE
function M.raw(dir_plugs, plugs_list, plug)
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
function M.repo(plugs_list, plug, branch, reset_hard)
    branch = branch or "master"
    if utils.string_ends_with(plugs_list[plug][1], ".git") then
        local status = utils.git_pull(plugins_path .. plug, branch, reset_hard)

        if status ~= "Already up to date." then
            lixlog.update("repo", "'" .. plug .. "' repo updated.")

            if plugs_list[plug][3] ~= nil then
                os.execute("cd plugins/" .. plug .. "; " .. plugs_list[plug][3])
            end
        end
    end
end

return M

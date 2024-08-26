local utils = require("lixling/utils")
local lixlog = require("lixling/lixlog")

local M = {}

local plugins_path = nil

function M.set_plugins_path(path)
    plugins_path = path
end

-----------------------------------------------------------------------
-- DOWNLOADING
-----------------------------------------------------------------------

-- RAW .LUA FILE
function M.raw(dir_plugs, plugs_list, plug)
    if not utils.array_has_value(dir_plugs, plug .. ".lua") then
        if utils.string_ends_with(plugs_list[plug][1], ".lua") then
            utils.curl(plugins_path .. "/" .. plug .. ".lua", plugs_list[plug][1])
            lixlog.install("raw", "Downloaded '" .. plug .. ".lua'")
        end
    end
end

-- GIT REPO CLONE
function M.repo(plugs_list, plug, branch)
    branch = branch or "master"
    if utils.string_ends_with(plugs_list[plug][1], ".git") then
        local status = utils.git_clone(plugins_path .. plug, plugs_list[plug][1], branch)

        if status then
            lixlog.install("repo", "Downloaded '" .. plug .. "'")
            if plugs_list[plug][3] ~= nil then
                os.execute("cd plugins/" .. plug .. "; " .. plugs_list[plug][3])
            end
        end
    end
end

return M

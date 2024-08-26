local core = require("core")

local M = {}

function M.log(message)
    core.log("LIXLING: " .. message)
end

function M.err(message)
    core.log("LIXLING ERROR: " .. message)
end

function M.clear(message)
    core.log("LIXLING CLEAR: " .. message)
end

function M.upgrade(message)
    core.log("LIXLING UPGRADE: " .. message)
end

function M.install(kind, message)
    kind = kind or ""

    if kind == "raw" then
        core.log("LIXLING INSTALL [raw]: " .. message)
    elseif kind == "raw" then
        core.log("LIXLING INSTALL [repo]: " .. message)
    else
        core.log("LIXLING INSTALL: " .. message)
    end
end

function M.update(kind, message)
    kind = kind or ""

    if kind == "raw" then
        core.log("LIXLING UPDATE [raw]: " .. message)
    elseif kind == "raw" then
        core.log("LIXLING UPDATE [repo]: " .. message)
    else
        core.log("LIXLING UPDATE: " .. message)
    end
end

return M

local core = require("core")

local M = {}

-- Lists items in a directory and returns an array
function M.dir_lookup(dir) -- {{{
    local files_array = {}

    for file in io.popen("ls -p " .. dir .. " "):lines() do
        table.insert(files_array, file)
    end

    return files_array
end -- }}}

-- Checks if array has value in it
function M.array_has_value(table, value) -- {{{
    for item in pairs(table) do
        if table[item] == value then
            return true
        end
    end

    return false
end -- }}}

-- Checks if string ends with
function M.string_ends_with(str, ending) -- {{{
    return ending == "" or str:sub(-#ending) == ending
end -- }}}

-- CURL Downloading
function M.curl(file, link) -- {{{
    local curl =
        process.start({ "sh", "-c", "curl -o 'plugins/" .. file .. "' -s " .. link .. " && echo 'file downloaded'" })

    while curl:running() do
        coroutine.yield(0.1)
    end
    if curl:read_stdout() == "file downloaded" then
        return true
    end

    return false
end -- }}}

-- UNIX diff
function M.diff(old_file, new_file) -- {{{
    core.add_thread(function()
        local diff = process.start({ "sh", "-c", "diff " .. old_file .. " " .. new_file .. " | wc -l" })

        while diff:running() do
            coroutine.yield(0.1)
        end

        if tonumber(diff:read_stdout()) > 1 then
            return true
        end

        return false
    end)
end -- }}}

-- GIT repo updating
function M.git_pull(local_path, branch) -- {{{
    branch = branch or "master"

    local result = process.start({ "sh", "-c", "git --git-dir " .. local_path .. "/.git pull origin " .. branch .. "" })
    while result:running() do
        coroutine.yield(0.1)
    end

    return result:read_stdout()
end -- }}}

-- GIT repo clone
function M.git_clone(local_path, link, branch) -- {{{
    branch = branch or "master"

    local result = process.start({
        "sh",
        "-c",
        "git clone -b " .. branch .. " '" .. link .. "' " .. local_path .. "/ && echo -n 'repo cloned'",
    })
    while result:running() do
        coroutine.yield(0.1)
    end

    if result:read_stdout() == "repo cloned" then
        return true
    end
    return false
end -- }}}

return M

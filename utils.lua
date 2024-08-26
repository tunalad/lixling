local process = process or {}

local M = {}

-- Lists items in a directory and returns an array
function M.dir_lookup(dir)
    local files_array = {}

    -- can't rewrite with process.start() because ls executes too quickly?
    for file in io.popen("ls -p " .. dir .. " "):lines() do
        table.insert(files_array, file)
    end

    return files_array
end

-- Checks if array has value in it
function M.array_has_value(table, value)
    for item in pairs(table) do
        if table[item] == value then
            return true
        end
    end

    return false
end

-- Checks if string ends with
function M.string_ends_with(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end

-- Run mkdir
function M.mkdir(full_path)
    local mkdir = process.start({ "sh", "-c", "mkdir " .. full_path })

    while true do
        local rdbuf = mkdir:read_stdout()
        if not rdbuf then
            break
        end
    end
end

-- Run `rm -rf`
function M.rmrf(path)
    local rm = process.start({ "sh", "-c", "rm -rf " .. path .. "&& echo 'deleted stuff'" })

    while true do
        local rdbuf = rm:read_stdout()
        if not rdbuf then
            break
        end
    end
end

-- CURL Downloading
function M.curl(path, link)
    local curl = process.start({ "sh", "-c", "curl -o '" .. path .. "' -s " .. link .. " && echo 'file downloaded'" })

    while curl:running() do
        coroutine.yield(0.1)
    end

    if curl:read_stdout() == "file downloaded" then
        return true
    end

    return false
end

-- UNIX diff
function M.diff(old_file, new_file)
    local diff = process.start({ "sh", "-c", "diff " .. old_file .. " " .. new_file .. " | wc -l" })

    while diff:running() do
        coroutine.yield(0.1)
    end

    local result = tonumber(diff:read_stdout()) > 1
    return result
end

-- GIT repo updating
function M.git_pull(local_path, branch, reset_hard)
    branch = branch or "master"
    reset_hard = reset_hard or true -- you shoulnd't have edited the plugin in the first place partner!

    if reset_hard then
        process.start({ "sh", "-c", "git --git-dir " .. local_path .. "/.git fetch reset --hard FETCH_HEAD" })
    else
        process.start({ "sh", "-c", "git --git-dir " .. local_path .. "/.git fetch origin " .. branch .. "" })
    end

    local result = process.start({ "sh", "-c", "git --git-dir " .. local_path .. "/.git pull origin " .. branch .. "" })

    while result:running() do
        coroutine.yield(0.1)
    end

    return result:read_stdout()
end

-- GIT repo clone
function M.git_clone(local_path, link, branch)
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
end

return M

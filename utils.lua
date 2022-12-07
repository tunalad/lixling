local M = {}

-- Lists items in a directory and returns an array
function M.dir_lookup(dir)-- {{{
	local files_array = {}

	for file in io.popen("ls -p ".. dir .." "):lines() do
		table.insert(files_array, file)
	end
    
    return files_array
end-- }}}

-- Checks if array has value in it
function M.array_has_value(table, value)-- {{{
    for item in pairs(table) do
        if table[item] == value then
            return true
        end
    end

    return false
end-- }}}

-- Checks if string ends with
function M.string_ends_with(str, ending)-- {{{
	return ending == "" or str:sub(-#ending) == ending
end-- }}}

-- CURL Downloading
function M.curl(file, link)-- {{{
    -- should be async
    io.popen("curl -o 'plugins/".. file .. "' -s ".. link.. ""):read("*a")
end-- }}}

-- UNIX diff
function M.diff(old_file, new_file)-- {{{
    if string.len(io.popen("diff ".. old_file .. " " .. new_file):read("*a")) > 1 then
        return true
    end

    return false
end-- }}}

-- GIT repo updating
function M.git_pull(local_path, branch)-- {{{
    branch = branch or "master"
    local result = io.popen("git --git-dir plugins/".. local_path .."/.git pull origin ".. branch ..""):read("*a")

    return result
end-- }}}

return M

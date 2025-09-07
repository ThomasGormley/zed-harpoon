#!/usr/bin/env lua

local M = {}

M.config = {
    config_dir = string.format("%s/.config/zed", os.getenv("HOME")),
    mark_filename = "harpoon.txt"
}

function M.dirname(path)
    if path == "/" then
        return "/"
    end
    local dir = path:match("(.*/)") or ""
    dir = dir:gsub("/$", "")
    return dir ~= "" and dir or "."
end

function M.basename(path)
    return path:match("([^/]+)$") or path
end

function M.get_nth_line(filename, n)
    local file = io.open(filename, "r")
    if not file then return nil end
    for i = 1, n - 1 do
        if not file:read("*l") then
            file:close()
            return nil -- Line doesn't exist
        end
    end
    local line = file:read("*l")
    file:close()
    return line
end

function M.find_project_root(path)
    local current = path
    while current ~= "/" do
        current = M.dirname(current)
        -- Look for common project markers
        local markers = { ".git", "package.json", "Cargo.toml", "go.mod", "pyproject.toml" }
        for _, marker in ipairs(markers) do
            local marker_file = io.open(current .. "/" .. marker, "r")
            if marker_file then
                marker_file:close()
                return current
            end
        end
    end
    return M.dirname(path) -- fallback to parent directory
end

function M.get_harpoon_file(path)
    local project_root = M.find_project_root(path)
    local project_dir = M.dirname(project_root)
    local project_base = M.basename(project_root)
    local project_name = string.format("%s-%s", M.basename(project_dir), project_base)
    return string.format("%s/%s__%s", M.config.config_dir, project_name, M.config.mark_filename)
end

function M.mark(path_to_mark)
    if not path_to_mark then
        print("Error: No path provided")
        os.exit(1)
    end

    local project_root = M.find_project_root(path_to_mark)
    local escaped_root = project_root:gsub("([^%w])", "%%%1")
    local relative_path = path_to_mark:gsub("^" .. escaped_root .. "/", "")

    local harpoon_file = M.get_harpoon_file(path_to_mark)
    local file = io.open(harpoon_file, "a")
    if not file then
        print("Error: Could not open harpoon file: " .. harpoon_file)
        os.exit(1)
    end

    file:write(relative_path .. "\n")
    file:close()
    print("Marked: " .. relative_path)
end

function M.pluck(worktree, index)
    if not worktree then
        print("Error: No worktree provided")
        os.exit(1)
    end
    if not index then
        print("Error: No index provided")
        os.exit(1)
    end

    local editor = os.getenv("EDITOR")
    if not editor then
        print("Error: $EDITOR not set")
        os.exit(1)
    end

    editor = assert(string.match(editor, "([^%s]+)"))

    -- Get the harpoon file for the worktree
    local harpoon_file = M.get_harpoon_file(worktree)

    -- Read the nth line from the harpoon file
    local file_path = M.get_nth_line(harpoon_file, tonumber(index))
    if not file_path then
        print("Error: Could not read line " .. index .. " from harpoon file")
        os.exit(1)
    end

    -- Execute the editor with the file path
    local command = editor .. " " .. file_path
    os.execute(command)
end

-- CLI interface (only run if this file is executed directly, not required)
if not pcall(debug.getlocal, 4, 1) then
    local command = arg and arg[1]
    if command == "mark" then
        M.mark(arg[2])
    elseif command == "pluck" then
        M.pluck(arg[2], arg[3])
    else
        print("Usage: lua harpoon.lua mark <path>")
        print("Usage: lua harpoon.lua pluck <worktree> <index>")
        os.exit(1)
    end
end


return M

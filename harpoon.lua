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

-- CLI interface (only run if this file is executed directly, not required)
if not pcall(debug.getlocal, 4, 1) then
    local command = arg and arg[1]
    if command == "mark" then
        M.mark(arg[2])
    else
        print("Usage: lua harpoon.lua mark <path>")
        os.exit(1)
    end
end

return M

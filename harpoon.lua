#!/usr/bin/env lua

local function get_project_name()
    local worktree_root = os.getenv("ZED_WORKTREE_ROOT") or "/tmp/test-project"
    local parent_dir = worktree_root:match(".*/(.+)/[^/]+$")
    local project_dir = worktree_root:match(".*/([^/]+)$")
    return parent_dir .. "-" .. project_dir
end

local function get_harpoon_file()
    local project_name = get_project_name()
    local home = os.getenv("HOME")
    return home .. "/.config/zed/" .. project_name .. "__harpoon.txt"
end

local function save_crp()
    local relative_file = os.getenv("ZED_RELATIVE_FILE") or "test-file.lua"
    local harpoon_file = get_harpoon_file()
    local f = io.open(harpoon_file, "a")
    if f then
        f:write(relative_file .. "\n")
        f:close()
    end
end

local function open_crp(slot)
    local harpoon_file = get_harpoon_file()
    local f = io.open(harpoon_file, "r")
    if not f then return end

    local lines = {}
    for line in f:lines() do
        if line:match("%S") then
            table.insert(lines, line)
        end
    end
    f:close()

    if #lines >= slot then
        local file = lines[slot]
        os.execute("echo 'zed " .. file .. "' >/dev/null") -- Simulate zed command
    end
end

local function edit_crp()
    local harpoon_file = get_harpoon_file()
    os.execute("echo 'zed " .. harpoon_file .. "' >/dev/null") -- Simulate zed command
end

-- CLI interface
local command = arg[1]
local arg2 = arg[2]

if command == "save" then
    save_crp()
elseif command == "open" and arg2 then
    open_crp(tonumber(arg2))
elseif command == "edit" then
    edit_crp()
else
    print("Usage: lua harpoon.lua save | open <1-3> | edit")
end

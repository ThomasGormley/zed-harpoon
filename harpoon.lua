#!/usr/bin/env lua

local function dirname(path)
    if path == "/" then
        return "/"
    end
    local dir = path:match("(.*/)") or ""
    dir = dir:gsub("/$", "")
    if dir == "" then
        return "."
    elseif dir == "/" then
        return "/"
    else
        return dir:match("([^/]+)$")
    end
end

local function basename(path)
    return path:match("([^/]+)$") or path
end

local home = os.getenv("HOME")
local ZED_CONFIG_DIR = string.format("%s/.config/zed", home)

local function harpoonFile(path)
    local dir = dirname(path)
    local base = basename(path)
    print("dir: " .. dir)
    print("base: " .. base)
    return string.format("%s/%s-%s__harpoon.txt", ZED_CONFIG_DIR, dir, base)
end

local function mark(path)
    print("writing to: " .. harpoonFile(path))
    print("path\n")
    local file = io.open(harpoonFile(path), "a")
    if file == nil then
        os.exit(1, true)
        return
    end
    -- file:write(path + "\n")
    -- file:close()
end

-- CLI interface
local command = arg[1]

if command == "mark" then
    local path = arg[2]
    print(path)
    mark(path)
end

print("Usage: lua harpoon.lua save | open <1-3> | edit")

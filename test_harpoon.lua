-- Test file for harpoon.lua
local harpoon = require("harpoon")

local function test_mark_root()
    local test_path = "/Users/thomasgormley/dev/zed-harpoon/harpoon.lua"

    -- Call the actual mark function but suppress the print output
    local old_print = print
    print = function() end
    harpoon.mark(test_path)
    print = old_print

    local expected_file = harpoon.config.config_dir .. "/dev-zed-harpoon__harpoon.txt"
    local file = io.open(expected_file, "r")
    assert(file, "File not created")
    local content = file:read("*a")
    file:close()
    local trimmed_content = content:gsub("\n$", "")
    assert(trimmed_content == "harpoon.lua", "Content mismatch: '" .. content .. "'")
end

local function test_mark_subdir()
    local test_path = "/Users/thomasgormley/dev/zed-harpoon/src/main.lua"

    -- Call the actual mark function but suppress the print output
    local old_print = print
    print = function() end
    harpoon.mark(test_path)
    print = old_print

    local expected_file = harpoon.config.config_dir .. "/dev-zed-harpoon__harpoon.txt"
    local file = io.open(expected_file, "r")
    assert(file, "File not created")
    local content = file:read("*a")
    file:close()
    local trimmed_content = content:gsub("\n$", "")
    assert(trimmed_content == "src/main.lua", "Content mismatch: '" .. content .. "'")
end

local function test_harpoon_file_generation()
    local test_path = "/Users/thomasgormley/dev/zed-harpoon/harpoon.lua"
    local expected_file = harpoon.config.config_dir .. "/dev-zed-harpoon__harpoon.txt"
    local actual_file = harpoon.get_harpoon_file(test_path)
    assert(actual_file == expected_file, string.format("Expected %s, got %s", expected_file, actual_file))
end

local function run_tests()
    -- Create temp dir and override config
    local temp_dir = io.popen("mktemp -d"):read("*l")
    local original_config_dir = harpoon.config.config_dir
    harpoon.config.config_dir = temp_dir

    test_harpoon_file_generation()
    test_mark_root()

    -- Clear the harpoon file between tests
    local harpoon_file = temp_dir .. "/dev-zed-harpoon__harpoon.txt"
    os.remove(harpoon_file)

    test_mark_subdir()

    -- Restore original config and cleanup
    harpoon.config.config_dir = original_config_dir
    os.execute("rm -rf " .. temp_dir)
    print("All tests passed!")
end

run_tests()

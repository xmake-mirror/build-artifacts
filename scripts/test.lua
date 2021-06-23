import("core.base.option")

local options =
{
    {'p', "plat",      "kv", os.host(), "Set platform"},
    {'a', "arch",      "kv", os.arch(), "Set architecture"},
    {'k', "kind",      "kv", nil,       "Set kind"},
    {'f', "configs",   "kv", nil,       "Set configs"},
    {nil, "vs_sdkver", "kv", nil,       "The Windows SDK Version of Visual Studio"}
}

function build_artifacts(name, version, opt)
    local argv = {"lua", "private.xrepo", "install", "-yD", "--shallow", "-p", opt.plat, "-a", opt.arch, "-k", opt.kind}
    if opt.configs then
        table.insert(argv, "-f")
        table.insert(argv, opt.configs)
    end
    if opt.vs_sdkver then
        table.insert(argv, "--vs_sdkver=" .. opt.vs_sdkver)
    end
    table.insert(argv, name .. " " .. version)
    os.execv("xmake", argv)
end

function main(...)
    local opt = option.parse(table.pack(...), options, "Test artifacts.", "", "Usage: xmake l scripts/test.lua [options]")
    local files = os.iorun("git diff --name-only HEAD^")
    for _, file in ipairs(files:split('\n'), string.trim) do
        if file:find("packages", 1, true) and path.filename(file) == "manifest.txt" then
            assert(file == file:lower(), "%s must be lower case!", file)
            local packagedir = path.directory(file)
            local version = path.filename(packagedir)
            local name = path.filename(path.directory(packagedir))
            assert(name and version, "package not found!")
            build_artifacts(name, version, opt)
        end
    end
end


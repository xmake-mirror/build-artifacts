import("core.base.option")
import("core.base.semver")
import("core.tool.toolchain")
import("lib.detect.find_tool")

local options =
{
    {'p', "plat",      "kv", os.host(), "Set platform"},
    {'a', "arch",      "kv", os.arch(), "Set architecture"},
    {'k', "kind",      "kv", nil,       "Set kind"},
    {'f', "configs",   "kv", nil,       "Set configs"},
    {nil, "vs",        "kv", nil,       "The Version of Visual Studio"},
    {nil, "vs_toolset","kv", nil,       "The Toolset Version of Visual Studio"},
    {nil, "vs_sdkver", "kv", nil,       "The Windows SDK Version of Visual Studio"}
}

function build_artifacts(name, version, opt)
    local argv = {"lua", "private.xrepo", "install", "-yvD", "--shallow", "--build", "--linkjobs=2", "-p", opt.plat, "-a", opt.arch, "-k", opt.kind}
    if opt.configs then
        table.insert(argv, "-f")
        table.insert(argv, opt.configs)
    end
    if opt.vs then
        table.insert(argv, "--vs=" .. opt.vs)
    end
    if opt.vs_toolset then
        table.insert(argv, "--vs_toolset=" .. opt.vs_toolset)
    end
    if opt.vs_sdkver then
        table.insert(argv, "--vs_sdkver=" .. opt.vs_sdkver)
    end
    table.insert(argv, name .. " " .. version)
    os.execv("xmake", argv)
end

function get_buildid_for_msvc(buildhash, opt)
    local msvc = toolchain.load("msvc", {plat = opt.plat, arch = opt.arch})
    assert(msvc:check(), "msvc not found!")
    local vcvars = assert(msvc:config("vcvars"), "vcvars not found!")
    local vs_toolset = vcvars.VCToolsVersion
    if vs_toolset and semver.is_valid(vs_toolset) then
        local vs_toolset_semver = semver.new(vs_toolset)
        local msvc_version = "vc" .. vs_toolset_semver:major() .. tostring(vs_toolset_semver:minor()):sub(1, 1)
        return opt.plat .. "-" .. opt.arch .. "-" .. msvc_version .. "-" .. buildhash
    end
end

function export_artifacts(name, version, opt)
    local argv = {"lua", "private.xrepo", "export", "-yD", "--shallow", "-p", opt.plat, "-a", opt.arch, "-k", opt.kind}
    if opt.configs then
        table.insert(argv, "-f")
        table.insert(argv, opt.configs)
    end
    table.insert(argv, "-o")
    table.insert(argv, "artifacts")
    table.insert(argv, name .. " " .. version)
    os.tryrm("artifacts")
    os.execv("xmake", argv)
    local buildhash
    for _, dir in ipairs(os.dirs(path.join("artifacts", "*", "*", "*", "*"))) do
        buildhash = path.filename(dir)
        break
    end
    assert(buildhash, "buildhash not found!")
    local oldir = os.cd("artifacts")
    local artifactfile
    if opt.plat == "windows" then
        local buildid = get_buildid_for_msvc(buildhash, opt)
        artifactfile = buildid .. ".7z"
        local z7 = assert(find_tool("7z"), "7z not found!")
        os.execv(z7.program, {"a", artifactfile, "*"})
    else
        raise("unknown platform: %s", opt.plat)
    end
    return artifactfile
end

function build(name, version, opt)
    build_artifacts(name, version, opt)
    return export_artifacts(name, version, opt)
end

function main(...)
    local opt = option.parse(table.pack(...), options, "Build artifacts.", "", "Usage: xmake l scripts/build.lua [options]")
    local buildinfo = io.load(path.join(os.scriptdir(), "..", "build.txt"))
    for _, version in ipairs(buildinfo.versions) do
        local artifactfile = build(buildinfo.name, version, opt)
        local tag = buildinfo.name .. "-" .. version
        local found = try {function () os.execv("gh", {"release", "view", tag}); return true end}
        if found then
            os.execv("gh", {"release", "upload", "--clobber", tag, artifactfile})
        else
            local created = try {function () os.execv("gh", {"release", "create", "--notes", tag .. " artifacts", tag, artifactfile}); return true end}
            if not created then
                os.execv("gh", {"release", "upload", "--clobber", tag, artifactfile})
            end
        end
    end
end

import("core.base.option")
import("core.base.json")
import("net.http")

function get_manifestkey(manifest)
    local key = ""
    for _, k in ipairs(table.orderkeys(manifest)) do
        key = key .. manifest[k].urls .. manifest[k].sha256
    end
    return key
end

function main()
    local buildinfo = io.load(path.join(os.scriptdir(), "..", "build.txt"))
    local name = buildinfo.name:lower()
    for _, version in ipairs(buildinfo.versions) do
        local tag = name .. "-" .. version
        local assets = os.iorunv("gh", {"release", "view", tag, "--json", "assets"})
        local assets_json = assert(json.decode(assets).assets, "assets not found!")
        os.mkdir("assets")
        for _, asset in ipairs(assets_json) do
            http.download(asset.url, path.join("assets", asset.name))
        end
        os.exec("git clone git@github.com:xmake-mirror/build-artifacts.git")
        os.cd("build-artifacts")
        local manifestfile = path.join("packages", name:sub(1, 1), name, version, "manifest.txt")
        local manifest = os.isfile(manifestfile) and io.load(manifestfile) or {}
        local manifest_oldkey = get_manifestkey(manifest)  
        for _, asset in ipairs(assets_json) do
            local buildid = path.basename(asset.name)
            manifest[buildid] = {
                urls = asset.url,
                sha256 = hash.sha256(path.join("..", "assets", asset.name))
            }
        end
        if get_manifestkey(manifest) == manifest_oldkey then
            print("manifest not changed!")
            return
        end
        local trycount = 0
        while trycount < 2 do
            local ok = try { function ()
                os.exec("git reset --hard HEAD^")
                os.exec("git pull origin main")
                io.save(manifestfile, manifest)
                print(manifestfile)
                io.cat(manifestfile)
                os.exec("git add -A")
                os.exec("git commit -a -m \"autoupdate %s-%s by ci\"", name, version)
                os.exec("git push origin main")
                os.exec("git push git@gitee.com:xmake-mirror/build-artifacts.git main")
                return true
            end }
            if ok then
                break
            end
            trycount = trycount + 1
        end
        assert(trycount < 2)
    end
end

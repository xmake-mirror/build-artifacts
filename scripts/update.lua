import("core.base.option")
import("core.base.json")
import("core.tool.toolchain")
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
        print("11111111")
        local assets = os.iorunv("gh", {"release", "view", tag, "--json", "assets"})
        print("2222222")
        local assets_json = assert(json.decode(assets).assets, "assets not found!")
        assert(#assets_json, "assets are empty!")
        os.mkdir("assets")
        print("4444444")
        for _, asset in ipairs(assets_json) do
            http.download(asset.url, path.join("assets", asset.name))
        end
        print("555555")
        os.exec("git clone git@github.com:xmake-mirror/build-artifacts.git")
        print("66666666")
        os.cd("build-artifacts")
        local manifestfile = path.join("packages", name:sub(1, 1), name, version, "manifest.txt")

        local trycount = 0
        while trycount < 3 do
            local ok = try
            {
                function ()
                    -- Push failure will trigger git pull in catch.
                    -- Reload manifest file in case it's content is changed.
                    local manifest = os.isfile(manifestfile) and io.load(manifestfile) or {}
                    local manifest_oldkey = get_manifestkey(manifest)
                    for _, asset in ipairs(assets_json) do
                        local buildid = path.basename(asset.name)
                        manifest[buildid] = {
                            urls = asset.url,
                            sha256 = hash.sha256(path.join("..", "assets", asset.name))
                        }
                        if asset.name:find("-vc143-", 1, true) then
                            manifest[buildid].toolset = "14.33.31629"
                        end
                        if asset.name:find("-vc142-", 1, true) then
                            manifest[buildid].toolset = "14.29.30133"
                        end
                        if asset.name:find("-vc141-", 1, true) then
                            manifest[buildid].toolset = "14.16.27023"
                        end
                    end
                    if get_manifestkey(manifest) == manifest_oldkey then
                        print("manifest not changed!")
                    end
                    io.save(manifestfile, manifest)
                    print(manifestfile)
                    io.cat(manifestfile)
                    os.exec("git add -A")
                    os.exec("git commit -a -m \"autoupdate %s-%s by ci\"", name, version)
                    --os.exec("git push origin main")
                    --os.exec("git push git@gitee.com:xmake-mirror/build-artifacts.git main")
                    --os.exec("git push git@gitlab.com:xmake-mirror/build-artifacts.git main")
                    return true
                end,
                catch
                {
                    function (errors)
                        if errors then
                            print(tostring(errors))
                        end
                        os.exec("git reset --hard HEAD^")
                        os.exec("git pull origin main")
                    end
                }
            }
            if ok then
                break
            end
            trycount = trycount + 1
        end
        assert(trycount < 3, "push manifest failed!")
    end
end

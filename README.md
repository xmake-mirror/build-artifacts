<div align="center">
  <a href="https://xmake.io">
    <img width="160" heigth="160" src="https://tboox.org/static/img/xmake/logo256c.png">
  </a>  

  <h1>build-artifacts</h1>

  <div>
    <a href="https://github.com/xmake-mirror/build-artifacts/actions?query=workflow%3AWindows">
      <img src="https://img.shields.io/github/workflow/status/xmake-mirror/build-artifacts/Windows/build.svg?style=flat-square&logo=windows" alt="github-ci" />
    </a>
    <a href="https://github.com/xmake-mirror/build-artifacts.git">
    <img width="160"

A configuration can optionnaly be specified as a string.

Example:
```lua
-- build.txt
{
    name = "llvm",
    versions = {
        "11.0.0",
        "12.0.0"
    },
    configs = "lld=true,openmp=true"
}
```

It will trigger CI build jobs to build/upload artifacts to releases/assets and update manifest to `main` branch.

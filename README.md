<div align="center">
  <a href="https://xmake.io">
    <img width="160" height="160" src="https://xmake.io/assets/img/logo.png">
  </a>  

  <h1>build-artifacts</h1>

  <div>
    <a href="https://github.com/xmake-mirror/build-artifacts/actions?query=workflow%3Abuild">
      <img src="https://img.shields.io/github/actions/workflow/status/xmake-mirror/build-artifacts/build.yml?style=flat-square&logo=windows" alt="github-ci" />
    </a>
    <a href="https://github.com/xmake-mirror/build-artifacts/releases">
      <img src="https://img.shields.io/github/release/xmake-mirror/build-artifacts.svg?style=flat-square" alt="Github All Releases" />
    </a>
  </div>
  <div>
    <a href="https://github.com/xmake-mirror/build-artifacts/blob/master/LICENSE.md">
      <img src="https://img.shields.io/github/license/xmake-mirror/build-artifacts.svg?colorB=f48041&style=flat-square" alt="license" />
    </a>
    <a href="https://www.reddit.com/r/xmake/">
      <img src="https://img.shields.io/badge/chat-on%20reddit-ff3f34.svg?style=flat-square" alt="Reddit" />
    </a>
    <a href="https://t.me/tbooxorg">
      <img src="https://img.shields.io/badge/chat-on%20telegram-blue.svg?style=flat-square" alt="Telegram" />
    </a>
    <a href="https://jq.qq.com/?_wv=1027&k=5hpwWFv">
      <img src="https://img.shields.io/badge/chat-on%20QQ-ff69b4.svg?style=flat-square" alt="QQ" />
    </a>
    <a href="https://discord.gg/xmake">
      <img src="https://img.shields.io/badge/chat-on%20discord-7289da.svg?style=flat-square" alt="Discord" />
    </a>
    <a href="https://xmake.io/about/sponsor">
      <img src="https://img.shields.io/badge/donate-us-orange.svg?style=flat-square" alt="Donate" />
    </a>
  </div>

  <p>An official xmake package artifacts repository</p>
</div>

## Support this project

Support this project by [becoming a sponsor](https://xmake.io/about/sponsor). Your logo will show up here with a link to your website. 🙏

<a href="https://opencollective.com/xmake#sponsors" target="_blank"><img src="https://opencollective.com/xmake/sponsors.svg?width=890"></a>
<a href="https://opencollective.com/xmake#backers" target="_blank"><img src="https://opencollective.com/xmake/backers.svg?width=890"></a>

## Introduction ([中文](/README_zh.md))

build-artifacts is an official xmake package artifacts repository. 

## Submit and update package artifacts

You only need to edit [build.txt](https://github.com/xmake-mirror/build-artifacts/blob/build/build.txt) to modify package name and versions, and submit a PR on the `build` branch.

A configuration can optionally be specified as a string.

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

<h1 align="center">✨ scoop-i18n ✨</h1>

<p align="center">
    <a href="readme.md">English</a> |
    <a href="readme.zh-CN.md">简体中文</a> |
    <a href="https://github.com/abgox/scoop-i18n">Github</a> |
    <a href="https://gitee.com/abgox/scoop-i18n">Gitee</a>
</p>

<p align="center">
    <a href="https://github.com/abgox/scoop-i18n/blob/main/license">
        <img src="https://img.shields.io/github/license/abgox/scoop-i18n" alt="license" />
    </a>
    <a href="https://img.shields.io/github/languages/code-size/abgox/scoop-i18n.svg">
        <img src="https://img.shields.io/github/languages/code-size/abgox/scoop-i18n.svg" alt="code size" />
    </a>
    <a href="https://img.shields.io/github/repo-size/abgox/scoop-i18n.svg">
        <img src="https://img.shields.io/github/repo-size/abgox/scoop-i18n.svg" alt="code size" />
    </a>
    <a href="https://github.com/abgox/scoop-i18n">
        <img src="https://img.shields.io/github/created-at/abgox/scoop-i18n" alt="created" />
    </a>
</p>

---

<p align="center">
  <strong>如果你喜欢这个项目，请给它一个 ⭐️</strong>
</p>

## 介绍

一个为 [Scoop](https://scoop.sh/) 设计的国际化工具，帮助不同语言的用户更轻松地使用 Scoop

- 🚀 无侵入性: 不修改 Scoop 源代码
- 🌍 多语言覆盖: 支持多种语言，持续扩展中

## 安装

1. 添加 [abyss](https://abyss.abgox.com) (使用 [Github](https://github.com/abgox/abyss) 或 [Gitee](https://gitee.com/abgox/abyss) 仓库)

   ```shell
   scoop bucket add abyss https://github.com/abgox/abyss
   ```

   ```shell
   scoop bucket add abyss https://gitee.com/abgox/abyss
   ```

2. 安装

   ```shell
   scoop install abyss/abgox.scoop-i18n
   ```

## 语言

> [!Tip]
>
> - 默认会选择 `$PSUICulture`，如果不可用，则会选择 `en-US`
> - 可以通过 `scoop config abgox-scoop-i18n-language <language>` 指定语言

<!-- prettier-ignore-start -->

|Language|Progress|
|:-:|:-:|
|[en-US](./i18n/en-US.json)|100%|
|[zh-CN](./i18n/zh-CN.json)|100%|
|[zh-TW](./i18n/zh-TW.json)|100%|

<!-- prettier-ignore-end -->

<h1 align="center">✨ <a href="https://scoop-i18n.abgox.com">scoop-i18n</a> ✨</h1>

<p align="center">
    <a href="readme.md">English</a> |
    <a href="readme.zh-CN.md">简体中文</a> |
    <a href="https://github.com/abgox/scoop-i18n">Github</a> |
    <a href="https://gitee.com/abgox/scoop-i18n">Gitee</a>
</p>

<p align="center">
    <a href="https://github.com/abgox/scoop-i18n">
        <img src="https://img.shields.io/github/stars/abgox/scoop-i18n" alt="github stars" />
    </a>
    <a href="https://github.com/abgox/scoop-i18n/blob/main/license">
        <img src="https://img.shields.io/github/license/abgox/scoop-i18n" alt="license" />
    </a>
    <a href="https://github.com/abgox/scoop-i18n">
        <img src="https://img.shields.io/github/languages/code-size/abgox/scoop-i18n" alt="code size" />
    </a>
    <a href="https://github.com/abgox/scoop-i18n">
        <img src="https://img.shields.io/github/repo-size/abgox/scoop-i18n" alt="repo size" />
    </a>
    <a href="https://github.com/abgox/scoop-i18n">
        <img src="https://img.shields.io/github/created-at/abgox/scoop-i18n" alt="created" />
    </a>
</p>

---

<p align="center">
  <strong>喜欢这个项目？请给它 Star ⭐️ 或 <a href="https://abgox.com/donate">赞赏 💰</a></strong>
</p>

## 介绍

[Scoop](https://scoop.sh/) 的国际化解决方案(语言包)，帮助不同语言的用户更轻松地使用 Scoop

- 🚀 简单易用

  - 安装简单：只需 `scoop install` 即可使用
  - 即时设置：安装后立即生效，无需复杂配置

- ⚡️ 非侵入式

  - Hook 方案：通过 Hook 实现，没有修改 Scoop
  - 无副作用：轻量且安全，不会干扰现有的设置

- 🌍 多语言支持
  - 全球友好：支持多种语言，且正在不断扩展
  - 开源协作：欢迎社区贡献翻译和新的语言支持

## 演示

![demo](https://scoop-i18n.abgox.com/demo.gif)

## 使用

1. 添加 [abyss](https://abyss.abgox.com) bucket ([Github](https://github.com/abgox/abyss) 或 [Gitee](https://gitee.com/abgox/abyss))

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

3. 安装完成后，运行 `scoop` 相关命令的输出将转换为 `$PSUICulture` 对应的语言

   - 如果不可用，它会回退到 `en-US`
   - 也可以通过以下命令指定语言:

     ```shell
     scoop config abgox-scoop-i18n-language zh-CN
     ```

## 语言

<!-- prettier-ignore-start -->

|Language|Progress|
|:-:|:-:|
|[de-DE](./i18n/de-DE.json)|95.15%|
|[en-US](./i18n/en-US.json)|0%|
|[fr-FR](./i18n/fr-FR.json)|95.45%|
|[ja-JP](./i18n/ja-JP.json)|95.76%|
|[ko-KR](./i18n/ko-KR.json)|96.06%|
|[ru-RU](./i18n/ru-RU.json)|95.76%|
|[zh-CN](./i18n/zh-CN.json)|100%|
|[zh-HK](./i18n/zh-HK.json)|96.06%|
|[zh-TW](./i18n/zh-TW.json)|95.76%|

<!-- prettier-ignore-end -->

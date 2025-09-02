<h1 align="center">✨ <a href="https://scoop-i18n.abgox.com">scoop-i18n</a> ✨</h1>

<p align="center">
    <a href="readme.zh-CN.md">简体中文</a> |
    <a href="readme.md">English</a> |
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
  <strong>Star ⭐️ or <a href="https://abgox.com/donate">Donate 💰</a> if you like it!</strong>
</p>

## Introduce

An internationalization tool (language pack) for [Scoop](https://scoop.sh/) helps users of different languages use Scoop more easily.

- 🚀 Non-intrusive: Does not modify the core code of Scoop, and no side effects.
- 🌍 Multi-language: Supports multiple languages and is expanding.

## Usage

1.  Add [abyss](https://abyss.abgox.com) with [Github](https://github.com/abgox/abyss) or [Gitee](https://gitee.com/abgox/abyss) repository.

    ```shell
    scoop bucket add abyss https://github.com/abgox/abyss
    ```

    ```shell
    scoop bucket add abyss https://gitee.com/abgox/abyss
    ```

2.  Install it.

    ```shell
    scoop install abyss/abgox.scoop-i18n
    ```

3.  Then the output of `scoop` will be converted to the language corresponding to `$PSUICulture`.

    - If unavailable, fall back to `en-US`.
    - You can also specify the language:

      ```shell
      scoop config abgox-scoop-i18n-language zh-CN
      ```

## Language

<!-- prettier-ignore-start -->

|Language|Progress|
|:-:|:-:|
|[de-DE](./i18n/de-DE.json)|0%|
|[en-US](./i18n/en-US.json)|0%|
|[fr-FR](./i18n/fr-FR.json)|0%|
|[ja-JP](./i18n/ja-JP.json)|0%|
|[ko-KR](./i18n/ko-KR.json)|0%|
|[ru-RU](./i18n/ru-RU.json)|0%|
|[zh-CN](./i18n/zh-CN.json)|100%|
|[zh-HK](./i18n/zh-HK.json)|0%|
|[zh-TW](./i18n/zh-TW.json)|100%|

<!-- prettier-ignore-end -->

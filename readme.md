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
  <strong>If you like this project, please give it a star ⭐️</strong>
</p>

## Introduce

An internationalization tool designed for [Scoop](https://scoop.sh/) to help users of different languages use Scoop more easily.

- 🚀 Non-intrusive: Does not modify the core code of Scoop.
- 🌍 Multilingual coverage: Supports multiple languages and is continuously expanding.

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

## Language

> [!Tip]
>
> - By default, `$PSUICulture` will be selected. If it is not available, `en-US` will be selected.
> - Use `scoop config abgox-scoop-i18n-language <language>` to specify the language.

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

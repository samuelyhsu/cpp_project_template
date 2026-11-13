# Changelog

<!-- 记录本 app 开发者可见的改动：命令行参数、输出格式、运行时行为、运行环境要求。src/ 里的库改动影响到本 app 时，从本 app 的角度记一条。每项改动随改动本身在 [Unreleased] 下记一条，不照抄提交标题。 -->

格式遵循 [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/)，版本号即本目录 `CMakeLists.txt` 的 `APP_VERSION`。

## [Unreleased]

### Added

- 逐个打印命令行参数的 CRC-16/CCITT-FALSE；`--version` 打印版本号。

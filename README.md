# Fastlane iOS 自动上线脚本使用说明

## 使用方法:

以发布 `0.0.1` 版本为例，脚本使用 env 文件名称为 `.env.wilddog` ：

```ruby
fastlane release version:0.0.1 env:wilddog
``` 

## 准备工作

### 安装

使用前请确保安装了以下 ruby 库

- yaml (Ruby自带)
- mail
- fastlane
- mustache 
- cocoapods

如果发版时需要更新官网信息，请确保已经安装了 [wilddog-cli](https://github.com/stackOverMind/wilddog-cli)。

### 配置

假设工程名称为 `WilddogMock`，再运行脚本前，确保：

- `/Deploy/buildWilddogMock.sh` 文件存在；
- `/Deploy/WilddogMock.podspec.mustache` 文件存在；
- `/WilddogMock.podspec.mustache` 文件存在（此为可选，仅供源码集成 SDK 使用）；
- `/CHANGELOG.yml` 文件存在，且添加了最新日志；
- git 仓库中存在名为 `origin` 的 remote repo，其地址为 GitLab iOS 组中的项目地址；
- git 仓库中存在名为 `myfork` 的 remote repo，其地址为你对 GitLab iOS 组中的项目进行 fork 生成的项目的地址；
- 所有本地修改都已提交。

由于不同项目发版流程并非完全一致，通用发版脚本包含部分发版步骤的控制开关，可以在各个项目的 `.env.yourname` 文件中定制脚本的行为。
为了简化 `.env.yourname` 的配置过程，提供了一个模板 `.env.default`，其中说明了各个环境变量的作用，可复制一份出来，按需修改具体的内容。

## 上线步骤

在终端执行 `fastlane release version:0.0.1 env:wilddog` 后，讲执行以下步骤：

### 1. 预处理
`fastlane preprocess version:0.0.1 --env wilddog`
- 执行 `pod install`
- 确保切换到 `master` 分支
- 确保所有更新都已提交
- 检查 `CHANGELOG.yml` 文件

### 2. 增加版本
`fastlane version version:0.0.1 --env wilddog`
- 修改 `Info.plist` 中的版本号
- 修改头文件中的版本号（可选）

### 3. 编译归档
`fastlane build version:0.0.1 --env wilddog`
- 运行所有测试用例（可选）
- 执行 Xcode 编译，生成 zip 文件并归档
- 更新 podspec 文件

### 4. 上传 SDK
`fastlane upload version:0.0.1 --env wilddog`
- 执行 `pod lib lint`
- 解压 zip 并上传 framework 到 CDN
- 等待 30s CDN刷新，执行 `pod trunk push`

### 5. 邮件通知
`fastlane mail version:0.0.1 --env wilddog`
- 根据 `CHANGELOG` 将更新内容发送邮件给指定联系人

### 6. 提交 Git
`fastlane gitlab version:0.0.1 --env wilddog` 
- 更新 `CHANGELOG` 
- 将更改提交到 Git（CHANGELOG、plist、podspec）
- 将更改 Push 到 myfork 分支
- 提交 merge request
- 接受 merge request
- 将 origin 上的更新 Pull 到本地
- 为新版本打 tag
- 将 tag 推送到 origin
- 将更新和 tag 推送到 myfork
- 执行 `pod repo push` 更新源码集成 podspec（可选）

### 7. 后处理
`fastlane postprocess version:0.0.1 --env wilddog`
- 更新官网下载链接和 checksum


## 其他说明

`fastlane release` 包含了各个步骤的子 `fastlane`，如果更新过程中出现问题，可以单步执行各个子 `fastlane`：
1. 预处理: `fastlane preprocess version:0.0.1 --env wilddog`
2. 增加版本: `fastlane version version:0.0.1 --env wilddog`
3. 编译归档: `fastlane build version:0.0.1 --env wilddog`
4. 上传 SDK: `fastlane upload version:0.0.1 --env wilddog`
5. 邮件通知: `fastlane mail version:0.0.1 --env wilddog`
6. 提交 Git: `fastlane gitlab version:0.0.1 --env wilddog` 
7. 后处理: `fastlane postprocess version:0.0.1 --env wilddog`

由于需要在各个项目中共享，通用发版脚本位于单独的一个 git repo 中，以 submodule 的形式集成于其他项目中（应放置于其他项目根目录下 fastlane 文件夹中）。

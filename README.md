# wilddog-fastlane-scripts

USAGE:

```ruby
fastlane release version:2.1.0 --env wanghaidong
``` 

此脚本为 WilddogCore、WilddogSync、WilddogAuth、WilddogRoom 以及 WilddogVideo 共用的发版脚本。

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

由于不同项目发版流程并非完全一致，通用发版脚本包含部分发版步骤的控制开关，可以在各个项目的 `.env.yourname` 文件中定制脚本的行为。
为了简化 `.env.yourname` 的配置过程，提供了一个模板 `.env.default`，其中说明了各个环境变量的作用，可复制一份出来，按需修改具体的内容。

同时，脚本假定项目满足下述要求

- `/Deploy/build{{release_project_name}}.sh` 文件存在，该构建脚本接受版本号字符串作为参数，执行完成后将在 Deploy 目录中生成 `{{release_project_name}}-{{version_string}}.zip` 文件。
- `/Deploy/{{release_project_name}}.podspec.mustache` 文件存在，其为发布用的 podspec 文件的模板。
- （可选）`/{{release_project_name}}.podspec.mustache` 文件存在，其为源码集成用的本地 podspec。
- git 仓库中存在名为 `origin` 的 remote repo，其地址为 GitLab iOS 组中的项目地址。
- git 仓库中存在名为 `myfork` 的 remote repo，其地址为你对 GitLab iOS 组中的项目进行 fork 生成的项目的地址。
- `/CHANGELOG.yml` 文件存在。该文件记录当前未发布版本及过去版本的变更日志。

## 使用脚本

以发布 1.0.0 版本为例，在终端执行 `fastlane release version:1.0.0 --env yourname`

脚本会执行以下任务：

- 执行 `pod install`
- 确保当前 git 分支为 `master`，且无待提交的变更。
- 变更 Info.plist 中的版本号。
- （可选）根据模板生成含有版本字符串常量定义的头文件。
- （可选）执行单元测试。
- 进入 Deploy 目录，执行构建脚本，构建脚本负责构建 framework 并将其打包为 zip 文件。
- 将 zip 包复制一份到当前版本对应的归档文件夹。
- 更新 changelog ，将 upcoming 中的信息转移到对应 release 区块中。
- 更新 podspec 文件中的 s.version 为 "1.0.0"。
- （可选）更新 podspec 文件中 :sha256 为新生成的 zip 校验值。
- （可选）更新源码集成用的本地 podspec。
- 将 podspec 文件归档。
- 对生成的 podspec 归档进行 pod lib lint。
- 将构建生成的 zip 包上传到 CDN。
- 将当前所有 fastlane 操作带来的变更进行提交，并 push 到自己 fork 的 repo 的 master 分支上。
- 通过gitlab接口向项目 repo 提交 merge request。将自己设置为 reviewer。
- 进入 Deploy 目录，执行 `pod trunk push WilddogVideo.podspec --allow-warnings --verbose`。该操作若失败，将以 30 秒为间隔，重试最多 10 次。
- Accept 之前提交的 Merge Request。
- pull origin 的 master 分支。
- 打 tag， push tag 到 origin repo。
- （可选）将源码集成用的本地 podspec push 到 内网的 Spec 仓库中。
- （可选）更新官网 SDK 下载地址及其 checksum。
- （可选）更新官网 SDK 更新日志。
- （可选）向 allstaff 发送发版邮件。

## 其他说明

由于需要在各个项目中共享，通用发版脚本位于单独的一个 git repo 中，以 submodule 的形式集成于其他项目中（应放置于其他项目根目录下 fastlane 文件夹中）。

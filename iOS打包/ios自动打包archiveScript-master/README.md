# archiveScript
iOS自动打包上传到Fir平台和Appstore的脚本文件

https://www.jianshu.com/p/05dc9f925467



iOS- 一键自动打包发布到Fir和AppStore
96  JiaJung 关注
2017.09.25 09:00* 字数 1445 阅读 4086评论 78喜欢 64
特别说明：如果项目没有采用Cocoapods管理，没有.xcworkspace,只有xcodeproj；只需要将脚本中这句

xcodebuild \
archive -workspace ${project_path}/${project_name}.xcworkspace \ 
这句替换成下面这样就ok了

xcodebuild \
archive -project ${project_path}/${project_name}.xcodeproj \
日常编译打包工作主要是以下两个目的：

提交测试版本ipa给测试人员
配置好测试描述文件，然后Product -> Archive编译打包,选择Organizer,导出ad hoc 的 ipa 包。再上传到Fir等第三方平台上，然后通知测试同事进行测试。整个流程下来需要人工监守操作比较耗费时间。
提交ipa包到App Store已供审核
配置好正式的描述文件，然后同样的方式打包导出app store 的 ipa 包。通过Application Loader 等方式提交到App store等待苹果处理二进制包，处理完后选择构建版本，最后提交等待苹果审核。
无论打测试包提供测试人员测试还是打正式包上传到App strore，整个过程都是重复耗费人工的操作，需要人工等待，然后各种点击选择...我们可以通过编写脚本语言来实现整个过程。

配置自动打包发布的流程

通过下面几步的设置好之后，以后再进行打包发布到第三方平台或者App Store 只需要一步就能搞定了（一个回车搞定）

笔者通过shell脚本实现从archive->生成ipa->上传到第三方平台（Fir.im 、蒲公英）或 App store。通过下面几步即可实现自动打包上传功能。

下载Shell脚本
将archiveScript中的几文件拖入工程的根目录
根据自己需求选择好描述文件
根据自己的项目修改一下shell.sh (修改哪里下面会指出)
cd到工程根目录，通过./shell.sh 执行脚本即可
下面通过实例详细演示整个过程

第一种：打包上传到第三方平台Fir （上传蒲公英原理一样）
第二种：打包上传到App store
将通过这几步来讲解整个过程

准备工作
准备工作做完后，正式开启自动化之路
自动化脚本执行过程中可能遇到的错误
准备工作

因为要上传到Fir平台，需要先安装fir-cli



安装fir-cli
如果没有安装过rvm，需要安装rvm，在终端输入rvm -v命令查看,如果打印出rvm:command not found说明没有安装过rvm，如果能打印出rvm版本等信息说明安装过。如果没有安装过rvm可以通过下面的命安装，如果已经安装过可以忽略。

在终端输入 curl -L get.rvm.io | bash -s stable ,然后稍等一会rvm就安装好了
在终端输入 source ~/.bashrc
在终端输入 source ~/.bash_profile
再输入rvm -v查看安装成功
准备工作做完后，正式开启自动化之路

一、将archiveScript中的3个文件拖入工程的根目录


Snip20170922_61.png
二、根据自己需求选择好描述文件


Snip20170922_53.png
三、修改一下shell.sh 文件


修改1

修改2

自己工程的project_name名字
Product ->Scheme -> Edit Scheme 查看自己的scheme_name


scheme_name
获取Fir平台的token



Snip20170922_50.png
三、 cd到工程根目录，./shell.sh 回车就会执行脚本


执行脚本
四、 根据自己的需求选择即可


Snip20170922_63.png
如果开始选择的1:app-store 会发布到app store


发布app store 成功
如果开始选择的2:ad-hoc 发布到fir平台


Snip20170922_65.png
如果遇到下面的错误


Snip20170922_56.png
解决方法：在终端 输入rvm system后重新执行sehll脚本就可以了


Snip20170922_57.png
如果前面已经安装过fir-cli，但是在脚本执行过程中任然报fir:command not found的错误
解决办法： 在终端输入rvm get head


Snip20170922_66.png
执行完毕后再次执行脚本就ok了
到这里就已经实现了通过脚本打包并发布到第三方平台Fir 和 Appstore的整个流程。接下来对shell中的脚本和一些自动化原理进行简单说明

shell中的脚本和一些自动化原理

正常情况下手动在Xcode中执行Product -> Archive , 在Xcode底层是通过xcodebuild相关的命令编译、打包生成ipa包的.（xcodebuild主要是用来编译，打包成Archive和导出ipa包）

进入终端可以通过下面的命令查看一下xcodebuild的version



Snip20170925_1.png
接下来，看一下Shell脚本


设置变量

选择输入
上面内容注释大家一看应该就明白


clean并archive

导出ipa
清理构建目录

xcodebuild \
clean -configuration ${development_mode}
编译之前先clean下，就如同在Xcode进行Product -> Clean。

编译打包成Archive

xcodebuild \
archive -workspace ${project_path}/${project_name}.xcworkspace \
-scheme ${scheme_name} \
-configuration ${development_mode} \
-archivePath ${build_path}/${project_name}.xcarchive
编译工程，编译并生成.xcarchive文件，放在build_path下，名字是project_name.xcarchive，就如在Xcode进行Product -> Archive这一步最为耗时.

将Archive导出ipa

xcodebuild -exportArchive -archivePath ${build_path}/${project_name}.xcarchive \
-configuration ${development_mode} \
-exportPath ${exportIpaPath} \
-exportOptionsPlist ${exportOptionsPlistPath}
将生成的.xcarchive文件导出.ipa包到指定的exportIpaPath路径下。

说明：
用\来进行换行分隔，一条shell命令过长时可以进行分割显示.
$变量名是引用变量，拿来使用
|| exit 指明如果这一条命令执行失败，则退出当前shell.


Snip20170925_10.png
通过Fir-cli命令上传到Fir平台

# 将XXX替换成自己的Fir平台的token
fir login -T XXX
fir publish $exportIpaPath/$scheme_name.ipa
通过altool工具提交ipa包到app store
这个工具实际上是Application Loader，打开Xcode-左上角Xcode-Open Developer Tool-Application Loader 可看到
altool的路径是：

/Applications/Xcode.app/Contents/Applications/Application\ Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Support/altool
#验证并上传到App Store
# 将-u 后面的XXX替换成自己的AppleID的账号，-p后面的XXX替换成自己的密码
altoolPath="/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Versions/A/Support/altool"
"$altoolPath" --validate-app -f ${exportIpaPath}/${scheme_name}.ipa -u XXX -p XXX -t ios --output-format xml
"$altoolPath" --upload-app -f ${exportIpaPath}/${scheme_name}.ipa -u  XXX -p XXX -t ios --output-format xml

Snip20170923_69.png

Snip20170923_70.png
整个过程和原理还算比较简单，shell脚本还是满有意思的，作为苹果开发人员，有必要学习一下，本人也刚学习shell 不久，欢迎大家交流。

参考文档：
http://www.jianshu.com/p/bd4c22952e01
https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man1/xcodebuild.1.html

小礼物走一走，来简书关注我

赞赏支持
日记本 © 著作权归作者所有 举报文章
96 关注JiaJung 
写了 10863 字，被 393 人关注，获得了 244 个喜欢
简简单单
喜欢 65    更多分享

78条评论 只看作者 按时间倒序按时间正序
Leesim
24楼 · 2018.08.01 11:26
请问我这边更新了developer center的device 然后shell脚本打出来之后上传到fir上并没有自动同步，添加了网上说的allowProvisioningUpdates 属性也是没有效果（或者说我加的方式有问题？） 更新完之后 必须手动上传一次fir包 下次自动打包到fir上才能同步 有方法处理吗？

赞  回复
propitious
23楼 · 2018.07.06 12:06
xcodebuild: error: Unknown build action 'Express/.xcworkspace'.

赞  回复
孙大宁的时光：  一样
2018.07.20 16:47  回复
添加新评论
propitious
22楼 · 2018.07.06 12:05
项目名称有空格就不能识别？

赞  回复
阳光的味道_丁达尔
21楼 · 2018.06.07 22:17
现在有一种更简便的方法生成测试包，在工程里面选择好齿轮文件，直接真机运行，然后在工程目录列表中 找到 Products 文件 找到里面的 XXX.app（工程名字）文件，show in finder ，找到之后 拷贝到桌面上的一个空文件夹里面，生成zip 文件，然后将 zip后缀改成 ipa ，就得到ipa 文件了

赞  回复
Bobo_Ma
20楼 · 2018.06.06 17:08
Xcode9以后都需要配置plist文件项目BundleID和描述文件才可以

赞  回复
Original_TJ
19楼 · 2018.05.24 17:56
楼主你好，请问我按照教程配置了以后，运行脚本。最后并没有生成ipa包是什么原因。
Error Domain=IDEProfileLocatorErrorDomain Code=1 "No profiles for 'com.dailyCooking.lxyd' were found" UserInfo={NSLocalizedDescription=No profiles for 'com.dailyCooking.lxyd' were found, NSLocalizedRecoverySuggestion=Xcode couldn't find any iOS Ad Hoc provisioning profiles matching 'com.dailyCooking.lxyd'. Automatic signing is disabled and unable to generate a profile. To enable automatic signing, pass -allowProvisioningUpdates to xcodebuild.}

** EXPORT FAILED **

赞  回复
HelloKids
18楼 · 2018.04.27 16:55
因为要上传到Fir平台，需要先安装fir-cli 蒲公英的安装指令呢

赞  回复
IT小王子666：  上传到蒲公英平台 ：https://blog.csdn.net/u013602835/article/details/79790020
2018.06.20 18:34  回复
添加新评论
IT小王子666
17楼 · 2018.04.12 09:57
您好，我项目中集成了极光推送，但是现在用这个脚本打包，收不到推送。您知道怎么解决吗？

赞  回复
海浪萌物
16楼 · 2018.03.20 14:48
如果.xcworkspace文件和.xcodeproj不在同一个文件夹下怎么整？上来就报xcodebuild: error: The directory /Users/zhaojing/BaoyinGit/baoYinNew does not contain an Xcode project.找不到工程的错误

1人赞  回复
孙大宁的时光：  同问
2018.07.20 16:47  回复
添加新评论
逍遙蒗
15楼 · 2017.12.20 11:12
可以，很赞，有个问题连续打包可以串联起来吗？怎么搞？连续两三个包？

赞  回复
wkservice123
14楼 · 2017.11.24 15:09
老铁，在输入./shell.sh 命令的时候 终端出现 xcodebuild: error: Unknown build action 'Work/WKWorkspace/hxbimoocs/hxbimoocs.xcworkspace'. 错误，执行这句脚本的时候xcodebuild \
archive -workspace ${project_path}/${project_name}.xcworkspace \
-scheme ${scheme_name} \
-configuration ${development_mode} \
-archivePath ${build_path}/${project_name}.xcarchive -quiet || exit，
请问是怎么回事啊

赞  回复
engineers：  直觉是找不到先对的路径 个人经验是 你的项目不是 pod 的工程项目 所以是没有xcworkspace的。 将xcworkspace 改成新建项目的名称 就可以了。
2017.12.06 11:48  回复
草原野马：  @IOSAEngineer 不是这个问题吧，我的是pod 项目，现在也是这样的问题。
2018.06.20 16:14  回复
添加新评论
engineers
13楼 · 2017.11.01 15:45
老铁 我目前问题是 项目使用了git的管理工具后 再使用 shell的脚本 是不可执行的 不知楼主有无相应的解决方案

赞  回复
engineers
12楼 · 2017.10.31 18:49
测试了一下 刚刚建立的工程是ok的 以后的工程 就不行 不知道楼主有没有遇到类似的问题

赞  回复
JiaJung：  @薛三日 以后的工程是什么意思，你们现有的项目吗
2017.10.31 19:55  回复
TiDown：  你好 xcode9.1报这个错,能帮忙解答一下吗
xcodebuild[54158:1132838] [MT] PluginLoading: Required plug-in compatibility UUID C3998872-68CC-42C2-847C-B44D96AB2691 for plug-in at path '~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/CocoaPods.xcplugin' not present in DVTPlugInCompatibilityUUIDs
2017.12.06 11:27  回复
牧羊人Q：  @TiDown 这个问题你解决了吗？求教
2018.05.10 11:33  回复
添加新评论 还有1条评论， 展开查看
engineers
11楼 · 2017.10.31 18:21
老铁，在输入./shell.sh 命令的时候 终端出现 operation not permitted 的情况 第一次配置还是可以的虽然失败了 第二次 这个命令 就不给用了 不知老铁有没有遇到过这样的情况

1人赞  回复
JiaJung：  @薛三日 我之前还真没遇到这个情况，等我看看
2017.10.31 19:56  回复
JiaJung：  @薛三日 你有详细报错信息吗
2017.10.31 19:56  回复
engineers：  @JiaJung 没就是脚本执行不了 出现在 我已上线的项目中 pod 过 也 git过的 项目 新建项目是可以的 不知道为啥
2017.11.01 09:02  回复
添加新评论 还有6条评论， 展开查看
新地球说着一口陌生腔调
10楼 · 2017.10.12 17:22
Application Loader 有时候就是个坑货

赞  回复
JiaJung：  @新地球说着一口陌生腔调 可以说说怎么坑，哈哈
2017.10.12 17:42  回复
添加新评论

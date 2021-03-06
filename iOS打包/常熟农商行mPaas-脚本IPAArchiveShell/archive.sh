#!/bin/bash
#使用方法
#打开终端。把本文件直接拉取到终端获取路径，点击回车执行

#引用同目录下的常用方法文件
source $(cd `dirname $0`; pwd)/commonFunctions.sh

#获取脚本所在路径
shell_path=$(cd `dirname $0`; pwd)

#获取脚本所在路径的上层路径（项目所在路径）
project_path=$(dirname "$shell_path")

#echoGreen $shell_path;
#echoGreen $project_path;
cd   $shell_path;
 
#如果没有文件夹
if [ ! -d ./IPADir ];
then
#创建路径
mkdir -p IPADir;
fi

cd $project_path;

# 蒲公英apiKey
#pgyerApiKey="d8dcxxxxxxxx416a4282"
pgyerApiKey="6c84xxxxxxxxxx4bec69" #私人测试


#描述信息 （可以修改）
packageTime="打包时间：【`date \"+%Y-%m-%d %H:%M:%S\"`】"
 
#脚本log
runLog="打包中"

#获取 .xcodeproj 文件全名
path_xcworkspace="*.xcodeproj"

#判断是否有xcworkspace文件设置项目名称
if [ -e *.xcworkspace ]; then
path_xcworkspace="*.xcworkspace"
project_name=`basename $path_xcworkspace .xcworkspace`;
else
path_xcworkspace="*.xcworkspace"
project_name=`basename $path_xcworkspace .xcodeproj`;
fi

##工程名 将XXX替换成自己的工程名
##project_name="${project_path##*/}"
#project_name=`basename $path_xcworkspace .xcodeproj`;

#scheme名 默认与项目名称一样，不同可以在这里修改
#scheme_name="${project_path##*/}"
scheme_name=$project_name;


#打包模式 Debug/Release
development_mode="Release"

#build文件夹路径
build_path=${shell_path}/build

#plist文件所在路径
exportOptionsPlistPath=${shell_path}/ExportOptions_development.plist
 
printf "\033[33;1m  %-15s %-50s \n "  蒲公英  $pgyerApiKey
printf " %-15s %-50s \n " 项目名称 $project_name
printf " %-15s %-50s \n " 描述信息 $packageTime
printf " %-15s %-50s \n " 打包模式 $development_mode
printf " %-15s %-50s \n \033[0m" build路径 $build



#导出.ipa文件所在路径
exportIpaPath=${shell_path}/IPADir/${development_mode}

#删除上一次的ipa包
rm -r -f $exportIpaPath

echoGreen " 正在清理工程 "


if [ -e *.xcworkspace ]; then

xcodebuild \
archive -workspace ${project_path}/${project_name}.xcworkspace \
-scheme ${scheme_name} \
clean -configuration ${development_mode} -quiet  || exit
else

#xcodebuild \
#clean -configuration ${development_mode} -quiet  || exit

xcodebuild \
archive -project ${project_path}/${project_name}.xcodeproj \
-scheme ${scheme_name} \
clean -configuration ${development_mode} -quiet  || exit
fi


echoGreen " 清理完成"


echoGreen "正在编译工程:${development_mode}"
 
# 判断使用Cocoapods
if [ -e *.xcworkspace ]; then
 
    xcodebuild \
    archive -workspace ${project_path}/${project_name}.xcworkspace \
    -scheme ${scheme_name} \
    -configuration ${development_mode} \
    -archivePath ${build_path}/${project_name}.xcarchive  -quiet  || exit
else
 
    xcodebuild \
    archive -project ${project_path}/${project_name}.xcodeproj \
    -scheme ${scheme_name} \
    -configuration ${development_mode} \
    -archivePath ${build_path}/${project_name}.xcarchive  -quiet  || exit
fi



 
echoGreen " 编译完成"


echoGreen " 开始ipa打包 "


xcodebuild -exportArchive -archivePath ${build_path}/${project_name}.xcarchive \
-configuration ${development_mode} \
-exportPath ${exportIpaPath} \
-exportOptionsPlist ${exportOptionsPlistPath} -allowProvisioningUpdates \
-quiet || exit

if [ -e $exportIpaPath/$scheme_name.ipa ]; then
 
    echoGreen " ipa包已导出"

    open $exportIpaPath

else
    echoRed " ipa包导出失败"

    runLog="ipa包导出失败  打包时间：【`date \"+%Y-%m-%d %H:%M:%S\"`】"
fi

   
    echoGreen "打包ipa完成"


    # 清除 当前目录的 build 文件夹
    rm -r $shell_path/build;
 

    runTime="工程名称:$project_name \
     scheme名称:$scheme_name  \
     打包模式:$development_mode  \
     打包时间：【`date \"+%Y-%m-%d %H:%M:%S\"`】"
    echo "$runTime" >> $exportIpaPath/run_time.log

# 下面是上传，暂时不用
#
#echo '///-------------'
#echo '/// 开始发布ipa包 '
#echo '///-------------'
#
#if [ $number == 1 ];then
#
#u="xxxxxxxcom"
#p="xxxxxxx---"
#
##验证并上传到App Store
## 将-u 后面的XXX替换成自己的AppleID的账号，-p后面的XXX替换成自己的密码
#altoolPath="/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Versions/A/Support/altool"
#"$altoolPath" --validate-app -f ${exportIpaPath}/${scheme_name}.ipa -u $(u) -p $(p) -t ios --output-format xml
#"$altoolPath" --upload-app -f ${exportIpaPath}/${scheme_name}.ipa -u $(u)  -p $(p) -t ios --output-format xml
#else
#
##上传到Fir
## 将XXX替换成自己的Fir平台的token
##fir login -T XXX
##fir publish $exportIpaPath/$scheme_name.ipa
#
#finalIPAPath=$exportIpaPath/$scheme_name.ipa
##上传到蒲公英
##http://www.pgyer.com/doc/api#uploadApp
#
#
# 通过api上传到蒲公英当中
echoGreen " 上传至蒲公英平台 "

echo $packageTime

ipa_path=$exportIpaPath

if [ -e ${ipa_path}/${project_name}.ipa ]; then

RESULT=$(curl -F "_api_key=${pgyerApiKey}" \
-F "file=@$exportIpaPath/$scheme_name.ipa" \
-F "buildUpdateDescription=${packageTime}" \
https://www.pgyer.com/apiv2/app/upload)
#-F "buildInstallType=2" \
#-F "buildPassword=1230" \
#-F "buildUpdateDescription=${packageTime}${des}" \


 echoGreen ${RESULT}
 
    if [ "${RESULT}" ]; then
    echoGreen "完成蒲公英平台上传 "
    runLog="完成蒲公英平台上传  打包时间：【`date \"+%Y-%m-%d %H:%M:%S\"`】"
    else
    echoRed " 上传蒲公英平台失败 "
    runLog="上传蒲公英平台失败  打包时间：【`date \"+%Y-%m-%d %H:%M:%S\"`】"
    fi
# open ${ipa_path}
else
echoRed " 上传蒲公英平台失败 "
runLog="打包失败  打包时间：【`date \"+%Y-%m-%d %H:%M:%S\"`】"
fi

echo "$runLog" >> $shell_path/run_time.log



###############删除构建目录
#sudo rm -r -f $build_path
rm -r -f $build_path

#
#fi
#
#
exit 0






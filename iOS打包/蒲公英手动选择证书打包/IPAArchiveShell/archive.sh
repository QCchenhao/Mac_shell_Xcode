#!/bin/bash

#使用方法
#打开终端。把本文件直接拉取到终端获取路径，点击回车执行

#获取脚本所在路径
shell_path=$(cd `dirname $0`; pwd)
#获取脚本所在路径的上层路径（项目所在路径）
project_path=$(dirname "$shell_path")
echo $project_path_basename;
cd $shell_path;

#如果没有文件夹
if [ ! -d ./IPADir ];
then
#创建路径
mkdir -p IPADir;
fi

cd $project_path;

# 蒲公英apiKey  这里替换成自己的
pgyerApiKey="XXXXXXXXXXXXXXXXXXXXXXXXXXX"

#描述信息 （可以修改）
packageTime="打包时间：【`date \"+%Y-%m-%d %H:%M:%S\"`】---"
 
#脚本log
runLog="打包中"

#获取 .xcodeproj 文件全名
path_xcworkspace="*.xcodeproj"

#工程名 将XXX替换成自己的工程名
#project_name="${project_path##*/}"
project_name=`basename $path_xcworkspace .xcodeproj`;

#scheme名 将XXX替换成自己的sheme名
#scheme_name="${project_path##*/}"
scheme_name=$project_name;
 

#打包模式 Debug/Release
development_mode="Release"

#build文件夹路径
build_path=${shell_path}/build

#plist文件所在路径
exportOptionsPlistPath=${shell_path}/ExportOptions_development.plist

##加入时间参数，在打包路径中
#DATE=`date '+%Y-%m-%d-%T'`

#导出.ipa文件所在路径
exportIpaPath=${shell_path}/IPADir/${development_mode}

#删除上一次的ipa包
rm -r -f $exportIpaPath
 

##app-store, ad-hoc, package, enterprise
#echo "请输入对应您选择打包方式的数字 ? [ 1:app-store（应用程序商店输入1） 2:enterprise （蒲公英-Fir输入2）] "
#
###
#read number
#while([[ $number != 1 ]] && [[ $number != 2 ]])
#do
#echo "错误! 应该输入1或者2"
#echo "Place enter the number you want to export ? [ 1:app-store 2:enterprise] "
#read number
#done
#
#if [ $number == 1 ];then
##development_mode=Release
#exportOptionsPlistPath=${shell_path}/exportAppstore.plist
#else
##development_mode=Debug
#exportOptionsPlistPath=${shell_path}/exportTest.plist
#fi

#exportOptionsPlistPath=${project_path}/OAexportTest.plist


echo '///-----------'
echo '/// 正在清理工程'
echo '///-----------'
xcodebuild \
clean -configuration ${development_mode} -quiet  || exit



echo '///--------'
echo '/// 清理完成'
echo '///--------'
echo ''

echo '///-----------'
echo '/// 正在编译工程:'${development_mode}
echo '///-----------'
if [ -e *.xcworkspace ]; then


    #echo "搜索到 .xcworkspace 文件，则使用了Cocoapods"
     
    xcodebuild \
    archive -workspace ${project_path}/${project_name}.xcworkspace \
    -scheme ${scheme_name} \
    -configuration ${development_mode} \
    -archivePath ${build_path}/${project_name}.xcarchive  -quiet  || exit
else

    #echo "未搜索到 .xcworkspace 文件，没使用Cocoapods"

    xcodebuild \
    archive -project ${project_path}/${project_name}.xcodeproj \
    -scheme ${scheme_name} \
    -configuration ${development_mode} \
    -archivePath ${build_path}/${project_name}.xcarchive  -quiet  || exit
fi



echo '///--------'
echo '/// 编译完成'
echo '///--------'
echo ''

echo '///----------'
echo '/// 开始ipa打包'
echo '///----------'


xcodebuild -exportArchive -archivePath ${build_path}/${project_name}.xcarchive \
-configuration ${development_mode} \
-exportPath ${exportIpaPath} \
-exportOptionsPlist ${exportOptionsPlistPath} -allowProvisioningUpdates \
-quiet || exit

if [ -e $exportIpaPath/$scheme_name.ipa ]; then
    echo '///----------'
    echo '/// ipa包已导出'
    echo '///----------'
    open $exportIpaPath

else
    echo '///-------------'
    echo '/// ipa包导出失败 '
    echo '///-------------'
    runLog="ipa包导出失败  打包时间：【`date \"+%Y-%m-%d %H:%M:%S\"`】---"
fi

    echo '///------------'
    echo '/// 打包ipa完成  '
    echo '///------------'
    echo ''

    # 清除 当前目录的 build 文件夹
    rm -r $build_path;
 

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
#u="weiJuTechnology@163.com"
#p="weiJu2019---"
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
echo "===上传至蒲公英平台==="

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


# echo ${RESULT}
    if [ "${RESULT}" ]; then
    echo "===完成蒲公英平台上传==="
    runLog="完成蒲公英平台上传  打包时间：【`date \"+%Y-%m-%d %H:%M:%S\"`】---"
    else
    echo "===上传蒲公英平台失败==="
    runLog="上传蒲公英平台失败  打包时间：【`date \"+%Y-%m-%d %H:%M:%S\"`】---"
    fi
# open ${ipa_path}
else
echo "===上传蒲公英平台失败==="
runLog="打包失败  打包时间：【`date \"+%Y-%m-%d %H:%M:%S\"`】---"
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






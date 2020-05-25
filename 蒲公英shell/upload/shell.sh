#使用方法
#打开终端。把b本文件直接拉取到终端获取路径，点击回车执行

#工程绝对路径 获取路径
project_path=$(cd `dirname $0`; pwd)

#cd $project_path;


# 通过api上传到蒲公英当中
echo "===上传至蒲公英平台==="

## 蒲公英userkey
pgyerUserKey="xxxxxx"

  

#描述信息
des="更新"

packageTime="打包时间：【`date \"+%Y-%m-%d %H:%M:%S\"`】---"
echo $packageTime


ipa_path="$project_path/api"
ipa_name=""


if [ -e ${ipa_path}/*.ipa ]; then


#获取文件夹下所有文件
files=$(ls ${ipa_path})
 
#遍历文件夹中文件，打印文件名
for filename in $files
do
# echo $filename
 ipa_name=${filename}
done
    echo ""
else

    echo '///--------'
    echo '/// 没有ipa文件'
    echo '///--------'
    echo ''
    open $ipa_path
exit
fi



echo $ipa_name
echo $ipa_path

## 7 上传IPA到蒲公英
# curl -F "file=@$ipa_path" \
# -F "_api_key=$pgyerApiKey" \
# https://www.pgyer.com/apiv2/app/upload
 


RESULT=$(curl -F "_api_key=$pgyerApiKey" \
-F "file=@$ipa_path/$ipa_name" \
https://www.pgyer.com/apiv2/app/upload)

#-F "buildPassword=1230" \
#-F "buildInstallType=2" \
#-F "buildUpdateDescription=${packageTime}${des}" \
 

 echo ${RESULT}
if [ "${RESULT}" ]; then
echo "===完成蒲公英平台上传==="
else
echo "===上传蒲公英平台失败==="
fi


#
#if [ -e ${ipa_path} ]; then
#
#
## open ${ipa_path}
#else
#echo "===上传蒲公英平台失败==="
#fi
 


exit 0



# archiveScript
1.使用方法，IPAArchiveShell文件夹复制放到有.xcodeproj 或者.xcworkspace后缀名的路径下

2.修改 pgyerApiKey 为自己的
3.配置ExportOptions_development 文件  method

development是测试证书
app-store 是公司账号
enterprise  企业账号
ad-hoc 

4.如果项目是手动配置证书需要 配置ExportOptions_development 文件  provisioningProfiles
 如果你用code打过包直接复制ExportOptions.plist中的provisioningProfiles字典即可
 
 
 最后无误后拖动 archive.sh到终端，回车执行，需要输入密码获取权限删除



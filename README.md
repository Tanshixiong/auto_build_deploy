# auto_build_deploy
Complete the code automation download, compile, deploy

##  测试环境  ##
- jenkins执行器
- 编译机器
- gitlab1, gitlab2

## 测试方法  ##
通过jenkins 远程访问编译器，下载代码，然后进行编译，把编译结果上传到最后的gitlab2中
再把gitlab2中所有的执行文件下载，打包
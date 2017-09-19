#！ /bin/bash

#
# echo HcZNvcGN32 > ./public/baidu_verify_HcZNvcGN32.html
# 百度站长统计验证文件内容


if [ -d .deploy_git/ ]
then
    cd .deploy_git/
    echo '进入站点发布文件夹：'
    pwd
    echo '开始更新...'
    git pull
    if [ $? -ne 0 ]
    then
        echo '更新远程站点文件失败'
        exit
    fi
    cd ../
    echo '更新远程站点文件成功'
    sleep 1
else
    echo '站点发布文件夹不存在,开始拉去文件到本地...'
    sleep 1
    git clone https://github.com/tomoncle/tomoncle.github.io.git .deploy_git/
    echo '拉取远程站点文件成功'
    sleep 1
fi

echo '退回到根目录：'
pwd
echo '开始部署文件到远程站点...'
sleep 1

echo '开始清除缓存...'
sleep 1
hexo clean

echo '发布文章内容到algolia...'
sleep 1
hexo algolia

echo '开始打包并上传...'
sleep 1
hexo g
echo HcZNvcGN32 > ./public/baidu_verify_HcZNvcGN32.html
hexo d

echo -e '\tdeploy success ...'
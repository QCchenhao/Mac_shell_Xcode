#!/bin/bash

#💙💚❤️🧡
#函数 输出绿色💚正常字符串
function echoGreen (){
    if [ $? -eq 0 ];then
        printf "\033[32m 💚 === $1 === \n \033[0m"
    else
        printf "$1 is no."
    fi
}

#函数 输出红色❤️异常字符串
function echoRed (){
    if [ $? -eq 0 ];then
        printf "\033[31m ❤️ === $1 === \n \033[0m"
    else
        printf "$1 is no."
    fi
}

#函数 输出蓝色💙配置文件字符串
function echoRed (){
    if [ $? -eq 0 ];then
        printf "\033[34m 💙 === $1 === \n \033[0m"
    else
        printf "$1 is no."
    fi
}

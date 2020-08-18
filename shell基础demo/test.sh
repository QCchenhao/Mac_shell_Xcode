#!/bin/bash
#History: chenhao

#echo "Hello World !"
#your_name="qinjx"
#echo $your_name
#your_name="陈2345\n"
#echo ${your_name}
#for skill in Ada Coffe Action Java; do
#echo "I am good at ${your_name}Script"
#done
#
#echo ${#your_name} #输出 变量your_name的长度 5

#echo '$your_name\"'

echo "脚本$0"

printf "\n"
printf "%-10s %-8s %-4s\n" 姓名 性别 体重kg
printf "%-10s %-8s %-4.2f\n" 郭靖 男 66.1234
printf "%-10s %-8s %-4.2f\n" 杨过 男 48.6543
printf "%-10s %-8s %-4.2f\n" 郭芙 女 47.9876

foldername="`date \"+%Y-%m-%d %H:%M:%S\"`"
echo "/// 正在编译工程:${foldername}"


clear
echo -e "\033[1m Hello World1"
# bold effect
echo -e "\033[5m Blink"
# blink effect
echo -e "\033[0m Hello World2"
# back to noraml

echo -e "\033[31m Hello World3"
# Red color
echo -e "\033[32m Hello World4"
# Green color
echo -e "\033[33m Hello World5"
# See remaing on screen
echo -e "\033[34m Hello World6"
echo -e "\033[35m Hello World7"
echo -e "\033[36m Hello World8"

echo -e -n "\033[0m"
# back to noraml
echo -e "\033[41m Hello World"
echo -e "\033[42m Hello World"
echo -e "\033[43m Hello World"
echo -e "\033[44m Hello World"
echo -e "\033[45m Hello World"
echo -e "\033[46m Hello World"

echo -e "\033[0m Hello World"

pmset -g

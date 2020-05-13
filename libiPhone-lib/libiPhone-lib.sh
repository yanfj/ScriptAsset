#!/usr/bin/env bash

if [ ! -f "./lib_input/libiPhone-lib.a" ];then
    echo "当前无输入文件: libiPhone-lib.a"
    exit
fi

echo "------------[ 检测文件 ]------------"
cd ./lib_input

input_info=`grep -r UIWebView .`
if [ -z "${input_info}" ];then
    echo "当前 libiPhone-lib.a 无 UIWebView调用"
    exit
else
    echo $input_info
fi

cd ..

#架构类型
ARMV_LIST=("armv7" "armv7s"  "arm64")

echo "------------[ 开始处理 ]------------"
for((i=0; i<${#ARMV_LIST[*]}; i++));do

    #1.创建对应架构的文件夹,如果存在，删除再创建
    path="./${ARMV_LIST[i]}"
    if [ -d $path ];then
        echo "移除已有目录: $path"
        rm -rf $path
    fi
    mkdir $path
    if [ -d $path ];then
        echo "创建目录: $path"
    fi

    #2.将 URLUtility.mm 生成对应的 URLUtility.o
    o_path="${path}/URLUtility.o"
    clang -c URLUtility.mm -arch ${ARMV_LIST[i]} -Wno-deprecated -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk  -o $o_path
    if [ -f $o_path ];then
        echo "生成 ${ARMV_LIST[i]} 架构 URLUtility.o"
    fi

    #3.拆分 libiPhone-lib.a
    a_path="${path}/libiPhone-lib.a"
    lipo ./lib_input/libiPhone-lib.a -thin ${ARMV_LIST[i]} -output $a_path
    if [ -f $a_path ];then
        echo "拆分 ${ARMV_LIST[i]} 架构 libiPhone-lib.a"
    fi

    #4. 替换 libiPhone-lib.a 中的 URLUtility.o
    # ar -d 是移除
    ar -d $a_path URLUtility.o
    # ar -q是添加
    ar -q $a_path $o_path
    echo "替换 ${ARMV_LIST[i]} 架构 libiPhone-lib.a 中的 URLUtility.o"


    echo "------------------------------------"
done 

#4. 合并 libiPhone-lib.a
lib_path="./lib_output"
if [ -d $lib_path ];then
    echo "移除已有libiPhone-lib.a"
    rm -rf $lib_path
fi
mkdir $lib_path

armv7_path="./${ARMV_LIST[0]}/libiPhone-lib.a"
armv7s_path="./${ARMV_LIST[1]}/libiPhone-lib.a"
arm64_path="./${ARMV_LIST[2]}/libiPhone-lib.a"

lipo -create $armv7_path $armv7s_path $arm64_path -output $lib_path/libiPhone-lib.a
if [ -f "$lib_path/libiPhone-lib.a" ];then
    echo "已合并libiPhone-lib.a"
    echo "路径: $lib_path/libiPhone-lib.a"
fi

echo "------------[ 检测文件 ]------------"
cd ./lib_output
echo "检测文件输出目录: ./lib_output"
output_info=`grep -r UIWebView .`
if [ -z "${output_info}" ];then
    echo "当前 libiPhone-lib.a 无 UIWebView调用"
else
    echo $output_info
    echo "libiPhone-lib.a 处理失败"
    exit
fi
cd ..

echo "------------[ 处理完毕 ]------------"
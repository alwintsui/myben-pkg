# USQCD软件使用与二次开发

本项目围绕USQCD软件（Chroma和QUDA等），实现简便使用和二次开发扩展。

- 提供一键安装配置
- 提供Chroma上层API函数集
- 提供Lime的面向对象封装
- 提供Chroma、Lime、XPathReader和Quda的Python封装

徐顺， 2025年1月


# 一键安装Chroma及其相关库

本例提供Linux系统中，一键安装格点QCD计算模拟常用软件Chroma及其相关库QMP、QDPXX（QIO/CLime）、QUDA等脚本。

需要先安装依赖库，之后修改安装Chroma的路径变量，之后运行脚本自动编译并以动态库的形式安装，最后测试实例。

徐顺， 2024年9月

## 安装依赖库

先安装依赖MPI和XML2解析库。

Ubuntu系统下之下，其他Linux系统类型。

```
sudo apt install libopenmpi-dev  openmpi-bin
sudo apt install cmake libxml2-dev libarchive-dev
```

## 安装配置

Makefile默认会自动在本地目录下载Chroma、QDPXX、QMP等模块，并新建build目录编译所有软件模块，指定统一的安装路径`${CHROMA_PATH}`。

修改env.sh中的环境变量，再执行以下命令就可以一键安装Chroma及其相关库

```
#vi env.sh
source env.sh
make usqcd
```

## 运行测试

tests/hadspec是Chroma自带例子，也即chroma/tests/chroma/hadron/hadspec。

安装完成之后，运行如下命令进行测试

```
make -C tests test-hadspec
```


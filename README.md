# GCisual

linux环境中的visualGC，jstat离线日志的图形工具linux下的jstat日志可视化工具

## gcisual使用方法

### 环境要求

linux bash

### 参数解释

- -p 图形参数，图形标识[A,B,L]，列号从1开始
     格式为：图形标识1=标题1:数据列号1:数据max列号1,图形标识2=标题2:数据列号2:数据max列号2
     其中，标题和数据max列号可为空，数据max列号为空时，max数值为100（格式如：图形标识1=:数据列号1:,...）

- -i 图形刷新时间间隔
     单位毫秒，非必填，填则必须大于0

- -s 跳过的行数
     默认为0，非必填，填则必须大于0
     如果设置为1，则表示跳过第1行数据，从第2行数据开始显示图形，一般用于跳过表头行


### 例子1（Quick Start 1）

对jstat日志输出实时图形，参数配置如下：

1. jstat日志第1行为表头`S0C S1C S0U S1U EC EU  OC OU MC  MU CCSC CCSU YGC  YGCT FGC FGCT GCT`，不需要做图形展示，因此需要设置参数-s 1，跳过第1行。当然也可以使用linux的sed命令过滤第1行，这样也可以不设置-s参数。

2. 图形展示Eden、S0、S1、Old、Perm的柱状图，以及Eden、S0、S1的面积图（jvisualvm的visualGC功能），Eden当前值在第6列，最大值在第5列，柱状图标识为B，因此-p参数为B=Eden:6:5，面积图为A=Eden:6:5，其他图形依次类推，每个图形参数用逗号隔开，图形按顺序显示。

3. jstat日志可以设置打印时间间隔，因此-i参数可以不设置。

gcisual支持管道传递数据，最终命令行如下：
```shell
jstat -gc pid 1000 | gcisual -s 1 -p B=Eden:6:5,B=S0:3:1,B=S1:4:2,B=Old:8:7,B=Perm:10:9,A=Eden:6:5,A=S0:3:1,A=S1:4:2
```

#### 输出图形
```
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||               | Eden: 20769.0 / 24576.0
|                                                                                                   | S0: 0.0 / 1024.0
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||                | S1: 852.6 / 1024.0
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||                                    | Old: 56675.9 / 88576.0
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||       | Perm: 42645.4 / 46080.0
Eden
-----------*---------------------------------------------------------------------------------------- 20769.0 / 24576.0
----------**--------------**-------------**------------**-------------**-------------**-------------
--------****------------****-----------****-----------***-----------****-----------****-----------**
------******----------******---------******---------*****---------******---------******----------***
----********--------********-------********-------*******-------********-------********--------*****
---*********------**********-----**********-----*********------*********------*********------*******
-***********----************---************---***********----***********---************----*********
************--**************--*************-*************--*************--*************--***********
S0
---------------------------------------------------------------------------------------------------- 0.0 / 1024.0
----------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------***************------------
-------------------------------------------------------------------------***************------------
-------------****************--------------------------------------------***************------------
-------------****************---------------**************---------------***************------------
-------------****************---------------**************---------------***************------------
-------------****************---------------**************---------------***************------------
S1
---------------------------------------------------------------------------------------------------- 852.6 / 1024.0
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------************
----------------------------------------------------------------------------------------************
----------------------------------------------------------***************---------------************
-************----------------***************--------------***************---------------************
-************----------------***************--------------***************---------------************
-************----------------***************--------------***************---------------************
```

### 例子2（Quick Start 2）

如果linux或linux的docker容器不支持bash（如alpine），可以采用离线日志方式输出图形，配置如下：

1、先将日志实时输出到文件，执行如下命令：
```
jstat -gc pid 1000 > gcstat.log
```

2、同时再从文件末尾读出数据，通过管道传给gcisual，进行图形输出，此时依然类似实时日志，不需要设置-i参数。执行命令如下：
```
tail -n 1 -f gcstat.log | gcisual -p B=Eden:6:5,B=S0:3:1,B=S1:4:2,B=Old:8:7,B=Perm:10:9,A=Eden:6:5,A=S0:3:1,A=S1:4:2
```

3、如果日志为离线历史记录，则需要配置-i参数，可以设置为1000，模拟实时输出图形效果。执行命令如下：
```
cat gcstat.log | gcisual -s 1 -i 1000 -p B=Eden:6:5,B=S0:3:1,B=S1:4:2,B=Old:8:7,B=Perm:10:9,A=Eden:6:5,A=S0:3:1,A=S1:4:2
```

#### 输出图形

同例子1

---

## 源码修改注意事项

1. 修改源码后，执行build.sh即可生成bash下的可执行文件gcisual

2. build.sh原理为合并main.sh和graph下的sh脚本，再通过shc生成gcisual文件，其中，合并位置参照为如下代码，因此，如下代码不能改动：
```shell
for graphSct in ./graph/*.sh; do
    source $graphSct
done
```

---

## 图形引擎

gcisual底层实现了一个简单的数据输出为图形的引擎，gcisual默认实现了单列数据展示柱状图，单列数据集展示折线图和面积图。

当然，用户也可以通过自定义sh脚本来实现图形。具体实现方法如下：

1、自定义图形sh文件放入/usr/local/gcisual文件夹下，文件夹下的所有sh文件都将注册为图形文件。

2、注册图形，sh文件第一行调用注册函数：
```shell
registGraph X
```
- X表示图形标识，必须唯一，柱状图B，折线图L，面积图A

3、绘制图形，sh文件中实现绘制函数：
```shell
function paintX() {
    # $1, $2, $3, $4
}
```
- X表示图形标识，必须唯一
- 函数传入4个参数，分别为$1, $2, $3, $4
    - $1 图形标题，数据类型字符串，如Eden
    - $2 当前数据值，数据类型正整数
    - $3 数据最大值，数据类型正整数。如果-p参数没有传入最大值，则默认为100（比如-p B=Eden:5:,B=S1:3:1，其中Eden的最大值默认为100）
    - $4 图形唯一编号

4、返回图形高度，sh文件中实现函数：
```shell
function cursorMoveNumA() {
    return num
}
```
- X表示图形标识，必须唯一
- num表示图形的高度，最大255（shell函数限制）。如柱状图占1行，则num为1，而面积图标题占1行，图形占8行，总共占9行，则返回9

备注：gcisual定义的默认图形sh文件在graph文件夹中，包含3种预置的图形，柱状图（B），折线图（L），面积图（A），可以参考其实现原理。


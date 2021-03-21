# -----------------------------------------------------------------------------
# version: v0.0.1
# license: Apache License 2.0
# author：strangeen
# url: www.dinghuiye.online
# github: github.com/strangeen
# -----------------------------------------------------------------------------

# 图形标识为L
registGraph L

# 宽度
dataLLen=100
# 高度
graphLHt=8

# 环形数组dataLN存放数据，容量为$2
# 设置初始头下标startIdxL=0，即为遍历数组的起始下标
# 添加元素的下标为startIdxL
# 添加元素后，头下标向后移一位，即startIdxL=(startIdxL+1)%$1
# 数组需要赋初值为0
# $1-唯一编号，$2-数组长度
function initL() {
    # 为每个编号生成独自的数组和头下标
    eval 'startIdxL'$1'=0'
    for ((i=0;i<$2;i++)); do
        eval 'dataL'$1'[$i]=0'
    done
    unset i
}


# 绘制折线
# 参数 $4-唯一编号，多个图形对应多个全局数组和头下标
function paintL() {
    # 初始化数组
    eval 'len=${#dataL'$4'[@]}'
    if [ $len -eq 0 ]; then
        initL $4 $dataLLen
    fi
    # 计算数取整
    leftNum=$2
    rightNum=$3
    if [ ! `expr index "$leftNum" .` -eq 0 ]; then
        intLen=`expr index "$leftNum" . - 1`
        leftNum=${leftNum:0:$intLen}
    fi
    if [ ! `expr index "$rightNum" .` -eq 0 ]; then
        intLen=`expr index "$rightNum" . - 1`
        rightNum=${rightNum:0:$intLen}
    fi
    # 计算映射到图形中的高度
    let currPos=$leftNum*$graphLHt/$rightNum
    eval 'dataL'$4'[$startIdxL'$4']=$currPos'
    # 移动头下标
    eval 'let startIdxL'$4'="($startIdxL'$4' + 1) % ${#dataL'$4'[@]}"'
    # 打印表头
    printf '%-'$dataLLen's\r\n' $1
    # 打印数组数据
    eval 'pos=$startIdxL'$4
    for ((i=$graphLHt;i>=1;i--)); do 
        l=''
        for ((j=$pos;j<$dataLLen;j++)); do
            eval 'val=${dataL'$4'[$j]}'
            if [ $val = $i ]; then 
                l+='x'
            else 
                l+='-'
            fi
        done
        for ((j=0;j<$pos;j++)); do
            eval 'val=${dataL'$4'[$j]}'
            if [ $val = $i ]; then
                l+='x'
            else 
                l+='-'
            fi
        done
        if [ $i = $graphAHt ]; then 
            printf '%-'$dataLLen's %s / %-11s\r\n' $l $2 $3
        else 
            printf '%-'$dataLLen's\r\n' $l
        fi
    done
    unset len
    unset leftNum
    unset rightNum
    unset intLen
    unset currPos
    unset val
    unset i
    unset j
    unset pos
    unset l
    unset max
}


# 返回柱状图高度
function cursorMoveNumL() {
    # 多一行表头
    return `expr $graphLHt + 1`
}
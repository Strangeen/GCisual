# -----------------------------------------------------------------------------
# version: v0.0.1
# license: Apache License 2.0
# author：strangeen
# url: www.dinghuiye.online
# github: github.com/strangeen
# -----------------------------------------------------------------------------

# 图形标识为A
registGraph A

# 宽度
dataALen=100
# 高度
graphAHt=8

# 环形数组dataAN存放数据，容量为$2
# 设置初始头下标startIdxA=0，即遍历数组的起始下标
# 添加元素的下标为startIdxA
# 添加元素后，头下标向后移一位，即startIdxA=(startIdxA+1)%$1
# 数组需要赋初值为0
# $1-唯一编号，$2-数组长度
function initA() {
    # 为每个编号生成独自的数组和头下标
    eval 'startIdxA'$1'=0'
    for ((i=0;i<$2;i++)); do
        eval 'dataA'$1'[$i]=0'
    done
    unset i
}


# 绘制折线
# 参数 $4-唯一编号，多个图形对应多个全局数组和头下标
function paintA() {
    # 初始化数组
    eval 'len=${#dataA'$4'[@]}'
    if [ $len -eq 0 ]; then
        initA $4 $dataALen
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
    let currPos=$leftNum*$graphAHt/$rightNum
    eval 'dataA'$4'[$startIdxA'$4']=$currPos'
    # 移动头下标
    eval 'let startIdxA'$4'="($startIdxA'$4' + 1) % ${#dataA'$4'[@]}"'
    # 打印表头
    printf '%-'$dataALen's\r\n' $1
    # 打印数组数据
    for ((i=$graphAHt;i>=1;i--)); do 
        l=''
        eval 'pos=$startIdxA'$4
        for ((j=$pos;j<$dataALen;j++)); do
            eval 'val=${dataA'$4'[$j]}'
            if [ $val -ge $i ]; then 
                l+='*'
            else 
                l+='-'
            fi
        done
        for ((j=0;j<$pos;j++)); do
            eval 'val=${dataA'$4'[$j]}'
            if [ $val -ge $i ]; then 
                l+='*'
            else 
                l+='-'
            fi
        done
        if [ $i = $graphAHt ]; then 
            printf '%-'$dataALen's %s / %-11s\r\n' $l $2 $3
        else 
            printf '%-'$dataALen's\r\n' $l
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
}


# 返回柱状图高度
function cursorMoveNumA() {
    # 多一行表头
    return `expr $graphAHt + 1`
}
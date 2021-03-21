# -----------------------------------------------------------------------------
# version: v0.0.1
# license: Apache License 2.0
# author：strangeen
# url: www.dinghuiye.online
# github: github.com/strangeen
# -----------------------------------------------------------------------------

# 图形标识为B
registGraph B


# 宽度
dataBLen=100


# 绘制柱状图
function paintB() {
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
    let currPos=$leftNum*$dataBLen/$rightNum
    b='|'
    for ((i=0;i<$currPos;i++)); do
        b+='|'
    done
    printf '%-'$dataBLen's| %s %s / %-11s\r\n' $b $1':' $2 $3
    unset b
    unset i
    unset leftNum
    unset rightNum
    unset intLen
    unset currPos
}

# 返回柱状图高度
function cursorMoveNumB() {
    return 1
}
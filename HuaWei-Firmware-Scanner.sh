#!/bin/bash
# @Author: 56304289@qq.com
# @Date: 2016.06.21
# @Last Modified by:   anchen
# @Last Modified time: 2016.06.19

echo "请输入手机型号: TL00 TL00H UL00"
read model

if [ ! $model ]; then
  echo "你没有输入手机型号,程序即将退出."
  exit 0
fi

case $model in
    "TL00")
        ml="1021"
        ;;
    "TL00H")
        ml="1022"
        ;;
    "UL00")
        ml="1018"
        ;;
esac

Filter(){
    if [[ $1 == "1" ]]; then
        File="$PWD/$model/$i.xml"
        Size=`ls -il $File | awk '{print $6}'`
        if [ $Size -le "162" ] || [ $Size == "1500" ];then
            echo
            echo "This is Not to Download File, Will be Deleted!"
            echo "File:$File"
            echo "Size:$Size"
            rm $File
        fi
    else
        for f in `ls $PWD/$model`; do
            File=`ls -il $PWD/$model/$f | awk '{print $10}'`
            Size=`ls -il $PWD/$model/$f | awk '{print $6}'`
            if [ $Size -le "162" ] || [ $Size == "1500" ];then
                echo
                echo "This is Not to Download File, Will be Deleted!"
                echo "File:$File"
                echo "Size:$Size"
                rm $File
            fi
        done
    fi
}

Filter

GetCount=0
declare -i GetCount
MaxCount=100
declare -i MaxCount

echo "请输入开始查询的版本号（推荐从 `cat $PWD/$model/NewVerID` `cat $PWD/$model/NewVer` 开始）："
read query_version
echo "请输入结束查询的版本号:"
read e

if [ ! $query_version ]&&[ ! $e ]; then
  echo "你没有输入要查询的版本,程序即将退出."
  exit 0
fi

download_url="http://update.hicloud.com:8180/TDS/data/files/p3/s15/G$ml/g223"

for ((i=$query_version;i<$e;i++));do
    if [ $GetCount != $MaxCount ]; then
        echo
        echo "正在查询版本 v$i，若想终止直接关闭窗口"
        echo
        changelog_url="$download_url/v$i/f1/full/changelog.xml"
        curl $changelog_url > $PWD/$model/$i.xml

        Filter 1
        GetCount=GetCount+1
    else
        echo "Stop 30s"
        sleep 30
        GetCount=0
    fi
done

echo "可下载版本:"
#for xml in `find $PWD/$model`;do
#    vs=(`basename -s .xml $xml`)
#    vars=(${vs[*]})
#    echo "${vars[*]}"
#done

vs=(`find $PWD/$model -name *.xml`)
vars=(`basename -s .xml ${vs[*]}`)
sort_vars=($(for sv in "${vars[@]}";do echo "$sv"; done | sort))

echo "${sort_vars[*]}"

num="${#sort_vars[@]}"

NewVer=(${sort_vars[$(($num - 1))]})

NewVer(){
  export "$1"
}

nver=`grep -n "B" $PWD/$model/$NewVer.xml | awk '{print $4}'`
NewVer $nver
echo $version >$PWD/$model/NewVer
echo $NewVer >$PWD/$model/NewVerID

echo "请输入要下载的版本:"
read var

if [ ! $var ]; then
  echo "你没有输入要下载的版本,程序即将退出."
  exit 0
fi

echo "请选择下载工具例如: axel curl wget"
read d

update_zip="$download_url/v$var/f1/full/update.zip"
precheck_script="$download_url/v$var/f1/full/precheck-script"

Downloader(){
  val=($@)

  mkdir -p HwOUC/$var
  if [[ `command -v $1` ]]; then
    if [ "${#val[@]}" > "1" ]; then
      cd HwOUC/$var
      $@ $update_zip
      cd ..
      $@ $precheck_script
    else
      cd HwOUC/$var
      $1 $update_zip
      cd ..
      $1 $precheck_script
    fi
  else
    echo "Not Install $1!"
  fi
}

case $d in
    "axel")
        val='-n 16'
    ;;
#    "curl")
#        val=""
#    ;;
#    "wget")
#        val=""
#    ;;
    *)
       echo "如果你的下载工具有参数要求,请输入你的参数,没有请直接回车."
       read val
    ;;
esac

Downloader $d $val
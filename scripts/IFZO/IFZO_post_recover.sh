#!/bin/sh
 
# 説明：
# 　システムリストア時のchroot後の処理を実行するスクリプト。
# 　restore.shにてリカバリ先の領域にコピーされる。
# 　処理実行後はrestore.shにて消去される。
#
# 前提：
# 　リストア後のファイルシステムに/tmpディレクトリが存在していること
#
# 使い方：
# 　after_chroot.sh <リカバリ前のblkid出力結果ファイル名>
# 変数：
#
# 引数：
# 　第1引数：リカバリ前のラベル情報(blkid出力結果ファイル名)
# 
 
if [ -z "$1" ] || [ ! -f "$1" ];then
    echo "Can't find blkid output file."
    exit 2
fi
# blkidの出力結果を引数に渡される
BLKID_TMP=$1

# 実行時のログファイル
SHELL_NAME=`basename ${0} .sh`
LOG_FILE=${BACKUP_DIR}/${SHELL_NAME}_`date +%Y%m%d`.log

ROOT_PART=`grep 'LABEL="/"' ${BLKID_TMP} | awk '{gsub(":","")}{print $1}'`
 
echo -e '\n\n############ Running after chroot script `date` #############' | tee -a ${LOG_FILE}
 
# grubのインストールに必要な領域をマウントする
mount /proc
mount -t sysfs none /sys
mount -o mode=0755 -t tmpfs none /dev

echo -e '\n\n############ mount information `date` #############' | tee -a ${LOG_FILE}
mount | tee -a ${LOG_FILE}

echo -e "\n\n############ Start udev `date` #############" | tee -a ${LOG_FILE}
/sbin/start_udev 2>&1 | tee -a ${LOG_FILE}
 
# /boot領域に必要な情報があることを確認する
ls -al /boot 2>&1 | tee -a ${LOG_FILE}

echo -e "\nPlease check the information you need."
echo -e "Press ENTER is continued grub-install.\nPress Ctrl+C is abort grub-install."
read WAIT

# リストア開始
cp /proc/mounts /etc/mtab
# ブートローダーのインストール
grub-install /dev/sda 2>&1 | tee -a ${LOG_FILE}
 
# 一時的に作成した${BLKID_TMP}から各パーティションにラベルを付与する
for ii in `fdisk -l /dev/sda | grep -e " 83 " | awk '{print $1}'`
do
    echo -e "\n\n############ Labeling now ${ii} #############\n######## `date`" | tee -a ${LOG_FILE}
    LABEL=`grep -E ${ii} ${BLKID_TMP} | awk -F'"' '{gsub(": LABEL=","")}{print $1,$2}'`
 
    echo -e "### CMD: e2label ${LABEL} ###"| tee -a ${LOG_FILE}
    e2label ${LABEL} 2>&1 | tee -a ${LOG_FILE}
    if [ 0 -ne 0 ]; then
        echo An Error occurred labeling for ${ii} | tee -a ${LOG_FILE}
        exit 2
    fi
 
    echo -n "LABEL for ${ii} is " 2>&1 | tee -a ${LOG_FILE}
    e2label ${ii} 2>&1 | tee -a ${LOG_FILE}
done
 
echo -e "\n\n############## Make SWAP area #############\n######## `date`" | tee -a ${LOG_FILE}
mkswap -L `grep 'TYPE="swap"' ${BLKID_TMP} | awk -F'"' '{gsub(": LABEL=","")}{print $2,$1}'` 2>&1 | tee -a ${LOG_FILE}
 

# ネットワーク構成情報のバックアップ実行選択
echo -en "\n\nDo you backup NIC information?(y/n) :"
read answer
 
case ${answer} in
    y)
        echo -e "\n############## Now Backup NIC informations in /tmp/old_ifcfg/.  #############"| tee -a ${LOG_FILE}
        mkdir /tmp/old_ifcfg
        cp /etc/sysconfig/network /tmp/old_ifcfg
        for jj in `find /etc/sysconfig/network-scripts ! -name *lo -and -name ifcfg* -or -name route*`
        do
            cp ${jj} /tmp/old_ifcfg/
        done
 
        echo -e "\n\nPlease rewrite the MAC address shown below.\n" 2>&1 | tee -a ${LOG_FILE}
        grep HWADDR /etc/sysconfig/network-scripts/ifcfg-* 2>&1 | tee -a ${LOG_FILE}
 
        echo -e "\n\nPlease rewrite the IP address shown below.\n" 2>&1 | tee -a ${LOG_FILE}
        grep IPADDR /etc/sysconfig/network-scripts/ifcfg-* 2>&1 | tee -a ${LOG_FILE}
 
        echo -e "\n\nAnd rewrite hostname in /etc/sysconfig/network\nBefore enter exit."| tee -a ${LOG_FILE}
        echo -e "\n############## cat /etc/sysconfig/network  #############"| tee -a ${LOG_FILE}
        cat /etc/sysconfig/network  2>&1 | tee -a ${LOG_FILE}
        ;;
    n)
        echo -e "\n############## No Backup NIC informations.  #############"| tee -a ${LOG_FILE}
        ;;
esac
 
echo -e '\n\n############ Complete after chroot script `date` #############' | tee -a ${LOG_FILE}
 
exit

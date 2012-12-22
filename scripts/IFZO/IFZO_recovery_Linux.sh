#!/bin/sh

# 前提：
# 　リカバリ対象の内部ディスクが/dev/sdaで認識されていること
# 　リカバリ対象の内部ディスクは全てext3構成かつLVM構成が含まれていないこと
# 　リカバリ対象のswap領域は1つであること
# 　バックアップ対象ディレクトリに"blkid"コマンドの出力結果があること
# 　リカバリするパーティションのdump情報のファイル名は下記の書式であること
# 　　"パーティション名.dump(例：sda1.dump)"
# 　システムバックアップディレクトリがNFSマウントされていること
#
# 使い方：
# 　restore.sh <リカバリ元ディレクトリ名> <リストア先マウントポイント>
# 　必要に応じて下記変数を変更する。
# 変数：
# 　RESTORE_DIR  ：リストア対象になるマウントポイント
# 　AFTER_SCRIPT ：chroot後実行スクリプト名
# 　SFDISK_TXT   ：sfdisk -lコマンド出力結果ファイル名
# 　BLKID    ：blkidコマンド出力結果ファイル名
#
# 引数：
# 　第1引数 リカバリするバックアップ情報を格納したディレクトリ名
# 　第2引数 リカバリ先とするマウントポイント

# Variable definition
MOUNTPOINT=`dirname ${0}`
BACKUP_DIR=${MOUNTPOINT}/$1
RESTORE_DIR=$2

AFTER_SCRIPT=IFZO_post_recover.sh
SFDISK_TXT=sfdisk.txt
BLKID_TXT=blkid.txt

# リストア実行時のログファイル
SHELL_NAME=`basename ${0} .sh`
LOG_FILE=${BACKUP_DIR}/${SHELL_NAME}_`date +%Y%m%d`.log

AFTER_CHROOT=${MOUNTPOINT}/${AFTER_SCRIPT}
SFDISK=${BACKUP_DIR}/${SFDISK_TXT}
BLKID=${BACKUP_DIR}/${BLKID_TXT}

# Check Args backup,restore directory
# 第1引数で指定したリカバリ元のディレクトリが無ければ終了。exit 2
if [ -z "$1" ] || [ ! -d ${BACKUP_DIR} ];then
    echo "Specifies the backup target is wrong."
    exit 2
fi

# 第2引数で指定したリカバリポイントが無ければ作成する。
if [ ! -d ${RESTORE_DIR} ]; then
    echo "create the destination directory could not be found."
    mkdir ${RESTORE_DIR}
fi

# ルートパーティション
ROOT_PART=`grep 'LABEL="/"' ${BLKID} | awk '{gsub(":","")}{print $1}'`

# タイムスタンプをUTCからJSTに設定
ln -s /usr/share/zoneinfo/Japan /etc/localtime
hwclock --hctosys

echo -e "############## Restorering START  #############\n######## `date`" | tee -a ${LOG_FILE}

sleep 5

# Mount check
# リストア対象のマウントポイントに何もマウントされていないことを確認。
# マウントされている場合には対象のアンマウントを試行。
# アンマウント試行中にエラーがあった場合には処理を終了。exit 2
RESTORE_POINT=`mount | grep ${RESTORE_DIR} | awk '{print $3}'`
while [ -n "${RESTORE_POINT}" ]
do
    echo -e "############## ${RESTORE_DIR} has mounted on ${RESTORE_POINT} #############\n######## `date`" | tee -a ${LOG_FILE}
    mount | grep ${RESTORE_DIR} >> ${LOG_FILE}
    umount ${RESTORE_POINT}
    if [ $? -ne 0 ]; then
        echo "An Error occurred during unmounting device on ${RESTORE_POINT}" | tee -a ${LOG_FILE}
        exit 2
    fi
    echo " Now unmounted ${RESTORE_POINT}"  >> ${LOG_FILE}
    RESTORE_POINT=`mount | grep ${RESTORE_DIR} | awk '{print $3}'`
done

# Disk re-partithioning
# ディスク(/dev/sda)のパーティション情報をリストアする。
echo "## Before Disk Partithion Information  cat ${SFDISK} ##" | tee -a ${LOG_FILE}
cat ${SFDISK} 2>&1 | tee -a ${LOG_FILE}

echo -e "\n\nDo you may continue the process?"
echo -e "Press ENTER is continued recovery.\nPress Ctrl+C is abort recovery."
read WAIT

echo -e "############## Disk Partithion Format! #############\n######## `date`" | tee -a ${LOG_FILE}
sfdisk /dev/sda < ${SFDISK}  2>&1 | tee -a ${LOG_FILE}

echo "############## cat /proc/partitions #############" | tee -a ${LOG_FILE}
cat /proc/partitions 2>&1 | tee -a ${LOG_FILE}

# Format
# リストアしたパーティションをext3でフォーマットする
echo -e "\n\n############## Format partithion START  #############\n######## `date`" | tee -a ${LOG_FILE}
for ii in `fdisk -l /dev/sda | grep -e " 83 " | awk '{print $1}' | sed -e 's/\/dev\/sda//'`
do
    sleep 3
    echo -e "\n\n############## Formatting now /dev/sda${ii} #############\n######## `date`" | tee -a ${LOG_FILE}
    (time mke2fs -j /dev/sda${ii}) 2>&1 | tee -a ${LOG_FILE}
done
echo -e "\n\n############## Format partithion END   #############\n######## `date`" | tee -a ${LOG_FILE}

# Restore
# フォーマットしたパーティションにバックアップ情報を書き戻す
# 最初にルートパーティション${ROOT_PART}をリカバリ
echo -e "\n\n############## Recover partithion START  #############\n######## `date`" | tee -a ${LOG_FILE}
mount -t ext3 ${ROOT_PART} ${RESTORE_DIR}
cd ${RESTORE_DIR}/
rm -rf ./lost+found
echo -e "\n\n#### Restoring now ${ROOT_PART} on ${RESTORE_DIR} ####\n######## `date`" | tee -a ${LOG_FILE}
echo "Current dir :`pwd`" | tee -a ${LOG_FILE}
(time restore rf ${BACKUP_DIR}/${ROOT_PART#/dev/}.dump)  2>&1 | tee -a ${LOG_FILE}

rm -rf ./restoresymtable

# リカバリしたルートパーティションを"$RESTORE_DIR"にマウントし、
# リカバリ対象パーティションを順次マウントしてリカバリ
# バックアップ時に取得した"${BLKID}"からマウントポイントの情報を得る
for ii in `fdisk -l /dev/sda | grep -e " 83 " | grep -v "${ROOT_PART}" | awk '{print $1}' | sed -e 's/\/dev\/sda//'`
do
    sleep 3
    LABEL=""
    LABEL=`grep -E /dev/sda${ii} ${BLKID} | awk '{print $2}' | cut -b 8- | sed -e 's/\"$//'`
    echo -e "\n\n#### Restore now /dev/sda${ii} on ${RESTORE_DIR}${LABEL}   ####\n######## `date`" | tee -a ${LOG_FILE}
    if [ -z "${LABEL}" ]; then
        echo "Can't find LABEL for /dev/sda${ii}" | tee -a ${LOG_FILE}
        exit 2
    fi

    mount -t ext3 /dev/sda${ii} ${RESTORE_DIR}${LABEL}
    cd ${RESTORE_DIR}${LABEL}

    rm -rf ./lost+found

    echo "Current dir :`pwd`" | tee -a ${LOG_FILE}

    (time restore rf ${BACKUP_DIR}/sda${ii}.dump)  2>&1 | tee -a ${LOG_FILE}
    if [ $? -ne 0 ]; then
        echo "An Error occurred restoring for /dev/sda${ii}" | tee -a ${LOG_FILE}
        exit 2
    fi

    rm -rf ./restoresymtable

done

echo -e "\n\n############## Recover partithion END   #############\n######## `date`" | tee -a ${LOG_FILE}
echo -e "\n\n######and prepare the script for the next processing. #######" | tee -a ${LOG_FILE}

# Prepare the script to be executed next.
# chrootを行うため、スクリプトは一時停止する。
# そのため、chroot後に実行するスクリプトを下記$AFTER_CHROOT_TMPに作成しておく。
# chroot後は/tmpにある$AFTER_CHROOT_TMPを実行する。
AFTER_CHROOT_TMP=${RESTORE_DIR}/tmp/${AFTER_SCRIPT}_`date +%H%M%S`.sh
BLKID_TMP=${RESTORE_DIR}/tmp/${BLKID_TXT}_`date +%H%M%S`.txt

cp -ap ${AFTER_CHROOT} ${AFTER_CHROOT_TMP}
cp -ap ${BLKID} ${BLKID_TMP}

chmod +x ${AFTER_CHROOT_TMP}
cat ${AFTER_CHROOT_TMP}  | tee -a ${LOG_FILE}
echo -e "\n\n############################################################" | tee -a ${LOG_FILE}
echo "### Restore has done. And run chroot.         ###" | tee -a ${LOG_FILE}
echo "### Please run the following script with the argument.   ###" | tee -a ${LOG_FILE}
echo "### ${AFTER_CHROOT_TMP#${RESTORE_DIR}} ${BLKID_TMP#${RESTORE_DIR}}" | tee -a ${LOG_FILE}
echo "### And please enter 'exit'                 ###" | tee -a ${LOG_FILE}
echo "############################################################" | tee -a ${LOG_FILE}

chroot ${RESTORE_DIR}

# 一時的に作成したスクリプトを削除
echo -e "\n\n###### Remove temp script #######" | tee -a ${LOG_FILE}
rm -f ${AFTER_CHROOT_TMP}
rm -f ${BLKID_TMP}


echo -e "\n\n########### Restore has comlete. #############\n######## `date`" | tee -a ${LOG_FILE}

exit

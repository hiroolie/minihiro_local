#!/bin/sh

# 説明：
# 　システムバックアップ取得スクリプト
# 　NFSマウントしたディレクトリに作成済みの、バックアップ先ディレクトリを指定し
# 　パーティションの形式が"83"のパーティションのdumpを取得する。
# 前提：
# 　システムバックアップディレクトリがNFSマウントされていること
# 　バックアップ対象は/dev/sda
#
# 使い方：
# 　backup.sh <pre_backup.shで作成済みのバックアップ先ディレクトリ名>
# 変数：
#
# 引数：
# 　第1引数(任意)：　pre_backup.shで作成されたバックアップ先ディレクトリ名を指定
#

# バックアップディレクトリ
MOUNTPOINT=`dirname ${0}`
BACKUP_DIR=${MOUNTPOINT}/$1

# 実行時のログファイル
SHELL_NAME=`basename ${0} .sh`
LOG_FILE=${BACKUP_DIR}/${SHELL_NAME}_`date +%Y%m%d`.log

# Check Args backup,restore directory
if [ -z "$1" ] || [ ! -d ${BACKUP_DIR} ];then
    echo "Specifies the backup target is wrong."
    exit 2
fi

# タイムスタンプをUTCからJSTに設定
ln -s /usr/share/zoneinfo/Japan /etc/localtime
hwclock --hctosys

# バックアップ開始
echo "############## Backup with dump START `date` #############"  | tee ${LOG_FILE}
for ii in `fdisk -l /dev/sda | grep -e " 83 " | awk '{print $1}' | sed -e 's/\/dev\/sda//'`
do
    sleep 3
    echo -e "\n\n############## Backup now /dev/sda${ii} #############" | tee -a ${LOG_FILE}
    ( time dump -f ${BACKUP_DIR}/sda${ii}.dump /dev/sda${ii} ) 2>&1 | tee -a ${LOG_FILE}
    if [ $? -ne 0 ]; then
        echo "An Error occurred during dump backup on /dev/sda${ii}" | tee -a ${LOG_FILE}
        exit 2
    fi
done

echo "############## Backup with dump END `date` #############"  | tee -a ${LOG_FILE}

exit

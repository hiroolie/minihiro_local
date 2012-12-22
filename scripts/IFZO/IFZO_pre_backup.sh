#!/bin/sh

# 説明：
# 　システムバックアップ取得前構成情報収集スクリプト
# 　NFSマウントしたディレクトリに、日付名のディレクトリを作成し
# 　構成情報を取得する。
# 前提：
# 　システムバックアップディレクトリがNFSマウントされていること
# 　バックアップ対象は/dev/sda
#
# 使い方：
# 　pre_backup.sh
# 変数：
#
# 引数：
# 　第1引数(任意)：　バックアップを取得するディレクトリ名を指定
# 　　　　　　　　　 指定しない場合は実行日(YYYYMMDD)となる

# 変数定義
MOUNTPOINT=`dirname ${0}`
SFDISK_TXT=sfdisk.txt
BLKID_TXT=blkid.txt
MOUNT_TXT=mount.txt
FSTAB_TXT=fstab.txt

# 引数をチェックし、あればバックアップ取得先に指定する。
if [ -n "$1" ]; then
    DIRNAME=$1
else
    DIRNAME=`date +%Y%m%d`
fi

BACKUP_DIR=${MOUNTPOINT}/${DIRNAME}
# バックアップ取得先が無ければ作成する
if [ ! -d ${BACKUP_DIR} ]; then
    mkdir ${BACKUP_DIR}

    if [[ $? -ne 0 ]]
    then
      echo "Can't create backup directory."
      exit 8
    fi
    
fi

# バックアップ前情報収集
echo -e "\n\n############ Start collecting the configuration information. #############"
mount > ${BACKUP_DIR}/mount.txt
cat /etc/fstab > ${BACKUP_DIR}/fstab.txt
sfdisk -d /dev/sda > ${BACKUP_DIR}/${SFDISK_TXT}
blkid > ${BACKUP_DIR}/${BLKID_TXT}

echo -e "\n\n############ Collecting the configuration information has done. #############"
ls -la ${BACKUP_DIR}

# バックアップ情報確認
echo -e "\n\n############ Check the configuration information.. #############"
ls -la ${BACKUP_DIR}
echo -e "\n\n############ mountdata backup data ${BACKUP_DIR}/mount.txt #############"
cat ${BACKUP_DIR}/mount.txt
echo -e "\n\n############ fstab backup data ${BACKUP_DIR}/fstab.txt #############"
cat ${BACKUP_DIR}/fstab.txt
echo -e "\n\n############ Partition backup data ${BACKUP_DIR}/${SFDISK_TXT} #############"
cat ${BACKUP_DIR}/${SFDISK_TXT}
echo -e "\n\n############ fstab backup data ${BACKUP_DIR}/${BLKID_TXT} #############"
cat ${BACKUP_DIR}/${BLKID_TXT}

exit

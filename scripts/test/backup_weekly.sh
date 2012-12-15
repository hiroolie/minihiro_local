#!/bin/sh

BACKUP_DIR=/backup/repositories
SVN_DIR=/data/repositories
LOG_DIR=/opt/csvn/data/logs/
LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H:%M:%S'`
LOGFILE="${LOG_DIR}${LOG_DATE}_`basename $0 .sh`.log"
REPO_LIST=/tmp/repo_list.txt
WEEKLY_BKUP=/opt/csvn/bin/svn_backup_weekly.pl
DAILY_BKUP=/opt/csvn/bin/svn_backup_daily.pl
EXPIRATION_DATE=7

if [ `date +%w` = 0 ]; then
    BKUP_PL=${WEEKLY_BKUP}
    TYPE_BK="Weekly full"
else
    BKUP_PL=${DAILY_BKUP}
    TYPE_BK="Daily incremental"
fi

# --共通関数定義--
# ログ出力関数
LOG(){
  # ログ出力先
  # 引数展開
  FILENM=`basename $0`
  MSG=$@

  # ログ出力実行
  printf "%-10s %-8s %-14s %-50s\n" \
  "${LOG_DATE}" "${LOG_TIME}" "${FILENM}" "${MSG}" >>${LOGFILE}
}

makedir(){
    mkdir $1

    if [ $? -ne 0 ]; then
        LOG "Can't make directory for backup."
        exit 1
    fi

    echo 0 > $1/.last_backed_up
}

deleteExpiration(){
DEL_DIR=$1
DEL_NAME=$2
find ${DEL_DIR}/${DEL_NAME}/ -maxdepth 1 \( -ctime +${EXPIRATION_DATE} -a -name '*${DEL_NAME}_[0-9]*[0-9]' \) -type f -exec rm {} \;

if [ `find ${DEL_DIR}/${DEL_NAME}/ -maxdepth 1 \( -ctime +${EXPIRATION_DATE} -a -name '*${DEL_NAME}_[0-9]*[0-9]' \) -type f | wc -l` != 0 ]; then
    LOG "Can't delete previous full backup files."
    exit 1
fi

find ${DEL_DIR}/${DEL_NAME}/ -maxdepth 1 \( -ctime +7 -a -name '*${DEL_NAME}_r[0-9]*[0-9]\:[0-9]*[0-9]_[0-9]*[0-9]' \) \-type f -exec rm {} \;

if [ `find ${DEL_DIR}/${DEL_NAME}/ -maxdepth 1 \( -name '*${DEL_NAME}_r[0-9]*[0-9]\:[0-9]*[0-9]_[0-9]*[0-9]' \) -type f | wc -l` != 0 ]; then
    LOG "Can't delete previous week incremental backup files."
    exit 1
fi

}

##################

ls -1 ${SVN_DIR} > ${REPO_LIST}

if [ ! -s ${REPO_LIST} ]; then
    LOG "Can not find repository for backup."
    exit 1
fi

while read REPONAME; do

    if [ ! -d ${BACKUP_DIR}/${REPONAME} ]; then
        makedir ${BACKUP_DIR}/${REPONAME}
    fi

    LOG "START ${TYPE_BK} BACK UP ${REPONAME}"
    ${BKUP_PL} ${REPONAME} ${BACKUP_DIR} ${SVN_DIR} >> ${LOGFILE} 2>&1
    LOG "END ${TYPE_BK} BACK UP ${REPONAME}"

    if [ ${BKUP_PL} = ${WEEKLY_BKUP} ];then
        deleteExpiration ${BACKUP_DIR} ${REPONAME}
    fi

done < ${REPO_LIST}



LOG "END ${TYPE_BK} BACK UP ${REPONAME}"

rm -rf ${REPO_LIST}

if [ -f {REPO_LIST} ]; then
    LOG "Can't delete repository list file."
    exit 1
fi
exit 0

#
#!/usr/bin/env bash

SCRIPT_NAME="$( basename "$0" )"
BASE_PATH="$( dirname $( readlink -e "$0" ) )"

function print_error() {
	echo $( date "+%y-%m-%d %H:%M:%S" ) ${SCRIPT_NAME} $@ 1>&2
}

function panic() {
    print_error $@
    exit 1
}

cd /tmp

MYSQL_DATABASE="${MYSQL_DATABASE}"
if [[ -z "${MYSQL_DATABASE}" ]]; then
    panic "MYSQL_DATABASE have to be defined"
fi
MYSQL_HOST="${MYSQL_HOST}"
MYSQL_USER="${MYSQL_USER}"
MYSQL_PORT="${MYSQL_PORT}"
MYSQL_PASSWORD="${MYSQL_PASSWORD}"

MYSQL_BACKUP_TYPE="${MYSQL_BACKUP_TYPE}"
MYSQL_BACKUP_TARGET="${MYSQL_BACKUP_TARGET}"
if [[ -z "${MYSQL_BACKUP_TARGET/}" ]]; then
    panic "MYSQL_BACKUP_TARGET have to be defined"
fi

case "${MYSQL_BACKUP_TYPE}" in
git)
    mysql_backup_dir="$( mktemp -d /tmp/mysql.XXX )"
    trap "rm -Rf ${mysql_backup_dir}" 0 1

    git clone "${MYSQL_BACKUP_TARGET}" "${mysql_backup_dir}" -q || \
        panic "Can't clone initial git dir ${MYSQL_BACKUP_TARGET}"
    ;;
hg|mercurial)
    mysql_backup_dir="$( mktemp -d /tmp/mysql.XXX )"
    trap "rm -Rf ${mysql_backup_dir}" 0 1

    hg clone "${MYSQL_BACKUP_TARGET}" "${mysql_backup_dir}" -q || \
        panic "Can't clone initial hg dir ${MYSQL_BACKUP_TARGET}"
    ;;
"")
    mysql_backup_dir="${MYSQL_BACKUP_TARGET}"
    ;;
*)
    print_error "$SCRIPT_NAME invalid MYSQL_BACKUP_TARGET have to be in [git|mercurial|\"\"]"
    exit 1
esac


mysql_env=
mysql_suffix=
if [[ ! -z "${MYSQL_PASSWORD}" ]] ; then
    mysql_env="${mysql_env} MYSQL_PWD=\"${MYSQL_PASSWORD}\""
fi

if [[ ! -z "${MYSQL_USER}" ]] ; then
    mysql_suffix="${mysql_suffix} --user=${MYSQL_USER}"
fi

if [[ ! -z "${MYSQL_HOST}" ]] ; then
    mysql_suffix="${mysql_suffix} --host=${MYSQL_HOST}"
fi

if [[ ! -z "${MYSQL_PORT}" ]] ; then
    mysql_suffix="${mysql_suffix} --port=${MYSQL_PORT}"
fi

mysql_split="${BASE_PATH}/mysqldump_splitsort.py"

sql_dump_file="$( mktemp /tmp/dump.XXXX )"
eval ${mysql_env} mysqldump ${mysql_suffix} --result-file="${sql_dump_file}" ${MYSQL_DATABASE} \
    -c --skip-opt --skip-dump-date || \
    panic "Error dumpring databse ${MYSQL_USER}@${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DATABASE}"

"${mysql_split}" "${sql_dump_file}" -d "${mysql_backup_dir}" -c || \
    panic "Error splitting databse dump "
rm -f "${sql_dump_file}"

case "${MYSQL_BACKUP_TYPE}" in
git)
    (
        cd ${mysql_backup_dir}  \
            && git add -A > /dev/null  \
            && { git commit -a -q -m "[Periodic backup]" > /dev/null || if [[ $? -gt 1 ]]; then false; fi } \
            && {
                git push -q 2> /dev/null \
                || git push -q
            }
    ) || panic "Can't commit and push changes to ${MYSQL_BACKUP_TARGET}"
    ;;
hg|mercurial)
    (
        cd ${mysql_backup_dir}  \
            && hg add . >> /dev/null \
            && { hg commit -A -q -m "[Periodic backup]" > /dev/null || if [[ $? -gt 1 ]]; then false; fi ; } \
            && {
                hg push -q &> /dev/null || if [[ $? -gt 1 ]]; then false; fi \
                || hg push -q > /dev/null || if [[ $? -gt 1 ]]; then false; fi
            }
    ) || panic "Can't commit and push changes to ${MYSQL_BACKUP_TARGET}"
    ;;
esac
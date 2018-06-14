#!/usr/bin/env bash

set -e

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

PGSQL_DATABASE="${PGSQL_DATABASE}"
if [[ -z "${PGSQL_DATABASE}" ]]; then
    panic "PGSQL_DATABASE have to be defined"
fi
PGSQL_HOST="${PGSQL_HOST}"
PGSQL_USER="${PGSQL_USER}"
PGSQL_PORT="${PGSQL_PORT}"
PGSQL_PASSWORD="${PGSQL_PASSWORD}"

PGSQL_BACKUP_TYPE="${PGSQL_BACKUP_TYPE}"
PGSQL_BACKUP_TARGET="${PGSQL_BACKUP_TARGET}"
if [[ -z "${PGSQL_BACKUP_TARGET/}" ]]; then
    panic "PGSQL_BACKUP_TARGET have to be defined"
fi

case "${PGSQL_BACKUP_TYPE}" in
git)
    mysql_backup_dir="$( mktemp -d /tmp/pgsql.XXX )"
    trap "rm -Rf ${mysql_backup_dir}" 0 1

    git clone "${PGSQL_BACKUP_TARGET}" "${mysql_backup_dir}" -q || \
        panic "Can't clone initial git dir ${PGSQL_BACKUP_TARGET}"
    ;;
hg|mercurial)
    mysql_backup_dir="$( mktemp -d /tmp/mysql.XXX )"
    trap "rm -Rf ${mysql_backup_dir}" 0 1

    hg clone "${PGSQL_BACKUP_TARGET}" "${mysql_backup_dir}" -q || \
        panic "Can't clone initial hg dir ${PGSQL_BACKUP_TARGET}"
    ;;
"")
    mysql_backup_dir="${PGSQL_BACKUP_TARGET}"
    ;;
*)
    print_error "$SCRIPT_NAME invalid PGSQL_BACKUP_TARGET have to be in [git|mercurial|\"\"]"
    exit 1
esac


pgsql_env=
pgdump_suffix=
if [[ ! -z "${PGSQL_PASSWORD}" ]] ; then
    pgsql_env="${pgsql_env} MYSQL_PWD=\"${PGSQL_PASSWORD}\""
fi

if [[ ! -z "${PGSQL_USER}" ]] ; then
    pgdump_suffix="${pgdump_suffix} --user=${PGSQL_USER}"
fi

if [[ ! -z "${PGSQL_HOST}" ]] ; then
    pgdump_suffix="${pgdump_suffix} --host=${PGSQL_HOST}"
fi

if [[ ! -z "${PGSQL_PORT}" ]] ; then
    pgdump_suffix="${pgdump_suffix} --port=${PGSQL_PORT}"
fi

pg_split="${BASE_PATH}/pgdump_splitsort.py"

sql_dump_file="$( mktemp /tmp/dump.XXXX )"
eval ${pgsql_env} pg_dump ${pgdump_suffix} ${PGSQL_DATABASE} \
    -c --skip-opt --skip-dump-date --create-options  > "${sql_dump_file}" || \
    panic "Error dumpring databse ${PGSQL_USER}@${PGSQL_HOST}:${PGSQL_PORT}/${PGSQL_DATABASE}"

"${pg_split}" "${sql_dump_file}" -d "${mysql_backup_dir}" -c || \
    panic "Error splitting databse dump "
rm -f "${sql_dump_file}"

case "${PGSQL_BACKUP_TYPE}" in
git)
    (
        cd ${mysql_backup_dir}  \
            && git add -A > /dev/null  \
            && { git commit -a -q -m "[Periodic backup]" > /dev/null || if [[ $? -gt 1 ]]; then false; fi } \
            && {
                git push -q 2> /dev/null \
                || git push -q
            }
    ) || panic "Can't commit and push changes to ${PGSQL_BACKUP_TARGET}"
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
    ) || panic "Can't commit and push changes to ${PGSQL_BACKUP_TARGET}"
    ;;
esac
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

POSTGRES_DB="${POSTGRES_DB}"
POSTGRES_USER="${POSTGRES_USER}"
POSTGRES_PASSWORD="${POSTGRES_DB}"
POSTGRES_HOST="${POSTGRES_HOST}"
POSTGRES_PORT="${POSTGRES_PORT}"

BACKUP_TYPE="${BACKUP_TYPE}"
BACKUP_TARGET="${BACKUP_TARGET}"

if [[ -z "${BACKUP_TARGET/}" ]]; then
    panic "BACKUP_TARGET have to be defined"
fi

case "${BACKUP_TYPE}" in
git)
    mysql_backup_dir="$( mktemp -d /tmp/pgsql.XXX )"
    trap "rm -Rf ${mysql_backup_dir}" 0 1

    git clone "${BACKUP_TARGET}" "${mysql_backup_dir}" -q || \
        panic "Can't clone initial git dir ${BACKUP_TARGET}"
    ;;
hg|mercurial)
    mysql_backup_dir="$( mktemp -d /tmp/mysql.XXX )"
    trap "rm -Rf ${mysql_backup_dir}" 0 1

    hg clone "${BACKUP_TARGET}" "${mysql_backup_dir}" -q || \
        panic "Can't clone initial hg dir ${BACKUP_TARGET}"
    ;;
"")
    mysql_backup_dir="${BACKUP_TARGET}"
    ;;
*)
    print_error "$SCRIPT_NAME invalid BACKUP_TARGET have to be in [git|mercurial|\"\"]"
    exit 1
esac


pgsql_env=
pgdump_suffix=
if [[ ! -z "${POSTGRES_PASSWORD}" ]] ; then
    pgsql_env="${pgsql_env} PGPASSWORD=\"${POSTGRES_PASSWORD}\""
fi

if [[ ! -z "${POSTGRES_USER}" ]] ; then
    pgdump_suffix="${pgdump_suffix} -U ${POSTGRES_USER}"
fi

if [[ ! -z "${POSTGRES_HOST}" ]] ; then
    pgdump_suffix="${pgdump_suffix} -h ${POSTGRES_HOST}"
fi

if [[ ! -z "${POSTGRES_PORT}" ]] ; then
    pgdump_suffix="${pgdump_suffix} -p ${POSTGRES_PORT}"
fi

pg_split="${BASE_PATH}/pgdump_splitsort.py"

sql_dump_file="$( mktemp /tmp/dump.XXXX )"
eval ${pgsql_env} pg_dump ${pgdump_suffix} ${POSTGRES_DB} > "${sql_dump_file}" || \
    panic "Error dumpring databse ${POSTGRES_USER}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}"

"${pg_split}" "${sql_dump_file}" -d "${mysql_backup_dir}" -c || \
    panic "Error splitting databse dump "
rm -f "${sql_dump_file}"

case "${BACKUP_TYPE}" in
git)
    (
        cd ${mysql_backup_dir}  \
            && git add -A > /dev/null  \
            && { git commit -a -q -m "[Periodic backup]" > /dev/null || if [[ $? -gt 1 ]]; then false; fi } \
            && {
                git push -q 2> /dev/null \
                || git push -q
            }
    ) || panic "Can't commit and push changes to ${BACKUP_TARGET}"
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
    ) || panic "Can't commit and push changes to ${BACKUP_TARGET}"
    ;;
esac
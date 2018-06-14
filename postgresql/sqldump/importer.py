import argparse
import json
import os
import sys
import re

__author__ = 'andriy'

__verbose = False


def verbose(*objs):
    if __verbose:
        sys.stderr.write(" ".join([str(i) for i in objs]) + '\n')
        sys.stderr.flush()


def create_argsparser():
    parser = argparse.ArgumentParser(description='Split database dump file to a chunks.')
    parser.add_argument('-m', dest='chunk_size_kb',
                        default=2 * 1024,
                        type=int,
                        help='Max chunk size of database part, in kb default 2014(2Mb)')
    parser.add_argument('-d', dest='destination_path', help='Path, where to store splitted files')
    parser.add_argument('-v', action="store_true",
                        help='Verbose dumping output')
    parser.add_argument('-c', action="store_true", help='Clean destination')
    parser.add_argument('sql_dump_file')
    args = parser.parse_args()
    args.chunk_size = args.chunk_size_kb * 1024

    global __verbose
    __verbose = args.v

    return args


_NUM_REP = {10: 'a',
            11: 'b',
            12: 'c',
            13: 'd',
            14: 'e',
            15: 'f',
            16: 'g',
            17: 'h',
            18: 'i',
            19: 'j',
            20: 'k',
            21: 'l',
            22: 'm',
            23: 'n',
            24: 'o',
            25: 'p',
            26: 'q',
            27: 'r',
            28: 's',
            29: 't',
            30: 'u',
            31: 'v',
            32: 'w',
            33: 'x',
            34: 'y',
            35: 'z'}


def str_in_base(num, n=36, min_with=0):
    """
    Change a  to a base-n number.
    Up to base-36 is supported without special notation.
    """

    if n < 1 or n > 36:
        raise ValueError("Support positional systems from 1 to 36")
    new_num_string = ''
    current = num
    while current != 0:
        remainder = current % n
        if 36 > remainder > 9:
            remainder_string = _NUM_REP[remainder]
        else:
            remainder_string = str(remainder)
        new_num_string = remainder_string + new_num_string
        current /= n
    while len(new_num_string) < min_with:
        new_num_string = '0' + new_num_string
    return ("-" if num < 0 else "") + new_num_string
# def str_in_base


def get_order_number(settings, table_name, previous_table):
    """

    :type settings: object
    :param settings: dictionary of settings { table_name: order }
    :type table_name: sting
    :param table_name:
    :type previous_table: string
    :param previous_table:
    :rtype string
    :return :table order encoded into 36positional system
    """

    def get_prev_table_order():
        for _key in settings:
            if previous_table == _key:
                return settings[_key]

    for key in settings:
        if table_name == key:
            return str_in_base(settings[key], min_with=4)

    if not previous_table:
        settings[table_name] = 36 * 8
        return str_in_base(settings[table_name], min_with=4)

    p_order = get_prev_table_order()
    if not p_order:
        raise ValueError("previous_table % has no order defined" % (previous_table,))

    next_tables = [settings[val] for val in settings if settings[val] > p_order]
    if not next_tables:
        order = p_order + 36 * 8
    else:
        next_order = min(next_tables)
        order = (p_order + next_order) // 2

    settings[table_name] = order

    return str_in_base(order, min_with=4)
# get_order_number


SQL_FILE_PART_RE = re.compile(r'^[0-9a-zA-Z]{4}_.*[sS][qQ][lL]$')


def split_sql_file(args, __do_split):
    verbose("Opening sql dump file:", args.sql_dump_file)
    with file(args.sql_dump_file) as sql_dump_file:
        if args.destination_path:
            verbose("Changing dir to:", args.destination_path)
            os.chdir(args.destination_path)
        # if -d path

        if args.c:
            verbose("Removing previous sql chunks...")
            for f in os.listdir("."):
                if SQL_FILE_PART_RE.match(f):
                    verbose("Removing file", f)
                    os.remove(f)
                    # for f
        # if -c

        if os.path.exists(".order"):
            with open('.order', 'r') as infile:
                order = json.load(infile)
                verbose("Read .order file", order)
        else:
            verbose("Can't find .order file, starting from scratch")
            order = {}
            # if .order exist

        __do_split(args, sql_dump_file, order)

        verbose("Writing updated .order file")
        with open('.order', 'w') as outfile:
            json.dump(order, fp=outfile, sort_keys=True, indent=4, separators=(',', ': '))
    # with sql_dump_file

# def split_sql_file
#!/usr/bin/env python3

import argparse
import logging
import sys

from mssql import Mssql


def parse_args(args):
    """
    Parse command line arguments.
    :param args:
    :return:
    """

    parser = argparse.ArgumentParser(prog="mssql_users", description="Manage MSSQL Users")
    parser.add_argument("--debug", action="store_true", default=False, help="Enable debug output.")
    parser.add_argument("-s", "--server", help="Sql Instance FQDN")
    parser.add_argument("-d", "--database", help="Database to connect to")
    parser.add_argument("--admin-user", help="Sql Instance Admin User")
    parser.add_argument("--admin-password", help="Sql Instance Admin password")
    parser.add_argument("-u", "--user", help="User to create on SQL Instance")
    parser.add_argument("-p", "--password", help="User password to create on SQL Instance")
    parser.add_argument("-r", "--roles", help="Roles list for the new user. Comma separated values")
    parser.add_argument("--delete", action="store_true", default=False, help="Delete the user and the login")

    return parser.parse_args(args)


if __name__ == "__main__":

    args = parse_args(sys.argv[1:])
    if args.debug:
        logging.basicConfig(level=logging.DEBUG)
    else:
        logging.basicConfig(level=logging.ERROR)

    sql_server = Mssql(server_fqdn=args.server,
                       admin_user=args.admin_user,
                       admin_password=args.admin_password,
                       database=args.database)

    if args.delete:
        logging.debug("Dropping login and user %s", args.user)
        sql_server.drop_user(args.user)
        sql_server.drop_login(args.user)
    else:
        sql_server.create_or_update_login(username=args.user,
                                          password=args.password)
        sql_server.create_or_update_user(username=args.user,
                                         roles=args.roles.split(',')
                                         )


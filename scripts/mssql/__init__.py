import pymssql
import logging
from typing import List, Dict, Tuple


class Mssql:
    def __init__(self, server_fqdn, admin_user, admin_password, database):
        self.admin_user = admin_user
        self.admin_password = admin_password
        self.database = database
        self.server_fdqn = server_fqdn
        self.master_conn = self.connect_to_sql_instance(server_fqdn, admin_user, admin_password, "master")
        self.db_conn = self.connect_to_sql_instance(server_fqdn, admin_user, admin_password, database)

    @staticmethod
    def connect_to_sql_instance(server_fqdn: str, admin_user: str, admin_password: str, database: str = "master") -> pymssql.Connection:
        """
        Connect to an SQL Server Instance
        :param server_fqdn: FQDN of the SQL Server Instance
        :param admin_user: Administrator username
        :param admin_password: Administrator Password
        :param database: Database to connect to
        :return: Connection object
        """

        server = server_fqdn.split('.')[0]
        admin_user = f'{admin_user}@{server}'

        return pymssql.connect(server=server_fqdn, user=admin_user, password=admin_password, database=database)

    def is_user_exists(self, username: str) -> bool:
        """
        Check if the user exists or not
        :param username: User to search
        :param database: Database on which the user should exists
        :param sql_connection: SQL Connection Object
        :return: Bool
        """

        # User is on database, force new connection

        cursor = self.db_conn.cursor()
        cursor.execute(f'SELECT name FROM sys.database_principals WHERE name = \'{username}\'')
        rows = cursor.fetchone()
        if rows is None:
            logging.debug("User %s not found", username)
            return False
        else:
            logging.debug("Found user %s", username)
            return True

    def is_login_exists(self, username: str) -> bool:
        """
        Check if the login exists on the Instance
        :param username: Username to Check
        :param sql_connection: SQL Connection Object
        :return: Bool
        """

        cursor = self.master_conn.cursor()
        cursor.execute(f'SELECT name FROM master.sys.sql_logins WHERE name = \'{username}\'')
        row = cursor.fetchone()
        if row is None:
            logging.debug("Login %s not found", username)
            return False
        else:
            logging.debug("Found Login %s", username)
            return True

    def create_or_update_login(self, username: str, password: str) -> None:
        """
        Create or Update user login
        :param username: username to create or update
        :param password: password to set to the user
        :return: None
        """

        if self.is_login_exists(username):
            self.update_login(username, password)
        else:
            self.create_login(username, password)

    def create_login(self, username: str, userpassword: str) -> None:
        """
        Create a login on a SQL Instance
        :param username: Name of the login to create. We assume login = user
        :param userpassword: Password to set to the login
        :return: None
        """

        sql_query = f'CREATE LOGIN "{username}" WITH PASSWORD = \'{userpassword}\';'
        cursor = self.master_conn.cursor()
        try:
            cursor.execute(sql_query)
            self.master_conn.commit()
        except pymssql.StandardError as err:
            logging.error("Fail to create login %s. %s", username, err)
            raise

    def update_login(self, username: str, userpassword: str):
        """
        Update an existing login on a SQL Instance
        :param username: Login to update. We assume login = username
        :param userpassword: Login password to set
        :return: None
        """

        sql_query = f'ALTER LOGIN "{username}" WITH PASSWORD = \'{userpassword}\';'
        cursor = self.master_conn.cursor()
        try:
            cursor.execute(sql_query)
            self.master_conn.commit()
        except pymssql.StandardError as err:
            logging.error("Fail to update user %s. %s", username, err)
            raise

    def create_or_update_user(self, username: str, roles: List[str]) -> None:
        """
        Create Or Update user on an SQLInstance
        :param username: Username of the user
        :param roles: List of roles to set
        :return: None
        """

        if self.is_user_exists(username):
            self.update_user(username, roles)
        else:
            self.create_user(username, roles)

    def create_user(self, username: str, roles: List[str], default_schema: str ="dbo") -> None:
        """
        Create a user on an SQL Database
        :param username: Name of the user to create
        :param roles: Roles to assign to user on the database
        :param default_schema: Default schema for the user
        :return: None
        """
        sql_query = f'CREATE USER "{username}" FOR LOGIN "{username}" WITH DEFAULT_SCHEMA = {default_schema}'
        logging.debug(sql_query)
        cursor = self.db_conn.cursor()
        try:
            cursor.execute(sql_query)

            # Apply Roles
            for role in roles:
                cursor.execute(f"EXEC sp_addrolemember '{role}', '{username}'")
            self.db_conn.commit()
        except pymssql.StandardError as err:
            logging.error("Fail to create user %s. %s", username, err)
            raise

    def update_user(self, username: str, roles: List[str], default_schema: str = "dbo") -> None:
        """

        :param username: Name of the user to update
        :param roles: List of roles to assign to the user on the database
        :param default_schema: Default schema for the user
        :return: None
        """
        sql_query = f'ALTER USER {username} WITH DEFAULT_SCHEMA = {default_schema}'
        cursor = self.db_conn.cursor()
        users_roles = self.get_user_roles(username)
        try:
            cursor.execute(sql_query)
            for role in roles:
                if role not in users_roles.keys():
                    cursor.execute(f"EXEC sp_addrolemember '{role}', '{username}'")
            for role in users_roles.keys():
                if role not in roles:
                    cursor.execute(f"EXEC sp_droprolemember '{role}', '{username}'")
            self.db_conn.commit()
        except pymssql.StandardError as err:
            logging.error(err)
            raise

    def get_user_roles(self, username: str) -> Dict[str, str]:
        """
        Get Roles associated with members
        :param username: Name of the user of which to get roles
        :return: Dict with role = username
        """

        query = f"""
SELECT p.NAME,m.NAME
FROM sys.database_role_members rm
JOIN sys.database_principals p
    ON rm.role_principal_id = p.principal_id
JOIN sys.database_principals m
    ON rm.member_principal_id = m.principal_id
WHERE m.NAME = '{username}'
        """

        cursor = self.db_conn.cursor()
        cursor.execute(query)
        rows = cursor.fetchall()

        dict_tup = {}
        for row in rows:
            dict_tup[row[0]] = row[1]

        return dict_tup

    def drop_user(self, username: str) -> None:
        """
        Drop a User
        :param username: Name of the user to drop
        :return: None
        """
        query = f'DROP USER "{username}"'
        cursor = self.db_conn.cursor()
        try:
            cursor.execute(query)
            self.db_conn.commit()
        except pymssql.StandardError as err:
            logging.error("Fail to drop user %s. %s", username, err)
            raise

    def drop_login(self, loginname: str) -> None:
        """
        Drop a login
        :param loginname: Name of the login to drop
        :return: None
        """
        query = f'DROP LOGIN "{loginname}"'
        cursor = self.master_conn.cursor()
        try:
            cursor.execute(query)
            self.master_conn.commit()
        except pymssql.StandardError as err:
            logging.warning("Fail to drop login %s, it may be used in another database. %s", loginname, err)

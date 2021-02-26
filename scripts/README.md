# mssql_users.py

## Dependancies

  * [pymssql](https://pymssql.readthedocs.io/en/stable/) >= 2.1.3
  * [freetds](https://www.freetds.org/userguide/) >= 0.9.1
    * freetds is embeeded on Linux/Windows pymssql package. But on OSX you need to install it via `brew install freetds` 

## Usage

### Create or update a user
```shell script
pip install pymssql
python3 mssql_users.py -s <server_fqdn> \
                       -d <Database_Name> \
                       --admin-user <adminUserName> \
                       --admin-password <adminPassword> \
                       -u <userToCreate> \
                       -p <userPassword> \
                       -r <role1,role2,role3>
```

### Delete a user
```shell script
python3 mssql_users.py -s <server_fqdn> \
                       -d <Database_Name> \
                       --admin-user <adminUserName> \
                       --admin-password <adminPassword> \
                       -u <userToDelete> \
                       --delete
```
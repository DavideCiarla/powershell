pip install databricks-cli

databricks -h

databricks configure --token

https://westeurope.azuredatabricks.net/
<token generato da databricks>

# databricks secrets create-scope --scope < scope name >

databricks secrets create-scope --scope < scope name > --initial-manage-principal users

databricks secrets put --scope < scope name > --key < key name >   # chiave dello storage account da prendere dal portale azure ì

#databricks secrets list-scopes

#databricks secrets list --scope < scope name >

#####################################

#da databricks 

storage_account_key = dbutils.secrets.get("< scope name >", "< key name >")

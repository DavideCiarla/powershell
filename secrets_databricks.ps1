pip install databricks-cli

databricks -h

databricks configure --token

https://westeurope.azuredatabricks.net/
<token generato da databricks>

databricks secrets create-scope --scope adlg2

databricks secrets create-scope --scope sc_adlg2 --initial-manage-principal users

databricks secrets put --scope sc_adlg2 --key adlg2_key   # chiave dello storage account da prendere dal portale azure ì

#databricks secrets list-scopes

#databricks secrets list --scope adlg2

#####################################

#da databricks 

storage_account_key = dbutils.secrets.get("sc_adlg2", "adlg2_key")

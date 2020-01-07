#azure connection

Import-Module AzureRM

#Connect-AzureRmAccount -Subscription "Microsoft Learn Sandbox" #doesn t work. later gives error

az login

$NAME = "cosmosdvd"

#cosmos creation
az cosmosdb create --name $NAME --kind GlobalDocumentDB --resource-group learn-fb0b5fe7-5505-439b-a818-7b924ce17c39

#db creation
az cosmosdb database create --name $NAME --db-name "Products" --resource-group learn-fb0b5fe7-5505-439b-a818-7b924ce17c39

#collection creation
az cosmosdb collection create --name $NAME --db-name "Products" --collection-name "Clothing" --partition-key-path "/productId" --throughput 1000 --resource-group learn-fb0b5fe7-5505-439b-a818-7b924ce17c39

#insert data (json) by UI : go in the collection and click "add item"

#by interface execute sql like queries :
    #SELECT p.price, p.description, p.productId 
    #FROM Products p 
    #ORDER BY p.price ASC

    #the only required sentence is SELECT, the others are not compulsory
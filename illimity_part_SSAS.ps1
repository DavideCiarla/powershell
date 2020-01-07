######################################################################################################################
###### correggere, pescarli da interfaccia
$db_name = "TEST_Partitioning"
$tbl_name = "ft_saldi_mlo"

$path_year = (get-date).ToString(“yyyy”) #$path_year.GetType() -- string
$path_month = (get-date).ToString(“MM”) #$path_month.GetType() -- string
$pr_name = $tbl_name + "_" + $path_year + $path_month   #"ft_saldi_mlo_201911" ------ ft_saldi_mlo201912  $pr_name.GetType() ---- string



function cr_query ([string]$db_name, [string]$tbl_name, [string]$pr_name) {

    '{
      "createOrReplace": {
        "object": {
          "database": "'+$db_name+'",
          "table": "'+$tbl_name+'",
          "partition": "'+$pr_name+'"      
        },
        "partition": {
          "name": "'+$pr_name+'",
          "source": {
            "type": "m",
            "expression": [
              "let",
              "    Source = ft_saldi_mlo,",
              "   #\"Partition Filter Year\"   =   Table.SelectRows(Source, each [year]= '+$path_year+'), ",
              "   #\"Partition Filter Month\" =  Table.SelectRows(#\"Partition Filter Year\" , each [month]= '+$path_month+')",
              "in",
              "    #\"Partition Filter Month\""
            ]
          }
        }
      }
    }'

}


cr_query $db_name $tbl_name $pr_name
######################################################################################################################
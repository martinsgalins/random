#! /bin/bash
API_endpoint="https://prod-117.westeurope.logic.azure.com:443/workflows/acd9d691ad604822a16072e888a666a2/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=dA_cTlGakf4pR-ax1nAXJ5veTszkUmTCgabSUcRgZXY"
sql_query_path="/home/mgal/AvailabilityReportAGS/availability_report.sql"
csv_path="/home/mgal/AvailabilityReportAGS/sys_list.csv"
csv_path_temp="/home/mgal/AvailabilityReportAGS/temp_sys_list.csv"
json_path="/home/mgal/AvailabilityReportAGS/sys_list.json"

mysql -uroot -p******** < "$sql_query_path" | tr "\\t" ";" > "$csv_path"
tail -n +2 "$csv_path" > "$csv_path_temp"

jq -Rsn '
  {"AGS":
    [inputs
     | . / "\n"
     | (.[] | select(length > 0) | . / ";") as $input
     | {"System Name": $input[1], "Availability":  $input[2]}]}
' < "$csv_path_temp" > "$json_path"

curl -X POST -H "Content-Type: application/json" --data-binary @"$json_path" "$API_endpoint"

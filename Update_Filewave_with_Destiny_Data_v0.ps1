
#Set the stage...
$fw_api_base = "https://filewave_server_URL_or_IPADDR/api"
$fw_api_inv_client_node = "/inv/api/v1/client"
$fw_api_inv_query_node = "/inv/api/v1/query"
$fw_api_inv_query_result_node = "/inv/api/v1/query_result"
$b64_token = "NotTheTokenYou'reLookingFor" #from FWAdmin-Assistants-Manage Admins
$header = @{"Authorization"="Bearer "+$b64_token} # build access token header
$date = Get-Date -Format "o"

# Hire a cue-card writer who knows about serial numbers and device IDs in Filewave 
# and a telepromter who can translate those cue cards into PowerShell

#Get serial_number & device_id map from FW Inventory Query
# PCSC Filewave Query named device_id-macOS/iOS with ID 155
$query_id = 155
$serial_to_deviceid_map_call = Invoke-RestMethod -Method GET -Headers $header `
 -Uri ($fw_api_base + $fw_api_inv_query_result_node + "/" + $query_id)

#Query results are a funny thing... so carve them up and make them make sense for reference
$pairs =  $serial_to_deviceid_map_call | Select-Object -ExpandProperty values
$pairs = $pairs -split " "
# This cue card writer seems very inefficient, but he does what he's supposed to do...

#$fw_serial_devid_hash.clear()
$fw_serial_devid_hash = @{}
for ( $i = 0; $i -lt $pairs.Length; $i += 2 ) {
  #Write-Host ("SN:" + $pairs[$i] + "->DEVID:" + $pairs[$i+1]);
  $hash_sn = $pairs[$i]
  $hash_devid = $pairs[$i+1] 
  $fw_serial_devid_hash += @{$hash_sn = $hash_devid}
}
# This teleprompter is probably inefficent too...


# Get a screenwriter familar with SQL and the storylines of K12 Media Centers, Destiny Resource Mgr and 1-to-1 device checkouts...
# If you can't find one, scour the interwebz and plagiarize whatever you can

#Get Destiny Data
$destiny_dump_filename = "/PATH_TO_FILE/destiny_device_info.csv"
$destiny_data = @(Import-Csv $destiny_dump_filename | Where-Object {$_.checked_out_psnum -ne "NULL"} )

# Find a Director to interpret the screenwriter's story about day-to-day inventory flow...
foreach ($asset in $destiny_data){

  #Cuecard and teleprompter... GO!
  #Get devid from hashtable with current destiny data asset's serial number...
  $asset_devid = $fw_serial_devid_hash.item($asset.serial_number)
  #Write-Host $asset.serial_number "->" $asset_devid
  $asset_URI = ($fw_api_base + $fw_api_inv_client_node + "/" + $asset_devid)
  
  # Check the screenwriter's work for $null and empty values while simutaneously translating for one guy in the audience named JaSON...
    if ($asset.checked_out_email -eq "" -or $asset.checked_out_email -eq $null){
    $email_body = '{"checked_out_psnum":{"exitCode":null,"status":0,"updateTime":"' + $date + '","value":"NoVal"}}'
  }
  Else{
    $email_body = '{"checked_out_psnum":{"exitCode":null,"status":0,"updateTime":"' + $date + '","value":' + $asset.checked_out_email + '}}'
  }
  
  if ($asset.checked_out_gradelevel -eq "" -or $asset.checked_out_gradelevel -eq $null){
    $grade_body = '{"checked_out_psnum":{"exitCode":null,"status":0,"updateTime":"' + $date + '","value":"NoVal"}}'
  }
  Else{
    $grade_body = '{"checked_out_psnum":{"exitCode":null,"status":0,"updateTime":"' + $date + '","value":' + $asset.checked_out_gradelevel + '}}'
  }

  if ($asset.checked_out_name -eq "" -or $asset.checked_out_name -eq $null){
    $name_body = '{"checked_out_psnum":{"exitCode":null,"status":0,"updateTime":"' + $date + '","value":"NoVal"}}'
  }
  Else{
    $name_body = '{"checked_out_psnum":{"exitCode":null,"status":0,"updateTime":"' + $date + '","value":' + $asset.checked_out_name + '}}'
  }

  if ($asset.checked_out_psnum -eq "" -or $asset.checked_out_psnum -eq $null){
    $psnum_body = '{"checked_out_psnum":{"exitCode":null,"status":0,"updateTime":"' + $date + '","value":"NoVal"}}'
  }
  Else{
    $psnum_body = '{"checked_out_psnum":{"exitCode":null,"status":0,"updateTime":"' + $date + '","value":' + $asset.checked_out_psnum + '}}'
  }

  if ($asset.checked_out_school -eq "" -or $asset.checked_out_school -eq $null){
    $school_body = '{"checked_out_psnum":{"exitCode":null,"status":0,"updateTime":"' + $date + '","value":"NoVal"}}'
  }
  Else{
    $school_body = '{"checked_out_psnum":{"exitCode":null,"status":0,"updateTime":"' + $date + '","value":' + $asset.checked_out_school + '}}'
  }

  if ($asset.checked_out_status -eq "" -or $asset.checked_out_status -eq $null){
    $status_body = '{"checked_out_psnum":{"exitCode":null,"status":0,"updateTime":"' + $date + '","value":"NoVal"}}'
  }
  Else{
    $status_body = '{"checked_out_psnum":{"exitCode":null,"status":0,"updateTime":"' + $date + '","value":' + $asset.checked_out_status + '}}'
  }

  # Wrap up all the bodies and bury them... 
  # just like Arsenic and Old Lace...
  $multi_body = $email_body + $grade_body + $name_body + $psnum_body + $school_body + $status_body
  $data = '{"CustomFields":' + $multi_body + '}'
  
  #Write-Host $multi_body + "`n"
  Invoke-RestMethod -Method PATCH -Headers $header -Body  $multi_body -ContentType application/json -Uri $asset_URI

  # Or if you prefer the Jeffrey Dahmer approach, wrap 'em up, put 'em on ice, and take one out when you need it...
  #$body_template = '{"CustomFields":{"CUSTOM_FIELD_NAME":{"exitCode":null,"status":0,"updateTime":"' + $date + '","value":"NoVal"}}}'
  #Invoke-RestMethod -Method PATCH -Headers $header -Body  $email_body -ContentType application/json -Uri $asset_URI
  #Invoke-RestMethod -Method PATCH -Headers $header -Body  $grade_body -ContentType application/json -Uri $asset_URI
  #Invoke-RestMethod -Method PATCH -Headers $header -Body  $psnum_body -ContentType application/json -Uri $asset_URI
  #Invoke-RestMethod -Method PATCH -Headers $header -Body  $school_body -ContentType application/json -Uri $asset_URI
  #Invoke-RestMethod -Method PATCH -Headers $header -Body  $status_body -ContentType application/json -Uri $asset_URI

  # et Fin...
}


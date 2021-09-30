
#Set the stage...
$fw_api_base = "https://filewave_server_url_or_IPADDR/api"
$fw_api_inv_client_node = "/inv/api/v1/client"
$fw_api_inv_query_node = "/inv/api/v1/query"
$fw_api_inv_query_result_node = "/inv/api/v1/query_result"
$b64_token = "NotTheTokenYou'reLookingFor=" #from FWAdmin-Assistants-Manage Admins
$header = @{"Authorization"="Bearer "+$b64_token} # build access token header
$date = Get-Date -Format "o"

# Depending on your version of PowerShell, you might need this...
#[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

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

# Get a screenwriter familar with SQL and the storylines of K12 Media Centers, 
# Destiny Resource Mgr and 1-to-1 device checkouts...
# If you can't find one, scour the interwebz and plagiarize whatever you can

#Get Destiny Data
#---On Destiny Server if you run it there...---
#$destiny_dump_filename = "C:\SCRIPTS\Filewave\destiny_device_info.csv"
#---On your local workstations if you run it there...---
$destiny_dump_filename = "\\PATH_TO_FILE\destiny_device_info.csv"

$destiny_data = @(Import-Csv $destiny_dump_filename | Where-Object {$_.checked_out_psnum -ne "NULL"} )

#foreach ($thing in $destiny_data){
#  Write-Host $fw_serial_devid_hash.item($thing.serial_number)
#}

# Find a Director to interpret the screenwriter's story about day-to-day inventory flow...
foreach ($asset in $destiny_data){
  
  if ($asset.serial_number -ne "-------------") {
  #Cuecard and teleprompter... GO!
  #Get devid from hashtable with current destiny data asset's serial number...
  $asset_devid = $fw_serial_devid_hash.item($asset.serial_number)
  #Write-Host $asset.serial_number "->" $asset_devid
  $asset_URI = ($fw_api_base + $fw_api_inv_client_node + "/" + $asset_devid)
  
  # Check the screenwriter's work for $null and empty values while simutaneously translating for one guy in the audience named JaSON...
    if ($asset.checked_out_email -eq "" -or $asset.checked_out_email -eq $null -or $asset.checked_out_email -eq "NULL"){
    $email_body = '"checked_out_email":"NoVal"'
  }
  Else{
    $email_body = '"checked_out_email":"' + $asset.checked_out_email + '"'
  }
  
  if ($asset.checked_out_gradelevel -eq "" -or $asset.checked_out_gradelevel -eq $null -or $asset.checked_out_gradelevel -eq "NULL"){
    $grade_body = '"checked_out_gradelevel":"NoVal"'
  }
  Else{
    $grade_body = '"checked_out_gradelevel":"' + $asset.checked_out_gradelevel + '"'
  }

  if ($asset.checked_out_name -eq "" -or $asset.checked_out_name -eq $null -or $asset.checked_out_name -eq "NULL"){
    $name_body = '"checked_out_name":"NoVal"'
  }
  Else{
    $name_body = '"checked_out_name":"' + $asset.checked_out_name + '"'
  }

  if ($asset.checked_out_psnum -eq "" -or $asset.checked_out_psnum -eq $null -or $asset.checked_out_psnum -eq "NULL"){
    $psnum_body = '"checked_out_psnum":"NoVal"'
  }
  Else{
    $psnum_body = '"checked_out_psnum":"' + $asset.checked_out_psnum + '"'
  }

  if ($asset.checked_out_school -eq "" -or $asset.checked_out_school -eq $null -or $asset.checked_out_school -eq "NULL"){
    $school_body = '"checked_out_school":"NoVal"'  
  }
  Else{
    $school_body = '"checked_out_school":"' + $asset.checked_out_school + '"'
  }

  if ($asset.checked_out_status -eq "" -or $asset.checked_out_status -eq $null -or $asset.checked_out_status -eq "NULL"){
    $status_body = '"checked_out_status":"NoVal"'
  }
  Else{
    $status_body = '"checked_out_status":"' + $asset.checked_out_status + '"'
  }

  # Wrap up all the bodies and bury them... 
  # just like Arsenic and Old Lace...
  # thx to Neal Davis for the formatting:
  #  {"stringfields": {"<custom_field_1_name>": "<custom_field_1_value>", "<custom_field_2_name>": "<custom_field_2_value>"}}
  $multi_body = '{"stringfields": {' + $email_body + "," + $grade_body + "," + $name_body + "," + $psnum_body + "," + $school_body + "," + $status_body + '}}'
  
  #Write-Host $multi_body "`n"
  $data = $multi_body
  Invoke-RestMethod -Method PATCH -Headers $header -Body $data -ContentType application/json -Uri $asset_URI

  # et Fin...
  } #end if for asset.serial_number -ne "-------------"
}


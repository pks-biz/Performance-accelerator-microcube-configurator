$Cred = Invoke-Expression -Command "C:\Users\prave\Desktop\AND\read_credentials.ps1"

#Sign in to Tableau Server
$server = "penguin.biztory.com"
$api_version = "3.8"
#$site_id = "300eb542-bc91-4d0f-8f75-9451648dfc48"
#$site_name = ""
$site_content_url = "PraveenSam"
$url_sign_in = "https://$server/api/$api_version/auth/signin"

 $body_sign_in  = (’<tsRequest>
  <credentials name=“’ + $Cred.GetNetworkCredential().UserName + ’” password=“’+ $Cred.GetNetworkCredential().Password + ’” >
   <site contentUrl="’ + $site_content_url +’"/>
  </credentials>
 </tsRequest>’)

$sign_in_response = Invoke-WebRequest -Method 'Post' -Uri $url_sign_in -Credential $Cred -Body $body_sign_in

$sign_in_xml = [XML] $sign_in_response.Content
$token = $sign_in_xml.tsResponse.credentials.token
$site_id = $sign_in_xml.tsResponse.credentials.site.id

$header = @{'X-Tableau-Auth' = $token}

#Find view names
$view_name = 'Order_date'
$url_views_list = "https://$server/api/$api_version/sites/$site_id/views?filter=name:eq:$view_name"
$views_list_response = Invoke-RestMethod -Method 'Get' -Headers $header -Uri $url_views_list
$view_list_xml = [XML]$views_list_response
$view_id = $view_list_xml.tsResponse.views.view.id

#Retrieve data
$url_view_data = "https://$server/api/$api_version/sites/$site_id/views/$view_id/data"
$view_data_response = Invoke-RestMethod -Method 'Get' -Headers $header -Uri $url_view_data
$test_dates = ""
$dates = $view_data_response.split("`n")
for ($i=1; $i -lt $dates.Length-1; $i++){
    $date_parts = $dates[$i].split('/')
    $test_dates = $test_dates + '"' + $date_parts[2] + "-" + $date_parts[0] + "-" + $date_parts[1] + '"' + ",`n`t`t`t`t"
}
$test_dates = $test_dates.TrimEnd()
$test_dates = $test_dates -replace ".$"


$projects = Import-Csv -Path '.\Project Name.csv'
$projects | Format-Table
$microcube_projects = ""
$projects | ForEach-Object {
    $microcube_projects = $microcube_projects + '"' + $_.'Project Name' + '"' + ",`n`t`t`t`t"
}
$microcube_projects = $microcube_projects.TrimEnd()
$microcube_projects = $microcube_projects -replace ".$"

$content = Get-Content -Path '.\microcube-configuration-template.json'
$content = $content -replace 'Project_name_from_script', $microcube_projects


$report_date = Import-Csv -Path '.\Report Date.csv'
$report_date | Format-Table
$microcube_dates = ""
$report_date | ForEach-Object {
    $date_parts = $_.'Report-Date'.split('/')
    $microcube_dates = $microcube_dates + '"' + $date_parts[2] + "-" + $date_parts[0] + "-" + $date_parts[1] + '"' + ",`n`t`t`t`t"
}
$microcube_dates = $microcube_dates.TrimEnd()
$microcube_dates = $microcube_dates -replace ".$"

$content = $content -replace 'Report_date_from_script', $microcube_dates

Set-Content -Path '.\microcube-configuration-run.json' -Value $content
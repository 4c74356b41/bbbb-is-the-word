$temp = 0
$branches = @()

c:\jenkins\git\bin\git.exe branch -a | % { if ($_ -match '\borigin\b' -and $_ -match '\d+'
) { $branches += $matches[0]} }
$branches | % { $temp = [math]::Max($_,$temp)}
$feature = 'feature' + $temp

while ($rgName -notmatch '^[a-z]') {
    $rgName = -join ((97..122) + (48..57) | Get-Random -Count 10 | % {[char]$_})
}
$location = @('northeurope','westeurope','eastus2') | get-random
$cred = ([pscredential]::new('py@core4c74356b41.onmicrosoft.com',(ConvertTo-SecureString -String $env:pwd -AsPlainText -Force)))
$null = Login-AzureRMAccount -Credential $cred -SubscriptionName 'MCT Subscription'
$null = New-AzureRmResourceGroup –Name $rgName –Location $location

$parameters = @{
    "Name" = "bbbb-is-the-word"
    "ResourceGroupName" = $rgName
    "TemplateUri"="https://raw.githubusercontent.com/4c74356b41/bbbb-is-the-word/$feature/_arm/parent.json"
    "TRAFFICMANAGERNAME"="$rgName-TM"
    "SKU"="S1"
    "BRANCH"="$feature"
    "ADMINISTRATORLOGIN"="dba"
    "SECRETNAME"="administratorLoginPassword"
    "DATABASENAME"="database"
    "ErrorAction"="stop"
}
try { $deploy = New-AzureRmResourceGroupDeployment @parameters }
catch { Remove-AzureRmResourceGroup -ResourceGroupName $rgName -Force; $error; $_; exit 1 }

$primaryWepAppName = $deploy.outputs.values.value[0]
$secondaryWebAppName = $deploy.outputs.values.value[1]
$functionWebAppName = $deploy.outputs.values.value[2]
$sqlServerPrimary = $deploy.Outputs.Values.value[3]

$tests = Invoke-Pester -OutputFormat NUnitXml -OutputFile tests.xml -PassThru
if ($tests.FailedCount -eq 0) { Remove-AzureRmResourceGroup -ResourceGroupName $rgName -Force }

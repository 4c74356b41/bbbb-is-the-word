# H/5 * * * *

while ($rgName -notmatch '^[a-z]') {
    $rgName = -join ((97..122) + (48..57) | Get-Random -Count 10 | % {[char]$_})
    $vaultName = $rgName + '-v'
}
$location = @('northeurope','westeurope','eastus2') | get-random

$pwd = (ConvertTo-SecureString -String $env:pwd -AsPlainText -Force)
$cred = ([pscredential]::new('py@core4c74356b41.onmicrosoft.com',$pwd))
$null = Login-AzureRMAccount -Credential $cred -SubscriptionName 'MCT Subscription'
$null = New-AzureRmResourceGroup –Name $rgName –Location $location
$null = New-AzureRmKeyVault -VaultName $vaultName -ResourceGroupName $rgName -Location $location
$null = Set-AzureRmKeyVaultAccessPolicy -EnabledForTemplateDeployment -VaultName $vaultName
$null = Set-AzureKeyVaultSecret -VaultName $vaultName -Name 'administratorLoginPassword' -SecretValue $pwd

$parameters = @{
    "Name" = "bbbb-is-the-word"
    "ResourceGroupName" = $rgName
    "TemplateUri"="https://raw.githubusercontent.com/4c74356b41/bbbb-is-the-word/master/_arm/parent.json"
    "TRAFFICMANAGERNAME"="$rgName-TM"
    "SKU"="S1"
    "ADMINISTRATORLOGIN"="dba"
    "VAULTNAME"=$vaultName
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
if ($tests.FailedCount -gt 12) { Remove-AzureRmResourceGroup -ResourceGroupName $rgName -Force }
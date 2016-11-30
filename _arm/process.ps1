#¿wha?
$resourceGroupName = 'bbbb'
$location = 'northeurope'
$vaultName = 'bau1ty'

#¡ready
New-AzureRmResourceGroup –Name $resourceGroupName –Location $location
New-AzureRmKeyVault -VaultName $vaultName -ResourceGroupName $resourceGroupName -Location $location
Set-AzureRmKeyVaultAccessPolicy -EnabledForTemplateDeployment -VaultName $vaultName

#set!
$secretvalue = ConvertTo-SecureString '!Q2w3e4r' -AsPlainText -Force
$secret = Set-AzureKeyVaultSecret -VaultName $vaultName -Name 'administratorLoginPassword' -SecretValue $secretvalue

#¡go!
$parameters = @{
    'Name' = 'bbbb-is-the-word'
    'Mode' = 'Incremental'
    'ResourceGroupName' = $resourceGroupName
    "TemplateUri"="https://raw.githubusercontent.com/4c74356b41/bbbb-is-the-word/master/ARM/parent.json"
    "SITENAME-PRIMARY"="$resourceGroupName-1s-the-word"
    "SITENAME-SECONDARY"="$resourceGroupName-1s-the-wordd"
    "SITENAME-FUNCTIONS"="$resourceGroupName-funct1ons"
    "HOSTINGPLAN-PRIMARY"="Plan-a"
    "HOSTINGPLAN-SECONDARY"="Plan-b"
    "TRAFFICMANAGERNAME"="$resourceGroupName-TM"
    "SKU"="S1"
    "ADMINISTRATORLOGIN"="dba"
    "VAULTNAME"=$vaultName
    "SECRETNAME"="administratorLoginPassword"
    "DATABASENAME"="database"
    "SERVERNAME"="$resourceGroupName-sq1-pr1"
    "SERVERREPLICANAME"="$resourceGroupName-sq1-rep1"
    "STORAGEACCOUNTSTUB"= $resourceGroupName
}
New-AzureRmResourceGroupDeployment @parameters
# >>finish<<

Param(
    [Parameter(Mandatory)]
    [string]$sourceVaultName,

    [Parameter(Mandatory=$false)]
    [string]$sourceSubscription,

    [Parameter(Mandatory)]
    [string]$destVaultName,

    [Parameter(Mandatory=$false)]
    [string]$descriptionSubscription
)

az login --tenant <source tenant>
if($sourceSubscription){
    az account set --subscription $sourceSubscription
}

Write-Host 'Reading secrets ids from' $sourceVaultName
$secretNames = az keyvault secret list --vault-name $sourceVaultName  -o json --query "[].name"  | ConvertFrom-Json

Write-Host 'Reading secrets values'
$secrets = $secretNames | % {
    $secret = az keyvault secret show --name $_ --vault-name $sourceVaultName -o json | ConvertFrom-Json
    [PSCustomObject]@{
        name  = $_;
        value = $secret.value;
    }
}

az login --tenant <destination tenant>
Write-Host 'writing secrets'

if($descriptionSubscription){
    az account set --subscription $descriptionSubscription
}

$secrets.foreach{
    az keyvault secret set --vault-name $destVaultName --name $_.name  --value  $_.value
}
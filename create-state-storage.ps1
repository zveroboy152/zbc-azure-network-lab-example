[CmdletBinding()]
param(
    [string]$SubscriptionId = '00000000-1111-2222-3333-444444444444',
    [string]$ResourceGroupName = 'rg-terraform-state',
    [string]$Location = 'westus3',
    [string]$StorageAccountName = 'tfstatesa12345', # lowercase, no dashes
    [string]$ContainerName = 'tfstate',
    [switch]$EnableSoftDelete
)

function Write-Step {
    param([string]$Message)
    Write-Host "[$(Get-Date -Format o)] $Message"
}

try {
    if (-not (Get-Module -ListAvailable -Name Az.Accounts)) {
        throw 'Az modules are required. Install-Module Az -Scope CurrentUser'
    }

    if (-not (Get-AzContext)) {
        Write-Step 'No Azure context detected. Connecting...'
        Connect-AzAccount -ErrorAction Stop | Out-Null
    }

    Set-AzContext -Subscription $SubscriptionId -ErrorAction Stop | Out-Null

    $resourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
    if (-not $resourceGroup) {
        Write-Step "Creating resource group '$ResourceGroupName' in '$Location'"
        $resourceGroup = New-AzResourceGroup -Name $ResourceGroupName -Location $Location -ErrorAction Stop
    } else {
        Write-Step "Resource group '$ResourceGroupName' already exists"
    }

    $storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -ErrorAction SilentlyContinue
    if (-not $storageAccount) {
        Write-Step "Creating storage account '$StorageAccountName'"
        $storageAccount = New-AzStorageAccount `
            -Name $StorageAccountName `
            -ResourceGroupName $ResourceGroupName `
            -Location $Location `
            -SkuName Standard_LRS `
            -Kind StorageV2 `
            -AccessTier Hot `
            -AllowBlobPublicAccess $false `
            -ErrorAction Stop
    } else {
        Write-Step "Storage account '$StorageAccountName' already exists"
    }

    $ctx = $storageAccount.Context

    $container = Get-AzStorageContainer -Name $ContainerName -Context $ctx -ErrorAction SilentlyContinue
    if (-not $container) {
        Write-Step "Creating blob container '$ContainerName'"
        $container = New-AzStorageContainer -Name $ContainerName -Context $ctx -Permission Off -ErrorAction Stop
    } else {
        Write-Step "Blob container '$ContainerName' already exists"
    }

    if ($EnableSoftDelete) {
        $serviceProps = Get-AzStorageBlobServiceProperty -Context $ctx
        if (-not $serviceProps.DeleteRetentionPolicy.Enabled) {
            Write-Step 'Enabling blob soft delete (7 days)'
            Set-AzStorageBlobServiceProperty -Context $ctx -EnableSoftDelete $true -SoftDeleteRetentionDays 7 | Out-Null
        } else {
            Write-Step 'Blob soft delete already enabled'
        }
    }

    Write-Step 'Terraform remote state storage is ready'
    [PSCustomObject]@{
        SubscriptionId     = $SubscriptionId
        ResourceGroupName  = $ResourceGroupName
        Location           = $Location
        StorageAccountName = $StorageAccountName
        ContainerName      = $ContainerName
        StateAccessKey     = (Get-AzStorageAccountKey -Name $StorageAccountName -ResourceGroupName $ResourceGroupName | Select-Object -First 1 -ExpandProperty Value)
    }
}
catch {
    Write-Error $_.Exception.Message
    throw
}

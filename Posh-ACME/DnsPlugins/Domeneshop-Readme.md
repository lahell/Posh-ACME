# How To Use the Domeneshop DNS Plugin

This plugin works against [Domeneshop](https://domene.shop/). It is assumed that you have an existing account with at least one domain.

## Setup

Domeneshop API is currently in beta. You have to [contact support](https://www.domeneshop.no/support) to get access to the [Domeneshop API](https://api.domeneshop.no/docs/).

## Using the Plugin

Your Domeneshop API credentials can either be passed to this plugin as PSCredential using the parameter `DomeneshopCredential`, or in plain text using parameters `DomeneshopToken` and `DomeneshopSecret`.

### Windows or PowerShell Core 6.2 and later

```powershell
$DomeneshopParams = @{ DomeneshopCredential = (Get-Credential) }
New-PACertificate test.example.com -DnsPlugin Domeneshop -PluginArgs $DomeneshopParams
```

### Any Operating System

```powershell
$DomeneshopParams = @{ DomeneshopToken = 'MyToken'; DomeneshopSecret = 'MySecret' }
New-PACertificate test.example.com -DnsPlugin Domeneshop -PluginArgs $DomeneshopParams
```

## Testing without Posh-ACME

You can test this plugin without loading Posh-ACME by dot sourcing the plugin and calling the functions directly. Note that to avoid errors you will first have to set the variable `$script:UseBasic`.

```
. .\Domeneshop.ps1
$script:UseBasic = @{ UseBasicParsing = $true }

$DomeneshopParams = @{
    RecordName = '_acme-challenge.example.com'
    TxtValue = 'data'
    DomeneshopCredential = (Get-Credential)
}

Add-DnsTxtDomeneshop @DomeneshopParams
Remove-DnsTxtDomeneshop @DomeneshopParams
```

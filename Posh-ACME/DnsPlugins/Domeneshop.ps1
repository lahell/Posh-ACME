function Add-DnsTxtDomeneshop {
    [CmdletBinding(DefaultParameterSetName='Secure')]
    param(
        [Parameter(Mandatory,Position=0)]
        [string]$RecordName,
        [Parameter(Mandatory,Position=1)]
        [string]$TxtValue,
        [Parameter(ParameterSetName='Secure',Mandatory)]
        [pscredential]$DomeneshopCredential,
        [Parameter(ParameterSetName='Insecure',Mandatory)]
        [string]$DomeneshopToken,
        [Parameter(ParameterSetName='Insecure',Mandatory)]
        [string]$DomeneshopSecret,
        [Parameter(ValueFromRemainingArguments)]
        $ExtraParams
    )

    Initialize-DomeneshopAuth @PSBoundParameters

    $domain = Get-DomeneshopDomain $RecordName
    $domainId = $domain.id

    $hostName = ($RecordName -replace $domain.domain).Trim('.')
    $request = New-DomeneshopRequest

    $jsonBody = @{
        type = 'TXT'
        host = $hostName
        ttl  = 300
        data = $TxtValue
    } | ConvertTo-Json -Compress

    $record = Get-DomeneshopRecord $RecordName $TxtValue

    if (-not $record) {
        $request.Uri   += "/domains/$domainId/dns"
        $request.Body   = $jsonBody
        $request.Method = 'Post' 

        Invoke-RestMethod @request @script:UseBasic | Out-Null
    }

    <#
    .SYNOPSIS
        Add a DNS TXT record to Domeneshop

    .DESCRIPTION
        Add a DNS TXT record to Domeneshop

        Domeneshop API is currently in beta and likely to change.
        Documentation (in Norwegian): https://api.domeneshop.no/docs/

    .PARAMETER RecordName
        The fully qualified name of the TXT record.

    .PARAMETER TxtValue
        The value of the TXT record.

    .PARAMETER DomeneshopCredential
        Domeneshop API Credential (Token and Secret) used as username and password in Basic HTTP Authentication.

    .PARAMETER DomeneshopToken
        Domeneshop API Token used as username in Basic HTTP Authentication.

    .PARAMETER DomeneshopSecret
        Domeneshop API Secret used as password in Basic HTTP Authentication.

    .PARAMETER ExtraParams
        This parameter can be ignored and is only used to prevent errors when splatting with more parameters than this function supports.

    .EXAMPLE
        $DomeneshopParams = @{ DomeneshopCredential = (Get-Credential) }
        Add-DnsTxtDomeneshop '_acme-challenge.site1.example.com' 'asdfqwer12345678' @DomeneshopParams

        Adds a TXT record for the specified site with the specified value.

    .EXAMPLE
        $DomeneshopParams = @{ DomeneshopToken = 'MyToken'; DomeneshopSecretInsecure = 'MySecret' }
        Add-DnsTxtDomeneshop '_acme-challenge.site1.example.com' 'asdfqwer12345678' @DomeneshopParams

        Adds a TXT record for the specified site with the specified value.

    .NOTES
        If testing this function without Posh-ACME, you have to first set the following variable:
        $script:UseBasic = @{ UseBasicParsing = $true }

        If you do not set this variable you will get this error message:
        Invoke-RestMethod : A positional parameter cannot be found that accepts argument '$null'.
    #>
}

function Remove-DnsTxtDomeneshop {
    [CmdletBinding(DefaultParameterSetName='Secure')]
    param(
        [Parameter(Mandatory,Position=0)]
        [string]$RecordName,
        [Parameter(Mandatory,Position=1)]
        [string]$TxtValue,
        [Parameter(ParameterSetName='Secure',Mandatory)]
        [pscredential]$DomeneshopCredential,
        [Parameter(ParameterSetName='Insecure',Mandatory)]
        [string]$DomeneshopToken,
        [Parameter(ParameterSetName='Insecure',Mandatory)]
        [string]$DomeneshopSecret,
        [Parameter(ValueFromRemainingArguments)]
        $ExtraParams
    )

    Initialize-DomeneshopAuth @PSBoundParameters

    $domain = Get-DomeneshopDomain $RecordName
    $domainId = $domain.id

    $record = Get-DomeneshopRecord $RecordName $TxtValue
    $recordId = $record.id

    $request = New-DomeneshopRequest

    if ($domainId -and $recordId) {
        $request.Uri   += "/domains/$domainId/dns/$recordId"
        $request.Method = 'Delete' 

        Invoke-RestMethod @request @script:UseBasic | Out-Null
    }

    <#
    .SYNOPSIS
        Remove a DNS TXT record from Domeneshop

    .DESCRIPTION
        Remove a DNS TXT record from Domeneshop

        Domeneshop API is currently in beta and likely to change.
        Documentation (in Norwegian): https://api.domeneshop.no/docs/

    .PARAMETER RecordName
        The fully qualified name of the TXT record.

    .PARAMETER TxtValue
        The value of the TXT record.

    .PARAMETER DomeneshopCredential
        Domeneshop API Credential (Token and Secret) used as username and password in Basic HTTP Authentication.

    .PARAMETER DomeneshopToken
        Domeneshop API Token used as username in Basic HTTP Authentication.

    .PARAMETER DomeneshopSecret
        Domeneshop API Secret used as password in Basic HTTP Authentication.

    .PARAMETER ExtraParams
        This parameter can be ignored and is only used to prevent errors when splatting with more parameters than this function supports.

    .EXAMPLE
        $DomeneshopParams = @{ DomeneshopCredential = (Get-Credential) }
        Remove-DnsTxtDomeneshop '_acme-challenge.site1.example.com' 'asdfqwer12345678' @DomeneshopParams

        Removes a TXT record for the specified site with the specified value.

    .EXAMPLE
        $DomeneshopParams = @{ DomeneshopToken = 'MyToken'; DomeneshopSecret = 'MySecret' }
        Remove-DnsTxtDomeneshop '_acme-challenge.site1.example.com' 'asdfqwer12345678' @DomeneshopParams

        Removes a TXT record for the specified site with the specified value.

    .NOTES
        If testing this function without Posh-ACME, you have to first set the following variable:
        $script:UseBasic = @{ UseBasicParsing = $true }

        If you do not set this variable you will get this error message:
        Invoke-RestMethod : A positional parameter cannot be found that accepts argument '$null'.
    #>
}

function Save-DnsTxtDomeneshop {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments)]
        $ExtraParams
    )
    <#
    .SYNOPSIS
        Not required.

    .DESCRIPTION
        This provider does not require calling this function to commit changes to DNS records.

    .PARAMETER ExtraParams
        This parameter can be ignored and is only used to prevent errors when splatting with more parameters than this function supports.
    #>
}

############################
# Helper Functions
############################

function Initialize-DomeneshopAuth {
    [CmdletBinding(DefaultParameterSetName='Secure')]
    param(
        [Parameter(ParameterSetName='Secure',Mandatory)]
        [pscredential]$DomeneshopCredential,
        [Parameter(ParameterSetName='Insecure',Mandatory)]
        [string]$DomeneshopToken,
        [Parameter(ParameterSetName='Insecure',Mandatory)]
        [string]$DomeneshopSecret,
        [Parameter(ValueFromRemainingArguments)]
        $ExtraConnectParams
    )

    if ($script:DomeneshopAuth) {
        return
    }

    if ('Secure' -eq $PSCmdlet.ParameterSetName) {
        $DomeneshopToken = $DomeneshopCredential.UserName
        $DomeneshopSecret = $DomeneshopCredential.GetNetworkCredential().Password
    }

    $script:DomeneshopAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${DomeneshopToken}:${DomeneshopSecret}"))
}

function New-DomeneshopRequest {
    [CmdletBinding()]
    param()

    $apiHost = 'api.domeneshop.no'
    $apiVersion = 'v0'
    $baseUri = "https://$apiHost/$apiVersion"
    $auth = $script:DomeneshopAuth

    $request = @{
        Uri = $baseUri
        Method = 'Get'
        Headers = @{
            Authorization = "Basic $auth"
        }
    }

    return $request
}

function Get-DomeneshopDomain {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)]
        [string]$RecordName
    )

    if (-not $script:DomeneshopDomains) { $script:DomeneshopDomains = @{} }

    if ($script:DomeneshopDomains.ContainsKey($RecordName)) {
        return $script:DomeneshopDomains.$RecordName
    }

    $request = New-DomeneshopRequest
    $request.Uri += "/domains"    
   
    $domains = Invoke-RestMethod @request @script:UseBasic
    $fragments = $RecordName.Split('.')

    $fragments.Count..2 | foreach {
        $domainName = ($fragments | select -Last $_) -join '.'
        if ($domainName -in $domains.domain) {
            $domain = $domains | where domain -eq $domainName
            $script:DomeneshopDomains.$RecordName = $domain
            return $domain
        }
    }

    return $null  
}

function Get-DomeneshopRecord {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)]
        [string]$RecordName,
        [Parameter(Mandatory,Position=1)]
        [string]$TxtValue
    )

    $domain = Get-DomeneshopDomain $RecordName
    $domainId = $domain.id

    $hostName = ($RecordName -replace $domain.domain).Trim('.')
       
    $request = New-DomeneshopRequest
    $request.Uri += "/domains/$domainId/dns"

    $records = Invoke-RestMethod @request @script:UseBasic

    foreach ($record in $records) {
        if ($record.type -eq 'TXT' -and $record.host -eq $hostName -and $record.data -eq $TxtValue) {
            return $record
        }
    }

    return $null
}

# Función para obtener el token de acceso
function Get-AccessToken {
    param (
        [string]$ClientId,
        [string]$ClientSecret,
        [string]$TenantId
    )

    $url = 'https://login.microsoftonline.com/' + $TenantId + '/oauth2/v2.0/token'
    $Scopes = New-Object System.Collections.Generic.List[string]
    $Scope = "https://graph.microsoft.com/.default"
    $Scopes.Add($Scope)
    
    $body = @{
        grant_type = "client_credentials"
        client_id = $ClientId
        client_secret = $ClientSecret
        scope = $Scopes
    }
    
    try {
        $res = Invoke-WebRequest -Method Post -Uri $url -Body $body
        $token = ($res.Content | ConvertFrom-Json).access_token
        return $Token
    }
    catch {
        Write-Host "Failed to obtain token, aborting..."
        return
    }
}

# Función para obtener el ID del sitio en SharePoint Online
function Get-SiteId {
    param (
        [string]$SiteName,
        [string]$AccessToken
    )

    $url = 'https://graph.microsoft.com/v1.0/sites?search=' + $SiteName + '&$select=webUrl,id'

    try {
        $response = Invoke-WebRequest -Method Get -Uri $url -Headers @{ 'Authorization' = "Bearer $AccessToken" }
        $result = $response.Content | ConvertFrom-Json
        $siteId = $result.value.id.Split(",")[1]
        return $siteId
    }
    catch {
        Write-Host "Failed to get site ID."
        return $null
    }
}

# Función para obtener el ID del drive en SharePoint Online
function Get-DriveId {
    param (
        [string]$SiteId,
        [string]$LibraryName,
        [string]$AccessToken
    )

    $url = "https://graph.microsoft.com/v1.0/sites/$SiteId/drives/?\$select=name,id"

    try {
        $response = Invoke-WebRequest -Method Get -Uri $url -Headers @{ 'Authorization' = "Bearer $AccessToken" }
        $result = $response.Content | ConvertFrom-Json
        $driveId = $result.value | Where-Object { $_.name -eq $LibraryName } | Select-Object -ExpandProperty id
        return $driveId
    }
    catch {
        Write-Host "Failed to get drive ID."
        return $null
    }
}

# Función para subir un archivo al drive en SharePoint Online
# Referencia: https://learn.microsoft.com/en-us/graph/api/driveitem-put-content?view=graph-rest-1.0&tabs=http

function UploadFileToDrive {
    param (
        [string]$DriveId,
        [string]$FileName,
        [string]$FilePath,
        [string]$AccessToken
    )

    $url = 'https://graph.microsoft.com/v1.0/drives/' + $DriveId + '/root:/' + $FileName + ':/content'

    try {
        Invoke-RestMethod -Uri $url -Headers @{ 'Authorization' = "Bearer $AccessToken" } -Method Put -InFile $FilePath -ContentType 'multipart/form-data'
        Write-Host "File uploaded successfully."
    }
    catch {
        Write-Host "Failed to upload file."
    }
}

# Configuración
$siteName = "XXXXXXX"
$libraryName = "XXXXXX"
$clientId = "XXXXXXXX"
$clientSecret = "XXXXXXX"
$tenantId = "XXXXXXXX"
$filePath = "C:\Assets\add-square.png"
$fileName = "add-square.png"

# Obtener el token de acceso
$accessToken = Get-AccessToken -ClientId $clientId -ClientSecret $clientSecret -TenantId $tenantId

if ($accessToken) {
    # Obtener el ID del sitio
    $siteId = Get-SiteId -SiteName $siteName -AccessToken $accessToken

    if ($siteId) {
        # Obtener el ID del drive
        $driveId = Get-DriveId -SiteId $siteId -LibraryName $libraryName -AccessToken $accessToken

        if ($driveId) {
            # Subir el archivo al drive
            UploadFileToDrive -DriveId $driveId -FileName $fileName -FilePath $filePath -AccessToken $accessToken
        }
    }
}
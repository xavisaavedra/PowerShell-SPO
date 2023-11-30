function Get-AccessToken {
    param (
        [string]$ClientId,             # ID del cliente para la autenticación
        [string]$ClientSecret,         # Secreto del cliente para la autenticación
        [string]$TenantId              # ID del Tenant para la autenticación
    )

    $url = 'https://login.microsoftonline.com/' + $TenantId + '/oauth2/v2.0/token'
    $Scopes = New-Object System.Collections.Generic.List[string]
    $Scope = "https://graph.microsoft.com/.default"
    $Scopes.Add($Scope)
    
    $body = @{
        grant_type    = "client_credentials"
        client_id     = $ClientId
        client_secret = $ClientSecret
        scope         = $Scopes
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

# Función para enviar un correo electrónico utilizando la API de Microsoft Graph
function Send-GraphEmail {
    param (
        [Parameter(Mandatory = $true)]
        [string]$From, # Dirección de correo electrónico del remitente

        [Parameter(Mandatory = $true)]
        [string]$To, # Dirección de correo electrónico del destinatario

        [Parameter(Mandatory = $true)]
        [string]$Subject, # Asunto del correo electrónico

        [Parameter(Mandatory = $true)]
        [string]$Body, # Cuerpo del correo electrónico

        [Parameter(Mandatory = $true)]
        [string]$AccessToken            # Token de acceso para la autenticación 
    )

    $sendEmailUrl = "https://graph.microsoft.com/v1.0/users/$From/sendMail"

    $emailParams = @{
        message = @{
            subject      = $Subject
            body         = @{
                contentType = "HTML"
                content     = $Body
            }
            toRecipients = @(
                @{
                    emailAddress = @{
                        address = $To
                    }
                }
            )
        }
    }

    $Email = ($emailParams | ConvertTo-Json -Depth 100) 

    Invoke-RestMethod -Uri $sendEmailUrl -Headers @{Authorization = "Bearer $AccessToken" } -Method POST -Body $Email -ContentType "application/json"
}
 
# Configuración Aplicación Tenant 
# Permisos: Mail.Send
$clientId = ""
$clientSecret = ""
$tenantId = ""


$To = ""        # Dirección de correo electrónico del destinatario
$From = ""      # Dirección de correo electrónico del remitente
$Subject = ""   # Asunto del correo electrónico

<# El $body tiene que ser en formato HTLM. Si se quiere cambiar por texto, hay que modificar la linea 54:
contentType = "HTML" por contentType = "Text" #>
$body = ""
        
 
Clear-Host

# Obtener el token de acceso
$accessToken = Get-AccessToken -ClientId $clientId -ClientSecret $clientSecret -TenantId $tenantId

# Enviar el correo electrónico utilizando la función Send-GraphEmail
Send-GraphEmail -From $From -To $To -Subject $Subject -Body $body -AccessToken $accessToken


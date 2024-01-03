# Establecer la URL del sitio de SharePoint Online
$siteUrl = "https://MY-SITE.sharepoint.com/sites/TestPnPFeatures"

# Obtener la ruta del archivo CSV que contiene las características de sitio
$csvPath = "features.csv"

# Leer el archivo CSV
$features = Import-Csv -Path $csvPath

# Conectar al sitio de SharePoint Online
Connect-PnPOnline -Url $siteUrl -interactive
# Recorrer las características de sitio del archivo CSV
foreach ($feature in $features) {
    $featureId = $feature.FeatureId
    $featureName = $feature.FeatureName
    $featureScope = $feature.Scope

    # Activar la característica de sitio
    Write-Host "Activando la característica de sitio: $featureName ($featureId)"
    Enable-PnPFeature -Identity $featureId -Scope $featureScope
}

# Desconectar del sitio de SharePoint Online
Disconnect-PnPOnline

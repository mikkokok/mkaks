$resourceGroupName = ""
$kubeClusterName = ""

$subscriptionId = (Get-AzContext).Subscription.Id

$currentContext = Get-AzContext
$accessToken = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate(
    $currentContext.'Account',
    $currentContext.'Environment',
    $currentContext.'Tenant'.'Id',
    $null,
    [Microsoft.Azure.Commands.Common.Authentication.ShowDialog]::Never,
    $null,
    'https://management.azure.com/'
).AccessToken

if (!$accessToken) {
    Write-Host "No accesstoken found. Exiting"
    exit
}

$providerUri = $subscriptionId + "/resourceGroups/" + $resourceGroupName + "/providers/Microsoft.ContainerService/managedClusters/" + $kubeClusterName + "/listClusterAdminCredential?api-version=2020-11-01"

$uri = "https://management.azure.com/subscriptions/" + $providerUri
$params = @{
    ContentType = 'application/json'
    Headers     = @{
        "Authorization" = "Bearer " + $accessToken
    }
    Method      = 'POST'
    URI         = $uri
}
$response = Invoke-WebRequest @params
$responseContent = $response.Content | ConvertFrom-Json
$responseContent.kubeconfigs.value
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($responseContent.kubeconfigs.value))
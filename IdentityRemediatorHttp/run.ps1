using namespace System.Net


param($Request, $TriggerMetadata)


# 1. Catch action variables sent from the Teams button press
$RequestBody = $Request.Body
$UserId = $RequestBody.user_id
$Action = $RequestBody.action


# 2. Acquire Graph Token
$Body = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $env:CLIENT_ID
    Client_Secret = $env:CLIENT_SECRET
}
$TokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$($env:TENANT_ID)/oauth2/v2.0/token" -Method Post -Body $Body
$Headers = @{ Authorization = "Bearer $($TokenResponse.access_token)"; "Content-Type" = "application/json" }


if ($Action -eq "disable") {
    # 3. Apply Zero-Trust Security Policy: Block the Account
    $PatchUrl = "https://graph.microsoft.com/v1.0/users/$UserId"
    $PatchBody = @{ accountEnabled = $false } | ConvertTo-Json
    
    try {
        $UpdateResponse = Invoke-WebRequest -Uri $PatchUrl -Method PATCH -Headers $Headers -Body $PatchBody
        
        # 4. Return an instant confirmation response card to Teams
        $SuccessCard = @{
            type = "AdaptiveCard"
            version = "1.4"
            body = @(@{
                type = "TextBlock"
                text = "✅ Remediation Success: Account $UserId has been successfully disabled."
                color = "Good"
                weight = "Bolder"
            })
        } | ConvertTo-Json -Depth 5


        Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = [HttpStatusCode]::OK
            Body = $SuccessCard
            Headers = @{ "Content-Type" = "application/json" }
        })
    }
    catch {
        Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = [HttpStatusCode]::InternalServerError
            Body = "Remediation Script Encountered an Error: $_"
        })
    }
}
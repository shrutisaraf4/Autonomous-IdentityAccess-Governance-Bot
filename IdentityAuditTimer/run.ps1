using namespace System.Net


# 1. Fetch access credentials from secure App Settings environment
$TenantId = $env:TENANT_ID
$ClientId = $env:CLIENT_ID
$ClientSecret = $env:CLIENT_SECRET
$TeamsWebhookUrl = $env:TEAMS_WEBHOOK_URL


# 2. Authenticate securely with Microsoft Graph API
$Body = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $ClientId
    Client_Secret = $ClientSecret
}
$TokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" -Method Post -Body $Body
$Headers = @{ Authorization = "Bearer $($TokenResponse.access_token)" }


# 3. Query Microsoft Entra for Inactive Guest Users (>90 Days)
$CutoffDate = (Get-Date).AddDays(-90).ToString("yyyy-MM-dd")
$GraphUrl = "https://graph.microsoft.com/v1.0/users?`$filter=userType eq 'Guest'&`$select=displayName,userPrincipalName,signInActivity"
$Users = (Invoke-RestMethod -Uri $GraphUrl -Method Get -Headers $Headers).value


foreach ($User in $Users) {
    $LastSignIn = $User.signInActivity.lastSuccessfulSignInDateTime
    
    # Trigger alert if account is dormant or has never logged in
    if (-not $LastSignIn -or ($LastSignIn -lt $CutoffDate)) {
        
        # 4. Construct Teams Workflow Adaptive Card JSON Payload
        $Payload = @{
            type = "message"
            attachments = @(@{
                contentType = "application/vnd.microsoft.card.adaptive"
                content = @{
                    type = "AdaptiveCard"
                    version = "1.4"
                    body = @(
                        @{ type = "TextBlock"; text = "🛡️ Identity Governance Alert"; weight = "Bolder"; size = "Medium"; color = "Attention" },
                        @{ type = "FactSet"; facts = @(
                            @{ title = "Target User:"; value = $User.displayName },
                            @{ title = "User Principal Name:"; value = $User.userPrincipalName },
                            @{ title = "Violation:"; value = "Dormant Guest Account (>90 Days Inactive)" }
                        )}
                    )
                    actions = @(@{
                        type = "Action.Http"
                        title = "Remediate Account"
                        method = "POST"AIAGovernanceBot
                        url = "https://AIAGovernanceBot.azurewebsites.net/api/remediator"
                        body = "{'user_id': '$($User.userPrincipalName)', 'action': 'disable'}"
                        headers = @(@{ name = "Content-Type"; value = "application/json" })
                    })
                }
            })
        }


        # 5. Route alert directly into your Microsoft Teams Workflow
        $JsonPayload = ConvertTo-Json $Payload -Depth 10
        Invoke-RestMethod -Uri $TeamsWebhookUrl -Method Post -ContentType "application/json" -Body $JsonPayload
    }
}

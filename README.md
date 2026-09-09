# Autonomous Identity & Access Governance Bot

An enterprise-grade, event-driven identity governance framework built using **Azure Functions (Python)** and **Microsoft Graph API**. This system continuously audits **Microsoft Entra ID** tenants to identify identity anomalies, alerts security operations teams via **Microsoft Teams Adaptive Cards**, and processes one-click administrator approval workflows to execute real-time, zero-trust cloud remediations.

---

## 📌 Purpose & Business Case
Unmanaged guest accounts, missing Multi-Factor Authentication (MFA) parameters, and permanent over-privileged administrator assignments represent primary attack surfaces for corporate cloud breaches. 

This project solves identity sprawl by transforming security monitoring from a manual, reactive checklist into an **automated, self-contained auditing cycle**. By leveraging serverless infrastructure, the framework minimizes management overhead while ensuring identity configurations maintain continuous compliance with modern zero-trust architecture rules.

---

## 🔄 Project Workflow Diagram

1. **Audit Phase**: A time-triggered Azure Function invokes daily scans against premium Microsoft Graph API directory endpoints.
2. **Analysis Phase**: The engine filters accounts based on specific identity criteria (such as guest inactivity tracking or incomplete authentication methods).
3. **Alert Phase**: If a configuration drift or vulnerability is identified, a structured webhook constructs and sends an interactive JSON Adaptive Card directly to an assigned Microsoft Teams IT administration channel.
4. **Remediation Phase**: The IT administrator reviews the card data directly within Teams and clicks the action trigger. An HTTP-triggered Azure Function processes the request payload and instantly updates the configuration in Microsoft Entra ID.

---

## 🛠️ Technology Stack Used

*   **Cloud Identity Orchestration**: Microsoft Entra ID (Features: Entra ID P2 Identity Logging, Group & Account Scans)
*   **API Management Layer**: Microsoft Graph API v1.0 (Endpoints used: `/users`, `/credentialUserRegistrationDetails`, `/directoryRoles`)
*   **Serverless Execution**: Azure Functions (Python v2 Model, featuring Timer Triggers and HTTP Webhook routes)
*   **Hosting Runtime Infrastructure**: Azure Consumption Plan (Optimized for pay-as-you-go free execution tiers)
*   **ChatOps UI Interface**: Microsoft Teams (Incoming Webhooks & JSON-formatted Interactive Adaptive Cards)

---

## 🚶‍♂️ End-to-End Implementation Steps

### Step 1: Microsoft Entra ID Enterprise App Registration
To establish secure communication between Azure and your identity data directories, register an isolated service application within your Entra ID tenant to generate API credentials.

1. Navigate to the **Microsoft Entra Admin Center** > **Identity** > **Applications** > **App registrations**.
2. Select **New Registration**, name it `Identity-Access-Governance-Bot`, and click **Register**<img width="1907" height="870" alt="image" src="https://github.com/user-attachments/assets/ebf452e4-fd9e-440e-9198-0e641e2c3d3e" />
3. Copy the **Application (client) ID** and **Directory (tenant) ID** values.<img width="1570" height="727" alt="image" src="https://github.com/user-attachments/assets/e4da8118-5a60-40cd-84ed-6db47395218e" />
4. Navigate to **Certificates & secrets**, generate a new client secret, and securely store the secret value string.
<img width="1532" height="792" alt="image" src="https://github.com/user-attachments/assets/129e699e-eba6-49f2-a0f8-8d08c22a3a65" />
<img width="1575" height="813" alt="image" src="https://github.com/user-attachments/assets/32c1ebbf-e8e2-4ec3-aaf4-a84bc3c596a7" />
<img width="1615" height="842" alt="image" src="https://github.com/user-attachments/assets/8b067dc3-7b4d-4328-bf10-1b64ccd6b559" />

---

### Step 2: Configuring High-Level Microsoft Graph API Permissions
Configure explicit least-privilege enterprise directory read and write policies to authorize the background bot engine.

1. Inside your App Registration dashboard, click **API permissions** > **Add a permission** > **Microsoft Graph**.
2. Choose **Application permissions** (not Delegated permissions).<img width="1618" height="813" alt="image" src="https://github.com/user-attachments/assets/1c1fc583-448d-4770-8c84-3feeb7933a15" />
3. Search for and check these specific permission scopes:
   * `User.ReadWrite.All` — Required to query guest fields and automatically disable non-compliant targets.<img width="917" height="817" alt="image" src="https://github.com/user-attachments/assets/ce1fe506-bd72-4b74-b613-006fe9f27075" />
   * `AuditLog.Read.All` — Grants explicit access to premium sign-in properties (`signInActivity`).<img width="962" height="797" alt="image" src="https://github.com/user-attachments/assets/8abe76dd-fde9-4c8d-9c98-f42a7c2cf861" />
   * `RoleManagement.Read.Directory` — Grants read-only visibility into privileged directory group hierarchies.<img width="927" height="787" alt="image" src="https://github.com/user-attachments/assets/ceab781c-0bb4-4aa9-9663-b8d6abe8c3d5" />
4. **Crucial Action**: Click **"Grant admin consent for [Your Organization Name]"** to clear security authorization flags.
<img width="1572" height="807" alt="image" src="https://github.com/user-attachments/assets/6a572029-37dc-4d8f-9123-032035b7a807" />
<img width="1557" height="457" alt="image" src="https://github.com/user-attachments/assets/debe7e80-2e9d-4162-b9a4-c04c795f056e" />
<img width="1257" height="397" alt="image" src="https://github.com/user-attachments/assets/4eca1125-f314-46c8-9d17-e32a0b16eff3" />


---

### Step 3: Setting Up the Microsoft Teams Incoming Webhook Channel
Configure your target Microsoft Teams collaboration workspace to receive external JSON payloads securely.

1. Open **Microsoft Teams**, create or choose an IT infrastructure operational channel, and click **Manage Channel**.<img width="1895" height="550" alt="image" src="https://github.com/user-attachments/assets/f783f171-ea2c-4962-81f0-1d0fdd779965" />
<img width="867" height="817" alt="image" src="https://github.com/user-attachments/assets/4c96ea96-2b29-481b-9bf6-6f2d904ef2d7" />
<img width="1835" height="697" alt="image" src="https://github.com/user-attachments/assets/6e56292d-0a9a-4a3d-b1fb-0f53f08f3b19" />
2. Navigate to **Workflows** > search for **Send webhook alerts to a channel**, and click to add.<img width="975" height="761" alt="image" src="https://github.com/user-attachments/assets/beb17b88-2ebd-4c84-ac6a-5a219e47d2ef" />
<img width="977" height="727" alt="image" src="https://github.com/user-attachments/assets/06c3836f-43f2-4b13-9068-aeccf57a680a" />
3. Copy the long webhook endpoint destination URL.
<img width="987" height="766" alt="image" src="https://github.com/user-attachments/assets/1ab080bd-ae1f-4ce0-b4e8-929a5db1b8ae" />

---

### Step 4: Deploying Serverless Infrastructure on Azure
Build and deploy the Python backend compute modules into your Azure Pay-As-You-Go subscription architecture.

1. Open the **Azure Portal**, select **Create a Resource**, and select **Function App**.<img width="1085" height="346" alt="image" src="https://github.com/user-attachments/assets/ba02bc43-88e3-4b99-899d-27c298dfd51b" />
2. Configure basic deployment settings:
     * **Hosting Plan**: Consumption (Serverless, free execution tier)<img width="1915" height="611" alt="image" src="https://github.com/user-attachments/assets/4428c17b-701a-44e8-89a7-3b9dd589230d" />
     * **Runtime Stack**: Powershell
     * **Version**: Select 7.2 (or the highest 7.x version available).
     * **Region: Choose your local or closest data center region (e.g., India South Central).<img width="1420" height="792" alt="image" src="https://github.com/user-attachments/assets/bffb98d9-8ec3-493f-b65d-2b913ee3524b" />
     * **Storage**: Pair it with a standard local LRS storage account block.<img width="1037" height="817" alt="image" src="https://github.com/user-attachments/assets/15103c16-b57f-4c4c-97d5-c6470adbb407" />
     * Proceed through the wizard tabs (Hosting, Monitoring) keeping the defaults, and click Review + Create, then Create*
<img width="1110" height="804" alt="image" src="https://github.com/user-attachments/assets/acc49a72-1c57-4ea1-b640-7b68d142c68c" /><img width="1163" height="862" alt="image" src="https://github.com/user-attachments/assets/15f0a3d4-4017-4acb-968a-f7087f8c0698" />

---

### Step 5: Inject Your Secret Credentials into Azure Portal
Your code needs to read sensitive connection arguments securely without exposing them in plain text. We will inject your parameters into Azure's secure 
environment blade.

1. Navigate to the [Azure Portal](https://portal.azure.com) and open your newly created **Function App**.
2. On the left sidebar menu, scroll down to the **Settings** section and click on **Configuration** (or **Environment variables** depending on the UI version 
layout).
3. Under the **Application settings** tab, click **+ New application setting** to add these four exact key-value pairs:

| Key Name | Value to Paste |
| :--- | :--- |
| `TENANT_ID` | *Your Microsoft Entra Tenant ID* | 
| `CLIENT_ID` | *Your registered App's Application ID (Client ID)* |
| `CLIENT_SECRET` | *Your App's Client Secret String Value* |
| `TEAMS_WORKHOOK_URL` | *The Workflow URL you copied from Microsoft Teams* |
<img width="1923" height="862" alt="image" src="https://github.com/user-attachments/assets/6e00b455-83a1-47a7-8a69-ad2e8829114e" />
<img width="1651" height="837" alt="image" src="https://github.com/user-attachments/assets/e74effdc-786e-436b-9442-2fc960bbef16" />
<img width="1477" height="852" alt="image" src="https://github.com/user-attachments/assets/9390022d-a076-40c0-ba76-1afc600f4f9a" />
<img width="1706" height="725" alt="image" src="https://github.com/user-attachments/assets/379cb0dd-2e6d-474c-bb2d-dfb8f16ec70e" />
<img width="1647" height="816" alt="image" src="https://github.com/user-attachments/assets/9f23116d-4fb1-40aa-af09-8c0400d4eac0" />

4. Click **Apply** or **Save** at the bottom of the configuration blade, then click **Confirm**. This instantly restarts your Function App to load the 
variables safely.

---

### Step 6: Establish the Local Project Structure
We will organize the application scripts locally before publishing them to the cloud. <img width="792" height="895" alt="Screenshot 2026-09-08 100951" src="https://github.com/user-attachments/assets/10fa288e-17be-4e5b-9bdb-2e1b3fb63bff" />
Create a folder on your computer named `IdentityGovernanceBot`. Open <img width="1250" height="660" alt="image" src="https://github.com/user-attachments/assets/74777dca-e2f9-43f4-90b3-f1427f4205be" /> this root folder inside **Visual Studio Code (VS Code)**.

Create the exact directory tree layout below and add the empty files inside it:
<img width="437" height="671" alt="image" src="https://github.com/user-attachments/assets/3a2864a9-e0a6-4ec0-bebb-ee97b7bb7b84" />

```text
IdentityGovernanceBot/
├── host.json
├── profile.ps1
├── requirements.psd1
├── IdentityAuditTimer/
│   ├── function.json
│   └── run.ps1
└── IdentityRemediatorHttp/
    ├── function.json
    └── run.ps1
```


---


### Step 7: Populate Root Configuration Files


#### 📄 `host.json`
<img width="1522" height="712" alt="image" src="https://github.com/user-attachments/assets/346ce4cd-2c92-48a4-a02f-42b1752a9275" />
This enables background managed engines to pull modern PowerShell modules automatically.
```json
{
  "version": "2.0",
  "managedDependency": {
    "enabled": true
  },
  "extensionBundle": {
    "id": "Microsoft.Azure.Functions.ExtensionBundle",
    "version": "[4.*, 5.0.0)"
  }
}
```


#### 📄 `requirements.psd1`
<img width="1335" height="717" alt="image" src="https://github.com/user-attachments/assets/e7b673b0-1c97-4d9a-af7b-1ca333c03a09" />
Instructs Azure to handle internal module imports dynamically.
```powershell
@{
    'Az' = '10.*'
}
```


#### 📄 `profile.ps1`
<img width="1201" height="671" alt="image" src="https://github.com/user-attachments/assets/20769801-af40-4299-ab20-f9b99a2c8f25" />
Runs standard initialization paths.
```powershell
if ($env:MSI_SECRET) {
    Disable-AzContextAutosave -Scope Process | Out-Null
    Connect-AzAccount -Identity
}
```

---


### Step 8: Populate Function Execution Folders

#### 🛠️ Function 1: IdentityAuditTimer (The Daily Background Auditor)
<img width="1012" height="622" alt="image" src="https://github.com/user-attachments/assets/ac65183d-d795-463d-94ef-d21a00bccaf0" />

*   **`IdentityAuditTimer/function.json`**
```json
{
  "bindings": [
    {
      "name": "Timer",
      "type": "timerTrigger",
      "direction": "in",
      "schedule": "0 0 0 * * *"
    }
  ]
}
```


*   **`IdentityAuditTimer/run.ps1`**
    <img width="1697" height="862" alt="image" src="https://github.com/user-attachments/assets/003ea6d5-2298-433f-9180-6ce04f407d72" />

```powershell
using namespace System.Net


# 1. Fetch access credentials from secure App Settings environment
$TenantId = $env:TENANT_ID
$ClientId = $env:CLIENT_ID
$ClientSecret = $env:CLIENT_SECRET
$TeamsWebhookUrl = $env:TEAMS_WORKHOOK_URL


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
                        method = "POST"
                        url = "https://YOUR_FUNCTION_APP_NAME.azurewebsites.net/api/remediator"
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
```
*(⚠️ Note: Replace `YOUR_FUNCTION_APP_NAME` in the url string parameters with the name of your actual Azure Function app.)*


---


#### 🛠️ Function 2: IdentityRemediatorHttp (The Instant One-Click Action Listener)

*   **`IdentityRemediatorHttp/function.json`**
  <img width="1681" height="767" alt="image" src="https://github.com/user-attachments/assets/6d180985-b5e0-40af-a247-1c699f81fd1b" />

```json
{
  "bindings": [
    {
      "authLevel": "function",
      "type": "httpTrigger",
      "direction": "in",
      "name": "Request",
      "methods": ["post"],
      "route": "remediator"
    },
    {
      "type": "http",
      "direction": "out",
      "name": "Response"
    }
  ]
}
```


*   **`IdentityRemediatorHttp/run.ps1`**
   <img width="1530" height="780" alt="image" src="https://github.com/user-attachments/assets/3b7fd99f-e86c-4326-af84-118a33952135" />

```powershell
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
```


---


### Step 9: Deploy Code via VS Code Extensions
Publish your configurations and scripts directly into your cloud platform runtime environment.


1. In VS Code, open the Extensions view (`Ctrl+Shift+X`), search for **Azure Account** and **Azure Functions**, and install them.
2. Click the **Azure icon** that appears in the left activity bar workspace, click **Sign in to Azure**, and follow the system browser authentication prompt.
3. Once logged in, locate the **Resources** panel inside the Azure extension workspace pane, expand your subscription node, right-click on your targeted 
**Function App**, and select **Deploy to Function App...**.
4. Select the `IdentityGovernanceBot` root folder directory when prompted. Click **Deploy** to push the automation code live.

---

### Step 10: Validating Live Governance Remediation (The Live Test)
## 🚀 Deployment & Validation Procedures

---

### 📦 Part 1: Deploying Code Directly to Azure (Making the Bot Live)

Follow these steps to upload your local PowerShell project files from Visual Studio Code straight into your Azure Pay-As-You-Go subscription.

#### Step 1: Install Required Extensions
1. Open **Visual Studio Code (VS Code)**.
2. Open the Extensions view by clicking the Extensions icon on the left Activity Bar (`Ctrl+Shift+X`).
3. Search for and install these two official extensions:
   * **Azure Resources**
   * **Azure Functions**
<img width="967" height="1012" alt="image" src="https://github.com/user-attachments/assets/2e738129-ef7e-4336-8003-7af9a7573daa" />

#### Step 2: Authenticate with Your Azure Account
1. Click on the newly visible **Azure icon** located on the far left Activity Bar.
2. In the Azure panel, click **Sign in to Azure...**.
3. A web browser window will automatically launch. Log in using your Azure Pay-As-You-Go subscription credentials.
4. Close the browser window once the confirmation message appears.

#### Step 3: Publish Your Files to the Cloud
1. In the VS Code Azure panel, locate and expand the **Resources** section.
2. Expand your active subscription tree to locate your target **Function App** name.
3. Right-click on your **Function App name** and select **Deploy to Function App...** from the context menu.<img width="709" height="997" alt="image" src="https://github.com/user-attachments/assets/c94628a1-aa60-467b-a0aa-6501524668d9" />
4. Select your local root folder path `IdentityGovernanceBot` when prompted for the workspace resource.
5. Click **Deploy** to confirm and initiate the file packaging upload sequence.
<img width="1123" height="995" alt="Screenshot 2026-09-08 153400" src="https://github.com/user-attachments/assets/4b6107c2-aac8-4d78-bdb8-b6fa147a91e1" />

#### Step 4: Monitor Deployment Status
1. Watch the execution progress panel in the bottom-right notification banner of your VS Code workspace.
2. Wait for the status indicator message to display **"Deployment successful"**. Your PowerShell automation engine is now live in the cloud.

---

### 📁 Part 2: Pushing Your Files to GitHub (Building Your Portfolio)

Follow these steps to safely share your project code with recruiters on GitHub without exposing confidential environment secrets.

⚠️ **Crucial Safety Warning:** Never upload your `local.settings.json` file. It contains your private application registration keys and client secret strings.

#### Step 1: Create a Git Ignore Parameter Rule
1. Inside your root folder path `IdentityGovernanceBot`, create a brand new file named exactly `.gitignore`.
2. Open the file and insert this single line of text:
   ```text
   local.settings.json
   ```
3. Save the file. This tells Git to permanently ignore your local secrets file so it can never be pushed to a public repository.

#### Step 2: Initialize and Publish via VS Code
1. Click the **Source Control** icon on the left Activity Bar (`Ctrl+Shift+G`).
2. Click the **Initialize Repository** button at the top of the pane.
3. In the input text box, type a clear commit message, such as: `Initial commit - Identity Governance Bot Code`.
4. Click the checkmark icon or click the arrow next to the **Commit** button to commit your local workspace files.
5. Click the blue **Publish Branch** button.
6. Select **Publish to GitHub public repository** from the dropdown option list.
7. VS Code will automatically prompt you to log into your GitHub account, build the remote cloud repository, and securely upload your project tracking history.

---

### 🛠️ Part 3: End-to-End Validation Testing Guide

Follow this walkthrough to simulate an identity vulnerability in a controlled environment and test your automation bot framework end-to-end.

#### Step 1: Create an Inactive Test Guest User Account
Because a new sandbox tenant does not contain old historical data, create a guest user who has never logged in before. The bot will flag it as "dormant" since its last sign-in log will be blank.
1. Sign into the [Microsoft Entra Admin Center](https://microsoft.com).
2. Go to **Identity** > **Users** > **All users**.
3. Click **+ New user** at the top of the interface and select **Invite external user**.
4. Fill out these profile properties:
   * **Email address:** Use a separate personal account you own (e.g., a personal `@gmail.com`).
   * **Display name:** `Test Dormant Guest`
   * **User type:** Ensure it is strictly set to **Guest**.
5. Click **Invite**.
6. Open a private incognito browser window, log into your personal email inbox, locate the invitation message from Microsoft, and click the verification link to accept the invite. **Stop there—do not attempt to log in further.**

#### Step 2: Manually Trigger Your Audit Engine
Instead of waiting for the midnight schedule trigger, force the function app to execute right now.
1. Open the [Azure Portal](https://azure.com) and go to your **Function App** dashboard.
2. In the left navigation menu, look under the **Functions** section and click **Functions**.
3. Click on your timer module: **IdentityAuditTimer**.
4. In its inner left sidebar, select **Code + Test**.
5. Click the **Test/Run** button located on the top command strip.
6. A configurations panel will slide out from the right side of the screen. Leave the request input body completely empty and click the green **Run** button at the bottom.
7. Watch the **Logs** streaming console window at the bottom. Confirm that the script logs show a successful Graph API connection, identify your test guest user, and send an alert notification payload to Teams.

#### Step 3: Verify the Security Alert in Microsoft Teams
1. Open your **Microsoft Teams** application client.
2. Open your dedicated **IT Security Operations** team space and select the `identity-alerts` channel.
3. Look at the bottom of the channel's **Posts** conversation feed. Verify that a new post containing an interactive Adaptive Card has arrived with these values:
   * **Title:** 🛡️ Identity Governance Alert
   * **Target User:** `Test Dormant Guest`
   * **Violation:** `Dormant Guest Account (>90 Days Inactive)`
   * Check that a prominent interactive action button labeled **"Remediate Account"** is visible.

#### Step 4: Execute the Direct Remediation Click Action
1. Click the **Remediate Account** button directly inside that Microsoft Teams post.
2. The Teams canvas will forward an HTTP POST remediation payload containing your target user parameter strings back to your live listening API endpoint (`IdentityRemediatorHttp`).
3. Watch the post item update inline. The active button will disappear, and the Adaptive Card layout will automatically rewrite itself to display this confirmation message:
   * `✅ Remediation Success: Account Test Dormant Guest has been successfully disabled.`

#### Step 5: Audit Account State Change inside Entra ID
1. Switch back to your [Microsoft Entra Admin Center](https://microsoft.com) window.
2. Navigate to **Identity** > **Users** > **All users**.
3. Select your `Test Dormant Guest` user account profile card to review its inner directory properties database.
4. Locate the **Account status** metric row visibility block.
5. Verify that the indicator has instantly been rewritten to read **Account Enabled: No**. 

<img width="1456" height="720" alt="image_60c52864" src="https://github.com/user-attachments/assets/74e4cfa0-0f78-4bcd-b76f-ab185059f642" />

# 🛡️ Autonomous Identity & Access Governance Bot

An enterprise-grade, event-driven identity governance framework built using **Azure Functions (PowerShell 7.2)**, **Microsoft Graph API**, **Microsoft Power Automate**, and **Microsoft Teams Adaptive Cards**.

The system continuously audits **Microsoft Entra ID** for identity risks, identifies dormant guest accounts, alerts IT teams through Teams, and enables a controlled one-click remediation workflow that disables non-compliant accounts through an HTTP-triggered Azure Function.

---

## 📌 Purpose & Business Case

Unmanaged guest accounts, missing Multi-Factor Authentication (MFA), and permanent over-privileged administrator assignments represent common attack surfaces in enterprise cloud environments.

This project transforms identity monitoring from a manual checklist into an **automated, event-driven governance cycle**:

- **Detect** identity risks automatically.
- **Alert** IT/security teams in Microsoft Teams.
- **Review** the affected account and violation details.
- **Remediate** the account through a controlled Power Automate action.
- **Confirm** the remediation result back in Teams.
- **Validate** the final account state in Microsoft Entra ID.

The design follows a practical **zero-trust / least-privilege** approach by separating detection, human approval, and remediation into distinct components.

---

## 🔄 End-to-End Workflow

```text
┌──────────────────────────────┐
│ Microsoft Entra ID           │
│ Guest Accounts + Sign-In     │
│ Activity                      │
└──────────────┬───────────────┘
               │
               │ Daily scheduled audit
               ▼
┌──────────────────────────────┐
│ Azure Function               │
│ IdentityAuditTimer           │
│ PowerShell 7.2               │
└──────────────┬───────────────┘
               │
               │ Dormant guest > 90 days
               ▼
┌──────────────────────────────┐
│ Microsoft Power Automate     │
│ Receives audit event         │
│ Posts Adaptive Card to Teams │
└──────────────┬───────────────┘
               │
               │ IT admin clicks
               │ "Remediate Account"
               ▼
┌──────────────────────────────┐
│ Power Automate               │
│ HTTP POST                    │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│ Azure Function               │
│ IdentityRemediatorHttp       │
│ PowerShell 7.2               │
└──────────────┬───────────────┘
               │
               │ Microsoft Graph PATCH
               ▼
┌──────────────────────────────┐
│ Microsoft Entra ID           │
│ accountEnabled = false       │
└──────────────┬───────────────┘
               │
               │ Success response
               ▼
┌──────────────────────────────┐
│ Microsoft Teams              │
│ Remediation confirmation     │
└──────────────────────────────┘
```

### Workflow phases

1. **Audit Phase** — `IdentityAuditTimer` runs on a daily timer and scans Entra ID guest accounts.
2. **Analysis Phase** — The function checks `signInActivity` and identifies accounts that have been inactive for more than 90 days or have never successfully signed in.
3. **Alert Phase** — The function sends the detected identity event to a **Power Automate HTTP-triggered flow**.
4. **Approval / Action Phase** — Power Automate posts an Adaptive Card to Microsoft Teams with a **Remediate Account** button.
5. **Remediation Phase** — Clicking the button causes Power Automate to call `IdentityRemediatorHttp`.
6. **Confirmation Phase** — The remediation function disables the account through Microsoft Graph and returns a success response. Power Automate posts the confirmation to Teams.

---

## 🛠️ Technology Stack Used

| Component | Technology | Purpose |
|---|---|---|
| Cloud Identity | **Microsoft Entra ID** | Identity directory and account state |
| API Layer | **Microsoft Graph API v1.0** | Query users/sign-in activity and update accounts |
| Serverless Execution | **Azure Functions** | Daily auditing and HTTP remediation |
| Runtime | **PowerShell 7.2** | Function implementation |
| Automation | **Microsoft Power Automate** | Teams alerting, approval/action handling, and remediation orchestration |
| Collaboration UI | **Microsoft Teams** | Adaptive Card alert and confirmation |
| Hosting | **Azure Functions Consumption Plan** | Serverless execution |
| Source Control | **GitHub** | Portfolio/source-code repository |

---

## 🚶‍♂️ End-to-End Implementation Steps

### Step 1: Microsoft Entra ID App Registration

Register a service application that the Azure Functions can use to authenticate to Microsoft Graph.

1. Open the **Microsoft Entra Admin Center**.
2. Go to **Identity** → **Applications** → **App registrations**.
3. Select **New Registration**.
4. Name the application:

   ```text
   Identity-Access-Governance-Bot
   ```

5. Click **Register**.

<img width="1907" height="870" alt="image" src="https://github.com/user-attachments/assets/ebf452e4-fd9e-440e-9198-0e641e2c3d3e" />

6. Copy the following values:
   - **Application (client) ID**
   - **Directory (tenant) ID**

<img width="1570" height="727" alt="image" src="https://github.com/user-attachments/assets/e4da8118-5a60-40cd-84ed-6db47395218e" />

7. Go to **Certificates & secrets**.
8. Create a new **Client secret**.
9. Store the secret value securely. Do not commit it to GitHub.

<img width="1532" height="792" alt="image" src="https://github.com/user-attachments/assets/129e699e-eba6-49f2-a0f8-8d08c22a3a65" />

<img width="1575" height="813" alt="image" src="https://github.com/user-attachments/assets/32c1ebbf-e8e2-4ec3-aaf4-a84bc3c596a7" />

<img width="1615" height="842" alt="image" src="https://github.com/user-attachments/assets/8b067dc3-7b4d-4328-bf10-1b64ccd6b559" />

---

### Step 2: Configure Microsoft Graph API Permissions

The application uses **Application permissions** because the Azure Functions run without a signed-in user.

1. Open the app registration.
2. Select **API permissions**.
3. Click **Add a permission**.
4. Select **Microsoft Graph**.
5. Select **Application permissions**.

<img width="1618" height="813" alt="image" src="https://github.com/user-attachments/assets/1c1fc583-448d-4770-8c84-3feeb7933a15" />

6. Add these permissions:

| Permission | Purpose |
|---|---|
| `User.ReadWrite.All` | Read user information and disable non-compliant accounts |
| `AuditLog.Read.All` | Read audit/sign-in information such as `signInActivity` |
| `RoleManagement.Read.Directory` | Read directory role information for identity governance scenarios |

<img width="917" height="817" alt="image" src="https://github.com/user-attachments/assets/ce1fe506-bd72-4b74-b613-006fe9f27075" />

<img width="962" height="797" alt="image" src="https://github.com/user-attachments/assets/8abe76dd-fde9-4c8d-9c98-f42a7c2cf861" />

<img width="927" height="787" alt="image" src="https://github.com/user-attachments/assets/ceab781c-0bb4-4aa9-9663-b8d6abe8c3d5" />

7. Click **Grant admin consent for [Your Organization Name]**.

<img width="1572" height="807" alt="image" src="https://github.com/user-attachments/assets/6a572029-37dc-4d8f-9123-032035b7a807" />

<img width="1557" height="457" alt="image" src="https://github.com/user-attachments/assets/debe7e80-2e9d-4162-b9a4-c04c795f056e" />

<img width="1257" height="397" alt="image" src="https://github.com/user-attachments/assets/4eca1125-f314-46c8-9d17-e32a0b16eff3" />

> **Important:** `signInActivity` availability depends on the licensing and audit capabilities of the tenant. If the property is unavailable, the audit logic must be adjusted accordingly.

---

### Step 3: Create the Azure Function App

Create the serverless backend that hosts both PowerShell functions.

1. Open the **Azure Portal**.
2. Select **Create a Resource** → **Function App**.

<img width="1085" height="346" alt="image" src="https://github.com/user-attachments/assets/ba02bc43-88e3-4b99-899d-27c298dfd51b" />

3. Configure the Function App:

   - **Hosting Plan:** Consumption
   - **Runtime Stack:** PowerShell
   - **Version:** PowerShell 7.2, or the highest compatible 7.x version available
   - **Region:** Choose an appropriate Azure region
   - **Storage:** Standard LRS storage

<img width="1915" height="611" alt="image" src="https://github.com/user-attachments/assets/4428c17b-701a-44e8-89a7-3b9dd589230d" />

<img width="1420" height="792" alt="image" src="https://github.com/user-attachments/assets/bffb98d9-8ec3-493f-b65d-2b913ee3524b" />

<img width="1037" height="817" alt="image" src="https://github.com/user-attachments/assets/15103c16-b57f-4c4c-97d5-c6470adbb407" />

4. Continue through **Hosting** and **Monitoring**.
5. Review the configuration.
6. Select **Create**.

<img width="1110" height="804" alt="image" src="https://github.com/user-attachments/assets/acc49a72-1c57-4ea1-b640-7b68d142c68c" />

<img width="1163" height="862" alt="image" src="https://github.com/user-attachments/assets/15f0a3d4-4017-4acb-968a-f7087f8c0698" />

---

### Step 4: Configure Azure Function App Environment Variables

Store application credentials in Azure Function App configuration rather than hard-coding them in scripts.

1. Open the new **Function App**.
2. Go to **Settings** → **Configuration** / **Environment variables**.
3. Add:

| Key | Value |
|---|---|
| `TENANT_ID` | Microsoft Entra Directory/Tenant ID |
| `CLIENT_ID` | App Registration Application/Client ID |
| `CLIENT_SECRET` | Client secret value |

> **Power Automate is now responsible for the Teams workflow endpoint.** The previous direct Teams webhook environment variable is no longer required by the updated architecture.

<img width="1923" height="862" alt="image" src="https://github.com/user-attachments/assets/6e00b455-83a1-47a7-8a69-ad2e8829114e" />

<img width="1651" height="837" alt="image" src="https://github.com/user-attachments/assets/e74effdc-786e-436b-9442-2fc960bbef16" />

<img width="1477" height="852" alt="image" src="https://github.com/user-attachments/assets/9390022d-a076-40c0-ba76-1afc600f4f9a" />

<img width="1706" height="725" alt="image" src="https://github.com/user-attachments/assets/379cb0dd-2e6d-474c-bb2d-dfb8f16ec70e" />

<img width="1647" height="816" alt="image" src="https://github.com/user-attachments/assets/9f23116d-4fb1-40aa-af09-8c0400d4eac0" />

<img width="1662" height="767" alt="image" src="https://github.com/user-attachments/assets/a7ac3900-f38f-46af-9a1c-60cebdf490ad" />

4. Click **Apply** / **Save**.

---

### Step 5: Create the Local Project Structure

Create the local PowerShell Azure Functions project.

<img width="792" height="895" alt="Screenshot 2026-09-08 100951" src="https://github.com/user-attachments/assets/10fa288e-17be-4e5b-9bdb-2e1b3fb63bff" />

Create a folder named:

```text
IdentityGovernanceBot
```

Open the folder in **Visual Studio Code**.

<img width="1250" height="660" alt="image" src="https://github.com/user-attachments/assets/74777dca-e2f9-43f4-90b3-f1427f4205be" />

Create this structure:

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

<img width="437" height="671" alt="image" src="https://github.com/user-attachments/assets/3a2864a9-e0a6-4ec0-bebb-ee97b7bb7b84" />

---

### Step 6: Configure Root Files

#### `host.json`

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

<img width="1522" height="712" alt="image" src="https://github.com/user-attachments/assets/346ce4cd-2c92-48a4-a02f-42b1752a9275" />

#### `requirements.psd1`

```powershell
@{
    'Az' = '10.*'
}
```

<img width="1335" height="717" alt="image" src="https://github.com/user-attachments/assets/e7b673b0-1c97-4d9a-af7b-1ca333c03a09" />

#### `profile.ps1`

```powershell
if ($env:MSI_SECRET) {
    Disable-AzContextAutosave -Scope Process | Out-Null
    Connect-AzAccount -Identity
}
```

<img width="1201" height="671" alt="image" src="https://github.com/user-attachments/assets/20769801-af40-4299-ab20-f9b99a2c8f25" />

---

### Step 7: Configure `IdentityAuditTimer`

`IdentityAuditTimer` is the daily detection engine.

#### `IdentityAuditTimer/function.json`

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

The schedule runs the function once per day at midnight according to the Function App's configured time basis.

<img width="1012" height="622" alt="image" src="https://github.com/user-attachments/assets/ac65183d-d795-463d-94ef-d21a00bccaf0" />

#### `IdentityAuditTimer/run.ps1`

The updated audit function uses **Power Automate instead of the deprecated direct Teams webhook/interactive HTTP card pattern**.

Set the Power Automate flow URL as an application setting:

```text
POWER_AUTOMATE_FLOW_URL
```

Then use:

```powershell
using namespace System.Net

param($Timer)

# 1. Read secure configuration
$TenantId = $env:TENANT_ID
$ClientId = $env:CLIENT_ID
$ClientSecret = $env:CLIENT_SECRET
$PowerAutomateFlowUrl = $env:POWER_AUTOMATE_FLOW_URL

if ([string]::IsNullOrWhiteSpace($TenantId) -or
    [string]::IsNullOrWhiteSpace($ClientId) -or
    [string]::IsNullOrWhiteSpace($ClientSecret) -or
    [string]::IsNullOrWhiteSpace($PowerAutomateFlowUrl)) {

    throw "Required application settings are missing."
}

# 2. Authenticate with Microsoft Graph using client credentials
$TokenBody = @{
    grant_type    = "client_credentials"
    scope         = "https://graph.microsoft.com/.default"
    client_id     = $ClientId
    client_secret = $ClientSecret
}

$TokenResponse = Invoke-RestMethod `
    -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" `
    -Method Post `
    -Body $TokenBody `
    -ContentType "application/x-www-form-urlencoded"

$Headers = @{
    Authorization = "Bearer $($TokenResponse.access_token)"
}

# 3. Calculate the 90-day inactivity cutoff
$CutoffDate = (Get-Date).ToUniversalTime().AddDays(-90)

# 4. Query guest accounts and sign-in activity
$GraphUrl = "https://graph.microsoft.com/v1.0/users?`$filter=userType eq 'Guest'&`$select=id,displayName,userPrincipalName,userType,signInActivity"

$Users = @(
    (Invoke-RestMethod `
        -Uri $GraphUrl `
        -Method Get `
        -Headers $Headers `
        -ErrorAction Stop).value
)

# 5. Identify dormant guest accounts
foreach ($User in $Users) {

    $LastSignIn = $null

    if ($User.signInActivity) {
        $LastSignIn = $User.signInActivity.lastSuccessfulSignInDateTime
    }

    $IsDormant = $false

    if ([string]::IsNullOrWhiteSpace($LastSignIn)) {
        $IsDormant = $true
    }
    else {
        try {
            $LastSignInDate = [DateTime]::Parse($LastSignIn).ToUniversalTime()

            if ($LastSignInDate -lt $CutoffDate) {
                $IsDormant = $true
            }
        }
        catch {
            Write-Warning "Could not parse sign-in date for $($User.userPrincipalName): $LastSignIn"
        }
    }

    if ($IsDormant) {

        # 6. Build the event consumed by Power Automate
        $Alert = @{
            id                = $User.id
            displayName       = $User.displayName
            userPrincipalName = $User.userPrincipalName
            violation         = "Dormant Guest Account (>90 Days Inactive)"
            action            = "disable"
        }

        $AlertJson = $Alert | ConvertTo-Json -Depth 5

        # 7. Send the identity event to Power Automate
        try {
            Invoke-RestMethod `
                -Uri $PowerAutomateFlowUrl `
                -Method Post `
                -ContentType "application/json" `
                -Body $AlertJson `
                -ErrorAction Stop

            Write-Output "Alert sent to Power Automate for $($User.userPrincipalName)"
        }
        catch {
            Write-Error "Failed to send Power Automate alert for $($User.userPrincipalName): $_"
        }
    }
}
```

<img width="1697" height="862" alt="image" src="https://github.com/user-attachments/assets/003ea6d5-2298-433f-9180-6ce04f407d72" />

> **Important:** The earlier `TEAMS_WEBHOOK_URL` / `TEAMS_WORKHOOK_URL` configuration and the old `Action.Http` Teams card are intentionally replaced by `POWER_AUTOMATE_FLOW_URL`.

---

### Step 8: Build the Microsoft Power Automate Workflow

Power Automate is the orchestration layer between the Azure audit function, Microsoft Teams, and the remediation Azure Function.

#### 8.1 Create the cloud flow

1. Open **Microsoft Power Automate**.
2. Select **Create** → **Automated cloud flow**.
3. Create the flow with the trigger:

   **When an HTTP request is received**

4. Configure the HTTP request JSON schema:

```json
{
  "type": "object",
  "properties": {
    "id": { "type": "string" },
    "displayName": { "type": "string" },
    "userPrincipalName": { "type": "string" },
    "violation": { "type": "string" },
    "action": { "type": "string" }
  }
}
```

5. Save the flow.
6. Copy the generated **HTTP POST URL**.
7. Store the URL in the Azure Function App configuration as:

```text
POWER_AUTOMATE_FLOW_URL
```

#### 8.2 Complete Power Automate workflow

```text
┌───────────────────────────────┐
│ When an HTTP request is       │
│ received                      │
└───────────────┬───────────────┘
                │
                ▼
┌───────────────────────────────┐
│ Read identity event payload   │
│ from IdentityAuditTimer       │
└───────────────┬───────────────┘
                │
                ▼
┌───────────────────────────────┐
│ Teams: Post adaptive card     │
│ in a chat or channel and      │
│ wait for a response           │
└───────────────┬───────────────┘
                │
                │ Remediate Account
                ▼
┌───────────────────────────────┐
│ Read Adaptive Card response   │
│ user_id + action              │
└───────────────┬───────────────┘
                │
                ▼
┌───────────────────────────────┐
│ HTTP POST                     │
│ /api/remediator               │
└───────────────┬───────────────┘
                │
                ▼
┌───────────────────────────────┐
│ IdentityRemediatorHttp        │
│ PATCH Microsoft Graph         │
│ accountEnabled = false        │
└───────────────┬───────────────┘
                │
                ▼
┌───────────────────────────────┐
│ Post confirmation to Teams    │
└───────────────────────────────┘
```

The updated architecture replaces the older direct Teams webhook / `Action.Http` approach. The Teams card uses `Action.Submit`; Power Automate receives the response and performs the HTTP call to `IdentityRemediatorHttp`.

#### 8.3 Configure the Microsoft Teams Adaptive Card

Add the Microsoft Teams action:

**Post adaptive card in a chat or channel and wait for a response**

Configure:

| Setting | Value |
|---|---|
| **Post as** | Flow bot |
| **Post in** | Channel |
| **Team** | `test` |
| **Channel** | `IT infrastructure operational` |

Use this Adaptive Card JSON:

```json
{
  "type": "AdaptiveCard",
  "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
  "version": "1.4",
  "body": [
    {
      "type": "TextBlock",
      "text": "🛡️ Identity Governance Alert",
      "weight": "Bolder",
      "size": "Medium",
      "color": "Attention"
    },
    {
      "type": "FactSet",
      "facts": [
        {
          "title": "Target User:",
          "value": "@{triggerBody()?['displayName']}"
        },
        {
          "title": "User Principal Name:",
          "value": "@{triggerBody()?['userPrincipalName']}"
        },
        {
          "title": "Violation:",
          "value": "@{triggerBody()?['violation']}"
        }
      ]
    }
  ],
  "actions": [
    {
      "type": "Action.Submit",
      "title": "Remediate Account",
      "data": {
        "user_id": "@{triggerBody()?['userPrincipalName']}",
        "action": "disable"
      }
    }
  ]
}
```

The critical response payload is:

```json
{
  "user_id": "...",
  "action": "disable"
}
```

#### 8.4 Add the remediation HTTP action

Immediately after **Post adaptive card in a chat or channel and wait for a response**, add the **HTTP** action.

Configure:

**Method**

```text
POST
```

**URI**

```text
https://<FunctionAppName>.azurewebsites.net/api/remediator
```

**Headers**

```text
Content-Type: application/json
```

**Body**

```json
{
  "user_id": "@{outputs('Post_adaptive_card_in_a_chat_or_channel_and_wait_for_a_response')?['body/data/user_id']}",
  "action": "@{outputs('Post_adaptive_card_in_a_chat_or_channel_and_wait_for_a_response')?['body/data/action']}"
}
```

> Power Automate may use a different internal action name. Prefer selecting **user_id** and **action** from the dynamic content produced by the Teams response action.

#### 8.5 Add the success confirmation

After the HTTP action, add:

**Microsoft Teams → Post message in a chat or channel**

Example:

```text
✅ Remediation Success
Account @{outputs('Post_adaptive_card_in_a_chat_or_channel_and_wait_for_a_response')?['body/data/user_id']} has been disabled.
```

The final action sequence is:

```text
1. When an HTTP request is received
2. Post adaptive card in a chat or channel and wait for a response
3. HTTP - POST /api/remediator
4. Post message in a chat or channel
```

#### 8.6 Add a remediation failure branch

Use **Configure run after** on the Teams confirmation action so that a separate failure message is posted when the HTTP remediation step **fails** or **times out**.

Example failure message:

```text
❌ Remediation Failed
The account remediation request could not be completed. Check the Power Automate run history and Azure Function logs.
```

Resulting logic:

```text
Adaptive Card response
        │
        ▼
HTTP /api/remediator
        │
        ├── Succeeded ──► Teams success message
        │
        └── Failed/Timed out ──► Teams failure message
```

#### 8.7 Validate the Power Automate workflow

1. Save the flow.
2. Confirm `POWER_AUTOMATE_FLOW_URL` is configured in the Azure Function App.
3. Run `IdentityAuditTimer`.
4. Confirm the Power Automate HTTP trigger receives the identity payload.
5. Confirm the Adaptive Card appears in **test → IT infrastructure operational**.
6. Select **Remediate Account**.
7. Confirm the Power Automate HTTP action calls `/api/remediator`.
8. Confirm `IdentityRemediatorHttp` returns success.
9. Confirm the Teams success message is posted.
10. Verify the account is disabled in Microsoft Entra ID.

#### 8.8 Validate using Power Automate run history

A successful run should show these stages:

```text
✓ HTTP trigger received
✓ Adaptive Card posted to Teams
✓ Remediate Account response received
✓ HTTP remediation request succeeded
✓ Teams confirmation posted
```

This makes the Power Automate run history the central audit trail for the workflow orchestration.

> **Security note:** In production, protect the remediation endpoint with appropriate authentication and authorization. Do not rely only on an exposed function URL for a privileged identity-management operation.

### Step 9: Configure `IdentityRemediatorHttp`

This function receives the approved action from Power Automate and applies the account change through Microsoft Graph.

#### `IdentityRemediatorHttp/function.json`

```json
{
  "bindings": [
    {
      "authLevel": "function",
      "type": "httpTrigger",
      "direction": "in",
      "name": "Request",
      "methods": [
        "post"
      ],
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

<img width="1681" height="767" alt="image" src="https://github.com/user-attachments/assets/6d180985-b5e0-40af-a247-1c699f81fd1b" />

#### `IdentityRemediatorHttp/run.ps1`

```powershell
using namespace System.Net

param($Request, $TriggerMetadata)

# 1. Read the request body sent by Power Automate
$RequestBody = $Request.Body

if ($RequestBody -is [string]) {
    try {
        $RequestBody = $RequestBody | ConvertFrom-Json -ErrorAction Stop
    }
    catch {
        Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = [HttpStatusCode]::BadRequest
            Body       = (@{
                success = $false
                error   = "Invalid JSON request body."
            } | ConvertTo-Json)
            Headers    = @{
                "Content-Type" = "application/json"
            }
        })
        return
    }
}

$UserId = $RequestBody.user_id
$Action = $RequestBody.action

if ([string]::IsNullOrWhiteSpace($UserId) -or
    [string]::IsNullOrWhiteSpace($Action)) {

    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::BadRequest
        Body       = (@{
            success = $false
            error   = "user_id and action are required."
        } | ConvertTo-Json)
        Headers    = @{
            "Content-Type" = "application/json"
        }
    })
    return
}

# 2. Only allow the remediation action explicitly supported by this function
if ($Action -ne "disable") {

    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::BadRequest
        Body       = (@{
            success = $false
            error   = "Unsupported remediation action."
        } | ConvertTo-Json)
        Headers    = @{
            "Content-Type" = "application/json"
        }
    })
    return
}

# 3. Acquire a Microsoft Graph application token
$TokenBody = @{
    grant_type    = "client_credentials"
    scope         = "https://graph.microsoft.com/.default"
    client_id     = $env:CLIENT_ID
    client_secret = $env:CLIENT_SECRET
}

try {

    $TokenResponse = Invoke-RestMethod `
        -Uri "https://login.microsoftonline.com/$($env:TENANT_ID)/oauth2/v2.0/token" `
        -Method Post `
        -Body $TokenBody `
        -ContentType "application/x-www-form-urlencoded" `
        -ErrorAction Stop

    $Headers = @{
        Authorization  = "Bearer $($TokenResponse.access_token)"
        "Content-Type" = "application/json"
    }

    # 4. Disable the target Entra ID account
    $PatchUrl = "https://graph.microsoft.com/v1.0/users/$UserId"

    $PatchBody = @{
        accountEnabled = $false
    } | ConvertTo-Json

    Invoke-RestMethod `
        -Uri $PatchUrl `
        -Method Patch `
        -Headers $Headers `
        -Body $PatchBody `
        -ErrorAction Stop

    # 5. Return success to Power Automate
    $ResponseBody = @{
        success = $true
        user_id = $UserId
        action  = "disable"
        message = "Account disabled successfully."
    } | ConvertTo-Json

    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $ResponseBody
        Headers    = @{
            "Content-Type" = "application/json"
        }
    })
}
catch {

    $ErrorBody = @{
        success = $false
        user_id = $UserId
        action  = $Action
        error   = $_.Exception.Message
    } | ConvertTo-Json

    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::InternalServerError
        Body       = $ErrorBody
        Headers    = @{
            "Content-Type" = "application/json"
        }
    })
}
```

<img width="1530" height="780" alt="image" src="https://github.com/user-attachments/assets/3b7fd99f-e86c-4326-af84-118a33952135" />

---

## 🔐 Important Remediation Security Note

The HTTP endpoint performs a privileged directory operation. For a production implementation, do not treat a publicly reachable function URL as sufficient authorization by itself.

Recommended controls include:

- Protect the HTTP-triggered function with appropriate authentication.
- Keep Graph permissions limited to what the application actually needs.
- Avoid exposing the Function App URL unnecessarily.
- Validate the incoming action and target user.
- Add logging and monitoring around every remediation.
- Consider additional approval and authorization controls for privileged environments.
- Use managed identity / Key Vault-based secret handling where appropriate for production deployments.

The portfolio implementation demonstrates the automation flow; enterprise deployments should harden the HTTP boundary before allowing production remediation.

---

## Step 10: Deploy the Functions with VS Code

### Part 1: Install Required Extensions

1. Open **Visual Studio Code**.
2. Open Extensions (`Ctrl+Shift+X`).
3. Install:

   - **Azure Resources**
   - **Azure Functions**

<img width="967" height="1012" alt="image" src="https://github.com/user-attachments/assets/2e738129-ef7e-4336-8003-7af9a7573daa" />

### Part 2: Sign in to Azure

1. Click the **Azure** icon in the VS Code Activity Bar.
2. Select **Sign in to Azure...**
3. Complete browser authentication.
4. Return to VS Code.

### Part 3: Deploy

1. Open the **Resources** section.
2. Expand the Azure subscription.
3. Locate the target **Function App**.
4. Right-click the Function App.
5. Select **Deploy to Function App...**

<img width="709" height="997" alt="image" src="https://github.com/user-attachments/assets/c94628a1-aa60-467b-a0aa-6501524668d9" />

6. Select the `IdentityGovernanceBot` project folder.
7. Confirm the deployment.

<img width="1123" height="995" alt="Screenshot 2026-09-08 153400" src="https://github.com/user-attachments/assets/4b6107c2-aac8-4d78-bdb8-b6fa147a91e1" />

### Part 4: Verify Deployment

Wait for VS Code to display:

```text
Deployment successful
```

Then verify that both functions appear in the Azure Function App:

```text
IdentityAuditTimer
IdentityRemediatorHttp
```

---

## Step 11: Configure the Power Automate Flow URL

After saving the Power Automate flow:

1. Open the flow.
2. Open the **When an HTTP request is received** trigger.
3. Copy its generated HTTP POST URL.
4. Open Azure Portal → **Function App** → **Configuration**.
5. Add/update:

```text
POWER_AUTOMATE_FLOW_URL = <Power Automate HTTP trigger URL>
```

6. Save the configuration.
7. Restart/reload the Function App if required.

> Do not place the Power Automate URL directly into source code if you can avoid it. Store it as an application setting.

---

## Step 12: Push the Project to GitHub

### `.gitignore`

Create a `.gitignore` file in the project root:

```text
local.settings.json
```

You may also exclude other local secret/configuration files as appropriate.

### Publish from VS Code

1. Open **Source Control** (`Ctrl+Shift+G`).
2. Select **Initialize Repository**.
3. Commit the project.
4. Select **Publish Branch**.
5. Choose **Publish to GitHub**.
6. Use a clear repository name such as:

```text
Autonomous-Identity-Access-Governance-Bot
```

### ⚠️ Never commit secrets

Never upload:

```text
local.settings.json
```

Never commit:

- Client secrets
- Access tokens
- Passwords
- Private keys
- Power Automate URLs containing sensitive access information

---

## 🧪 Step 13: End-to-End Validation

The following test validates the complete detection → Teams → Power Automate → remediation → confirmation chain.

### Part 1: Create a Test Guest

1. Open the **Microsoft Entra Admin Center**.
2. Go to **Identity** → **Users** → **All users**.
3. Select **+ New user**.
4. Select **Invite external user**.
5. Configure a test guest:

   - Display name: `Test Dormant Guest`
   - User type: `Guest`
   - Email: a test external account

<img width="1560" height="850" alt="image" src="https://github.com/user-attachments/assets/78248f76-aa9d-4bcc-acbc-df588a294115" />

6. Send the invitation.

<img width="1607" height="856" alt="image" src="https://github.com/user-attachments/assets/5afcc4a8-c653-482a-9114-83bc45d85083" />

The audit logic treats an account with no successful sign-in value as dormant.

---

### Part 2: Manually Trigger the Audit

1. Open the **Azure Portal**.
2. Open the **Function App**.
3. Go to **Functions**.
4. Select:

   ```text
   IdentityAuditTimer
   ```

<img width="1922" height="855" alt="image" src="https://github.com/user-attachments/assets/68c18729-3d4a-4f2b-a937-ca860e3867a8" />

5. Select **Code + Test**.
6. Select **Test/Run**.
7. Run the function with an empty request body.

<img width="1917" height="929" alt="image" src="https://github.com/user-attachments/assets/59586fc8-3582-4d13-ab84-d25c9aaa067c" />

8. Check the logs.

Expected sequence:

```text
Graph authentication succeeds
        ↓
Guest users queried
        ↓
Dormant guest identified
        ↓
Power Automate HTTP trigger called
        ↓
Adaptive Card posted to Teams
```

<img width="1461" height="192" alt="image" src="https://github.com/user-attachments/assets/3fadf3e7-54ae-4eb7-a7da-1a2c06b72117" />

---

### Part 3: Verify the Teams Adaptive Card

Open the Teams channel configured in Power Automate.

The card should contain:

- **🛡️ Identity Governance Alert**
- Target User
- User Principal Name
- Violation
- **Remediate Account** button

Example:

```text
🛡️ Identity Governance Alert

Target User: Test Dormant Guest
User Principal Name: test@example.com
Violation: Dormant Guest Account (>90 Days Inactive)

[ Remediate Account ]
```

---

### Part 4: Execute Remediation

1. Click **Remediate Account**.
2. Power Automate receives the Adaptive Card response.
3. The HTTP action sends:

```json
{
  "user_id": "test@example.com",
  "action": "disable"
}
```

4. `IdentityRemediatorHttp` authenticates to Microsoft Graph.
5. Microsoft Graph updates:

```json
{
  "accountEnabled": false
}
```

6. The function returns a success response.
7. Power Automate posts the confirmation to Teams.

Expected confirmation:

```text
✅ Remediation Success: Account test@example.com disabled.
```

---

### Part 5: Verify the Entra ID Account State

1. Return to **Microsoft Entra Admin Center**.
2. Go to **Identity** → **Users** → **All users**.
3. Open the test guest account.
4. Check the account status.

Expected state:

```text
Account Enabled: No
```

This confirms the complete remediation path worked.

---

## 🔎 Troubleshooting

### 1. Function reports a missing `Timer` binding

Make sure `IdentityAuditTimer/run.ps1` starts with:

```powershell
param($Timer)
```

The `function.json` binding name must match the parameter name:

```json
"name": "Timer"
```

---

### 2. Power Automate does not receive the audit event

Check:

- `POWER_AUTOMATE_FLOW_URL` is configured correctly.
- The HTTP trigger flow is saved and enabled.
- The Function App has outbound network access.
- Application Insights / Function logs show the HTTP request.
- The Power Automate run history shows the trigger attempt.

---

### 3. Teams card appears but the button is missing

Check the Power Automate Teams action and make sure:

- The action is **Post adaptive card in a chat or channel and wait for a response**.
- The card is valid Adaptive Card JSON.
- The `actions` array is inside the Adaptive Card.
- The action uses:

```json
{
  "type": "Action.Submit",
  "title": "Remediate Account",
  "data": {
    "user_id": "...",
    "action": "disable"
  }
}
```

Do not use the previous direct Teams `Action.Http` approach for this updated architecture.

---

### 4. Power Automate HTTP action fails

Check:

- Function URL is correct.
- Route is:

```text
/api/remediator
```

- Method is `POST`.
- Header contains:

```text
Content-Type: application/json
```

- Request body contains both:

```json
{
  "user_id": "...",
  "action": "disable"
}
```

---

### 5. Microsoft Graph returns authorization errors

Verify:

- `TENANT_ID` is correct.
- `CLIENT_ID` is correct.
- `CLIENT_SECRET` is valid.
- `User.ReadWrite.All` is granted.
- `AuditLog.Read.All` is granted.
- Admin consent has been granted.

---

### 6. `signInActivity` is empty

An empty `lastSuccessfulSignInDateTime` is treated by the audit logic as a potentially dormant/never-used guest account.

If the tenant does not provide the required sign-in activity data, adjust the detection logic rather than assuming every missing value represents inactivity.

---

### 7. PowerShell parsing errors

Before deploying, verify:

- Every `{` has a matching `}`.
- Every `(` has a matching `)`.
- JSON strings use valid escaping.
- No accidental text exists inside PowerShell property assignments.
- The script is actually deployed to the intended Function App.
- The Function App runtime is PowerShell 7.2 / compatible PowerShell 7.x.

---

## 🔐 Security Considerations

### Secrets

Never commit:

```text
local.settings.json
```

Store secrets in Azure configuration or, for production, use a dedicated secret-management solution such as Azure Key Vault.

### Graph permissions

The application uses privileged Graph permissions. Keep the permission set as small as practical and periodically review whether every permission is still required.

### Remediation authorization

Disabling an account is a privileged operation. Production deployments should authenticate and authorize the remediation caller rather than relying solely on an exposed function endpoint.

### Auditability

Every remediation should be traceable through:

- Azure Function logs
- Power Automate run history
- Microsoft Graph activity
- Teams confirmation messages

---

## 📦 Project Structure

```text
IdentityGovernanceBot/
│
├── host.json
├── profile.ps1
├── requirements.psd1
│
├── IdentityAuditTimer/
│   ├── function.json
│   └── run.ps1
│
├── IdentityRemediatorHttp/
│   ├── function.json
│   └── run.ps1
│
└── .gitignore
```

---

## 🎯 Detection and Remediation Logic

### Detection

```text
Guest User
   ↓
Read signInActivity
   ↓
No successful sign-in?
   ├── Yes → Flag
   └── No
        ↓
Last successful sign-in older than 90 days?
   ├── Yes → Flag
   └── No → Ignore
```

### Remediation

```text
Teams button
   ↓
Power Automate
   ↓
POST /api/remediator
   ↓
Validate action
   ↓
Microsoft Graph PATCH
   ↓
accountEnabled = false
   ↓
Success response
   ↓
Teams confirmation
```

---

## 🚀 Deployment Checklist

Before considering the project complete:

- [ ] Entra ID App Registration created
- [ ] Tenant ID copied
- [ ] Client ID copied
- [ ] Client secret created securely
- [ ] Graph Application permissions configured
- [ ] Admin consent granted
- [ ] Azure Function App created
- [ ] PowerShell 7.2 configured
- [ ] `TENANT_ID` configured
- [ ] `CLIENT_ID` configured
- [ ] `CLIENT_SECRET` configured
- [ ] Power Automate HTTP trigger created
- [ ] `POWER_AUTOMATE_FLOW_URL` configured
- [ ] Teams Adaptive Card configured
- [ ] `IdentityAuditTimer` deployed
- [ ] `IdentityRemediatorHttp` deployed
- [ ] `.gitignore` created
- [ ] `local.settings.json` excluded
- [ ] Test guest account created
- [ ] Audit manually triggered
- [ ] Teams alert verified
- [ ] **Remediate Account** button verified
- [ ] Power Automate HTTP action verified
- [ ] Account disabled successfully
- [ ] Teams confirmation verified
- [ ] Entra ID account state verified

---

## ✨ Project Outcome

This implementation demonstrates an end-to-end identity governance workflow using:

**Microsoft Entra ID → Microsoft Graph → Azure Functions → Power Automate → Microsoft Teams → Azure Functions → Microsoft Graph**

The updated architecture replaces the previous direct Teams webhook / `Action.Http` remediation approach with **Power Automate Adaptive Card response handling**, keeping the Teams interaction and remediation orchestration inside the Power Automate workflow.

The result is a practical portfolio project demonstrating:

- Cloud identity governance
- Microsoft Graph API integration
- Serverless PowerShell automation
- Event-driven security workflows
- Microsoft Teams Adaptive Cards
- Power Automate orchestration
- Automated account remediation
- Zero-trust and least-privilege concepts
- Azure deployment and GitHub source control

---

## 📄 Portfolio / GitHub Notes

For a public portfolio repository:

1. Keep the README updated with the actual architecture.
2. Do not publish credentials or private tenant information.
3. Keep screenshots that demonstrate configuration and successful execution.
4. Include a clear workflow diagram.
5. Explain the separation between detection, approval/action, and remediation.
6. Include the troubleshooting section so reviewers can understand how deployment issues were diagnosed.

The existing project screenshots are retained throughout this README to preserve the original implementation evidence.


## 📷 Preserved Project Screenshots

<img width="1895" height="550" alt="image" src="https://github.com/user-attachments/assets/f783f171-ea2c-4962-81f0-1d0fdd779965" />

<img width="867" height="817" alt="image" src="https://github.com/user-attachments/assets/4c96ea96-2b29-481b-9bf6-6f2d904ef2d7" />

<img width="1835" height="697" alt="image" src="https://github.com/user-attachments/assets/6e56292d-0a9a-4a3d-b1fb-0f53f08f3b19" />

<img width="975" height="761" alt="image" src="https://github.com/user-attachments/assets/beb17b88-2ebd-4c84-ac6a-5a219e47d2ef" />

<img width="977" height="727" alt="image" src="https://github.com/user-attachments/assets/06c3836f-43f2-4b13-9068-aeccf57a680a" />

<img width="987" height="766" alt="image" src="https://github.com/user-attachments/assets/1ab080bd-ae1f-4ce0-b4e8-929a5db1b8ae" />

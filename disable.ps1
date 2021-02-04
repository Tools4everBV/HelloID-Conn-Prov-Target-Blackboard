#2021-02-04
$config = ConvertFrom-Json $configuration;
 
#Initialize default properties
$success = $False;
$p = $person | ConvertFrom-Json
$aRef = $accountReference | ConvertFrom-Json;
$auditMessage = " not disabled successfully";

$account = @{
    available = "false"
};

try
{
    #Build access token request
    $requestUri = "$($config.domain)/learn/api/public/v1/oauth2/token";
        
    $headers = @{
		'Authorization' = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $config.appKey,$config.secret)))
		'Accept' = 'application/JSON'
		'Content-Type' = 'application/x-www-form-urlencoded'
	};	
	$body = "grant_type=client_credentials";
	
    #Request access token
    $response = Invoke-RestMethod -Method Post -Uri $requestUri -Headers $headers -Body $body -Verbose:$false;
    $accessToken = $response.access_token;
    
    #Add the authorization header to the request
    $authorization = @{
        Authorization = "Bearer $accesstoken";
        'Content-Type' = "application/json";
        Accept = "application/json";
    };

        
    if(-Not($dryRun -eq $True)) {
        $body = $account | ConvertTo-Json -Depth 10
        $response = Invoke-RestMethod -Uri "$($config.domain)/learn/api/public/v1/users/$aRef" -Method PATCH -Headers $authorization -Body $body -Verbose:$false
        $aRef = $response.id
    }

    $success = $True;
    $auditMessage = " successfully"; 
} catch {
    $auditMessage = " : General error $($_)";
    Write-Error -Verbose $_;
}

#build up result
$result = [PSCustomObject]@{
    Success= $success;
    AccountReference= $aRef;
    AuditDetails=$auditMessage;
    Account= $account;
};

Write-Output $result | ConvertTo-Json -Depth 10;
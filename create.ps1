#2021-02-03
$config = ConvertFrom-Json $configuration;
 
#Initialize default properties
$success = $False;
$p = $person | ConvertFrom-Json
$auditMessage = "Account for person $($p.DisplayName) not created successfully";
 
#Generate random password for user
$password = [System.Web.Security.Membership]::GeneratePassword(10, 0); ##Method doesn't work with cloud agent. See https://github.com/Tools4everBV/HelloID-Conn-Prov-HelperFunctions/blob/master/PowerShell/Algorithms/password.random.cloudagent.ps1

#Change mapping here
#For all of the supported attributes visit https://developer.blackboard.com/portal/displayApi and scroll to users > POST /learn/api/public/v1/users
$account = @{
    externalId = $p.ExternalId
    username = $p.Username
    password = $password
    name = @{
        given = $p.Name.NickName
        family = $p.Name.FamilyName
    }
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
        $response = Invoke-RestMethod -Uri "$($config.domain)/learn/api/public/v1/users" -Method POST -Headers $authorization -Body $body -Verbose:$false
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

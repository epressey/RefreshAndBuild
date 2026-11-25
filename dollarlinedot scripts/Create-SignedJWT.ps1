#important details, the same used for connect-MgGraph
$clientId = "{your app registration's application ID}" #application (or client) ID from app registration in Entra
$tenantId = "{your tenant ID}" #tenant ID from app registration in Entra (or from Entra properties page)
$certificateName = "CN=PowerShell App-Only" #or your certificates CommonName (CN)

#actions with the certificate
$certificate = Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.subject -eq $certificateName} #find the certificate in our machine's certificate store with the CommonName (CN)
$certificateHash = $certificate.GetCertHash([System.Security.Cryptography.HashAlgorithmName]::SHA256) #create a hash of the certificate using the 'SHA256' algorithm
$base64CertificateHash = [System.Convert]::ToBase64String($certificateHash) #convert the SHA256 hash value we created to base64
$safeBase64CertificateHash = $base64CertificateHash -replace '\+', '-' -replace '/', '_' -replace '=' #remove characters to ensure safe encoding for web

#build the JWT header - describes the token to the identity systems
$header = @{
    'alg' = "PS256" #the algorithm used to sign the JWT (which we will be doing later)
    'typ' = "JWT" #the type of token we are passing
    'x5t#S256' = $safeBase64CertificateHash #the base64 encoded hash we built from our certificate earlier
}

#set a timestamp
$timeNow = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()

#built the JWT payload - describes who we are and what we want to do to the identity systems
$payload = @{  
    aud = "https://login.microsoftonline.com/$($tenantId)/oauth2/v2.0/token" #the 'audience', which tenant and endpoint (oauth2 in this case) we want to direct the request to
    iss = $clientId #the 'issuer', our app registration in Entra, the certificate uploaded there will be checked against the certificate we are referring to in our JWT
    sub = $clientId #the 'subject', the identity the token is about (i.e. our app registration in Entra)
    jti = [guid]::NewGuid().ToString() #JWT ID - a new guid to track the request, this is a unique ID we come up with randomly in Powershell, and is carried through with the request to the identity system  
    nbf = $timeNow #not before, the token is not valid before the time we specify, we need to be explicit (this is best practise for security)
    exp = $timeNow + 600 #expiration time, the token is not valid after the time we specify, we need to by explicit (this is best practise for security), 600 seconds is 10 minutes
}

#convert header and payload from hashtables to JSON text, then to UTF8 (for byte format), which can then be converted into base64
$headerBase64  = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(($header  | ConvertTo-Json -Compress)))
$payloadBase64 = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(($payload | ConvertTo-Json -Compress)))

#remove unsafe characters from both payloads (which are now base64)
$headerBase64  = $headerBase64  -replace '\+', '-' -replace '/', '_' -replace '='
$payloadBase64 = $payloadBase64 -replace '\+', '-' -replace '/', '_' -replace '='

#combine the base64-encoded header and payload with "." to create an unsigned JWT
$unsignedJWT = $headerBase64 + "." + $payloadBase64

#get a reference to the private key of our certificate on our machine, we use the $certificate variable we set earlier to retrieve this
$rsa = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($certificate)

#sign the combined JWT text: SHA-256 hash with PSS padding (PS256)
$signatureBytes = $rsa.SignData(
    [System.Text.Encoding]::UTF8.GetBytes($unsignedJWT),
    [System.Security.Cryptography.HashAlgorithmName]::SHA256,
    [System.Security.Cryptography.RSASignaturePadding]::Pss
)

#base64-encode the signature, and remove unsafe characters
$encodedSignature = [System.Convert]::ToBase64String($signatureBytes) -replace '\+', '-' -replace '/', '_' -replace '='

#and finally, append the encoded signature to the unsigned JWT - making it a fully signed JWT
$jwt = "$unsignedJWT.$encodedSignature"

#create the body to make the request to the Microsoft Identity Platform, we need to tell it some more identifying information about the call generally, such as the grant type
$body = @{
    client_id             = $clientId #app registration client ID, which we set earlier
    scope                 = "https://graph.microsoft.com/.default" #this can be amended, the scope can change depending on where you want to have access to in the Graph API (it's a large ecosystem at this point), the app registration will also need to have these permissions applied in Entra
    client_assertion_type = "urn:ietf:params:oauth:client-assertion-type:jwt-bearer" #as defined by documentation
    client_assertion      = $jwt #signed JWT
    grant_type            = "client_credentials" #as defined by documentation
}

#we then make a call to get an access token from the Microsoft Identity Platform
$tokenResponse = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$($tenantId)/oauth2/v2.0/token" -Body $body -ContentType "application/x-www-form-urlencoded" -verbose

#build the header hashtable to store authentication information, including the access token
$headers = @{
  "Content-Type" = "application/json"
  "Authorization" = "Bearer $($tokenResponse.access_token)"
}

#make a call to the Graph API with the access token in our headers variable
Invoke-RestMethod -Method Get -Uri "https://graph.microsoft.com/v1.0/users" -Headers $headers

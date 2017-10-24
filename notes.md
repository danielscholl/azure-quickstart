# Integrated Windows Auth in Docker Container Notes

These are instructions on how to setup infrastructure to support creating containers with Active Directory Support.

This procedure makes use of Group Managed Service Accounts [gMSA][]

## PreRequisites

1.  Active Directory IaaS setup and functioning
2.  Container Host Server setup and joined to the Domain


## Active Directory Additional Setup

#### Create a KDS Root Key

```powershell
Import-Module ActiveDirectory
Add-KdsRootKey -EffectiveTime ((get-date).addhours(-10));
```

#### Create a Global Security Group _"Container Hosts"_ 

```powershell
$AD_GROUP_NAME = "Container Hosts"
$GROUP = Get-ADGroup -Identity $AD_GROUP_NAME -ErrorAction SilentlyContinue
if (!$GROUP) {
  $GROUP = New-ADGroup –name $AD_GROUP_NAME –groupscope Global
}
```

#### Create a GMSA account in Active Directory

_**This assumes an active directory domain called 'my.local'_
```powershell
$DOMAIN = "my.local"
$ACCOUNT_NAME = 'containerhost'
$ACCOUNT = Get-ADServiceAccount -Filter "Name -like '$ACCOUNT_NAME'" -ErrorAction SilentlyContinue
if (!$ACCOUNT) {
    New-ADServiceAccount -Name $ACCOUNT_NAME `
        -DNSHostName $DOMAIN `
        -PrincipalsAllowedToRetrieveManagedPassword "Domain Controllers", "domain admins", $GROUP.DistinguishedName `
        -KerberosEncryptionType RC4, AES128, AES256
}
```

#### Add the GMSA Account to Docker Host Servers

1. Open Active Directory Admin Center
2. Select the containerhost account and click on properties
3. Select security and click on add
4. Select only Computers as the Object Type
5. Select Advanced to find the the servers that will be container hosts and add them

#### Reboot ALL Servers (AD and ContainerHosts)

```powershell
Restart-Computer -Force
```


#### Set the Service Account

```powershell
$HOSTNAMES = 'MY-JUMPBOX$'
Set-ADServiceAccount -Identity $ACCOUNT_NAME -PrincipalsAllowedToRetrieveManagedPassword $HOSTNAMES
```

## Container Hosts

#### Install Docker on ContainerHost Machine

```powershell
Install-PackageProvider -Name NuGet -Force
Install-Module -Name DockerMsftProvider -Force 
Install-Package -Name docker -ProviderName DockerMsftProvider -Force 
```

#### Reboot the Container Host Servers

```powershell
Restart-Computer -Force
```

#### Enable AD Features

```powershell
Enable-WindowsOptionalFeature -FeatureName ActiveDirectory-Powershell -online -all
```

#### Add the ServiceAccount to the ContainerHost

```powershell
$ACCOUNT_NAME = "containerhost"
$ACCOUNT = Get-ADServiceAccount -Identity $ACCOUNT_NAME -ErrorAction SilentlyContinue
if ($ACCOUNT) {
    Install-ADServiceAccount -Identity $ACCOUNT_NAME
}
Test-AdServiceAccount -Identity $ACCOUNT_NAME
```

#### Create a Credential Spec

```powershell
Invoke-WebRequest "https://raw.githubusercontent.com/Microsoft/Virtualization-Documentation/live/windows-server-container-tools/ServiceAccounts/CredentialSpec.psm1" -UseBasicParsing -OutFile $env:TEMP\cred.psm1
Import-Module $env:temp\cred.psm1
New-CredentialSpec -Name my-jumpbox -AccountName $ACCOUNT_NAME

#This will return location and name of JSON file
Get-CredentialSpec
```


#### Test a Container

```powershell
docker pull microsoft/windowsservercore
docker run -it --security-opt "credentialspec=file://Gmsa.json" microsoft/windowsservercore nltest /parentdomain

docker run -d -h containerhost --security-opt "credentialspec=file://my-jumpbox.json" -p 8888:80 artisticcheese/winauth:nano-iis
```


#### Set the SPN

```powershell
setspn -c -s HTTP/my-jumpbox my\my-jumpbox
setspn -c -s HTTP/my-jumpbox.my.local my\my-jumpbox
```

#### Run the Container

```powershell
docker run -it --name infoApp -h my-jumpbox -p 8000:80 --security-opt "credentialspec=file://my-jumpbox.json" microsoft/winsowservercore:latest
```


# Manage IIS on a Container

1. Start up a container with a dotnet-framework base.

 `docker run -it --name IISServer -h my-jumpbox --security-opt "credentialspec=file://my-jumpbox.json" -v c:\shared:c:\shared microsoft/dotnet-framework:4.6.2 powershell`

2. Install IIS + IIS Management

`Install-WindowsFeature -name Web-Server -IncludeManagementTools`

3. Install IIS Management Service

`Dism /online /enable-feature /featurename:IIS-ManagementService /all`

4. Enable Remote Access

`New-ItemProperty -Path HKLM:\software\microsoft\WebManagement\Server -Name EnableRemoteManagement -Value 1 -Force`

5. Install any desired Web Modules

```powershell
Import-Module Dism

Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServer
Enable-WindowsOptionalFeature -Online -FeatureName IIS-CommonHttpFeatures
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpErrors
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpRedirect
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationDevelopment
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HealthAndDiagnostics
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpLogging
Enable-WindowsOptionalFeature -Online -FeatureName IIS-LoggingLibraries
Enable-WindowsOptionalFeature -Online -FeatureName IIS-RequestMonitor
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpTracing
Enable-WindowsOptionalFeature -Online -FeatureName IIS-Security
Enable-WindowsOptionalFeature -Online -FeatureName IIS-URLAuthorization
Enable-WindowsOptionalFeature -Online -FeatureName IIS-RequestFiltering
Enable-WindowsOptionalFeature -Online -FeatureName IIS-IPSecurity
Enable-WindowsOptionalFeature -Online -FeatureName IIS-Performance
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpCompressionDynamic
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerManagementTools
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WindowsAuthentication
Enable-WindowsOptionalFeature -Online -FeatureName IIS-StaticContent
Enable-WindowsOptionalFeature -Online -FeatureName IIS-DefaultDocument
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET45
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASP
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIExtensions
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIFilter
Enable-WindowsOptionalFeature -Online -FeatureName IIS-CustomLogging
Enable-WindowsOptionalFeature -Online -FeatureName IIS-BasicAuthentication
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpCompressionStatic
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementConsole
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementService
```





[gMSA]: https://blogs.technet.microsoft.com/askpfeplat/2012/12/16/windows-server-2012-group-managed-service-accounts/
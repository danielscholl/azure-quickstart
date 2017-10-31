# This script installs IIS and the features required to run asp.net applications


Install-WindowsFeature -name Web-Server -IncludeManagementTools

Dism /online /enable-feature /featurename:IIS-ManagementService /all
New-ItemProperty -Path HKLM:\software\microsoft\WebManagement\Server -Name EnableRemoteManagement -Value 1 -Force


Enable-WindowsOptionalFeature -Online -All -FeatureName IIS-WebServerRole
Enable-WindowsOptionalFeature -Online -All -FeatureName IIS-WebServer
Enable-WindowsOptionalFeature -Online -All -FeatureName IIS-CommonHttpFeatures
Enable-WindowsOptionalFeature -Online -All -FeatureName IIS-HttpErrors
Enable-WindowsOptionalFeature -Online -All -FeatureName IIS-HttpRedirect
Enable-WindowsOptionalFeature -Online -All -FeatureName IIS-ApplicationDevelopment
Enable-WindowsOptionalFeature -Online -All -FeatureName IIS-NetFxExtensibility45
Enable-WindowsOptionalFeature -Online -All -FeatureName IIS-HealthAndDiagnostics
Enable-WindowsOptionalFeature -Online -All -FeatureName IIS-HttpLogging
Enable-WindowsOptionalFeature -Online -All -FeatureName IIS-LoggingLibraries
Enable-WindowsOptionalFeature -Online -All -FeatureName IIS-RequestMonitor
Enable-WindowsOptionalFeature -Online -All -FeatureName IIS-HttpTracing
Enable-WindowsOptionalFeature -Online -All -FeatureName IIS-Security
Enable-WindowsOptionalFeature -Online -All -FeatureName IIS-RequestFiltering
Enable-WindowsOptionalFeature -Online -All -FeatureName IIS-Performance
Enable-WindowsOptionalFeature -Online -All -FeatureName IIS-WebServerManagementTools
Enable-WindowsOptionalFeature -Online -All -FeatureName IIS-IIS6ManagementCompatibility
Enable-WindowsOptionalFeature -Online -All -FeatureName IIS-Metabase
Enable-WindowsOptionalFeature -Online -All -FeatureName IIS-ManagementConsole
Enable-WindowsOptionalFeature -Online -All -FeatureName IIS-BasicAuthentication
Enable-WindowsOptionalFeature -Online -All -FeatureName IIS-WindowsAuthentication
Enable-WindowsOptionalFeature -Online -All -FeatureName IIS-StaticContent
Enable-WindowsOptionalFeature -Online -All -FeatureName IIS-DefaultDocument
Enable-WindowsOptionalFeature -Online -All -FeatureName IIS-WebSockets
Enable-WindowsOptionalFeature -Online -All -FeatureName IIS-ApplicationInit
Enable-WindowsOptionalFeature -Online -All -FeatureName IIS-NetFxExtensibility45
Enable-WindowsOptionalFeature -Online -All -FeatureName IIS-ASPNET45
Enable-WindowsOptionalFeature -Online -All -FeatureName IIS-ISAPIExtensions
Enable-WindowsOptionalFeature -Online -All -FeatureName IIS-ISAPIFilter
Enable-WindowsOptionalFeature -Online -All -FeatureName IIS-HttpCompressionStatic

net stop Iisadmin
net stop W3svc
net stop wmsvc

net start Iisadmin
net start W3svc
net start wmsvc

net user azureuser Password1! /ADD
net localgroup administrators azureuser /add
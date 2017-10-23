Configuration AppServer {

  Import-DscResource -ModuleName xPendingReboot
  Import-DscResource -ModuleName xPSDesiredStateConfiguration

  $features = @(
    @{Name = "Web-Server"; Ensure = "Present"},
    @{Name = "Web-WebServer"; Ensure = "Present"},
    @{Name = "Web-Common-http"; Ensure = "Present"},
    @{Name = "Web-Default-Doc"; Ensure = "Present"},
    @{Name = "Web-Dir-Browsing"; Ensure = "Present"},
    @{Name = "Web-Http-Errors"; Ensure = "Present"},
    @{Name = "Web-Static-Content"; Ensure = "Present"},
    @{Name = "Web-Health"; Ensure = "Present"},
    @{Name = "Web-Http-Logging"; Ensure = "Present"},
    @{Name = "Web-Performance"; Ensure = "Present"},
    @{Name = "Web-Stat-Compression"; Ensure = "Present"},
    @{Name = "Web-Dyn-Compression"; Ensure = "Present"},
    @{Name = "Web-Security"; Ensure = "Present"},
    @{Name = "Web-Filtering"; Ensure = "Present"},
    @{Name = "Web-Basic-Auth"; Ensure = "Present"},
    @{Name = "Web-Windows-Auth"; Ensure = "Present"},
    @{Name = "Web-App-Dev"; Ensure = "Present"},
    @{Name = "Web-Net-Ext45"; Ensure = "Present"},
    @{Name = "Web-Asp-Net45"; Ensure = "Present"},
    @{Name = "Web-ISAPI-Ext"; Ensure = "Present"},
    @{Name = "Web-ISAPI-Filter"; Ensure = "Present"},
    @{Name = "Web-Ftp-Server"; Ensure = "Present"},
    @{Name = "Web-Mgmt-Tools"; Ensure = "Present"},
    @{Name = "Web-Mgmt-Console"; Ensure = "Present"}
  )

  node ContainerHost {

    # Install containers feature
    foreach ($feature in $features) {
      WindowsFeature ($feature.Name) {
        Name = $feature.Name
        Ensure = $feature.Ensure
      }
    }

    Script DockerService {
      TestScript = {
        $pkg =  Get-Module -Name DockerMsftProvider

        if ($pkg -ne $null) {
          return $false
        }
        else {
          return $true
        }
      }
      SetScript = {
        Install-PackageProvider -Name NuGet -Force
        Install-Module -Name DockerMsftProvider -Force 
        Install-Package -Name docker -ProviderName DockerMsftProvider -Force
      }

      GetScript = {@{Result = $true}}
    }
  }

  # Reboot the system to complete Containers feature setup
  xPendingReboot Reboot
  {
    Name = "Reboot After Containers"
  }

   # Start up the Docker Service and ensure it is set
  # to start up automatically.
  xServiceSet DockerService
  {
    Ensure      = 'Present'
    Name        = 'Docker'
    StartupType = 'Automatic'
    State       = 'Running'
  }
}

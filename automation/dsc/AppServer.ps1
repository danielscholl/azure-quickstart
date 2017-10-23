Configuration AppServer {

  Import-DscResource -ModuleName xPendingReboot
  Import-DscResource -ModuleName xPSDesiredStateConfiguration

  $features = @(
    @{Name = "Web-Server"; Ensure = "Present"},
    @{Name = "Web-WebServer"; Ensure = "Present"},
    @{Name = "Web-Common-http"; Ensure = "Present"},
    @{Name = "Web-Default-Doc"; Ensure = "Present"},
    @{Name = "Web-Http-Errors"; Ensure = "Present"},
    @{Name = "Web-Static-Content"; Ensure = "Present"},
    @{Name = "Web-Health"; Ensure = "Present"},
    @{Name = "Web-Http-Logging"; Ensure = "Present"},
    @{Name = "Web-Performance"; Ensure = "Present"},
    @{Name = "Web-Security"; Ensure = "Present"},
    @{Name = "Web-Filtering"; Ensure = "Present"},
    @{Name = "Web-Windows-Auth"; Ensure = "Present"},
    @{Name = "Web-Net-Ext45"; Ensure = "Present"},
    @{Name = "Web-Asp-Net45"; Ensure = "Present"},
    @{Name = "Web-ISAPI-Ext"; Ensure = "Present"},
    @{Name = "Web-ISAPI-Filter"; Ensure = "Present"},
    @{Name = "Web-Mgmt-Tools"; Ensure = "Present"},
    @{Name = "Web-Mgmt-Console"; Ensure = "Present"},
    @{Name = "Containers"; Ensure = "Present"}
  )

  node ContainerHost {

    # Install Windows feature
    foreach ($feature in $features) {
      WindowsFeature ($feature.Name) {
        Name = $feature.Name
        Ensure = $feature.Ensure
      }
    }

    # Install the Docker
    Script DockerService {
      TestScript = {
        if (Get-Service -Name Docker -ErrorAction SilentlyContinue) {
          return $True
        }
        return $False
      }
      SetScript = {
        Install-PackageProvider -Name NuGet -Force
        Install-Module -Name DockerMsftProvider -Force
        Install-Package -Name docker -ProviderName DockerMsftProvider -Force
      }

      GetScript  = {
        return @{
          'Service' = (Get-Service -Name Docker).Name
        }
      }
    }
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

  # Reboot the system to complete Containers feature setup
  xPendingReboot Reboot
  {
    Name = "Reboot After Containers"
  }
}

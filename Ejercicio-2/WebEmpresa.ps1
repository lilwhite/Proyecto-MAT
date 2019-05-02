Configuration WebEmpresa
{
  param ($MachineName)

  Node $MachineName
  {
    #Install Web-Mgmt-Console
    WindowsFeature WebServerManagementConsole
    {
      Ensure = "Present"
      Name = "Web-Mgmt-Console"
    }  
    #Install the IIS Role
    WindowsFeature IIS
    {
      Ensure = "Present"
      Name = "Web-Server"
    }
    #Install ASP.NET 4.5
    WindowsFeature ASP
    {
      Ensure = "Present"
      Name = "Web-Asp-Net45"
    }

     
  }
} 
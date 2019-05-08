Configuration WebEmpresa
{
  param ()

  Node 'localhost'
  {
    #Install the IIS Role
    WindowsFeature IIS
    {
      Ensure = "Present"
      Name = "Web-Server"
      IncludeAllSubFeature = $true
    }
    #Install ASP.NET 4.5
    WindowsFeature ASP
    {
      Ensure = "Present"
      Name = "Web-Asp-Net45"
    }


  }
}

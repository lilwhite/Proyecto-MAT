# Script Ejercicio 2
# Variables Comunes
$1ResourceGroupName = "myResourceGroup"
$1Location = "eastus"
$1vmName = "WebEmpresa"
$1ImageName = "MicrosoftWindowsServer:WindowsServer:2016-Datacenter-Server-Core:latest"
$1VirtualNetworkName = "WebVNET"
$1SubnetName = "WebSubVNET"
$1SecurityGroupName = "WebNSG"
$1PublicIpAddressName = "WebPublicIP"
$1Size = "Standard_B1s"

# Crear grupo de recursos
New-AzResourceGroup -Name $1ResourceGroupName -Location $1Location

# Crea el objeto de usuario
$1cred = Get-Credential -Message "Introduce el usuario y la contraseña para la máquina virtual."

# Crea la máquina virtual
New-AzVM `
  -ResourceGroupName $1ResourceGroupName `
  -Name $1vmName `
  -Location $1location `
  -ImageName $1ImageName `
  -VirtualNetworkName $1VirtualNetworkName `
  -SubnetName $1SubnetName `
  -SecurityGroupName $1SecurityGroupName `
  -PublicIpAddressName $1PublicIpAddressName `
  -Credential $1cred `
  -Size $1Size `
  -OpenPorts 80

# Instalación Web-Management-Service

Write-Host "Instalación Web-Management-Service" -ForegrundColor DarkGreen -BackgroundColor Black

$1SettingsString = 'Install-WindowsFeature Web-Management-Service'

Set-AzVMExtension `
  -ResourceGroupName $1ResourceGroupName `
  -Location $1Location `
  -VMName $1vmName `
  -Name "CustomScriptExtension" `
  -Publisher "MAT.Compute" `
  -Type "CustomScriptExtension" `
  -TypeHandlerVersion "1.0" `
  -SettingString $1SettingsString

# Instalación IIS

$1PublicSettings = '{"ModulesURL":"https://github.com/lilwhite/Proyecto-MAT/raw/master/Ejercicio-2/WebEmpresa.ps1.zip", "configurationFunction": "WebEmpresa.ps1\\WebEmpresa", "Properties": {"MachineName": '+'"'+$1vmName+'"'+'} }'

Set-AzVMExtension `
  -ExtensionName "DSC" `
  -ResourceGroupName $1ResourceGroupName `
  -VMName $1vmName `
  -Publisher "Microsoft.Powershell" `
  -ExtensionType "DSC" `
  -TypeHandlerVersion 2.7 `
  -SettingString $1PublicSettings `
  -Location $1Location

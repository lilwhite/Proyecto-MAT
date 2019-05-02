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

# Instalación IIS
$1PublicSettings = '{"ModulesURL":"https://github.com/Azure/azure-quickstart-templates/raw/master/dsc-extension-iis-server-windows-vm/ContosoWebsite.ps1.zip", "configurationFunction": "ContosoWebsite.ps1\\ContosoWebsite", "Properties": {"MachineName": "myVM"} }'

Set-AzVMExtension -ExtensionName "DSC" -ResourceGroupName $1ResourceGroupName -VMName $1vmName `
  -Publisher "Microsoft.Powershell" -ExtensionType "DSC" -TypeHandlerVersion 2.19 `
  -SettingString $1PublicSettings -Location $1Location

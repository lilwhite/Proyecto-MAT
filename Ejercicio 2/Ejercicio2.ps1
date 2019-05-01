# SCRIPT EJERCICIO-2
# Variables comunes
$ResourceGroupName = "RG-WebEmpresa"
$LocationName = "eastus"
$VMName = "VM"
$ComputerName = "VM"
$VMSize = "Standar_B1S"

$NetworkName = "WebVnet"
$NICname = "WebNIC"
$SubnetName = "WebSubnet"
$SubnetAddressPrefix = "10.0.0.0/24"
$VnetAddressPrefix = "10.0.0.0/16"

# Crear nuevo recurso
New-AzResourceGroup -Name $ResourceGroupName -Location $LocationName

# Creación de subredes

$SingleSubnet = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressPrefix
$Vnet = New-AzVirtualNetwork -Name $NetworkName -ResourceGroupName $ResourceGroupName -Location $LocationName -AddressPrefix $VnetAddressPrefix -Subnet $SingleSubnet
$NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName -Location $LocationName -SubnetId $Vnet.Subnets[0].Id



# Crear usuario para la máquina virtual
$Credential = Get-Credential -Message "Introduce el usuario y contraseña de la máquina virtual."

# Creación máquina virtual
# Publicador: Microsoft Windows server
# Oferta: Windows Server
# SKU: 2016-Datacenter-Server-Core

$VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2016-Datacenter-Server-Core' -Version latest

New-AzVM -ResourceGroupName $ResourceGroupName -VM $VirtualMachine -Location $LocationName -SecurityGroupName "WEB-NSG" -PublicIpAddressName "WebEmpresa" -OpenPorts 80 -Verbose

# Instalación IIS
$PublicSettings = '{"ModulesURL":"https://github.com/Azure/azure-quickstart-templates/raw/master/dsc-extension-iis-server-windows-vm/ContosoWebsite.ps1.zip", "configurationFunction": "ContosoWebsite.ps1\\ContosoWebsite", "Properties": {"MachineName": "myVM"} }'

Set-AzVMExtension -ExtensionName "DSC" -ResourceGroupName $ResourceGroupName -VMName $VMName -Publisher "Microsoft.Powershell" -ExtensionType "DSC" -TypeHandlerVersion 2.19 -SettingString $PublicSettings -Location $LocationName

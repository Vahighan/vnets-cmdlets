$rg = @{
    Name = 'build-agents-01'
    Location = 'West Europe'
}
New-AzResourceGroup @rg

$vnet = @{
    Name = 'build-agents-vnet'
    ResourceGroupName = 'build-agents-01'
    Location = 'West Europe'
    AddressPrefix = '10.0.0.0/16'    
}
$virtualNetwork = New-AzVirtualNetwork @vnet

$subnet = New-AzVirtualNetworkSubnetConfig -Name 'agents-subnet' -AddressPrefix '10.0.1.0/24'
$subnet = New-AzVirtualNetworkSubnetConfig -Name 'jumpbox-subnet' -AddressPrefix '10.0.2.0/24'

$rulensg = New-AzNetworkSecurityRuleConfig -Name 'Allow-RDP' -Description "Allow RDP" `
  -Access Allow -Protocol Tcp -Direction Inbound -Priority 200 `
  -SourceAddressPrefix Internet -SourcePortRange * `
  -DestinationAddressPrefix * -DestinationPortRange 3389

$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $RgName -Location $location `
  -Name 'MyNsg' -SecurityRules $rulensg

Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name 'MySubnet' `
  -AddressPrefix '10.0.0.0/16' -NetworkSecurityGroup $nsg

$subnetConfig = Add-AzVirtualNetworkSubnetConfig @subnet

$virtualNetwork | Set-AzVirtualNetwork
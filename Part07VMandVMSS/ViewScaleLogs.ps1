$VMSSResource = Get-AzVmss -VMScaleSetName 'VMSSFlex'
$VMSSResourceID =  $VMSSResource.Id

$VMSSResource | Format-List
$VMSSResource.VirtualMachineProfile #see the profile

Start-AzVmss -VMScaleSetName 'VMSSFlex' -ResourceGroupName RG-VMSS

$alllogs = Get-AzLog -DetailedOutput -ResourceId $VMSSResourceID -StartTime (Get-Date).AddDays(-7) -EndTime (Get-Date) -WarningAction SilentlyContinue
$scalelogs = $alllogs | Where-Object {$_.OperationName -eq "Autoscale scale down completed" -or
            $_.OperationName -eq "Autoscale scale up completed"}
$scalelogs = $scalelogs | Sort-Object -Property EventTimestamp

$scalelogs |
    select-object EventTimestamp, OperationName, @{Name='OldCount';Expression={$_.properties.content.OldInstancesCount}},@{Name='NewCount';Expression={$_.properties.content.NewInstancesCount}}

Stop-AzVmss -VMScaleSetName 'VMSSFlex' -ResourceGroupName RG-VMSS #cannot do if ephemeral
<#
.NAME
    Destiny 2 Solo Mode Enabler
.AUTHOR
    Jon Ausherman
.PURPOSE
    Disables the ports used by match making on the local client to prevent random users from joining you
.VERSION
    1.5
.FAQ
    Recommend to: Set-ExecutionPolicy -ExecutionPolicy Unrestricted
    Recommend to: Run Powershell ISE as Admin, and launch the script from there
.WARNING
    Error handling has not been implemented. This script assumes that your admin account can make the changes below to the Windows FireWall
#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

#checks to see if any solo rules are set up
Function Get-ModeStatus{

   If( [boolean]$(Get-NetFirewallRule -DisplayName "Destiny2-Solo-1" -ErrorAction SilentlyContinue) -or 
        [boolean]$(Get-NetFirewallRule -DisplayName "Destiny2-Solo-2" -ErrorAction SilentlyContinue) -or 
        [boolean]$(Get-NetFirewallRule -DisplayName "Destiny2-Solo-3" -ErrorAction SilentlyContinue) -or
        [boolean]$(Get-NetFirewallRule -DisplayName "Destiny2-Solo-4" -ErrorAction SilentlyContinue) ){
            RETURN $True
        }else{
            RETURN $false
        }  
}

Function Color-Picker([boolean]$status){
    if($status){
        RETURN "Green"
    }else{
        RETURN "Red" 
    }
}

$StatusHolder = Get-ModeStatus

$SoloD2                          = New-Object system.Windows.Forms.Form
$SoloD2.ClientSize               = '451,232'
$SoloD2.text                     = "Form"
$SoloD2.TopMost                  = $false

$ModeStatus_Label                        = New-Object System.Windows.Forms.Label
$ModeStatus_Label.Text                   = "Solo Mode Enabled: "
$ModeStatus_Label.location               = New-Object System.Drawing.Point(120,40)
$ModeStatus_Label.AutoSize               = $true

$ModeStatusBig_Label                     = New-Object System.Windows.Forms.Label
$ModeStatusBig_Label.Text                   = "$StatusHolder"
$ModeStatusBig_Label.Location            = New-Object System.Drawing.Point(230,30)
$ModeStatusBig_Label.AutoSize            = $true
$ModeStatusBig_Label.Font                = "Comic Sans,15"
$ModeStatusBig_Label.ForeColor           = Color-Picker -status $StatusHolder

$SoloMode_Button                        = New-Object system.Windows.Forms.Button
$SoloMode_Button.BackColor              = "#e709f3"
$SoloMode_Button.text                   = "Activate Solo Mode"
$SoloMode_Button.width                  = 180
$SoloMode_Button.height                 = 104
$SoloMode_Button.location               = New-Object System.Drawing.Point(14,86)
$SoloMode_Button.Font                   = 'MS PGothic,15'

$RegularMode_Button                     = New-Object system.Windows.Forms.Button
$RegularMode_Button.text                = "Activate Regular Mode"
$RegularMode_Button.width               = 203
$RegularMode_Button.height              = 104
$RegularMode_Button.location            = New-Object System.Drawing.Point(222,87)
$RegularMode_Button.Font                = 'Microsoft Sans Serif,14'
$RegularMode_Button.ForeColor           = "#7ed321"

$SoloD2.controls.AddRange(@($SoloMode_Button,$RegularMode_Button,$ModeStatus_Label,$ModeStatusBig_Label))

$SoloMode_Button.Add_Click({
    New-NetFirewallRule -DisplayName "Destiny2-Solo-1" -Direction Outbound -LocalPort 1935,3097,3478-3480 -Protocol TCP -Action Block
    New-NetFirewallRule -DisplayName "Destiny2-Solo-2" -Direction Outbound -LocalPort 1935,3097,3478-3480 -Protocol UDP -Action Block
    New-NetFirewallRule -DisplayName "Destiny2-Solo-3" -Direction Inbound -LocalPort 1935,3097,3478-3480 -Protocol TCP -Action Block
    New-NetFirewallRule -DisplayName "Destiny2-Solo-4" -Direction Inbound -LocalPort 1935,3097,3478-3480 -Protocol UDP -Action Block

    $StatusHolder = Get-ModeStatus
    $ModeStatusBig_Label.Text                   = "$StatusHolder"
    $ModeStatusBig_Label.ForeColor           = Color-Picker -status $StatusHolder
})

$RegularMode_Button.Add_Click({
    Remove-NetFirewallRule -DisplayName "Destiny2-Solo-1" 
    Remove-NetFirewallRule -DisplayName "Destiny2-Solo-2" 
    Remove-NetFirewallRule -DisplayName "Destiny2-Solo-3" 
    Remove-NetFirewallRule -DisplayName "Destiny2-Solo-4"

    $StatusHolder = Get-ModeStatus
    $ModeStatusBig_Label.Text                   = "$StatusHolder"
    $ModeStatusBig_Label.ForeColor           = Color-Picker -status $StatusHolder

})


[void]$SoloD2.ShowDialog()
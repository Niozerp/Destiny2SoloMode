<#
.NAME
    Destiny 2 Solo Mode Enabler
.AUTHOR
    Jon Ausherman
.PURPOSE
    Disables the ports used by match making on the local client to prevent random users from joining you
.VERSION
    1.7.4
.FAQ
    Recommend to: Set-ExecutionPolicy -ExecutionPolicy Unrestricted
    Recommend to: Run Powershell ISE as Admin, and launch the script from there
.WARNING
    This file modifies your Destiny 2 experience outside of what may be considered the normal permaters of game play. Use at your own risk.
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

#returns the color used on the Status Label based on the boolean provided
Function Color-Picker([boolean]$status){
    if($status){
        RETURN "Green"
    }else{
        RETURN "Red" 
    }
}

#establishes the current status. Holding the status in a variable greatly decreses load and visual update times
$global:StatusHolder = Get-ModeStatus

#GUI established using Windows Forms. .NET method of making the UI
$SoloD2                          = New-Object system.Windows.Forms.Form
$SoloD2.ClientSize               = '451,232'
$SoloD2.text                     = "Form"
$SoloD2.TopMost                  = $false

$ModeStatus_Label                        = New-Object System.Windows.Forms.Label
$ModeStatus_Label.Text                   = "Solo Mode Enabled: "
$ModeStatus_Label.location               = New-Object System.Drawing.Point(120,40)
$ModeStatus_Label.AutoSize               = $true

$ModeStatusBig_Label                     = New-Object System.Windows.Forms.Label
$ModeStatusBig_Label.Text                   = "$global:StatusHolder"
$ModeStatusBig_Label.Location            = New-Object System.Drawing.Point(230,30)
$ModeStatusBig_Label.AutoSize            = $true
$ModeStatusBig_Label.Font                = "Comic Sans,15"
$ModeStatusBig_Label.ForeColor           = Color-Picker -status $global:StatusHolder

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

#add all the objects to the control
$SoloD2.controls.AddRange(@($SoloMode_Button,$RegularMode_Button,$ModeStatus_Label,$ModeStatusBig_Label))

#clicking the solo mode button creates the four firewall rules. checks to see if Solo Mode is currently enabled. Stops immediately if a firewall rule cannot be created
$SoloMode_Button.Add_Click({


    #updates the status text and color
    $global:StatusHolder = Get-ModeStatus
    $ModeStatusBig_Label.Text                   = "$global:StatusHolder"
    $ModeStatusBig_Label.ForeColor           = Color-Picker -status $global:StatusHolder



  if($global:StatusHolder -eq $false){
      try{  New-NetFirewallRule -DisplayName "Destiny2-Solo-1" -Direction Outbound -LocalPort 1935,3097,3478-3480 -Protocol TCP -Action Block -ErrorAction Stop }
        catch{
                    #popup notification with specific error dialog
                    $wshell = New-Object -ComObject Wscript.Shell
                    $wshell.Popup("Failed to Create FireWall Rule: Destiny2-Solo-1",0,"OK",4096)
        }
      try{  New-NetFirewallRule -DisplayName "Destiny2-Solo-2" -Direction Outbound -LocalPort 1935,3097,3478-3480 -Protocol UDP -Action Block -ErrorAction Stop }
        catch{
                    #popup notification with specific error dialog
                    $wshell = New-Object -ComObject Wscript.Shell
                    $wshell.Popup("Failed to Create FireWall Rule: Destiny2-Solo-2",0,"OK",4096)
        }
      try{  New-NetFirewallRule -DisplayName "Destiny2-Solo-3" -Direction Inbound -LocalPort 1935,3097,3478-3480 -Protocol TCP -Action Block -ErrorAction Stop }
        catch{
                    #popup notification with specific error dialog
                    $wshell = New-Object -ComObject Wscript.Shell
                    $wshell.Popup("Failed to Create FireWall Rule: Destiny2-Solo-1",0,"OK",4096)
        }      
      try{  New-NetFirewallRule -DisplayName "Destiny2-Solo-4" -Direction Inbound -LocalPort 1935,3097,3478-3480 -Protocol UDP -Action Block -ErrorAction Stop }
        catch{
                    #popup notification with specific error dialog
                    $wshell = New-Object -ComObject Wscript.Shell
                    $wshell.Popup("Failed to Create FireWall Rule: Destiny2-Solo-1",0,"OK",4096)
        }
    }else{
        #popup notification with specific error dialog
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("Solo Mode Is Already Enabled",0,"OK",4096)
    }

    #updates the status text and color
    $global:StatusHolder = Get-ModeStatus
    $ModeStatusBig_Label.Text                   = "$global:StatusHolder"
    $ModeStatusBig_Label.ForeColor           = Color-Picker -status $global:StatusHolder
})

#removes the four firewall rules. checks to see if Solo mode is current disabled. Stops immediately if a firewall rule cannot be deleted
$RegularMode_Button.Add_Click({

    #updates the status text and color
    $global:StatusHolder = Get-ModeStatus
    $ModeStatusBig_Label.Text                   = "$global:StatusHolder"
    $ModeStatusBig_Label.ForeColor           = Color-Picker -status $global:StatusHolder



    if($global:StatusHolder -eq $true){

      try{  Remove-NetFirewallRule -DisplayName "Destiny2-Solo-1" -ErrorAction stop }
        catch{
                    #popup notification with specific error dialog
                    $wshell = New-Object -ComObject Wscript.Shell
                    $wshell.Popup("Failed to Delete FireWall Rule: Destiny2-Solo-1",0,"OK",4096)
        }
     try{   Remove-NetFirewallRule -DisplayName "Destiny2-Solo-2" -ErrorAction Stop }
        catch{
                    #popup notification with specific error dialog
                    $wshell = New-Object -ComObject Wscript.Shell
                    $wshell.Popup("Failed to Delete FireWall Rule: Destiny2-Solo-2",0,"OK",4096)
        }

     try{   Remove-NetFirewallRule -DisplayName "Destiny2-Solo-3" -ErrorAction stop }
        catch{
                    #popup notification with specific error dialog
                    $wshell = New-Object -ComObject Wscript.Shell
                    $wshell.Popup("Failed to Delete FireWall Rule: Destiny2-Solo-3",0,"OK",4096)
        }

     try{   Remove-NetFirewallRule -DisplayName "Destiny2-Solo-4" -ErrorAction Stop }
        catch{
                    #popup notification with specific error dialog
                    $wshell = New-Object -ComObject Wscript.Shell
                    $wshell.Popup("Failed to Delete FireWall Rule: Destiny2-Solo-4",0,"OK",4096)
        }



    }else{
        #popup notification with specific error dialog
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("Solo Mode Is Already Disabled",0,"OK",4096)
    }

    #updates the status text and color
    $global:StatusHolder = Get-ModeStatus
    $ModeStatusBig_Label.Text                   = "$global:StatusHolder"
    $ModeStatusBig_Label.ForeColor           = Color-Picker -status $global:StatusHolder

})

#displays the window, kicking off the program launch
[void]$SoloD2.ShowDialog()

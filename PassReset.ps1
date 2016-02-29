# Author: Kieran Graves || http://gravzy.com/
# Date 29/02/2016
# Purpose: With little input from the user this script resets a users password using a baseword and 4 random numbers.
# RSAT is needed to run this script.
#ASCII Art displaying company name.
Write-Host "Visit http://www.network-science.de/ascii/ and use 'small' as your font for best results. Clear this white space.




" # Branding.

function GetAuth #Gets Credentials for later use.
{
$Global:LoggedUser = whoami.exe # Grab the logged in user.
Write-Host "Please enter your system password to authenticate with Active Directory during the password reset stage."
$Global:Creds = Get-Credential $Global:LoggedUser 
Write-Host "Thanks for that, preparing a list of users, it should appear soon!"
if (-not (Get-Module ActiveDirectory)) # Import the AD module if it isn't already added.
{ 
Import-Module ActiveDirectory -Force
}
} 

function AddInAD # Sets a random password. Baseword can be changed.
{
if (-not (Get-Module ActiveDirectory)) # Import AD again if it's not already added, this is to double check.
{ 
Import-Module ActiveDirectory -Force
}

$basepass = "ChangeMe" # Change this to any word of your liking.
$randompass = Get-Random -minimum 1000 -maximum 9999 # Chooses a random number from 1000 to 9999 forming 4 numbers. Increase to 99999 for 5 numbers.
$plainpass = $basepass+$randompass # Combines the words.
$SecurePassword = $PlainPass | ConvertTo-SecureString -AsPlainText -Force # AD only accepts SecureString's so this converts it.

ForEach ($x in $objListBox.SelectedItems) 
{ 
$selecteduser = $x  # Selects the user you've selected in the listbox.

Try{
Set-ADAccountPassword $selecteduser -AuthType Negotiate -Credential $Creds -NewPassword $SecurePassword -Reset #Resets the AD password. Invalid Credentials at the start of the script could cause this to fail.
Write-Host "Password reset to $plainpass"
}

Catch
{   
Write-Warning "$($error[0]) "   
Break   
}     
 
$Date =  Get-Date -format dd/MM/yyyy
$Time = Get-Date -format %H:mm:ss
$Space = " "
$DateLogged = $Date+$Space+$Time # Creates a readable time and date in UK date format.
$LoggingFile = "c:\log.txt" # The location of the log files.
Try
{
Add-Content $LoggingFile "`n$selecteduser 's password was reset to $plainpass on $DateLogged by $Global:LoggedUser." # Appends log notice to log file.
}

Catch
{   
Write-Warning "$($error[0]) "   
Break   
}   
   
Write-Host "Password logged in " $LoggingFile
}
Try
{
Remove-Item $ContentFile -Force -ea SilentlyContinue # Clean up.
Remove-Item $ContentDir -Force -ea SilentlyContinue # Clean up.
}

Catch 
{   
Write-Warning "$($error[0]) "   
Break   
} 
}

Function SetupForm 
{ 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") # Loading required assemblies.
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")  
 
$objForm = New-Object System.Windows.Forms.Form  # Creating the form.
$objForm.Text = "Select user to reset." 
$objForm.Size = New-Object System.Drawing.Size(300,320)  
$objForm.StartPosition = "CenterScreen" 
$btnReset = New-Object System.Windows.Forms.Button 
$btnReset.Location = New-Object System.Drawing.Size(120,240) 
$btnReset.Size = New-Object System.Drawing.Size(75,35) 
$btnReset.Text = "Reset Password" 
$objForm.Controls.Add($btnReset)  # Adds the reset button.


Try
{
# $Icon = New-Object system.drawing.icon ("\\path\to\file\file.ico") 
# $objForm.Icon = $Icon # Sets the icon.
}

Catch 
{   
Write-Warning "$($error[0]) "   
Break   
}      

$btnReset.Add_Click({  # On button click, go to the reset function.
write-host "Resetting password." 
AddInAD
})

$CancelButton = New-Object System.Windows.Forms.Button 
$CancelButton.Location = New-Object System.Drawing.Size(200,240) 
$CancelButton.Size = New-Object System.Drawing.Size(75,23) 
$CancelButton.Text = "Exit" 
$CancelButton.Add_Click({ # On click, exit.
Try
{
Remove-Item $ContentFile -Force -ea SilentlyContinue # Clean up.
Remove-Item $ContentDir -Force -ea SilentlyContinue # Clean up.
}

Catch 
{   
Write-Warning "$($error[0]) "   
Break   
} 
$objForm.Close()
})

$objForm.Controls.Add($CancelButton)  # Adds Cancel Button.
 
$objLabel = New-Object System.Windows.Forms.Label  
$objLabel.Location = New-Object System.Drawing.Size(10,20)  
$objLabel.Size = New-Object System.Drawing.Size(280,20)  
$objLabel.Text = "Please select user to password reset:" 
$objForm.Controls.Add($objLabel)  # Adds a label with instructions.
  
$objListBox = New-Object System.Windows.Forms.ListBox 
$objListBox.Location = New-Object System.Drawing.Size(10,40)  
$objListBox.Size = New-Object System.Drawing.Size(260,300)  
$objListBox.Height = 180 
$objListBox.SelectionMode = "One" # Only allows one user to be selected at a time.
 
$ContentDir = "c:\pw\" # Change this to your liking or if you cannot write to the C drive.
$ContentFile = "c:\pw\Staff.txt" # Change this to your liking or if you cannot write to the C drive.

if((Test-Path $ContentDir) -eq 0) # Checks if $ContentDir exists.
{

Try
{
New-Item $ContentDir -type directory -ea Stop # If it doesn't, it tries to create it. You may need to change the directory and path if you cannot write to the local Drive.
}

Catch
{
Write-Warning "$($error[0]) "
Break
}

}

Try
{ 
Get-ADUser -Filter * -SearchBase "OU=EXAMPLE,OU=CurrentStaff,OU=Staff,DC=EXAMPLE,DC=local" | Select sAMAccountName | Export-Csv $ContentFile -ea stop  # Grabs all AD Users int he specified DC / OU's.
(Get-Content $ContentFile) | ForEach-Object { $_ -replace '"' } > $ContentFile # The next few lines do some formatting.
(Get-Content $ContentFile) | ForEach-Object { $_ -replace 'sAMAccountName' } > $ContentFile
(Get-Content $ContentFile) | ForEach-Object { $_ -replace '#TYPE Selected.Microsoft.ActiveDirectory.Management.ADUser' } > $ContentFile
(Get-Content $ContentFile) | ForEach-Object { $_ -replace '' } > $ContentFile
(Get-Content $ContentFile) | ? {$_.trim() -ne "" }  > $ContentFile  
[array]$users = (Get-Content $ContentFile) # Add formatted users to the users array.
}   
  
Catch

{   
Write-Warning "$($error[0]) "   
Break   
}      

$uniqueusers = $users | Select-Object -Unique | Sort-Object  # Remove duplicate users.

ForEach($user in $uniqueusers)
{ 
[void] $objListBox.Items.Add($user) # Adds each user to the list box.
} 
$objForm.Controls.Add($objListBox)  # Adds the actual listbox.
$objForm.Topmost = $True 
$objForm.Add_Shown({$objForm.Activate()}) 
[void] $objForm.ShowDialog() # Shows the form!

}

GetAuth # Starts Auth Function.
SetupForm # Sets up and displays the form.

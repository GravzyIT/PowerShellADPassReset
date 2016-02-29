# PowerShellADPassReset
A powershell script to reset an Active Directory password.

### Features:
* Random password creation using a base word.
* Easy to use GUI.
* Authentication required.
* Logging of actions.
* Reset multiple passwords without restarting the script.
*  Set a custom form icon. (Off by default, needs commenting.)

### Configuration
The following lines need to be edited to your liking and environment.
* Line 6 allows for branding, visit http://www.network-science.de/ascii/ and use "small" as your font for best results.
* Line 32 allows you to choose a base word, it's default is ChangeMe
* Line 33 allows you to choose the random numbers min and max, 99999 max would allow 5 numbers and 999999 would allow 6.
* Line 52 allows you to change the date format.
* Line 56 allows you to choose where to log the resets, this can work across network shares too.
* Line 101 allows you to choose where the form icon is loaded from, this needs to be a .ico file. This needs commenting to work.
* Line 147 allows you to choose if you want to be able to select multiple users in the listbox. Change this to MultiExtended or One.
* Line 149 allows you to change the directory that is temp made to format the user list. This needs to be writable.
* Line 150 allows you to change the location of the user list whilst formatting users. This needs to be writable.
* Line 170 allows you to change the DC and OU to search for users - this will need changing to your environment.

### Prerequisites
* RSAT (Remote Server Administration Tools) are needed for this script, they can be downloaded from Microsoft.
* Execution Policy needs to be set to Unrestricted to do this open PowerShell and type "Set-ExecutionPolicy – Unrestricted".

Feel free to submit fork and pull requests.
http://gravzy.com/

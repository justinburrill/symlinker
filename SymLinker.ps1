$path = Read-Host "Enter folder to be moved and linked"
$target = Read-Host "Enter the new location"

# move data
Copy-Item -Path $

if (Test-Path -Path $target) { # check if target folder exists

}

# create symlink
New-Item -ItemType SymbolicLink -Path $target -Target $target


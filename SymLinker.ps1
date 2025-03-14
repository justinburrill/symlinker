
$erroractionPreference="stop" # make sure UnauthorizedAccessException can be caught

if ($env:OS -ne "Windows_NT") {
    Write-Host "Warning: Script has not been tested on any non-windows OS."
    # Break
}

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
	Write-Host "Admin powers required"
	exit 1
}


$path = Read-Host "Enter directory to be moved and linked" | Resolve-Path
if ( -not (Test-Path -Path $path)) {
    Write-Host "Directory $path not found."
    exit 1
}
$target = Read-Host "Enter the new location" | Resolve-Path


$path_dir_name = Split-Path -Path $path -Leaf -Resolve
$target_dir_name = Split-Path -Path $target -Leaf -Resolve



if ($target_dir_name -ieq $path_dir_name) { # if end of target path equals the dir to be linked name
    # don't need to adjust path
}
else {
    $target = Join-Path -Path $target -ChildPath $path_dir_name
    # now $target equals the full path of the target, not it's directory
}

$target_parent = Split-Path -Path $target -Parent


Write-Host "Files will be copied to $target"

if (Test-Path -Path $target) { # check if target folder exists
    Write-Host "Target directory already exists:"
	try {
		#New-Item -Type Directory -Path (Split-Path -Path $target -Parent) -Name $path_dir_name
		Remove-Item $target
	}
    catch {
		Write-Host "Failed to create the target directory:"
		Write-Host $_
		exit 1
	}
}

$test_file_name = "test.txt"

try {
	New-Item -Path $target_parent -ItemType "file" -Name $test_file_name
	Write-Host "Success creating test file in $target_parent"
}
catch {
	Write-Host "Error: Can't create files in $target_parent due to: $_"
	exit 1
}
try {
	Remove-Item -Path (Join-Path -Path $target_parent -ChildPath $test_file_name)
}
catch {
	Write-Host "Error: I accidentally left a test file in $target_parent. sorry about that: $_"
}


# move data
try {
	Move-Item -Path $path -Destination $target_parent
}
catch {
	Write-Host "Error: Was unable to move the folder: $_"
	exit 1
}


# create symlink
try {
    New-Item -ItemType SymbolicLink -Path $path -Target $target
    Write-Host "Symlink created at $path to $target"
}
catch {
    Write-Host "Error: Symlink failed to be created: $_"	
}




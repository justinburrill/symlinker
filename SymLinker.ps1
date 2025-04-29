function New-Link() {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true)]
		[string]$Path,
		[Parameter(Mandatory=$true)]
		[string]$Target
	)
		
	$erroractionPreference="stop" # make sure UnauthorizedAccessException can be caught

	if ($env:OS -ne "Windows_NT") {
		Write-Host "Warning: Script has not been tested on any non-windows OS."
		# Break
	}

	if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
	{
		Write-Host "Error: Admin powers required."
		return
	}

	try {
		$path = Resolve-Path $Path
	}
	catch {
		Write-Host "Couldn't resolve path ${path}: $_"
		return
	}

	if ( -not (Test-Path -Path $path)) {
		Write-Host "Directory $path not found."
		return
	}

	try {
		# TODO: should i resolve this? probably not because if i enter a path that doesn't exist...
		$target = $Target 
	}
	catch {
		Write-Host "Couldn't resolve target path"
		return
	}

	$path_item_name = Split-Path -Path $path -Leaf -Resolve
	$target_item_name = Split-Path -Path $target -Leaf # don't resolve because it may not exist yet

	if ($target_item_name -ieq $path_item_name) { # if end of target path equals the dir to be linked name
		# don't need to adjust path
	}
	else {
		$target = Join-Path -Path $target -ChildPath $path_item_name
		# now $target equals the full path of the target, not it's directory
	}

	$target_parent = Split-Path -Path $target -Parent

	if (Test-Path -Path $target) { # check if target folder exists
		Write-Host "Target directory already exists:"
		try {
			Remove-Item $target
		}
		catch {
			Write-Host "Failed to remove the target directory:"
			Write-Host $_
			return
		}
	}

	$test_file_name = "test.txt"

	# create test file
	try {
		New-Item -Path $target_parent -ItemType "file" -Name $test_file_name | Out-Null
	}
	catch {
		Write-Host "Error: Can't create files in $target_parent due to: $_"
		return
	}
	# remove test file
	try {
		Remove-Item -Path (Join-Path -Path $target_parent -ChildPath $test_file_name)
	}
	catch {
		Write-Host "Error: I accidentally left a test file in ${target_parent}. sorry about that: $_"
	}

	# move data
	try {
		Write-Host "Moving data to $target ... this might take a minute"
		Move-Item -Path $path -Destination $target_parent -Force
		Write-Host "Success moving data"
	}
	catch {
		Write-Host "Error: Was unable to move the folder: $_"
		return
	}

	# create symlink
	try {
		New-Item -ItemType SymbolicLink -Path $path -Target $target | Out-Null
		Write-Host "Symlink created at $path to $target"
	}
	catch {
		Write-Host "Error: Symlink failed to be created: $_"	
		return
	}
}

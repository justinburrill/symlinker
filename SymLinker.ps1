

if ($env:OS -ne "Windows_NT") {
    Write-Host "Warning: Script has not been tested on any non-windows OS."
    # Break
}

$path = Read-Host "Enter directory to be moved and linked"
if ( -not (Test-Path -Path $path)) {
    Write-Host "Directory $path not found."
    Break
}
$target = Read-Host "Enter the new location"


$path_dir_name = Split-Path -Path $path -Leaf
$target_dir_name = Split-Path -Path $target -Leaf
$target_dir_parent = Split-Path -Path $target -Parent


if ($target_dir_name -ieq $path_dir_name) { # if end of target path equals the dir to be linked name
    # don't need to adjust path
}
else {
    $target = Join-Path -Path $target -ChildPath $path_dir_name
    # now $target equals the full path of the target, not it's directory
}

Write-Host "Files will be copied to $target"

if ( -not (Test-Path -Path $target)) { # check if target folder exists
    Write-Host "Target dir not found, creating."
    New-Item -Type Directory -Path (Split-Path -Path $target -Parent) -Name $path_dir_name
}

# move data
Copy-Item -Path (Join-Path $path -ChildPath "*") -Destination $target

# delete old folder
Remove-Item -Path $path -Recurse -Force

# create symlink
try {
    New-Item -ItemType SymbolicLink -Path $path -Target $target
    Write-Host "Symlink created at $path to $target"
}
catch {
    Write-Host "Symlink failed to be created."
    Write-Host $_
}




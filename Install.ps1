# PowerShell Configuration

$dotfilesPath = "$HOME\.dotfiles"
$nvimConfigPath = "$HOME\AppData\Local\nvim"
$dotfilesNvimPath = "$dotfilesPath\nvim"
$powershellProfilePath = "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
$dotfilesPowershellProfile = ".\powershell\Microsoft.PowerShell_profile.ps1"
$dotfilesTerminalSettings = ".\powershell\settings.json"

if (Test-Path $dotfilesPowershellProfile) {
    Copy-Item $dotfilesPowershellProfile $powershellProfilePath -Force
    Write-Host "PowerShell profile copied to $powershellProfilePath."
}

# preview path
$previewTerminalSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

if (Test-Path $previewTerminalSettingsPath) {
    # Backup the current settings.json
    if (Test-Path $previewTerminalSettingsPath ) {
        Copy-Item $previewTerminalSettingsPath "$previewTerminalSettingsPath.bak"
        Write-Host "Backup of the original settings.json created."
    }

    # Copy the custom settings.json from dotfiles to Windows Terminal config directory
    Copy-Item $dotfilesTerminalSettings $previewTerminalSettingsPath -Force
    Write-Host "Custom settings.json copied to Windows Terminal directory."
} else {
    Write-Host "Windows Terminal is not installed or settings.json was not found."
}

# Install and configure NVIM


# Check if Neovim is installed
if (-not (Get-Command nvim -ErrorAction SilentlyContinue)) {
    Write-Host "Neovim is not installed. Installing via Chocolatey..."
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Chocolatey is not installed. Installing Chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force; `
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
        iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }
    choco install neovim -y
} else {
    Write-Host "Neovim is already installed."
}

# Backup existing Neovim configuration if it exists
if (Test-Path $nvimConfigPath) {
    $backupPath = "$nvimConfigPath.bak"
    Write-Host "Backing up existing Neovim configuration to $backupPath"
    Rename-Item $nvimConfigPath $backupPath -Force
}

# Create Neovim config directory if it doesn't exist
if (-not (Test-Path $nvimConfigPath)) {
    New-Item -ItemType Directory -Path $nvimConfigPath -Force
}

# Copy or create symbolic links to Neovim configuration files
if (Test-Path $dotfilesNvimPath) {
    # Create symbolic links 
    New-Item -ItemType SymbolicLink -Path "$nvimConfigPath\init.vim" -Target "$dotfilesNvimPath\init.vim"
    Write-Host "Neovim configuration linked from dotfiles."
} else {
    Write-Host "Neovim configuration in dotfiles not found."
}

# Additional setup: Install plugins using a plugin manager (if applicable)
Write-Host "Setting up Neovim plugins..."
nvim --headless +PlugInstall +qall  # Example with vim-plug, modify according to your plugin manager

Write-Host "Neovim setup completed."

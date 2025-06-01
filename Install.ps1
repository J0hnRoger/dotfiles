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
}
else {
    Write-Host "Windows Terminal is not installed or settings.json was not found."
}

# Installer Tool : Chocolatey
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Chocolatey is not installed. Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force; `
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
        # TODO - utiliser Powershell rest call
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Install and configure tools from chocolatey 
$jsonFilePath = '.\choco.json'
$packages = Get-Content $jsonFilePath | ConvertFrom-Json

foreach ($package in $packages.packages) {
    $packageName = $package.name
    $targetVersion = $package.version

    # Check if exists 
    $installedPackage = choco list --local-only --exact $packageName | Select-String -Pattern "^$packageName " | ForEach-Object { $_ -replace "^$packageName ", "" }

    if ($installedPackage) {
        # Comparer la version installée avec la version désirée
        if ($installedPackage -ne $targetVersion) {
            Write-Host "$packageName is installed but not at the desired version ($installedPackage). Updating to version $targetVersion..."
            if ($targetVersion -eq "latest") {
                choco upgrade $packageName -y
            }
            else {
                choco upgrade $packageName --version=$targetVersion -y
            }
            Write-Host "$packageName updated to new version: $targetVersion"
        }
        else {
            Write-Host "$packageName is already installed and at the correct version ($installedPackage)."
        }
    }
    else {
        Write-Host "$packageName is not installed. Installing version $targetVersion..."
        if ($targetVersion -eq "latest") {
            choco install $packageName -y --params "/ALLUSERS" --force
        }
        else {
            choco install $packageName --version=$targetVersion -y --params "/ALLUSERS" --force
        }
        Write-Host "$packageName installed at version $targetVersion."
    }
}

# Backup existing Neovim configuration if it exists
if (Test-Path $nvimConfigPath) {
    $currentDate = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $backupPath = "$nvimConfigPath-$currentDate.bak"
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
}
else {
    Write-Host "Neovim configuration in dotfiles not found."
}

$dotfilesPath = "$HOME\.dotfiles"
$aiderConfigPath = "$HOME\.aider.conf.yml"
$dotfilesAiderConfigPath = "$dotfilesPath\.aider.conf.yml"

# Check if the .aider.conf.yml exists in dotfiles
if (Test-Path $dotfilesAiderConfigPath) {
    # Remove existing symlink if it exists
    if (Test-Path $aiderConfigPath) {
        Remove-Item $aiderConfigPath -Force
    }
    
    # Create symbolic link
    New-Item -ItemType SymbolicLink -Path $aiderConfigPath -Target $dotfilesAiderConfigPath
    Write-Host ".aider.conf.yml symlink created in $HOME."
}
else {
    Write-Host ".aider.conf.yml not found in dotfiles."
}

# Additional setup: Install plugins using a plugin manager (if applicable)
Write-Host "Setting up Neovim plugins..."
nvim --headless +PlugInstall +qall  # Example with vim-plug, modify according to your plugin manager

Write-Host "Neovim setup completed."

# IA Setup
Install-Module Az.KeyVault
Import-Module Az.KeyVault
Connect-AzAccount
$vaultName = "jrr-keyvault"
$secretName = "jrr-openai-apikey"

$secret = Get-AzKeyVaultSecret -VaultName $vaultName -Name $secretName
$OPEN_AI_KEY = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret.SecretValue))
if ($OPEN_AI_KEY -eq $null){
  Write-Host "La clé OpenAI est null ou vide."
}

setx OPENAI_API_KEY $OPEN_AI_KEY

# Définir les chemins
$dotfilesAiderConfigPath = "$dotfilesPath\.aider.conf.yml"
$homeAiderConfigPath = "$HOME\.aider.conf.yml"

# Vérifier si un fichier de configuration existe déjà dans $HOME, le sauvegarder si nécessaire
if (Test-Path $homeAiderConfigPath) {
    Copy-Item $homeAiderConfigPath "$homeAiderConfigPath.bak"
    Write-Host "Backup of existing .aider.conf.yml created at $homeAiderConfigPath.bak"
    Remove-Item $homeAiderConfigPath -Force
}

# Créer le lien symbolique
if (Test-Path $dotfilesAiderConfigPath) {
    New-Item -ItemType SymbolicLink -Path $homeAiderConfigPath -Target $dotfilesAiderConfigPath
    Write-Host "Symbolic link for .aider.conf.yml created at $homeAiderConfigPath."
}
else {
    Write-Host "The aider config file does not exist in dotfiles. Please create $dotfilesAiderConfigPath."
}


# Créer le lien symbolique pour les fichiers de conf cursor
$dotfilesPath = "$env:USERPROFILE\.dotfiles\cursor"
$cursorUserPath = "$env:APPDATA\Cursor\User"

# Supprimer les fichiers existants si besoin
Remove-Item "$cursorUserPath\settings.json" -Force
Remove-Item "$cursorUserPath\keybindings.json" -Force
Remove-Item "$cursorUserPath\snippets" -Recurse -Force

# Créer les symlinks
New-Item -ItemType SymbolicLink -Path "$cursorUserPath\settings.json" -Target "$dotfilesPath\settings.json"
New-Item -ItemType SymbolicLink -Path "$cursorUserPath\keybindings.json" -Target "$dotfilesPath\keybindings.json"
New-Item -ItemType SymbolicLink -Path "$cursorUserPath\snippets" -Target "$dotfilesPath\snippets"

python -m pip install --upgrade pip
python -m pip install httpx
python -m pip install aider-chat

# To work with GPT-4:
aider --4o --openai-api-key $OPEN_AI_KEY




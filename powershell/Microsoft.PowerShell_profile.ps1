$nvim = "$HOME\AppData\Local\nvim"

# NVIM Config
$env:XDG_CONFIG_HOME="$HOME\.dotfiles"

# Quick Actions

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

Import-Module posh-git

# dotnet suggest shell start
$availableToComplete = (dotnet-suggest list) | Out-String
$availableToCompleteArray = $availableToComplete.Split([Environment]::NewLine, [System.StringSplitOptions]::RemoveEmptyEntries)

Register-ArgumentCompleter -Native -CommandName $availableToCompleteArray -ScriptBlock {
  param($wordToComplete, $commandAst, $cursorPosition)
  $fullpath = (Get-Command $commandAst.CommandElements[0]).Source

  $arguments = $commandAst.Extent.ToString().Replace('"', '\"')
  dotnet-suggest get -e $fullpath --position $cursorPosition -- "$arguments" | ForEach-Object {
    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
  }
}

function Get-PRs {
  Invoke-WebRequest "https://dev.azure.com/boostmymail/BoostMyMail/_apis/git/pullrequests?api-version=6.0"
}

$env:DOTNET_SUGGEST_SCRIPT_VERSION = "1.0.1"
#
# dotnet suggest script end
$env:AZURE_DEVOPS_EXT_PAT = "" 

function Play-MI {
  Invoke-Expression -Command C:\Dev\Script\MissionImpossible.ps1
}

# Set BMM Environnment for Shell
# Default env: 
$env:DOTNET_BMM_ENV = "Staging"

function GitLog {
  git log --graph --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%an%C(reset)%C(bold yellow)%d%C(reset) %C(dim white)- %s%C(reset)' --all
}

function Remove-LocalBranches {
  git fetch --all -p
  $branches = git branch -vv
  $branchNames = git branch
  foreach ($branch in $branches){
    if ($branch -match ".*: gone].*"){
      $branchName = $branchNames | Where { $branch.Contains($_)} | ForEach-Object { $_.Trim() }
      git branch -D $branchName
      Write-Host("deleted branch:$branchName")
    }
  }
}

$MYVIM = "$HOME\AppData\Local\nvim\init.lua"

$NVIM = "$HOME\AppData\Local\nvim"

$PERSO = "C:\Personal\"

$TASK = "$HOME/tasks/"
Write-Host "Welcome to Shell: $MYVIM"

oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/catppuccin_macchiato.omp.json" | Invoke-Expression

# Function that launch the command `t day show`
function ShowDailyTodo(){
  Invoke-Expression -Command "t day show"
}

function ShowBacklog(){
  Invoke-Expression -Command "t task list"
}

Set-Alias d ShowDailyTodo
Set-Alias bb ShowBacklog

function DirLast() {
  Get-ChildItem | Sort-Object LastWriteTime
}
Set-Alias last DirLast

function FocusWindow($appName)
{
  # Trouver le processus par son nom
  $process = Get-Process | Where-Object { $_.MainWindowTitle -like "*$appName*" } | Select-Object -First 1

  if ($process -ne $null)
  {
      # Obtention du handle de la fenêtre
      $hwnd = $process.MainWindowHandle

      # Importation des fonctions nécessaires depuis user32.dll
      Add-Type @"
      using System;
      using System.Runtime.InteropServices;
      public class User32 {
          [DllImport("user32.dll")]
          public static extern bool SetForegroundWindow(IntPtr hWnd);
      }
"@

      # Donner le focus à la fenêtre
      [User32]::SetForegroundWindow($hwnd)
  }
  else
  {
      Write-Host "Application '$appName' non trouvée."
  }
}

function CopyCurrentPath {
    $path = (Get-Location).Path
    $path | Set-Clipboard
    Write-Output "Path copied to clipboard: $path"
}

Set-Alias -Name cpwd -Value CopyCurrentPath

Set-Alias -Name rider -Value "$HOME\AppData\Local\JetBrains\JetBrains Rider 2023.3.4\bin\rider64.exe"

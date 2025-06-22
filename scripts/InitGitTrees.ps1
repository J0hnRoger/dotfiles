function Get-GitRepoPath {
    try {
        $repoPath = git rev-parse --show-toplevel 2>$null
        if (!$repoPath) {
            throw "This directory is not part of a Git repository."
        }
        return $repoPath
    } catch {
        Write-Host "Error: $_" -ForegroundColor Red
        exit 1
    }
}

# Génère des workspaces pour les worktrees du dépôt Git courant
function Create-GitWorktreeWorkspaces {
    $repoPath = Get-GitRepoPath

    Write-Host "Using Git repository: $repoPath" -ForegroundColor Green

    # Chemin vers le template JSON
    $templatePath = Join-Path -Path $PSScriptRoot -ChildPath "workspace-template.json"
    if (!(Test-Path $templatePath)) {
        Write-Host "Error: workspace-template.json not found in script directory." -ForegroundColor Red
        exit 1
    }

    # Charger le template JSON
    $template = Get-Content -Path $templatePath -Raw | ConvertFrom-Json

    # Récupérer la liste des worktrees
    $worktrees = git -C $repoPath worktree list | ForEach-Object {
        $_ -split '\s+\[' | Select-Object -First 1
    }

    # Parcourir chaque worktree et générer un .code-workspace
    foreach ($worktree in $worktrees) {
        # Créer un dossier .vscode dans le worktree si nécessaire
        $vscodeDir = Join-Path -Path $worktree -ChildPath ".vscode"
        if (!(Test-Path $vscodeDir)) {
            New-Item -ItemType Directory -Path $vscodeDir | Out-Null
        }

        # Chemin du fichier workspace
        $workspaceFile = Join-Path -Path $vscodeDir -ChildPath "worktree.code-workspace"

        # Remplacer le chemin dans le template
        $template.folders[0].path = $worktree

        # Écrire le fichier .code-workspace
        $template | ConvertTo-Json -Depth 10 | Set-Content -Path $workspaceFile -Force

        Write-Host "Workspace created at $workspaceFile" -ForegroundColor Yellow
    }

    Write-Host "All worktrees processed. You can open them with VS Code!" -ForegroundColor Cyan
}

# Appelle la fonction principale
Create-GitWorktreeWorkspaces
# Chemin vers la base de connaissances
$kbSourcePath = "C:\Personal\john-roger\src\content\"
# Chemin cible pour la copie de la KB
$aiDocsPath = "$PWD\ai_docs"
# Chemin vers le .gitignore
$gitignorePath = "$PWD\.gitignore"

# Crée le dossier ai_docs s'il n'existe pas
if (!(Test-Path -Path $aiDocsPath)) {
    Write-Host "Dossier 'ai_docs' créé à la racine du répertoire courant."
    New-Item -ItemType Directory -Path $aiDocsPath -Force | Out-Null
}

# Copier les fichiers .md du dossier knowledge_base vers ai_docs
Get-ChildItem -Path $kbSourcePath -Filter *.md -Recurse | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination $aiDocsPath -Force
}
Write-Host "Fichiers Markdown copiés dans 'ai_docs'."

# Ajouter 'ai_docs' au .gitignore si ce n'est pas déjà inclus
if (Test-Path -Path $gitignorePath) {
    $gitignoreContent = Get-Content -Path $gitignorePath
    if ($gitignoreContent -notcontains "ai_docs/") {
        Add-Content -Path $gitignorePath -Value "`nai_docs/"
        Write-Host "'ai_docs' ajouté au .gitignore."
    }
    else {
        Write-Host "'ai_docs' est déjà présent dans le .gitignore."
    }
}
else {
    Write-Host ".gitignore non trouvé dans le répertoire courant."
}


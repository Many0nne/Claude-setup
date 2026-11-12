# Compile le shim gh (gh.cs) vers %USERPROFILE%\bin\gh.exe. A relancer apres modification de gh.cs ou sur un nouveau poste.
# Le PATH est prepare par le profil PowerShell ($HOME\bin en tete) ; Git Bash a deja ~/bin en tete.
$ErrorActionPreference = "Stop"
$bin = Join-Path $HOME "bin"
New-Item -ItemType Directory -Force $bin | Out-Null
$csc = Get-ChildItem "C:\Windows\Microsoft.NET\Framework64\v4*\csc.exe" | Select-Object -Last 1 -Expand FullName
& $csc /nologo /optimize /target:exe "/out:$bin\gh.exe" (Join-Path $PSScriptRoot "gh.cs")
if ($LASTEXITCODE -ne 0) { throw "compilation du shim gh echouee" }
"shim : $bin\gh.exe"

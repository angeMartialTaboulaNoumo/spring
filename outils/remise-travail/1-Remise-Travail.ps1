# Créer une archie et la dépose sur NextCloud

#-------
# Paramètres généraux
#-------

$nomDevoir="Tuto Web Java"

# Libretic
$urlDepot	 = "https://nextcloud.libretic.fr"
$tokenDepot1 = "FpTeM58DWn9Erbm"
$urlVisu1	 = "https://nextcloud.libretic.fr/s/MdKkQZQq6bAHjGj"
$tokenDepot2 = "GpxJLCDMgWdQLY"
$urlVisu2	 = "https://nextcloud.libretic.fr/s/RpbwYtz6Fzx9Egd"
$tokenDepot3 = "DzEnNJksHwtARYE"
$urlVisu3	 = "https://nextcloud.libretic.fr/s/mQfAKNy6LpMYbxe"

# Zaclys ncloud4
$urlDepot	 = "https://ncloud4.zaclys.com"
$tokenDepot1 = "wkzESCSFbDidk3d"
$urlVisu1	 = "https://ncloud4.zaclys.com/index.php/s/CDJGcGJEkFqoFqL"
$tokenDepot2 = "HLi4J97d8jgzzBz"
$urlVisu2	 = 'https://ncloud4.zaclys.com/index.php/s/Lg87Ac5k2ZWyHNk'
$tokenDepot3 = "q597sEiHpcsSDAw"
$urlVisu3	 = 'https://ncloud4.zaclys.com/index.php/s/gYQRbMPSsdbtfa9'


cd $PSScriptRoot
cd ..\..\..

#-------
# Saisie des infos et détermination du nom de l'archive
#-------

$pathDirArchive= $PWD.Path

# Affiche le nom du devoir
Write-Host
Write-Host $nomDevoir
Write-Host

# Saisie du groupe
while ($groupe -notin 1,2,3,4) {
	$groupe = Read-Host -Prompt "Quel est votre groupe de TD (1, 2, 3 ou 4) : "
}

if ($groupe -in 1,4) {
	$tokenDepot = $tokenDepot1
	$urlVisu = $urlVisu1
}
if ($groupe -eq 2) {
	$tokenDepot = $tokenDepot2
	$urlVisu = $urlVisu2
}
if ($groupe -eq 3) {
	$tokenDepot = $tokenDepot3
	$urlVisu = $urlVisu3
}

# Saisie du nom et prénom
Write-Host
$nomArchive = Read-Host -Prompt "Indiquez votre nom + prénom : "
$nomArchive = $nomArchive.trim().toUpper() 
$fichierArchive = $nomArchive + ".zip"

$pathArchive = $pathDirArchive + "\" + $fichierArchive


#-------
# Crée l'archive
#-------

# Crée le fichier témoin
$utilisateur = [System.Environment]::UserName
$ordinateur = [System.Environment]::MachineName
$identite = "$nomArchive - $utilisateur - $ordinateur"
$identite | Out-File -FilePath "$identite.id.txt"



# Ajoute le nom de l'élève dans le footer des pages web
Get-ChildItem -Path "." -Directory | ForEach-Object {
	$ok = $_.Name -like "cantine*" `
		  -or $_.Name -like "tuto*"
	if( $ok ) {
		Get-ChildItem -Path "$_\src\main\resources\templates" -Directory | ForEach-Object {
			Get-ChildItem -Path $_.FullName -File -Recurse | ForEach-Object {
				if( $_.Name -eq "layout.html" ) {
					$contenu = Get-Content $_.FullName -Raw
					$contenuModifie = $contenu -replace "\&copy;.*\[\[", "&copy; $identite [["
					Set-Content $_.FullName $contenuModifie
				}
			}
		}
	}
}

# Supprime l'archive si elle existe
if (Test-Path $pathArchive) {Remove-Item $pathArchive -Force}
# Crée l'archive
Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::Open($pathArchive, 'Update')


function AddToArchive {
    param (
        [System.IO.FileInfo]$File
    )
	$path = $File.FullName.Substring($PWD.Path.Length + 1)	  
	[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
		$archive,
		$File.FullName,
		$path,
		[System.IO.Compression.CompressionLevel]::Optimal
	) | Out-Null
}

function FilterByFolder {
    param (
        [System.IO.FileInfo]$File
    )
	$path = $File.FullName.Substring($PWD.Path.Length + 1)	  
	$ok = $path -notlike "*\resources\static\*" `
	      -and $path -notlike "*\resources\*.properties" 
	return $ok
}

# Traite le fichier témoin
Get-ChildItem -Path "." -File | ForEach-Object {
	$ok = $_.Name -like "*.id.txt"
	if( $ok ) {
		AddToArchive -File $_
	}
}	

# Traite les dossiers tuto\src et canine\src
Write-Host 
Get-ChildItem -Path "." -Directory | ForEach-Object {
	$ok = $_.Name -like "cantine*" `
		  -or $_.Name -like "tuto*"
	if( $ok ) {
		Write-Host $_.Name
		Get-ChildItem -Path "$_\src" -Directory | ForEach-Object {
			Get-ChildItem -Path $_.FullName -File -Recurse | ForEach-Object {
				if( FilterByFolder -File $_ ) {
					AddToArchive -File $_
				}
			}
		}
	}
}
# Ferme l'archive
$archive.Dispose()

# Supprime le fichier témoin
Remove-Item "*.id.txt"


# Supprime le nom de l'élève dans le footer des pages web
Get-ChildItem -Path "." -Directory | ForEach-Object {
	$ok = $_.Name -like "cantine*" `
		  -or $_.Name -like "tuto*"
	if( $ok ) {
		Get-ChildItem -Path "$_\src\main\resources\templates" -Directory | ForEach-Object {
			Get-ChildItem -Path $_.FullName -File -Recurse | ForEach-Object {
				if( $_.Name -eq "layout.html" ) {
					$contenu = $contenuModifie
					$contenuModifie = $contenu -replace "\&copy;.*\[\[", "&copy; [["
					Set-Content $_.FullName $contenuModifie
				}
			}
		}
	}
}

#-------
# Envoie l'archive à NextCloud
#-------

#$commande="curl.exe -k -T " + $pathArchive + ' -u "' + $tokenDepot +':" ' + #$urlDepot +'/' +$nomArchive
#Write-Output $commande
#Invoke-Expression $commande

$headers = @{
    "Authorization"=$("Basic $([System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($("$($tokenDepot):"))))");
    "X-Requested-With"="XMLHttpRequest";
}
Write-Output $headers

$UrlWebdav = "$($urlDepot)/public.php/webdav/$($fichierArchive)"
Write-Output $UrlWebdav

Invoke-RestMethod -Uri $UrlWebdav -InFile $pathArchive -Headers $headers -Method Put

#-------
# Affiche la page de contrôle
#-------

Start-Process $urlVisu

#explorer /n,$pathDirArchive

Write-Host
Write-Host "Appuyez sur une touche pour continuer..."
[System.Console]::ReadKey($true) | Out-Null
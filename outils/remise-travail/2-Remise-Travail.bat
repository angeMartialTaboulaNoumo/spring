@ECHO OFF
CHCP 65001 >NUL
PROMPT $G
CD /D "%~dp0"
CD ..\..\..

SET     PATH_ROOT=C:\DEV26
SET PATH_EXE_7ZIP=%PATH_ROOT%\utils\bin\7z.exe
SET  PATH_EXE_SED=%PATH_ROOT%\utils\bin\sed.exe

SET      NOM_EI=Tuto Web Java

:: Libretic
SET     URL_DEPOT=https://nextcloud.libretic.fr
SET TOKEN_DEPOT_1=FpTeM58DWn9Erbm
SET    URL_VISU_1=https://nextcloud.libretic.fr/s/MdKkQZQq6bAHjGj
SET TOKEN_DEPOT_2=wGpxJLCDMgWdQLY
SET    URL_VISU_2=https://nextcloud.libretic.fr/s/RpbwYtz6Fzx9Egd
SET TOKEN_DEPOT_3=DzEnNJksHwtARYE
SET    URL_VISU_3=https://nextcloud.libretic.fr/s/mQfAKNy6LpMYbxe

:: Zaclys ncloud4
SET     URL_DEPOT=https://ncloud4.zaclys.com
SET TOKEN_DEPOT_1=wkzESCSFbDidk3d
SET    URL_VISU_1=https://ncloud4.zaclys.com/index.php/s/CDJGcGJEkFqoFqL
SET TOKEN_DEPOT_2=B9x4mDXSZrj3LYa
SET    URL_VISU_2=https://ncloud4.zaclys.com/index.php/s/tHBCgR6EiGmEqCs
SET TOKEN_DEPOT_3=q597sEiHpcsSDAw
SET    URL_VISU_3=https://ncloud4.zaclys.com/index.php/s/gYQRbMPSsdbtfa9


:: Affiche le nom de l'EI
ECHO.
ECHO.%NOM_EI%
ECHO.

:saisie-groupe
ECHO.
SET GROUPE=
SET /P "GROUPE=Quel est votre groupe de TD (1, 2, 3 ou 4) : "
IF "%GROUPE%" == "1" (
  SET    URL_VISU=%URL_VISU_1%
  SET TOKEN_DEPOT=%TOKEN_DEPOT_1%
)
IF "%GROUPE%" == "4" (
  SET    URL_VISU=%URL_VISU_1%
  SET TOKEN_DEPOT=%TOKEN_DEPOT_1%
)
IF "%GROUPE%" == "2" (
  SET    URL_VISU=%URL_VISU_2%
  SET TOKEN_DEPOT=%TOKEN_DEPOT_2%
)
IF "%GROUPE%" == "3" (
  SET    URL_VISU=%URL_VISU_3%
  SET TOKEN_DEPOT=%TOKEN_DEPOT_3%
)
IF "%TOKEN_DEPOT%" == "" (
  GOTO :saisie-groupe
)


:saisie
::Saisie du nom + prénom
ECHO.
SET /P "NAME_ARCHIVE=Indiquez votre nom + prénom : "
IF "%NAME_ARCHIVE%"=="" GOTO :saisie

:: Mise ne majuscule du nom de l'archive
CALL :toUpper NAME_ARCHIVE "%NAME_ARCHIVE%"

:: Nom et chemin du fichier archive
SET FILE_ARCHIVE=%NAME_ARCHIVE%.zip
SET PATH_ARCHIVE=%FILE_ARCHIVE%

:: Paramètres de 7-Zip
SET ARGS_7ZIP=a "%PATH_ARCHIVE%"
SET ARGS_7ZIP=%ARGS_7ZIP% *.id.txt
SET ARGS_7ZIP=%ARGS_7ZIP% cantine*/src/main/java
SET ARGS_7ZIP=%ARGS_7ZIP% cantine*/src/main/resources/db
SET ARGS_7ZIP=%ARGS_7ZIP% cantine*/src/main/resources/templates
SET ARGS_7ZIP=%ARGS_7ZIP% cantine*/src/test
SET ARGS_7ZIP=%ARGS_7ZIP% tuto*/src/main/java
SET ARGS_7ZIP=%ARGS_7ZIP% tuto*/src/main/resources/templates
SET ARGS_7ZIP=%ARGS_7ZIP% -x!"*/src/main/resources/db/*.lo1"
SET ARGS_7ZIP=%ARGS_7ZIP% -mx

echo. &echo ==^> ( 1 ) Création du fichier témoin
:: Crée un fichier témoin
SET _IDENTITE=%NAME_ARCHIVE% - %USERNAME% - %COMPUTERNAME%
ECHO %_IDENTITE% >"%_IDENTITE% .id.txt"

echo. &echo ==^> ( 2 ) Création de l'archive 
:: Crée l'archive
IF EXIST "%PATH_ARCHIVE%" DEL "%PATH_ARCHIVE%"
"%PATH_EXE_7ZIP%" %ARGS_7ZIP%

echo. &echo ==^> ( 3 ) Suppression du fichier témoin
:: Supprime le fichier témoi
DEL /Q	 *.id.txt


:: Envoie le fichier
CALL :formaURL URL_DEST "%URL_DEPOT%/public.php/webdav/%FILE_ARCHIVE%"

echo. &echo ==^> ( 4 ) Test de la présence de curl
SET count=0
FOR /F "tokens=* USEBACKQ" %%F IN (`curl --version`) DO (
  CALL SET /A count=%%count%% + 1
)
IF "%count%" == "0" GOTO :echec

SET PATH_FILE_OUTPUT=..\Remise-Travail.log
IF EXIST "%PATH_FILE_OUTPUT%" DEL "%PATH_FILE_OUTPUT%"

echo. &echo ==^> ( 5 ) Envoi de l'archive avec curl
echo.
curl -T "%PATH_ARCHIVE%" -u "%TOKEN_DEPOT%":"" "%URL_DEST%" >"%PATH_FILE_OUTPUT%"

IF errorlevel 1 GOTo :echec

SET count=0
FOR /F "tokens=*" %%F IN ('TYPE "%PATH_FILE_OUTPUT%"' ) DO (
  CALL SET /A count=%%count%% + 1
  ECHO %%F
)
IF NOT "%count%" == "0" GOTO :echec

echo. &echo ==^> ( 6 ) Ouvre la page web de contrôle
:open-visu
:: Ouvre la page de vérification visuelle
START "" "%URL_VISU%"

:: Ouvre l'explorateur de fichiers de Windows
::ping localhost -n 3 > NUL
::explorer /n,..

:: Fin du traitement
ECHO. & PAUSE

IF EXIST "%PATH_FILE_OUTPUT%" DEL "%PATH_FILE_OUTPUT%"
GOTO :EOF

:: Procédure de mise en majuscule
:toUpper <return_var> <str>
FOR /f "usebackq delims=" %%I IN (`powershell "\"%~2\".toUpper()"`) DO SET "%~1=%%~I"
GOTO :EOF

:: Procédure de normalisaton d'url
:formaURL <return_var> <str>
FOR /f "usebackq delims=" %%I IN (`powershell "\"%~2\".replace(' ', '%%20' )"`) DO SET "%~1=%%~I"
GOTO :EOF

:echec
ECHO. & ECHO. & ECHO.
ECHO       ┌──────────────────────────────┐
ECHO       │  !!! ECHEC DU TRANSFERT !!!  │
ECHO       └──────────────────────────────┘
ECHO. & ECHO. & ECHO. & ECHO. & ECHO. & ECHO.
ECHO. & ECHO. & ECHO. & ECHO. & ECHO. & ECHO.
PAUSE
GOTO :EOF

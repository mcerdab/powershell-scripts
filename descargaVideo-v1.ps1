# Título: Descarga automatizada de un video generado por partes
# Fecha: 18/09/2022
# Autor: Xavi García (ElCiberProfe)
# Lenguaje: PowerShell
# Probado en: Windows PowerShell v5.1

##################################
#                                #
# CONTENIDO CON FINES EDUCATIVOS #
#                                #
##################################

#1. Realiza un FORK del proyecto en tu GITHUB y clona el repositorio a tu ordenador local
#2. Mejora el SCRIPT para que a partir de la URL del video original se genere automáticamente la URL de la API
#3. Mejora el SCRIPT para que solamente ejecute FFMPEG si existen partes de videos en el directorio
#4. Mejora el SCRIPT para no descargue el contenido JSON durante el proceso y lo mantenga en memoria
#5. Mejora el SCRIPT para que realice la descarga de varios videos a través de leer un fichero TXT
#6. Mejora el SCRIPT para que a partir de una URL real con todos los videos realice la descarga de todos ellos

$separador = "-"*50
$ProgressPreference = "SilentlyContinue"

#URL Video a Descargar: https://noixion.tv/videos/player/iMjxwrPAwSMgU_erS-rbQg
#Formato API Descargas: https://noixion.tv/api/videos/hls/iMjxwrPAwSMgU_erS-rbQg?file=index0.ts&res=1080P

$baseUrl = "https://noixion.tv/api/videos/hls/iMjxwrPAwSMgU_erS-rbQg?file=index"
$finUrl = ".ts&res=1080P"
$indice = 0

do {
    $indiceStr = $indice.ToString()
    $url = "$baseUrl$indiceStr$finUrl"
    Write-Host $separador
    Write-Host "[+]Descargando video Parte $indice ..."
	try {
	    Write-Host "[+]1.Almacenando el contenido del JSON en el fichero $indiceStr.txt"
        Invoke-WebRequest $url -OutFile "$indiceStr.txt" -PassThru | Tee-Object -Variable peticion > $null
        
        Write-Host "[+]2.Obteniendo la URL de la parte del video y almacenándola en el fichero Url$indiceStr.txt"
        $contenidoJSON = "$indiceStr.txt"
	    $urlJSON = "Url$indiceStr.txt"
	    Get-Content $contenidoJSON | ConvertFrom-Json | Select -ExpandProperty url > $urlJSON
	    
        Write-Host "[+]3.Descargando la parte del video y almácenandola en $indiceStr.ps"
        $urlVideo = Get-Content $urlJSON
	    Invoke-WebRequest $urlVideo -OutFile "$indiceStr.ps" -PassThru | Tee-Object -Variable peticion | Out-Null
	} catch{
	    Write-Warning "[!]ERROR: La URL de la parte $indice no existe"
	    break
	}
	$indice++
} until ($peticion.StatusCode -ne 200)
#Start-Sleep -Seconds 1

Write-Host $separador
Write-Host "[+]Uniendo las partes del video con FFMPEG..."
$partesVideo = (Get-ChildItem *.ps | Select -ExpandProperty Name ) -join '|'
$videoCompleto = "video.ts"
./ffmpeg -hide_banner -loglevel error -i "concat:$partesVideo" -c copy $videoCompleto

Write-Host "[+]Eliminando los ficheros sobrantes..."
Get-ChildItem *.txt -File -r | Remove-Item
Get-ChildItem *.ps -File -r | Remove-Item

$ProgressPreference = "Continue"
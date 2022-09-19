$urlOriginal = "https://noixion.tv/videos/player/iMjxwrPAwSMgU_erS-rbQg"

$baseUrl = "https://noixion.tv/api/videos/hls/"

$arrayUrl = $urlOriginal.split('/')
$logitud = $arrayUrl.Length - 1
$apiKey = $arrayUrl[$logitud]

$indexUrl = "?file=index0"

$finUrl = ".ts&res=1080P"

$indice = 0

$indiceStr = $indice.ToString()

$url = "$baseUrl$apiKey$indiceStr$finUrl"

Write-Host "$url"
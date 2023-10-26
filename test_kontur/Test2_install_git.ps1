# C:\gitlab-runner\**
$GLPath = "$env:SystemDrive\gitlab-runner"
$GLBin  = "$GLPath\gitlab-runner.exe"

# Р”Р»СЏ Р»СЋР±РѕРіРѕ СЃРєСЂРёРїС‚Р° РёР»Рё РєРѕРјР°РЅРґС‹, РІС‹РїРѕР»РЅСЏСЋС‰РµРіРѕСЃСЏ РІРЅРµ СЃРµР°РЅСЃР°, С‚СЂРµР±СѓРµС‚СЃСЏ using РјРѕРґРёС„РёРєР°С‚РѕСЂ РѕР±Р»Р°СЃС‚СЊ РґР»СЏ РІРЅРµРґСЂРµРЅРёСЏ Р·РЅР°С‡РµРЅРёР№ РїРµСЂРµРјРµРЅРЅС‹С… РёР· РІС‹Р·С‹РІР°СЋС‰РµРіРѕ СЃРµР°РЅСЃР° РѕР±Р»Р°СЃС‚СЊ, С‡С‚РѕР±С‹ РїРѕР»СѓС‡РёС‚СЊ Рє РЅРёРј РґРѕСЃС‚СѓРї РёР· РєРѕРґР° СЃРµР°РЅСЃР°. Р¤РѕРЅРѕРІС‹Рµ Р·Р°РґР°РЅРёСЏ, Р·Р°РїСѓС‰РµРЅРЅС‹Рµ СЃ Start-Job (СЃРµР°РЅСЃ РІРЅРµ РїСЂРѕС†РµСЃСЃР°).
$Token  = $using:Token
$User   = $using:User
$Pass   = $using:Pass


$GitUri = 'https://github.com/git-for-windows/git/releases/download/v2.25.0.windows.1/Git-2.25.0-64-bit.exe'
$Uri    = 'https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-windows-amd64.exe'

# РџСЂРё РІРѕР·РЅРёРєРЅРѕРІРµРЅРёРё РѕС€РёР±РѕРє - РјРѕР»С‡Р° РїСЂРѕРґРѕР»Р¶Р°С‚СЊ
$progressPreference = 'silentlyContinue'

# РЈРєР°Р·С‹РІР°РµРј С‚РёРїС‹ РїСЂРѕС‚РѕРєРѕР»РѕРІ Р±РµР·РѕРїР°СЃРЅРѕСЃС‚Рё
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'


# РЈСЃС‚РЅРѕРІРєР° GIT
& git --version | Out-Null
if ($LASTEXITCODE -ne 0) {
    Set-Location "$env:windir\temp"
    Invoke-WebRequest -UseBasicParsing -Uri $GitUri -OutFile ".\git-installer.exe"
    Start-Process '.\git-installer.exe' -ArgumentList '/SILENT' -NoNewWindow -Wait
    Remove-Item '.\git-installer.exe' -Force
    # РћР±РЅРѕРІР»РµРЅРёРµ РїРµСЂРµРјРµРЅРЅС‹С…
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# РќР°СЃС‚СЂРѕР№РєР° GIT
# -ea 0 (error action) - РѕС€РёР±РєР° РЅРµ РІС‹РІРµРґРµС‚СЃСЏ РЅР° СЌРєСЂР°РЅ - СЂР°Р±РѕС‚Р° РїСЂРѕРґРѕР»Р¶РёС‚СЃСЏ
# РўСѓС‚ РёСЃРїРѕР»СЊР·СѓРµС‚СЃСЏ РѕР±РЅРѕРІР»РµРЅРёРµ gitlab-runner
if(Get-Service "gitlab-runner" -ea 0){
    # РїРѕР»СѓС‡РёРј РїРѕР»РЅС‹Р№ РїСѓС‚СЊ РґРѕ РёСЃРїРѕР»РЅСЏРµРјРѕРіРѕ С„Р°Р№Р»Р°, split - СЂР°Р·Р±РёС‚СЊ РїРѕ СЃС‚СЂРѕРєР°, Select-Object -First 1 - РІР·СЏС‚СЊ РїРµСЂРІС‹Р№ СЌР»РµРјРµРЅС‚ РёР· РІСЃРµС… СЃС‚СЂРѕРє
    $bin = (Get-WmiObject win32_service | Where-Object{$_.Name -like 'gitlab-runner'} | Select-Object PathName).PathName -split ' ' | Select-Object -First 1
    # РїРѕР»СѓС‡Р°РµРј РїР°РїРєСѓ РіРґРµ Р»РµР¶РёС‚ РёСЃРїРѕР»РЅСЏРµРјС‹Р№ С„Р°Р№Р»
    $GLPath = Split-Path $bin -Parent
    Set-Location $GLPath
    # РЈР·РЅР°РµРј РІРµСЂСЃРёСЋ РёСЃРїРѕР»РЅСЏРµРјРѕРіРѕ С„Р°Р№Р»Р°, c РїРѕРјРѕРјС‰СЊСЋ СЂРµРі РІС‹СЂ -match РёС‰РµРј РЅРѕРјРµСЂ РІРµСЂСЃРёРё, Out-Null СЃРєСЂРѕРµС‚ Р·РЅР°С‡РµРЅРёРµ
    & $bin --version | Where-Object {$_ -match '^Version:\s*(\d+\.\d+\.\d+)'} | Out-Null
    # РџРѕР»СѓС‡РµРј СЂРµР·СѓР»СЊС‚Р°С‚ РІ РІРёРґРµ - Major, minor, build
    $VersionOld = [version]$Matches[1]
    # РµСЃР»Рё Р·РЅР°С‡РµРЅРёРµ РѕС‚СЃС‚СѓС‚СЃРІСѓРµС‚, РІС‹РґР°С‚СЊ РѕС€РёР±РєСѓ Рё Р·Р°РІРµСЂС€РёС‚СЊ СЂР°Р±РѕС‚Сѓ СЃРєСЂРёРїС‚Р° СЃ РєРѕРґРѕРј 1
    if(!$VersionOld) {
        throw "Error"
        exit 1
    }

    $GLBinNew = "$GLPath\gitlab-runner_new.exe"
    # РєР°С‡Р°РµРј РЅРѕРІС‹Р№ С„Р°Р№Р»
    Invoke-WebRequest -UseBasicParsing -Uri $Uri -OutFile $GLBinNew

    # РїСЂРѕРІРµСЂСЏРµРј РІРµСЂСЃРёСЋ
    & $GLBinNew --version | Where-Object {$_ -match '^Version:\s*(\d+\.\d+\.\d+)'} | Out-Null
    $VersionNew = [version]$Matches[1]

    # СЃСЂР°РІРЅРµРЅРёРµ, РµСЃР»Рё Р±РѕР»СЊС€Рµ РёР»Рё СЂР°РІРЅРѕ
    if($VersionOld -ge $VersionNew){
        # СѓРґР°Р»СЏРµРј Рё Р·Р°РІРµСЂС€Р°РµРј СЂР°Р±РѕС‚Сѓ СЃРєСЂРёРїС‚Р°
        Remove-Item $GLBinNew
        exit 0
    }

    # РµСЃР»Рё РІРµСЂСЃРёСЏ РЅРѕРІР°СЏ, С‚РѕРіРґР° СЃС‚РѕРїР°РµРј, СѓРґР°Р»СЏРµРј, Рё СѓРґР°Р»СЏРµРј РёСЃРїРѕР»РЅСЏРµРјС‹Р№ С„Р°Р№Р»
    Write-Host "`nРЈСЃС‚Р°РЅРѕРІРєР° РІРµСЂСЃРёРё $VersionNew"
    & $bin stop      2>&1 | Write-Host
    & $bin uninstall 2>&1 | Write-Host
    Remove-Item $bin -Force

    # РїРµСЂРµРёРјРµРЅРѕРІС‹РІР°РµРј gitlab-runner_new.exe РІ gitlab-runner.exe
    Rename-Item $GLBinNew -NewName $GLBin
    # РџСЂРѕРІРѕРґРёРј СѓСЃС‚Р°РЅРѕРІСѓРє СЃ РїР°СЂР°РјРµС‚СЂР°РјРё
    & $GLBin install --user "$User" --password "$Pass" 2>&1 | Write-Host
    & $GLBin start 2>&1 | Write-Host

    Write-Host "`nDone."
}
# РџРµСЂРІРѕРЅР°С‡Р°Р»СЊРЅР°СЏ СѓСЃС‚Р°РЅРѕРІРєР°
else{
    # РЎРѕР·РґР°РµРј РґРёСЂРµРєС‚РѕСЂРёСЋ
    New-Item -ItemType Directory -Path $GLPath -ea 0
    Set-Location $GLPath

    # РїРѕР»СѓС‡Р°РµРј РёРјСЏ СЃРІРѕРµРіРѕ РєРѕРјРїР°, РµСЃР»Рё РѕРЅРѕ РЅРµ СЂР°РІРЅРѕ dev.kontur, С‚РѕРіРґР° РѕС‚РґР°РµРј $false='Evrika-prod'
    $Tags = @{$true='Evrika-dev';$false='Evrika-prod'}[([System.Net.Dns]::GetHostByName("localhost").HostName) -match 'dev.kontur']

    # РєР°С‡Р°РµРј РёСЃРїРѕР»РЅСЏРµРјС‹Р№ С„Р°Р№Р»
    Invoke-WebRequest -UseBasicParsing -Uri $Uri -OutFile $GLBin

    # СѓСЃС‚Р°РЅР°РІР»РёРІР°РµРј
    & $GLBin install --user "$User" --password "$Pass" 2>&1 | Write-Host

    # РјРµРЅСЏРµРј РїРѕР»РёС‚РёРєРё Р±РµР·РѕРїР°СЃРЅРѕСЃС‚Рё, Р° РёРјРµРЅРЅРѕ РїРѕР»СЊР·РѕРІР°С‚РµР»СЏ, gc=getcontent,sc=select content
    $tmp = New-TemporaryFile
    secedit /export /cfg "$tmp.inf" | Out-Null
    (gc -Encoding ascii "$tmp.inf") -replace '^SeServiceLogonRight .+', "`$0,$User" | sc -Encoding ascii "$tmp.inf"
    secedit /import /cfg "$tmp.inf" /db "$tmp.sdb" | Out-Null
    secedit /configure /db "$tmp.sdb" /cfg "$tmp.inf" | Out-Null
    rm $tmp* -ea 0

    # СЂРµРіРёСЃС‚СЂРёСЂСѓРµРјСЃСЏ РЅР° git
    & $GLBin register                     `
        --non-interactive                 `
        --url 'https://git.skbkontur.ru/' `
        --registration-token $Token       `
        --executor "shell"                `
        --description "Evrika"            `
        --tag-list $Tags 2>&1 | Write-Host

    # Р—Р°РїСѓСЃРє
    Write-Host "`nStart gitlab-runner"
    & $GLBin start 2>&1 | Write-Host
}
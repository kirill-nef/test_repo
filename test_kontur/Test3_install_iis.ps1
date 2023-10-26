$site_name = "mysite"
$site_port = 4321
$site_path = "$env:SystemDrive\$site_name"


# Р¤СѓРЅРєС†РёСЏ РїСЂРѕРІРµСЂРєРё РІРѕР·РјРѕР¶РЅРѕСЃС‚Рё СѓСЃС‚Р°РЅРѕРІРєРё WindowsFeature
if (!(Get-Command -Noun 'WindowsFeature')) {
    Write-Host "РќРµ РЅР°Р№РґРµРЅ РјРѕРґСѓР»СЊ WindowsFeature. РўРІРѕСЏ РІРµСЂСЃРёСЏ Windows РЅРµ РїРѕРґРґРµСЂР¶РёРІР°РµС‚ СЃРїРѕСЃРѕР± СѓСЃС‚Р°РЅРѕРІРєРё С‡РµСЂРµР· PowerShell." -ForegroundColor Red
    exit 1
}
Write-Host "РќР°С…РѕР¶Сѓ РјРѕРґСѓР»СЊ WindowsFeature, СЂР°Р±РѕС‚Р° СЃ IIS С‡РµСЂРµР· PowerShell РІРѕР·РјРѕР¶РЅР°!" -ForegroundColor Green


# Р¤СѓРЅРєС†РёСЏ СѓСЃС‚Р°РЅРѕРІРєРё iis
Write-Host "РџСЂРѕРІРµСЂСЏСЋ РЅР°Р»РёС‡РёРµ СѓСЃС‚Р°РЅРѕРІР»РµРЅРЅРѕРіРѕ Web-Server (IIS)." -ForegroundColor Yellow
if (!(Get-WindowsFeature -Name Web-Server | Where-Object Installed)) {
    Write-Host "Р—Р°РїСѓС‰РµРЅР° СѓСЃС‚Р°РЅРѕРІРєР° Web-Server (IIS)." -ForegroundColor Yellow
    Install-WindowsFeature -name Web-Server -IncludeManagementTool
}
Write-Host "Web-Server (IIS) СѓСЃС‚Р°РЅРѕРІР»РµРЅ." -ForegroundColor Green


# РђРєС‚РІРёСЂСѓРµРј РјРѕРґСѓР»СЊ Webadministration
Import-Module Webadministration


# РџСЂРѕРІРµСЂСЏСЋ РЅР°Р»РёС‡РёРµ Default Web Site, РµСЃР»Рё РѕРЅ РµСЃС‚СЊ - СѓРґР°Р»СЏСЋ
if (Get-ChildItem -Path IIS:\Sites | findstr 'Default Web Site') {
    Write-Host "РЈРґР°Р»СЏСЋ Default Web Site (РґРµС„РѕР»С‚РЅС‹Р№ СЃР°Р№С‚)." -ForegroundColor Yellow
    Remove-IISSite -Name "Default Web Site" -Confirm:$false
    if (Get-ChildItem -Path IIS:\Sites | findstr 'Default Web Site') {
        Write-Host "РќРµ СѓРґР°Р»РѕСЃСЊ СѓРґР°Р»РёС‚СЊ Default Web Site (РґРµС„РѕР»С‚РЅС‹Р№ СЃР°Р№С‚)." -ForegroundColor Red
    }
}


# РџСЂРѕРІРµСЂСЏСЋ РЅР°Р»РёС‡РёРµ СЃР°Р№С‚Р° $site_name, РµСЃР»Рё РµРіРѕ РЅРµС‚ - СѓСЃС‚Р°РЅРѕРІР»СЋ
if (!(Get-ChildItem -Path IIS:\Sites | findstr ${site_name})) {
    Write-Host "РЈСЃС‚Р°РЅР°РІР»РёРІР°СЋ СЃР°Р№С‚ $site_name РЅР° РїРѕСЂС‚Сѓ $site_port." -ForegroundColor Yellow
    mkdir $site_path -Force
    Copy-Item ".\html_data\*" -Destination "$site_path" -Recurse
    New-Item iis:\Sites\$site_name -bindings @{protocol="http";bindingInformation=":${site_port}:"} -physicalPath $site_path
    if (Get-ChildItem -Path IIS:\Sites | findstr ${site_name}) {
        Write-Host "РЎР°Р№С‚ $site_name СѓСЃС‚Р°РЅРѕРІР»РµРЅ." -ForegroundColor Green 
    }
    else {
        Write-Host "РЎР°Р№С‚ $site_name РЅРµ СѓСЃС‚Р°РЅРѕРІР»РµРЅ." -ForegroundColor Red 
    }
}


Write-Host "РќР°СЃС‚СЂР°РёРІР°СЋ Recycle." -ForegroundColor Yellow
set-ItemProperty 'IIS:\AppPools\DefaultAppPool' -Name Recycling.periodicRestart.time -Value 0.00:00:00
set-ItemProperty 'IIS:\AppPools\DefaultAppPool' -Name Recycling.periodicRestart.schedule -Value @{value="03:00:00"} 
Write-Host "РЈСЃС‚Р°РЅРѕРІРєР° Р·Р°РІРµСЂС€РµРЅР°!" -ForegroundColor Green
exit 0

$site_name = "mysite"
$site_port = 4321
$site_path = "$env:SystemDrive\$site_name"


# Функция проверки возможности установки WindowsFeature
if (!(Get-Command -Noun 'WindowsFeature')) {
    Write-Host "Не найден модуль WindowsFeature. Твоя версия Windows не поддерживает способ установки через PowerShell." -ForegroundColor Red
    exit 1
}
Write-Host "Нахожу модуль WindowsFeature, работа с IIS через PowerShell возможна!" -ForegroundColor Green


# Функция установки iis
Write-Host "Проверяю наличие установленного Web-Server (IIS)." -ForegroundColor Yellow
if (!(Get-WindowsFeature -Name Web-Server | Where-Object Installed)) {
    Write-Host "Запущена установка Web-Server (IIS)." -ForegroundColor Yellow
    Install-WindowsFeature -name Web-Server -IncludeManagementTool
}
Write-Host "Web-Server (IIS) установлен." -ForegroundColor Green


# Актвируем модуль Webadministration
Import-Module Webadministration


# Проверяю наличие Default Web Site, если он есть - удаляю
if (Get-ChildItem -Path IIS:\Sites | findstr 'Default Web Site') {
    Write-Host "Удаляю Default Web Site (дефолтный сайт)." -ForegroundColor Yellow
    Remove-IISSite -Name "Default Web Site" -Confirm:$false
    if (Get-ChildItem -Path IIS:\Sites | findstr 'Default Web Site') {
        Write-Host "Не удалось удалить Default Web Site (дефолтный сайт)." -ForegroundColor Red
    }
}


# Проверяю наличие сайта $site_name, если его нет - установлю
if (!(Get-ChildItem -Path IIS:\Sites | findstr ${site_name})) {
    Write-Host "Устанавливаю сайт $site_name на порту $site_port." -ForegroundColor Yellow
    mkdir $site_path -Force
    Copy-Item ".\html_data\*" -Destination "$site_path" -Recurse
    New-Item iis:\Sites\$site_name -bindings @{protocol="http";bindingInformation=":${site_port}:"} -physicalPath $site_path
    if (Get-ChildItem -Path IIS:\Sites | findstr ${site_name}) {
        Write-Host "Сайт $site_name установлен." -ForegroundColor Green 
    }
    else {
        Write-Host "Сайт $site_name не установлен." -ForegroundColor Red 
    }
}


Write-Host "Настраиваю Recycle." -ForegroundColor Yellow
set-ItemProperty 'IIS:\AppPools\DefaultAppPool' -Name Recycling.periodicRestart.time -Value 0.00:00:00
set-ItemProperty 'IIS:\AppPools\DefaultAppPool' -Name Recycling.periodicRestart.schedule -Value @{value="03:00:00"} 
Write-Host "Установка завершена!" -ForegroundColor Green
exit 0

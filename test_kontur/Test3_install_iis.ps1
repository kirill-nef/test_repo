$site_name = "mysite"
$site_port = 4321
$site_path = "$env:SystemDrive\$site_name"

# Функция проверки возможности установки WindowsFeature
function fn_check_module_wf {
    if (Get-Command -Noun 'WindowsFeature') {
        Write-Host "Нахожу модуль WindowsFeature, работа с IIS через PowerShell возможна!" -ForegroundColor Green
        return $true
    }
    else {
        Write-Host "Не найден модуль WindowsFeature. Твоя версия Windows не поддерживает способ установки через PowerShell." -ForegroundColor Red
        return $false
    }
}

# Функция проверки наличия установленного IIS
function fn_check_install_iis {
    Write-Host "Проверяю наличие установленного Web-Server (IIS)." -ForegroundColor Yellow
    if (Get-WindowsFeature -Name Web-Server | Where-Object Installed) {
        Write-Host "Web-Server (IIS) установлен." -ForegroundColor Green
        return $true
    }
    else {
        Write-Host "Web-Server (IIS) не установлен." -ForegroundColor Yellow
        return $false
    }
}

function fn_install_iis {
    Write-Host "Запущена установка Web-Server (IIS)." -ForegroundColor Yellow
    Install-WindowsFeature -name Web-Server -IncludeManagementTool
}

# Функция настройки и конфигурирования сайта
function fn_config_iis {
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
    if (Get-ChildItem -Path IIS:\Sites | findstr ${site_name}) {
        Write-Host "Сайт $site_name уже установлен." -ForegroundColor Green
    }
    else {
        Write-Host "Устанавливаю сайт $site_name на порту $site_port." -ForegroundColor Yellow
        mkdir $site_path -Force
        Copy-Item ".\html_data\*" -Destination "$site_path" -Recurse
        New-Item iis:\Sites\$site_name -bindings @{protocol="http";bindingInformation=":${site_port}:"} -physicalPath $site_path
        if (Get-ChildItem -Path IIS:\Sites | findstr ${site_name}) {
            Write-Host "Сайт $site_name установлен." -ForegroundColor Green 
        }
    }

    # Выполняю конфигурацию recycle
    Write-Host "Настраиваю Recycle." -ForegroundColor Yellow
    set-ItemProperty 'IIS:\AppPools\DefaultAppPool' -Name Recycling.periodicRestart.time -Value 0.00:00:00
    set-ItemProperty 'IIS:\AppPools\DefaultAppPool' -Name Recycling.periodicRestart.schedule -Value @{value="03:00:00"} 

    Write-Host "Установка завершена." -ForegroundColor Green
    exit 0
}

# Начинаем с проверки установленного модуля WindowsFeature
if (fn_check_module_wf) {
    # Проверяем наличие установленного IIS
    if (fn_check_install_iis) {
        # Вызываем функцию настройки IIS
        fn_config_iis
    }
    # Если не установлен, установим и настроим
    else {
        # Вызываем функцию установки IIS
        fn_install_iis
        # Проверяем установился-ли IIS
        if (fn_check_install_iis) {
            # Вызываем функцию настройки IIS
            fn_config_iis
        }
        else {
            Write-Host "Установка Web-Server (IIS) не удалась." -ForegroundColor Red
            exit 1
        }
    }
}
# Если модуль не найден, то выход
else {
    exit 1
}


# tttttt
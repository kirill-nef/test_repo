# C:\gitlab-runner\**
$GLPath = "$env:SystemDrive\gitlab-runner"
$GLBin  = "$GLPath\gitlab-runner.exe"

# Для любого скрипта или команды, выполняющегося вне сеанса, требуется using модификатор область для внедрения значений переменных из вызывающего сеанса область, чтобы получить к ним доступ из кода сеанса. Фоновые задания, запущенные с Start-Job (сеанс вне процесса).
$Token  = $using:Token
$User   = $using:User
$Pass   = $using:Pass


$GitUri = 'https://github.com/git-for-windows/git/releases/download/v2.25.0.windows.1/Git-2.25.0-64-bit.exe'
$Uri    = 'https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-windows-amd64.exe'

# При возникновении ошибок - молча продолжать
$progressPreference = 'silentlyContinue'

# Указываем типы протоколов безопасности
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'


# Устновка GIT
& git --version | Out-Null
if ($LASTEXITCODE -ne 0) {
    Set-Location "$env:windir\temp"
    Invoke-WebRequest -UseBasicParsing -Uri $GitUri -OutFile ".\git-installer.exe"
    Start-Process '.\git-installer.exe' -ArgumentList '/SILENT' -NoNewWindow -Wait
    Remove-Item '.\git-installer.exe' -Force
    # Обновление переменных
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# Настройка GIT
# -ea 0 (error action) - ошибка не выведется на экран - работа продолжится
# Тут используется обновление gitlab-runner
if(Get-Service "gitlab-runner" -ea 0){
    # получим полный путь до исполняемого файла, split - разбить по строка, Select-Object -First 1 - взять первый элемент из всех строк
    $bin = (Get-WmiObject win32_service | Where-Object{$_.Name -like 'gitlab-runner'} | Select-Object PathName).PathName -split ' ' | Select-Object -First 1
    # получаем папку где лежит исполняемый файл
    $GLPath = Split-Path $bin -Parent
    Set-Location $GLPath
    # Узнаем версию исполняемого файла, c помомщью рег выр -match ищем номер версии, Out-Null скроет значение
    & $bin --version | Where-Object {$_ -match '^Version:\s*(\d+\.\d+\.\d+)'} | Out-Null
    # Получем результат в виде - Major, minor, build
    $VersionOld = [version]$Matches[1]
    # если значение отстутсвует, выдать ошибку и завершить работу скрипта с кодом 1
    if(!$VersionOld) {
        throw "Error"
        exit 1
    }

    $GLBinNew = "$GLPath\gitlab-runner_new.exe"
    # качаем новый файл
    Invoke-WebRequest -UseBasicParsing -Uri $Uri -OutFile $GLBinNew

    # проверяем версию
    & $GLBinNew --version | Where-Object {$_ -match '^Version:\s*(\d+\.\d+\.\d+)'} | Out-Null
    $VersionNew = [version]$Matches[1]

    # сравнение, если больше или равно
    if($VersionOld -ge $VersionNew){
        # удаляем и завершаем работу скрипта
        Remove-Item $GLBinNew
        exit 0
    }

    # если версия новая, тогда стопаем, удаляем, и удаляем исполняемый файл
    Write-Host "`nУстановка версии $VersionNew"
    & $bin stop      2>&1 | Write-Host
    & $bin uninstall 2>&1 | Write-Host
    Remove-Item $bin -Force

    # переименовываем gitlab-runner_new.exe в gitlab-runner.exe
    Rename-Item $GLBinNew -NewName $GLBin
    # Проводим установук с параметрами
    & $GLBin install --user "$User" --password "$Pass" 2>&1 | Write-Host
    & $GLBin start 2>&1 | Write-Host

    Write-Host "`nDone."
}
# Первоначальная установка
else{
    # Создаем директорию
    New-Item -ItemType Directory -Path $GLPath -ea 0
    Set-Location $GLPath

    # получаем имя своего компа, если оно не равно dev.kontur, тогда отдаем $false='Evrika-prod'
    $Tags = @{$true='Evrika-dev';$false='Evrika-prod'}[([System.Net.Dns]::GetHostByName("localhost").HostName) -match 'dev.kontur']

    # качаем исполняемый файл
    Invoke-WebRequest -UseBasicParsing -Uri $Uri -OutFile $GLBin

    # устанавливаем
    & $GLBin install --user "$User" --password "$Pass" 2>&1 | Write-Host

    # меняем политики безопасности, а именно пользователя, gc=getcontent,sc=select content
    $tmp = New-TemporaryFile
    secedit /export /cfg "$tmp.inf" | Out-Null
    (gc -Encoding ascii "$tmp.inf") -replace '^SeServiceLogonRight .+', "`$0,$User" | sc -Encoding ascii "$tmp.inf"
    secedit /import /cfg "$tmp.inf" /db "$tmp.sdb" | Out-Null
    secedit /configure /db "$tmp.sdb" /cfg "$tmp.inf" | Out-Null
    rm $tmp* -ea 0

    # регистрируемся на git
    & $GLBin register                     `
        --non-interactive                 `
        --url 'https://git.skbkontur.ru/' `
        --registration-token $Token       `
        --executor "shell"                `
        --description "Evrika"            `
        --tag-list $Tags 2>&1 | Write-Host

    # Запуск
    Write-Host "`nStart gitlab-runner"
    & $GLBin start 2>&1 | Write-Host
}
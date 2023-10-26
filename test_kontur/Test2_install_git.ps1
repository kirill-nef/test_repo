# C:\gitlab-runner\**
$GLPath = "$env:SystemDrive\gitlab-runner"
$GLBin  = "$GLPath\gitlab-runner.exe"

# ��� ������ ������� ��� �������, �������������� ��� ������, ��������� using ����������� ������� ��� ��������� �������� ���������� �� ����������� ������ �������, ����� �������� � ��� ������ �� ���� ������. ������� �������, ���������� � Start-Job (����� ��� ��������).
$Token  = $using:Token
$User   = $using:User
$Pass   = $using:Pass


$GitUri = 'https://github.com/git-for-windows/git/releases/download/v2.25.0.windows.1/Git-2.25.0-64-bit.exe'
$Uri    = 'https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-windows-amd64.exe'

# ��� ������������� ������ - ����� ����������
$progressPreference = 'silentlyContinue'

# ��������� ���� ���������� ������������
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'


# �������� GIT
& git --version | Out-Null
if ($LASTEXITCODE -ne 0) {
    Set-Location "$env:windir\temp"
    Invoke-WebRequest -UseBasicParsing -Uri $GitUri -OutFile ".\git-installer.exe"
    Start-Process '.\git-installer.exe' -ArgumentList '/SILENT' -NoNewWindow -Wait
    Remove-Item '.\git-installer.exe' -Force
    # ���������� ����������
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# ��������� GIT
# -ea 0 (error action) - ������ �� ��������� �� ����� - ������ �����������
# ��� ������������ ���������� gitlab-runner
if(Get-Service "gitlab-runner" -ea 0){
    # ������� ������ ���� �� ������������ �����, split - ������� �� ������, Select-Object -First 1 - ����� ������ ������� �� ���� �����
    $bin = (Get-WmiObject win32_service | Where-Object{$_.Name -like 'gitlab-runner'} | Select-Object PathName).PathName -split ' ' | Select-Object -First 1
    # �������� ����� ��� ����� ����������� ����
    $GLPath = Split-Path $bin -Parent
    Set-Location $GLPath
    # ������ ������ ������������ �����, c �������� ��� ��� -match ���� ����� ������, Out-Null ������ ��������
    & $bin --version | Where-Object {$_ -match '^Version:\s*(\d+\.\d+\.\d+)'} | Out-Null
    # ������� ��������� � ���� - Major, minor, build
    $VersionOld = [version]$Matches[1]
    # ���� �������� �����������, ������ ������ � ��������� ������ ������� � ����� 1
    if(!$VersionOld) {
        throw "Error"
        exit 1
    }

    $GLBinNew = "$GLPath\gitlab-runner_new.exe"
    # ������ ����� ����
    Invoke-WebRequest -UseBasicParsing -Uri $Uri -OutFile $GLBinNew

    # ��������� ������
    & $GLBinNew --version | Where-Object {$_ -match '^Version:\s*(\d+\.\d+\.\d+)'} | Out-Null
    $VersionNew = [version]$Matches[1]

    # ���������, ���� ������ ��� �����
    if($VersionOld -ge $VersionNew){
        # ������� � ��������� ������ �������
        Remove-Item $GLBinNew
        exit 0
    }

    # ���� ������ �����, ����� �������, �������, � ������� ����������� ����
    Write-Host "`n��������� ������ $VersionNew"
    & $bin stop      2>&1 | Write-Host
    & $bin uninstall 2>&1 | Write-Host
    Remove-Item $bin -Force

    # ��������������� gitlab-runner_new.exe � gitlab-runner.exe
    Rename-Item $GLBinNew -NewName $GLBin
    # �������� ��������� � �����������
    & $GLBin install --user "$User" --password "$Pass" 2>&1 | Write-Host
    & $GLBin start 2>&1 | Write-Host

    Write-Host "`nDone."
}
# �������������� ���������
else{
    # ������� ����������
    New-Item -ItemType Directory -Path $GLPath -ea 0
    Set-Location $GLPath

    # �������� ��� ������ �����, ���� ��� �� ����� dev.kontur, ����� ������ $false='Evrika-prod'
    $Tags = @{$true='Evrika-dev';$false='Evrika-prod'}[([System.Net.Dns]::GetHostByName("localhost").HostName) -match 'dev.kontur']

    # ������ ����������� ����
    Invoke-WebRequest -UseBasicParsing -Uri $Uri -OutFile $GLBin

    # �������������
    & $GLBin install --user "$User" --password "$Pass" 2>&1 | Write-Host

    # ������ �������� ������������, � ������ ������������, gc=getcontent,sc=select content
    $tmp = New-TemporaryFile
    secedit /export /cfg "$tmp.inf" | Out-Null
    (gc -Encoding ascii "$tmp.inf") -replace '^SeServiceLogonRight .+', "`$0,$User" | sc -Encoding ascii "$tmp.inf"
    secedit /import /cfg "$tmp.inf" /db "$tmp.sdb" | Out-Null
    secedit /configure /db "$tmp.sdb" /cfg "$tmp.inf" | Out-Null
    rm $tmp* -ea 0

    # �������������� �� git
    & $GLBin register                     `
        --non-interactive                 `
        --url 'https://git.skbkontur.ru/' `
        --registration-token $Token       `
        --executor "shell"                `
        --description "Evrika"            `
        --tag-list $Tags 2>&1 | Write-Host

    # ������
    Write-Host "`nStart gitlab-runner"
    & $GLBin start 2>&1 | Write-Host
}
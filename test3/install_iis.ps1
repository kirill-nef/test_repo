$site_name = "mysite"
$site_port = 4321
$site_path = "$env:SystemDrive\$site_name"

# ������� �������� ����������� ��������� WindowsFeature
function fn_check_module_wf {
    if (Get-Command -Noun 'WindowsFeature') {
        Write-Host "������ ������ WindowsFeature, ������ � IIS ����� PowerShell ��������!" -ForegroundColor Green
        return $true
    }
    else {
        Write-Host "�� ������ ������ WindowsFeature. ���� ������ Windows �� ������������ ������ ��������� ����� PowerShell." -ForegroundColor Red
        return $false
    }
}

# ������� �������� ������� �������������� IIS
function fn_check_install_iis {
    Write-Host "�������� ������� �������������� Web-Server (IIS)." -ForegroundColor Yellow
    if (Get-WindowsFeature -Name Web-Server | Where-Object Installed) {
        Write-Host "Web-Server (IIS) ����������." -ForegroundColor Green
        return $true
    }
    else {
        Write-Host "Web-Server (IIS) �� ����������." -ForegroundColor Yellow
        return $false
    }
}

function fn_install_iis {
    Write-Host "�������� ��������� Web-Server (IIS)." -ForegroundColor Yellow
    Install-WindowsFeature -name Web-Server -IncludeManagementTool
}

# ������� ��������� � ���������������� �����
function fn_config_iis {
    # ��������� ������ Webadministration
    Import-Module Webadministration

    # �������� ������� Default Web Site, ���� �� ���� - ������
    if (Get-ChildItem -Path IIS:\Sites | findstr 'Default Web Site') {
        Write-Host "������ Default Web Site (��������� ����)." -ForegroundColor Yellow
        Remove-IISSite -Name "Default Web Site" -Confirm:$false
        if (Get-ChildItem -Path IIS:\Sites | findstr 'Default Web Site') {
            Write-Host "�� ������� ������� Default Web Site (��������� ����)." -ForegroundColor Red
        }
    }

    # �������� ������� ����� $site_name, ���� ��� ��� - ���������
    if (Get-ChildItem -Path IIS:\Sites | findstr ${site_name}) {
        Write-Host "���� $site_name ��� ����������." -ForegroundColor Green
    }
    else {
        Write-Host "������������ ���� $site_name �� ����� $site_port." -ForegroundColor Yellow
        mkdir $site_path -Force
        Copy-Item ".\html_data\*" -Destination "$site_path" -Recurse
        New-Item iis:\Sites\$site_name -bindings @{protocol="http";bindingInformation=":${site_port}:"} -physicalPath $site_path
        if (Get-ChildItem -Path IIS:\Sites | findstr ${site_name}) {
            Write-Host "���� $site_name ����������." -ForegroundColor Green 
        }
    }

    # �������� ������������ recycle
    Write-Host "���������� Recycle." -ForegroundColor Yellow
    set-ItemProperty 'IIS:\AppPools\DefaultAppPool' -Name Recycling.periodicRestart.time -Value 0.00:00:00
    set-ItemProperty 'IIS:\AppPools\DefaultAppPool' -Name Recycling.periodicRestart.schedule -Value @{value="03:00:00"} 

    Write-Host "��������� ���������." -ForegroundColor Green
    exit 0
}

# �������� � �������� �������������� ������ WindowsFeature
if (fn_check_module_wf) {
    # ��������� ������� �������������� IIS
    if (fn_check_install_iis) {
        # �������� ������� ��������� IIS
        fn_config_iis
    }
    # ���� �� ����������, ��������� � ��������
    else {
        # �������� ������� ��������� IIS
        fn_install_iis
        # ��������� �����������-�� IIS
        if (fn_check_install_iis) {
            # �������� ������� ��������� IIS
            fn_config_iis
        }
        else {
            Write-Host "��������� Web-Server (IIS) �� �������." -ForegroundColor Red
            exit 1
        }
    }
}
# ���� ������ �� ������, �� �����
else {
    exit 1
}

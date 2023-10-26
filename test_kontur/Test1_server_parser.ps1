# ������ �������, ������������� ������ � ������� �������� vm-test[1-3],vm-test3,vm-test[4-7],vm-test8
# � ������ ���� vm-test1 vm-test2 vm-test3 vm-test3 vm-test4 vm-test5 vm-test6 vm-test7 vm-test8.

# ������� ������
$in_servers_data = 'vm-test[1-3],vm-test3,vm-test[4-7],vm-test8'

# ����������� � ������
$in_servers_data_arr = $in_servers_data -split ','

# ������ ������ ��� ������
$arr_out = @()

# � ����� ����� ������ �������
foreach ($el_servers_data_arr in $in_servers_data_arr) {

    # ��������� ������� ������
    if ($el_servers_data_arr -match [Regex]::Escape("[")) {
        # �������� ��� �������
        $serv_name = $el_servers_data_arr.Substring(0,$el_servers_data_arr.IndexOf('['))
        # �������� �������� ����� � �������, ����������� [] � ! ��� �������
        $servers_data_arr = $el_servers_data_arr -replace [Regex]::Escape("]"), "!" -replace [Regex]::Escape("["), "!" -match '!(.*)!'
        # ����������� - � .. ����� ��������� �������� ��������
        $servers_data_arr = $Matches[0] -replace [Regex]::Escape("!"), "" -replace "-", ".."
        $servers_data_arr = invoke-expression $servers_data_arr 
        # ����� ����� ����, ������� � ����� ������
        foreach ($elem_arr in $servers_data_arr) {
            $arr_out += $serv_name+$elem_arr
        }
    }
    else {
        # ������� � ������ ��� ������� ��� ������
        $arr_out += $el_servers_data_arr
    }
}

$arr_out -join ' '
'�����'
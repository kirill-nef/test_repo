# ����� �㭪��, �८�ࠧ����� ��ப� � ������� �ࢥ஢ vm-test[1-3],vm-test3,vm-test[4-7],vm-test8
# � ᯨ᮪ ���� vm-test1 vm-test2 vm-test3 vm-test3 vm-test4 vm-test5 vm-test6 vm-test7 vm-test8.

# �室�� �����
$in_servers_data = 'vm-test[1-3],vm-test3,vm-test[4-7],vm-test8'

# �८�ࠧ㥬 � ���ᨢ
$in_servers_data_arr = $in_servers_data -split ','

# ���⮩ ���ᨢ ��� �뢮��
$arr_out = @()

# � 横�� ��६ ����� �����
foreach ($el_servers_data_arr in $in_servers_data_arr) {

    # �஢��塞 ����稥 ᪮���
    if ($el_servers_data_arr -match [Regex]::Escape("[")) {
        # �⤥�塞 ��� �ࢥ�
        $serv_name = $el_servers_data_arr.Substring(0,$el_servers_data_arr.IndexOf('['))
        # ����砥� �������� �ᥫ � ᪮����, �८�ࠧ㥬 [] � ! ��� 㮡�⢠
        $servers_data_arr = $el_servers_data_arr -replace [Regex]::Escape("]"), "!" -replace [Regex]::Escape("["), "!" -match '!(.*)!'
        # �८�ࠧ㥬 - � .. �⮡� ����稫�� �������� ���祭��
        $servers_data_arr = $Matches[0] -replace [Regex]::Escape("!"), "" -replace "-", ".."
        $servers_data_arr = invoke-expression $servers_data_arr 
        # ����� �᫠ ����, ����㥬 � ��騩 ���ᨢ
        foreach ($elem_arr in $servers_data_arr) {
            $arr_out += $serv_name+$elem_arr
        }
    }
    else {
        # ����㥬 � ���ᨢ ��� �ࢥ� ��� ᪮���
        $arr_out += $el_servers_data_arr
    }
}

$arr_out -join ' '
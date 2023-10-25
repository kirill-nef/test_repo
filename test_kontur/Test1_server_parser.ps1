# Напиши функцию, преобразующую строку с именами серверов vm-test[1-3],vm-test3,vm-test[4-7],vm-test8
# в список вида vm-test1 vm-test2 vm-test3 vm-test3 vm-test4 vm-test5 vm-test6 vm-test7 vm-test8.

# Входные данные
$in_servers_data = 'vm-test[1-3],vm-test3,vm-test[4-7],vm-test8'

# Преобразуем в массив
$in_servers_data_arr = $in_servers_data -split ','

# Пустой массив для вывода
$arr_out = @()

# В цикле берем каждый элемент
foreach ($el_servers_data_arr in $in_servers_data_arr) {

    # Проверяем наличие скобок
    if ($el_servers_data_arr -match [Regex]::Escape("[")) {
        # Отделяем имя сервера
        $serv_name = $el_servers_data_arr.Substring(0,$el_servers_data_arr.IndexOf('['))
        # Получаем диапазон чисел в скобках, Преобразуем [] в ! для уобства
        $servers_data_arr = $el_servers_data_arr -replace [Regex]::Escape("]"), "!" -replace [Regex]::Escape("["), "!" -match '!(.*)!'
        # Преобразуем - в .. чтобы получился диапазон значений
        $servers_data_arr = $Matches[0] -replace [Regex]::Escape("!"), "" -replace "-", ".."
        $servers_data_arr = invoke-expression $servers_data_arr 
        # Какие числа есть, плюсуем в общий массив
        foreach ($elem_arr in $servers_data_arr) {
            $arr_out += $serv_name+$elem_arr
        }
    }
    else {
        # Плюсуем в массив имя сервера без скобок
        $arr_out += $el_servers_data_arr
    }
}

$arr_out -join ' '
# ТЗ 
# Напиши функцию, преобразующую строку с именами серверов vm-test[1-3],vm-test3,vm-test[4-7],vm-test8 в список вида vm-test1 vm-test2 vm-test3 vm-test3 vm-test4 vm-test5 vm-test6 vm-test7 vm-test8.

# Вводные данные
servers_data = 'vm-test[1-3], vm-test3, vm-test[4-7], vm-test8'

def convert_data(in_servers_data):
    # Преобразуем строку в массив
    in_data_to_arr = in_servers_data.replace(' ', '').split(',')

    # Массив выходных данных
    out_data_arr=[]

    # В цикле обрабатываем каждый элемент массива
    for elem_arr in in_data_to_arr:
        # если элемент содержит скобки
        if '[' in elem_arr and ']' in elem_arr:
            # Получаем имя сервера
            serv_name_pref = elem_arr[0:elem_arr.find('[')]
            # Получаем номера сервера и создаем массив
            sev_num_pref = elem_arr[elem_arr.find('[')+1:elem_arr.find(']')].split('-')
            # Создаем новый массив
            new_sev_num_pref = []
            new_sev_num_pref.extend(range(int(sev_num_pref[0]), int(sev_num_pref[1]) + 1))

            # В цикле заполняем массив выходных данных
            for elem in new_sev_num_pref:
                out_data_arr.append(serv_name_pref+str(elem))
        # если элемент без скобок
        else:
            out_data_arr.append(elem_arr)
    # Сортируем и убираем повторяющиеся значения и преобразуем в строку
    return ', '.join(sorted(list(set(out_data_arr))))

print(convert_data(servers_data))  
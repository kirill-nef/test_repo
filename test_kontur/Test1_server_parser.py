# РќР°РїРёС€Рё С„СѓРЅРєС†РёСЋ, РїСЂРµРѕР±СЂР°Р·СѓСЋС‰СѓСЋ СЃС‚СЂРѕРєСѓ СЃ РёРјРµРЅР°РјРё СЃРµСЂРІРµСЂРѕРІ vm-test[1-3],vm-test3,vm-test[4-7],vm-test8
# РІ СЃРїРёСЃРѕРє РІРёРґР° vm-test1 vm-test2 vm-test3 vm-test3 vm-test4 vm-test5 vm-test6 vm-test7 vm-test8.

# Р’РІРѕРґРЅС‹Рµ РґР°РЅРЅС‹Рµ
servers_data = 'vm-test[1-3], vm-test3, vm-test[4-7], vm-test8'

def convert_data(in_servers_data):
    # РџСЂРµРѕР±СЂР°Р·СѓРµРј СЃС‚СЂРѕРєСѓ РІ РјР°СЃСЃРёРІ
    in_data_to_arr = in_servers_data.replace(' ', '').split(',')

    # РњР°СЃСЃРёРІ РІС‹С…РѕРґРЅС‹С… РґР°РЅРЅС‹С…
    out_data_arr=[]

    # Р’ С†РёРєР»Рµ РѕР±СЂР°Р±Р°С‚С‹РІР°РµРј РєР°Р¶РґС‹Р№ СЌР»РµРјРµРЅС‚ РјР°СЃСЃРёРІР°
    for elem_arr in in_data_to_arr:
        # РµСЃР»Рё СЌР»РµРјРµРЅС‚ СЃРѕРґРµСЂР¶РёС‚ СЃРєРѕР±РєРё
        if '[' in elem_arr and ']' in elem_arr:
            # РџРѕР»СѓС‡Р°РµРј РёРјСЏ СЃРµСЂРІРµСЂР°
            serv_name_pref = elem_arr[0:elem_arr.find('[')]
            # РџРѕР»СѓС‡Р°РµРј РЅРѕРјРµСЂР° СЃРµСЂРІРµСЂР° Рё СЃРѕР·РґР°РµРј РјР°СЃСЃРёРІ
            sev_num_pref = elem_arr[elem_arr.find('[')+1:elem_arr.find(']')].split('-')
            # РЎРѕР·РґР°РµРј РЅРѕРІС‹Р№ РјР°СЃСЃРёРІ РёР· С‡РёСЃРµР» [1-4] РІ [1,2,3,4]
            new_sev_num_pref = []
            new_sev_num_pref.extend(range(int(sev_num_pref[0]), int(sev_num_pref[1]) + 1))
            # Р’ С†РёРєР»Рµ Р·Р°РїРѕР»РЅСЏРµРј РјР°СЃСЃРёРІ РІС‹С…РѕРґРЅС‹С… РґР°РЅРЅС‹С… (СЃРєР»РµРёРІР°РµРј РёРјСЏ СЃРµСЂРІРµСЂР° Рё РЅРѕРјРµСЂ)
            for elem in new_sev_num_pref:
                out_data_arr.append(serv_name_pref+str(elem))
        # РµСЃР»Рё СЌР»РµРјРµРЅС‚ Р±РµР· СЃРєРѕР±РѕРє
        else:
            out_data_arr.append(elem_arr)
    # РЎРѕСЂС‚РёСЂСѓРµРј Рё РїСЂРµРѕР±СЂР°Р·СѓРµРј РІ СЃС‚СЂРѕРєСѓ
    return ' '.join(sorted(out_data_arr))

print(convert_data(servers_data))
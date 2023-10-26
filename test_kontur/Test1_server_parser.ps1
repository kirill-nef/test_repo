# РќР°РїРёС€Рё С„СѓРЅРєС†РёСЋ, РїСЂРµРѕР±СЂР°Р·СѓСЋС‰СѓСЋ СЃС‚СЂРѕРєСѓ СЃ РёРјРµРЅР°РјРё СЃРµСЂРІРµСЂРѕРІ vm-test[1-3],vm-test3,vm-test[4-7],vm-test8
# РІ СЃРїРёСЃРѕРє РІРёРґР° vm-test1 vm-test2 vm-test3 vm-test3 vm-test4 vm-test5 vm-test6 vm-test7 vm-test8.

# Р’С…РѕРґРЅС‹Рµ РґР°РЅРЅС‹Рµ
$in_servers_data = 'vm-test[1-3],vm-test3,vm-test[4-7],vm-test8'

# РџСЂРµРѕР±СЂР°Р·СѓРµРј РІ РјР°СЃСЃРёРІ
$in_servers_data_arr = $in_servers_data -split ','

# РџСѓСЃС‚РѕР№ РјР°СЃСЃРёРІ РґР»СЏ РІС‹РІРѕРґР°
$arr_out = @()

# Р’ С†РёРєР»Рµ Р±РµСЂРµРј РєР°Р¶РґС‹Р№ СЌР»РµРјРµРЅС‚
foreach ($el_servers_data_arr in $in_servers_data_arr) {

    # РџСЂРѕРІРµСЂСЏРµРј РЅР°Р»РёС‡РёРµ СЃРєРѕР±РѕРє
    if ($el_servers_data_arr -match [Regex]::Escape("[")) {
        # РћС‚РґРµР»СЏРµРј РёРјСЏ СЃРµСЂРІРµСЂР°
        $serv_name = $el_servers_data_arr.Substring(0,$el_servers_data_arr.IndexOf('['))
        # РџРѕР»СѓС‡Р°РµРј РґРёР°РїР°Р·РѕРЅ С‡РёСЃРµР» РІ СЃРєРѕР±РєР°С…, РџСЂРµРѕР±СЂР°Р·СѓРµРј [] РІ ! РґР»СЏ СѓРѕР±СЃС‚РІР°
        $servers_data_arr = $el_servers_data_arr -replace [Regex]::Escape("]"), "!" -replace [Regex]::Escape("["), "!" -match '!(.*)!'
        # РџСЂРµРѕР±СЂР°Р·СѓРµРј - РІ .. С‡С‚РѕР±С‹ РїРѕР»СѓС‡РёР»СЃСЏ РґРёР°РїР°Р·РѕРЅ Р·РЅР°С‡РµРЅРёР№
        $servers_data_arr = $Matches[0] -replace [Regex]::Escape("!"), "" -replace "-", ".."
        $servers_data_arr = invoke-expression $servers_data_arr 
        # РљР°РєРёРµ С‡РёСЃР»Р° РµСЃС‚СЊ, РїР»СЋСЃСѓРµРј РІ РѕР±С‰РёР№ РјР°СЃСЃРёРІ
        foreach ($elem_arr in $servers_data_arr) {
            $arr_out += $serv_name+$elem_arr
        }
    }
    else {
        # РџР»СЋСЃСѓРµРј РІ РјР°СЃСЃРёРІ РёРјСЏ СЃРµСЂРІРµСЂР° Р±РµР· СЃРєРѕР±РѕРє
        $arr_out += $el_servers_data_arr
    }
}

$arr_out -join ' '
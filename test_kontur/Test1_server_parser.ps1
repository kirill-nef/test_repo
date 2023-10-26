# Ќ ЇЁиЁ дг­ЄжЁо, ЇаҐ®Ўа §гойго бва®Єг б Ё¬Ґ­ ¬Ё бҐаўҐа®ў vm-test[1-3],vm-test3,vm-test[4-7],vm-test8
# ў бЇЁб®Є ўЁ¤  vm-test1 vm-test2 vm-test3 vm-test3 vm-test4 vm-test5 vm-test6 vm-test7 vm-test8.

# ‚е®¤­лҐ ¤ ­­лҐ
$in_servers_data = 'vm-test[1-3],vm-test3,vm-test[4-7],vm-test8'

# ЏаҐ®Ўа §гҐ¬ ў ¬ ббЁў
$in_servers_data_arr = $in_servers_data -split ','

# Џгбв®© ¬ ббЁў ¤«п ўлў®¤ 
$arr_out = @()

# ‚ жЁЄ«Ґ ЎҐаҐ¬ Є ¦¤л© н«Ґ¬Ґ­в
foreach ($el_servers_data_arr in $in_servers_data_arr) {

    # Џа®ўҐапҐ¬ ­ «ЁзЁҐ бЄ®Ў®Є
    if ($el_servers_data_arr -match [Regex]::Escape("[")) {
        # Ћв¤Ґ«пҐ¬ Ё¬п бҐаўҐа 
        $serv_name = $el_servers_data_arr.Substring(0,$el_servers_data_arr.IndexOf('['))
        # Џ®«гз Ґ¬ ¤Ё Ї §®­ зЁбҐ« ў бЄ®ЎЄ е, ЏаҐ®Ўа §гҐ¬ [] ў ! ¤«п г®Ўбвў 
        $servers_data_arr = $el_servers_data_arr -replace [Regex]::Escape("]"), "!" -replace [Regex]::Escape("["), "!" -match '!(.*)!'
        # ЏаҐ®Ўа §гҐ¬ - ў .. зв®Ўл Ї®«гзЁ«бп ¤Ё Ї §®­ §­ зҐ­Ё©
        $servers_data_arr = $Matches[0] -replace [Regex]::Escape("!"), "" -replace "-", ".."
        $servers_data_arr = invoke-expression $servers_data_arr 
        # Љ ЄЁҐ зЁб«  Ґбвм, Ї«обгҐ¬ ў ®ЎйЁ© ¬ ббЁў
        foreach ($elem_arr in $servers_data_arr) {
            $arr_out += $serv_name+$elem_arr
        }
    }
    else {
        # Џ«обгҐ¬ ў ¬ ббЁў Ё¬п бҐаўҐа  ЎҐ§ бЄ®Ў®Є
        $arr_out += $el_servers_data_arr
    }
}

$arr_out -join ' '
#文字コード：UTF-8 with BOM
#This project is hosted at GitHub: https://github.com/minsk19/shortcut
#version2.1 2022/6/16



######################プログラム########################
#環境設定のファイル読み込み
. ./config_env.ps1

$lines = @()

if($window_powershell){
    if($Args[0] -ne "true"){
        $script_name = $myInvocation.MyCommand.name
        start-process powershell -ArgumentList ("./"+$script_name,"true")
        exit
    }
}

#設定ファイルの読み込みとこのスクリプトがある場所をカレントディレクトリにする
$current_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$configfilepath_1 = $current_dir + "\" + $config_file_name_1
Set-Location $current_dir

$aliasfilepath = $current_dir + "\" + $alias_file_name

function reloadconfig(){
    $lines.clear()
    #Write-Output "reloadconfig"
    #Write-Output $configfilepath_1
    $lines_origin = Get-Content -Encoding "UTF8" $configfilepath_1

    #エイリアスとコメントアウト行の処理
    $lines_alias = Get-Content -Encoding "UTF8" $aliasfilepath
    for($idx=0;$idx -lt $lines_origin.Length;$idx = $idx+1){
        # Write-Output $lines[$idx]
        if(($lines_origin[$idx] -like "#*") -Or (($lines_origin[$idx] -eq ""))){
            #コメントアウトor空行の行は飛ばす
            #なにもしない
        }else{
            #コメントアウトでない行は
            #各ファイル名の行とエイリアス設定と突合する
            for($idx2=0;$idx2 -lt $lines_alias.Length;$idx2 = $idx2+1){
                #もし$lines[$idx]の中にlines_alias[$idx2]の文字が含まれていたら、lにlines_alias[$idx]を追加
                $alias = $lines_alias[$idx2] -split ","
                for($idx3=0;$idx3 -lt $alias.Length;$idx3 = $idx3+1){
                    if($lines_origin[$idx].Contains($alias[$idx3]) -and ($alias[$idx3] -ne "")){
                        $lines_origin[$idx] = $lines_origin[$idx] + " $ " +$lines_alias[$idx2]
                        break
                    }
                }
            }
            $lines += $lines_origin[$idx]
            $lines += $lines_origin[$idx+1]
            $idx = $idx+1
        }
    }
    $lines_origin.clear()
}

function check(){
    Write-Output "存在しないフォルダ または ファイルの一覧"
    $lines_origin = Get-Content -Encoding "UTF8" $configfilepath_1

    for($idx=0;$idx -lt $lines_origin.Length;$idx = $idx+1){
        if(($lines_origin[$idx] -like "#*") -Or (($lines_origin[$idx] -eq ""))){
            #コメントアウトor空行の行は飛ばす
            #なにもしない
        }else{
            $path = $lines_origin[$idx+1]
            if((Test-Path $path) -or ($path -match "https?://[\w/:%#\$&\?\(\)~\.=\+\-]+") -or ($path -like "shell:*")){
                # ファイルが存在した or httpで始まっていた or UMPアプリだった
                # Write-Output "ファイルはあった" + $path
            }else{
                $gyo = $idx +1
                Write-Output "$gyo 行目"
                Write-Output $lines_origin[$idx]
                Write-Output $lines_origin[$idx+1]
            }
            $idx = $idx +1
        }
    }
}

. reloadconfig #ドットソースで処理を呼び出すと、呼出元と呼出先の変数のスコープが同一となるため

while(1){
    #####キーワード入力#####
    $result = @()
    $Input = Read-Host ">>"
    #特殊コマンド:設定ファイルの再読み込み
    if($input -eq "#reload"){
        . reloadconfig
    }
    #特殊コマンド:設定ファイルをサクラエディタで開く
    if($input -eq "#edit"){
        Write-Output "設定ファイルを開く"
        Write-Output "編集後は#reloadコマンドを実行すべし"
        start-process $sakura -ArgumentList $configfilepath_1
    }

    if($input -eq "#alias"){
        Write-Output "エイリアス設定を開く"
        Write-Output "編集後は#reloadコマンドを実行すべし"
        start-process $sakura -ArgumentList $aliasfilepath
    }

    #特殊コマンド:新しいウィンドウで開く
    if($input -eq "#restart"){
        $script_name = $myInvocation.MyCommand.name
        start-process powershell -ArgumentList ("./"+$script_name,"true")
        exit
    }

    #特殊コマンド:設定ファイルに追記
    if($input -eq "#add"){
        Write-Output "設定ファイルの末尾に追記"
        $add_key = Read-Host "キーワードを入力>>"
        $add_path = Read-Host "パスを入力>>"
        Write-Output "この内容を設定ファイルに追記しますか？"
        Write-Output "キーワード↓"$add_key
        Write-Output "パス↓"$add_path
        $ok = Read-Host "[y or n]"
        if($ok -eq "y"){
            . reloadconfig
            $temp="`r`n"
            $temp=$temp+"#####Added at "+(Get-Date -U “%Y%m%d_%H%M”)+ "`r`n"
            $temp=$temp+$add_key+ "`r`n"+$add_path
            Write-Output $temp | Add-Content $configfilepath_1 -Encoding "UTF8"
            . reloadconfig
            Write-Output "追記完了"
        }
    }
    #特殊コマンド:ファイルの存在チェック
    if($input -eq "#check"){
        . check
    }

    #デバッグ用 設定ファイルの表示
    if($input -eq "#show"){
        Write-Output "-----変数&環境設定-----"
        Write-Output ("このスクリプトのパス&カレントディレクトリ"+$current_dir)
        Write-Output ("configfilepath_1     "+$configfilepath_1)
        Write-Output ("Input              "+$Input)
        Write-Output ("path               "+$path)
        Write-Output ("maxlength          "+$maxlength)
        Write-Output ("display_right      "+$display_right)
        Write-Output ("display_left       "+$display_left)
        $tmp = Get-ExecutionPolicy
        Write-Output ("Get-ExecutionPolicy "+$tmp)
        Write-Output "-----設定ファイル-----lines"
        Write-Output $lines
        $Input = ""
    }

    #特殊コマンド:googleで検索
    if($Input -match "#google*"){
        #googleで検索
        if($Input -ne "#google"){
            $arg = "https://www.google.com/search?q=" + $Input.Substring(8,$Input.length-8)
            $arg = $arg.Replace("　","+")
            $arg = $arg.Replace(" ","+")
            start-process chrome -ArgumentList ($arg)
            $Input = ""
        }else{
            $Input = "google"
        }
    }

    #####検索#####
    #検索結果を新しい配列に入れる
    if($Input  -ne ""){
        #全角数字を半角に
        $Input = [regex]::replace($Input,"[０-９]", { $args.value[0] - 65248 -as "char" })
        #全角スペースを半角にしてAND検索できるように配列keyに入れる
        $Input = $Input.Replace("　"," ")
        $key = $Input -split " "
        
        for($idx=0;$idx -lt $lines.Length;$idx = $idx+1){
            # Write-Output $lines[$idx]
            if(($lines[$idx] -like "#*") -Or (($lines[$idx] -eq ""))){
                #コメントアウトor空行の行は飛ばす
                #なにもしない
            }else{
                #コメントアウトでない行は
                #AND検索して(keyの文字列が設定ファイルの各行にあるかどうかを調べる)
                #もしヒットすれば配列$resultの偶数個目にキーワード、奇数個目にそのファイルパスの順に格納していく
                #AND検索する
                $flag = $TRUE #最後までtrueならヒット
                $l = $lines[$idx]
                for($i=0;$i -lt $key.length;$i++){#and検索
                    if($l -notlike "*"+[string]$key[$i]+"*"){
                        $flag = $FALSE
                        break
                    }
                }
                #検索にヒットしたら結果を格納する
                if($flag){
                    $result += $lines[$idx]
                    $result += $lines[$idx+1]
                }
                $idx = $idx+1
            }
        }
    }

    #####検索結果表示#####
    if($result.length -ne 0){
        #Write-Output "================Result====================="
        for($idx=0;$idx -lt $result.length;$idx = $idx+2){
            $out = [string]($idx/2 + 1)
            $out = $out + ">>"
            if($display_title){
                #$display_titleがtrueのとき結果表示にパスタイトルを表示する
                $out = $out + [string]$result[$idx] + "`r`n"
                if($out.LastIndexOf("$") -ge 1){
                    $out = $out.Remove($out.IndexOf("$"),$out.length - $out.IndexOf("$"))+ "`r`n"
                }
                $space = "   "
                if(($idx/2 + 1) -ge 10){
                    $space = $space + " "
                }
            }else{
                $space = " "
            }
            $temp = [string]$result[$idx+1]
            if($temp.length -ge $maxlength){
                #1行が長すぎるときの整形
                $out = $out + $space + $temp.Substring(0,$display_left) +"....."
                $out = $out + $temp.Substring($temp.length - $display_right,$display_right )
            }else{
                $out = $out + $space + $result[$idx+1]
            }
            $out = $out + "  >>" + [string]($idx/2 + 1)
        $out
        }
    }
    #$result.length

    #####ファイル/フォルダを開く#####
    if($result.length -ne 0){
        $Input = Read-Host ":"
        #全角数字を半角に
        $Input = [regex]::replace($Input,"[０-９]", { $args.value[0] - 65248 -as "char" })
        #入力値チェック


        if($Input -eq ""){
            #何も入力がなかったら1が入力されたとする
            $Input = 1
        }
        if($Input -match "^\d{1,}$"){
            #数字だった場合は規定のプログラム or Tablacus Explorerで開く
            #ただしURLの場合は規定のプログラムを無視してchromeで開く
            if($result.length -ge ([int]$Input*2)){
                #入力値が結果の数以下を確認する
                $path = $result[($Input-1)*2+1]

                if($path -match "https?://[\w/:%#\$&\?\(\)~\.=\+\-]+"){
                    start-process chrome -ArgumentList $path
                }else{
                    $item = Get-Item $path
                    if($tablacus){#tablacusで開く
                        if($item.PSIsContainer){#pathがフォルダの場合
                            start-process $tablacus_exe -ArgumentList $path
                        }else{                  #pathがファイルの場合
                            #Tablacusの引数に入れてもファイルは開かないのでデフォルトアプリで開く
                            start-process $path
                        }
                    }else{#標準エクスプローラーで開く
                        start-process $path
                    }
                }
                #explorer.exe $path #なんかこれだと遅い気がする
            }else{
                Write-Output "error"
            }
        }elseif($Input -match "^cl\s\d{1,}$"){
        #開くアプリケーションを指定した場合
            #開くアプリケーション指定(クリップボード貼り付け)
            $Input = $Input.Substring(3,$Input.length-3)
            $path = $result[($Input-1)*2+1]
            Set-Clipboard $path
            Write-Output ("copied>>"+$path)
        }elseif($Input -match "^ps\s\d{1,}$"){
            #開くアプリケーション指定(Powershellで開く)
            #もしファイルならそのファイルがあるフォルダを開く(未実装)
            $Input = $Input.Substring(3,$Input.length-3)
            $tmp = "-Noexit -command `"Get-Date;cd `'"
            $tmp += $result[($Input-1)*2+1]
            $tmp += "`';"
            $tmp += "Set-Alias -name st -value Start-Process;"
            $tmp += "Set-Alias -name grep -value Select-String;"
            $tmp += "`'ls -l .`';pwd;"
            $tmp += "`""
            #$tmp
            start-process powershell -ArgumentList $tmp
        }elseif($Input -match "^ie\s\d{1,}$"){
            #開くアプリケーション指定(デフォルトブラウザ(IE)で開く)
            $Input = $Input.Substring(3,$Input.length-3)
            $tmp = $result[($Input-1)*2+1]
            start-process $tmp
        }elseif($Input -match "^ex\s\d{1,}$"){
            #開くアプリケーション指定(デフォルトアプリで開く)
            # $tablacus=$TRUE にしているときに今だけエクスプローラーで開きたい時用
            $Input = $Input.Substring(3,$Input.length-3)
            $tmp = $result[($Input-1)*2+1]
            start-process $tmp
        }else{
            #Write-Output "skip"
        }

        #開いたらPowershellのウィンドウを最背面にする処理を入れたい
    }    
        #Write-Output "------------------------------------"
}

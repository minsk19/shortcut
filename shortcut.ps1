#文字コード：UTF-8 with BOM


######################設定######################
#設定ファイル
$config_file_name_1 = "shortcut.txt"

##表示設定
###長い行の表示設定
$maxlength = 100
$display_right = 40
$display_left = 10
###表示結果にパスタイトルを含めるか
$display_title = $TRUE

##アプリケーションのパス設定
###sakuraエディタ
$sakura = "C:\Program Files (x86)\sakura\sakura.exe"

######################プログラム######################

#バッチファイルから起動した時はウインドウがコマンドプロンプトのままでダサいのでPowershellのウインドウで開くようにする
#これを呼び出したときの第1引数にtrueを指定されていたらPowershellで開かれているものとする
#無効化するなら4行をコメントアウト
#if($Args[0] -ne "true"){
#    start-process powershell -ArgumentList ("./shortcut.ps1","true")
#    exit
#}


#設定ファイルの読み込みとこのスクリプトがある場所をカレントディレクトリにする
$current_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$configfilepath_1 = $current_dir + "\" + $config_file_name_1
Set-Location $current_dir

function reloadconfig(){
    #Write-Output "reloadconfig"
    #Write-Output $configfilepath_1
    $lines = Get-Content -Encoding "UTF8" $configfilepath_1
    if(($lines.length) % 2 -eq 1){
        $lines += "#"
        "設定ファイルにフォーマットエラー"
    }
}
. reloadconfig #ドットソースで処理を呼び出すと、呼出元と呼出先の変数のスコープが同一となるため

while(1){
    #####キーワード入力#####
    $result = @()
    $Input = Read-Host ">>"

    #設定ファイルの再読み込み
    if($input -eq "#reload"){
        . reloadconfig
    }
    #設定ファイルをサクラエディタで開く
    if($input -eq "#edit"){
        start-process $sakura -ArgumentList $configfilepath_1
    }

    #新しいウィンドウで開く
    if($input -eq "#restart"){
        start-process powershell -ArgumentList ("./shortcut.ps1","true")
        exit
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
        Write-Output "-----設定ファイル-----"
        Write-Output $lines
        $Input = ""
    }
    #特殊コマンド
    #googleで検索
    if($Input -match "google*"){
        #googleで検索
        if($Input -ne "google"){
            $arg = "https://www.google.com/search?q=" + $Input.Substring(7,$Input.length-7)
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
        for($idx=0;$idx -lt $lines.Length;$idx = $idx+2){
            if($lines[$idx] -notlike "#*"){
                #コメントアウトは飛ばす
                #and検索をする
                $flag = $TRUE #最後までtrueならヒット
                $l = $lines[$idx]
                for($i=0;$i -lt $key.length;$i++){
                    if($l -notlike "*"+[string]$key[$i]+"*"){
                        $flag = $FALSE
                        break
                    }
                }
                if($flag){
                    $result += $lines[$idx]
                    $result += $lines[$idx+1]
                }
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
                    $out = $out.Remove($out.LastIndexOf("$"),$out.length - $out.LastIndexOf("$"))+ "`r`n"
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

        if($Input -eq""){
            #何も入力がなかったら1が入力されたとする
            $Input = 1
        }

        if($Input -match "^\d{1,}$"){
            #数字だった場合は規定のプログラムで開く
            #ただしURLの場合は規定のプログラムを無視してchromeで開く
            if($result.length -ge ([int]$Input*2)){
                #入力値が結果の数以下を確認する
                $path = $result[($Input-1)*2+1]
                if($path -match "https?://[\w/:%#\$&\?\(\)~\.=\+\-]+"){
                    start-process chrome -ArgumentList $path
                }else{
                    start-process $path
                }
                #explorer.exe $path #なんかこれだと遅い気がする
            }else{
                Write-Output "error"
            }
        }elseif($Input -match "^cl\s\d{1,}$"){
            #開くアプリケーション指定(クリップボード貼り付け)
            $Input = $Input.Substring(3,1)
            $path = $result[($Input-1)*2+1]
            Set-Clipboard $path
            Write-Output ("copied>>"+$path)
        }elseif($Input -match "^ps\s\d{1,}$"){
            #開くアプリケーション指定(Powershellで開く)
            #もしファイルならそのファイルがあるフォルダを開く(未実装)
            #    #考え中
                 #正規表現で\....拡張子 を消す
            $Input = $Input.Substring(3,1)
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
            $Input = $Input.Substring(3,1)
            $tmp = $result[($Input-1)*2+1]
            start-process $tmp
        }else{
            #Write-Output "skip"
        }

        #開いたらPowershellのウィンドウを最背面にする処理を入れたい
    }    
        #Write-Output "------------------------------------"
}

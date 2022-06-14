#文字コード：UTF-8 with BOM

######################設定######################
#ファイルパス一覧のファイル名
$config_file_name_1 = "config_files.txt"

#エイリアス設定のファイル名
$alias_file_name = "config_alias.txt"

#外観設定
##ウィンドウ設定
###バッチファイルから起動した時はウインドウがコマンドプロンプトのままでダサいのでPowershellのウインドウで開くようにする
$window_powershell = $FALSE
#                    $TRUE→Powershellの青いウィンドウ
#                    $FLASE→コマンドプロンプトの黒い画面

##表示設定
###長い行の表示設定
$maxlength = 100
$display_right = 40
$display_left = 10
###表示結果にパスタイトルを含めるか
$display_title = $TRUE

## Tablacus Explorerとの連携
$tablacus = $FLASE
#           $TRUE→Tablacus Explorerでフォルダを開く
#           $FLASE→標準エクスプローラーでフォルダを開く
#これを$TRUEにするなら$tablacus_exeに実行ファイルの場所を登録する

##アプリケーションのパス設定
###sakuraエディタ
$sakura = "C:\Program Files (x86)\sakura\sakura.exe"
###Tablacus Explorer (任意)
$tablacus_exe = "C:\dev\te220411\TE64.exe"

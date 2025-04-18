# PC-6001mk2 MODE1～MODE4にSD-CARDからロード、セーブ機能

![TITLE](https://github.com/yanataka60/PC-6001mk2_SD/blob/main/JPEG/TITLE.jpg)

　PC-6001mk2の MODE1～MODE4でSD-CARDからロード、セーブ機能を実現するものです。

　対応機種は、PC-6001mk2、PC-6001mk2SR、PC-6601、PC-6601SRです。PC-6601、PC-6601SRはドライブ数切替スイッチは0として使ってください。

　対応しているCMT形式は、P6形式(拡張子はP6、CASのどちらでも大丈夫)とP6T形式です。

　CMTからの読み込み実行に数分掛かっていたゲームも数十秒で実行できます。

　なお、Arduino、ROMへ書き込むための機器が別途必要となります。

　また、本体内のBASIC-ROMを差し替えられるスキルがあればMODE5もSD対応にできます。詳細は、「MODE5対応について」を参照してください。

![PC-6001mk2_SD](https://github.com/yanataka60/PC-6001mk2_SD/blob/main/JPEG/PC-6001mk2_SD.JPG)

## 対応できないもの
　MODE1～MODE4については、BASIC-ROMを裏RAMにコピーしCMT関連ルーチンをSD-CARDアクセスに書き換えてSD-CARDへのアクセスを実現しています。

　MODE5についてはBASIC-ROMのCMT関連ルーチンにパッチを当てたROMに差し替えることでSD-CARDへのアクセスを実現していますが、MODE6についてはBASIC-ROMのCMT関連ルーチンが特定できていないためSD-CARDは使えません。

　また、BASIC-ROMのCMT関連ルーチンをコールせず独自ルーチンによりCMTからLOADするソフト（ロードランナー等）も対応できないので途中で止まります。

## 回路図
　KiCadフォルダ内のPC-6001mk2_SD.pdfを参照してください。

[回路図](https://github.com/yanataka60/PC-6001mk2_SD/blob/main/Kicad/PC-6001_mk2_SD.pdf)

![PC-6001mk2_SD](https://github.com/yanataka60/PC-6001mk2_SD/blob/main/Kicad/PC-6001_mk2_SD_1.jpg)

## 部品
|番号|品名|数量|備考|
| ------------ | ------------ | ------------ | ------------ |
||J2、J3のいずれか(注1)|||
|J2|Micro_SD_Card_Kit|1|秋月電子通商 AE-microSD-LLCNV (注2)|
|J3|MicroSD Card Adapter|1|Arduino等に使われる5V電源に対応したもの (注4)|
|U1|74LS04|1||
|U2|74LS30|1||
|U4|8255|1||
|U5|2764/28C64相当品|1||
|U6|Arduino_Pro_Mini_5V|1|Atmega328版を使用 168版は不可。(注3)|
|C1 C2 C4 C5|積層セラミックコンデンサ 0.1uF|4||
|C6|電解コンデンサ 16v100uF|1||
||ピンヘッダ|2Pin分|Arduino_Pro_MiniにはA4、A5用のピンヘッダが付いていないため別途調達が必要です 秋月電子通商 PH-1x40SGなど|
||ピンソケット(任意)|26Pin分|Arduino_Pro_Miniを取り外し可能としたい場合に調達します 秋月電子通商 FHU-1x42SGなど|

　　　注1)J2又はJ3のどちらかを選択して取り付けてください。

　　　注2)秋月電子通商　AE-microSD-LLCNVのJ1ジャンパはショートしてください。

　　　注3)Arduino Pro MiniはA4、A5ピンも使っています。

　　　注4)MicroSD Card Adapterを使う場合

　　　　　J3に取り付けます。

　　　　　MicroSD Card Adapterについているピンヘッダを除去してハンダ付けするのが一番確実ですが、J3の穴にMicroSD Card Adapterをぴったりと押しつけ、裏から多めにハンダを流し込むことでハンダ付けをする方法もあります。なお、この方法の時にはしっかりハンダ付けが出来たかテスターで導通を確認しておいた方が安心です。

ハンダ付けに自信のない方はJ2の秋月電子通商　AE-microSD-LLCNVをお使いください。AE-microSD-LLCNVならパワーLED、アクセスLEDが付いています。

![MicroSD Card Adapter1](https://github.com/yanataka60/PC-6001mk2_SD/blob/main/JPEG/MicroSD%20Card%20Adapter.JPG)

![MicroSD Card Adapter2](https://github.com/yanataka60/PC-6001mk2_SD/blob/main/JPEG/MicroSD%20Card%20Adapter2.JPG)

![MicroSD Card Adapter3](https://github.com/yanataka60/PC-6001mk2_SD/blob/main/JPEG/MicroSD%20Card%20Adapter3.JPG)

## ROMへの書込み
　Z80フォルダ内のEXT_ROM.binをROMライター(TL866II Plus等)を使って2764又は28C64に書き込みます。

## Arduinoプログラム
　Arduino IDEを使ってArduinoフォルダのPC-6001mk2_SDフォルダ内PC-6001mk2_SD.inoを書き込みます。

　SdFatライブラリを使用しているのでArduino IDEメニューのライブラリの管理からライブラリマネージャを立ち上げて「SdFat」をインストールしてください。

　「SdFat」で検索すれば見つかります。「SdFat」と「SdFat - Adafruit Fork」が見つかりますが「SdFat」のほうを使っています。

注)Arduinoを基板に直付けしている場合、Arduinoプログラムを書き込むときは、カートリッジスロットから抜き、74LS04を外したうえで書き込んでください。

## 接続
　カートリッジスロットに挿入します。

![cartridge](https://github.com/yanataka60/PC-6001mk2_SD/blob/main/JPEG/cartridge.jpg)

　カートリッジスロットへの抜き差しに基板のみでは不便です。

　STLフォルダに基板を載せられるトレイの3Dデータを置いたので出力して使うと便利です。

![Tray](https://github.com/yanataka60/PC-6001mk2_SD/blob/main/JPEG/TRAY.JPG)

　PC-6601、PC-6601SRはドライブ数切替スイッチは0として使ってください。

![Drive](https://github.com/yanataka60/PC-6001mk2_SD/blob/main/JPEG/DRIVE.JPG)

## SD-CARD
　出来れば8GB以下のSDカードを用意してください。

　ArduinoのSdFatライブラリは、SD規格(最大2GB)、SDHC規格(2GB～32GB)に対応していますが、SDXC規格(32GB～2TB)には対応していません。

　また、SDHC規格のSDカードであっても32GB、16GBは相性により動作しないものがあるようです。

　FAT16又はFAT32が認識できます。NTFSは認識できません。

　ルートに置かれた拡張子が「.P6T」又は「.CAS」の形式ファイルのみ認識できます。(以外のファイル、フォルダも表示されますがLOAD実行の対象になりません)

　ファイル名は拡張子を除いて32文字まで、ただし半角カタカナ、及び一部の記号はArduinoが認識しないので使えません。パソコンでファイル名を付けるときはアルファベット、数字および空白でファイル名をつけてください。

　起動直後の画面は横32文字表示です。拡張子を含めて27文字以下にしたほうが画面の乱れません。

## 使い方

起動直後は拡張ROMのプログラムが走り、以下のコマンドが使えます。

### Launcherコマンド
#### 1から4までのいずれかの後に[CR]
次に「How Many Pages?(1-4)」と聞いてくるので画面数を入力すると入力された数字のMODEと画面数でSD対応にして起動します。

#### B[CR]
SD対応せずにBASICを起動します。

[STOP]キーと動作は同じです。

#### [STOP]キー
SD対応せずにBASICを起動します。

B[CR]と動作は同じです。

#### F[CR]又はF 文字列[CR]
文字列を入力せずにF[CR]のみ入力するとSD-CARDルートディレクトリにあるファイルの一覧を表示します。

文字列を付けて入力すればSD-CARDルートディレクトリにあるその文字列から始まるファイルの一覧を表示します。

10件表示したところで指示待ちになるので打ち切るならESC又は↑を入力すると打ち切られ、Bキーで前の10件に戻ります。それ以外のキーで次の10件を表示します。

　行頭に「*L 」を付加して表示してあるので実行したいファイルにカーソルキーを合わせて[CR]キーを押すだけでLOAD可能です。

　LOADの挙動については次のLコマンドの記述を参照してください。

　表示される順番は、登録順となりファイル名アルファベッド順などのソートした順で表示することはできません。

##### 例)
　　F[CR]

　　F S[CR]

　　F SP[CR]

#### L DOSファイル名[CR]
指定したDOSフィル名のファイルをSD-CARDからLOADします。

ファイル名の最後の「.P6T」「.CAS」は有っても無くても構いませんが、無い場合は「.P6T」が指定されたものとみなします。

　例)

　　L TEST.P6T -> DOSファイル名「TEST.P6T」を読み込みます。

　　L TEST.CAS -> DOSファイル名「TEST.CAS」を読み込みます。

　　L TEST -> DOSファイル名「TEST.P6T」を読み込みます。

　選択したファイルが「P6T」形式の場合、設定されたMODEと設定されたPagesで起動したうえで自動実行文字列を実行します。

　選択したファイルが「CAS」形式の場合、「Mode?(1-4)」と聞いてくるのでモードを入力、次に「How Many Pages?(1-4)」と聞いてくるので画面数を入力、最後に「Auto Run?(y/c/n)」と聞いてくるので「y」とすれば起動直後にCLOAD[CR]RUN[CR]が実行され、「c」とすればCLOAD[CR]だけが実行、「n」とすれば何も実行されません。

#### 操作上の注意
　~~「SD-CARD INITIALIZE ERROR」と表示されたときは、SD-CARDをいったん抜き再挿入したうえでArduinoをリセットしてください。~~

　~~SD-CARDにアクセスしていない時に電源が入ったままで SD-CARDを抜いた後、再挿入しSD-CARDにアクセスすると「SD-CARD INITIALIZE ERROR」となる場合があります。再挿入した場合にはSD-CARDにアクセスする前にArduinoを必ずリセットしてください。~~

　~~SD-CARDの抜き差しは電源を切った状態で行うほうがより確実です。~~

　(2024.3.12) SD-CARDにアクセスしていない時に電源が入ったままでSD-CARDを抜くと再度SD-CARDを挿入してもSD-CARDにアクセスできない問題を解消しました。(Arduinoを最新版に書き換えてください)

　再度SD-CARDを挿入した後、Fコマンド、Lコマンド、CLOAD、CSAVE等でSD-CARDに3回ほどアクセスすれば復旧します。


### BASICコマンド
#### CLOAD "DOSファイル名"[CR]
指定したDOSフィル名のBASICプログラムをSD-CARDからLOADします。

ファイル名は6文字以内で必須です。6文字以上入力された場合には7文字以降は無視されます。ファイル名を入力せずにCLOAD[CR]とすると暴走します。

ファイル名の前に"(ダブルコーテーション)は必須ですが、ファイル名の後ろに"(ダブルコーテーション)は有っても無くても構いません。

ファイル名の最後に「.CAS」は必要ありません。「.CAS」が指定されたものとみなします。

　例)

　　CLOAD "TEST" -> DOSファイル名「TEST.CAS」を読み込みます。

　　CLOAD "TESTTEST" -> DOSファイル名「TESTTE.CAS」を読み込みます。

　　CLOAD "TEST.BAS.CMT" -> DOSファイル名「TEST.BA.CMT」を読み込みます。

#### CSAVE "DOSファイル名"[CR]
BASICプログラムを指定したDOSフィル名でSD-CARDに上書きSAVEします。

ファイル名は6文字以内で必須です。6文字以上入力された場合には7文字以降は無視されます。

ファイル名の前に"(ダブルコーテーション)は必須ですが、ファイル名の後ろに"(ダブルコーテーション)は有っても無くても構いません。

ファイル名の最後の「.CAS」は必要ありません。「.CAS」が指定されたものとみなします。

　例)

　　CSAVE "TEST" -> 「TEST.CAS」で保存される。

　　CSAVE "TESTTEST" -> 「TESTTE.CAS」で保存される。

## MODE5対応について(本体BASIC-ROMの差し替えが必要です、自己責任でお願いします)
　MODE5では裏RAMが使われるため、「BASIC-ROMを裏RAMにコピーしCMT関連ルーチンをSD-CARDアクセスに書き換え」が出来ませんのでSD-CARDアクセス用にパッチを当てたBASIC-ROMに差し替えることでMODE5に対応します。

　なお、市販ソフトでは2段目以降のCMTロードはBASIC-ROMを使わずに独自のロードルーチンを使っているものがあり、動かないことが多いです。

　雑誌打ち込みプログラムのロード、セーブ用と割り切ってください。

　また、本体ROMの抜き差し等において本体が故障又はBASIC-ROMが破損しても当方では責任をとれませんので自己責任で行ってください。

　本体BASIC-ROMの本体内の位置及びROM内容の吸出しに関しても自分で解決できる方のみ挑戦願います。

#### 従来MONITORのRコマンド未対応としていましたが、最初に何らかのBASICプログラムが無いと正常に読み込めないのが原因です。
#### 月刊マイコン '85/11月号掲載「サブマリン606」のように最初にCLOAD、次にMON、R-0とするプログラムは正常に読み込めます。
#### 未確認ですが、機械語だけをR-0で読み込むプログラムも最初になんらかのBASICプログラム(10 clearだけでも)をくっつけたp6ファイルに修正すればR-0で読み込み、Gxxxxで実行できると思います。

### Arduinoプログラム
　ArduinoフォルダのPC-6001mk2_SDフォルダ内PC-6001mk2_SD.inoと同じもので動作します。

### ROMへの書込み
　Z80フォルダ内のEXT_ROM.binと同じもので動作します。

### BASIC-ROMへのパッチあて
　以下のアドレスを修正します。

|ADDRESS|修正前|修正後|
| ------------ | ------------ | ------------ |
|1A61|C5 D5 E5|C3 12 58|
|1A70|C5 D5 E5|C3 15 58|
|1AB8|C5 D5 E5|C3 18 58|
|1ACC|C5 D5 E5|C3 1B 58|
|1B06|C5 D5 E5|C3 1E 58|

　MODE5フォルダ内のROM_PATCH.binの内容で5812H～5A20Hまでを差し替えます。

　この差し替えによりfilesが使えなくなり、FDDを繋いでいない限り問題はないと思うのですが、何かしらのサブルーチンをつぶしてしまっているかもしれません。

　リセットが掛かってしまう等が起きるソフトのSD起動は取り敢えず諦めてください。

　出来上がったバイナリを27256等に焼いて本体内ICソケットにそのまま差し替えると、CMT、FDDが使えなくなってしまうので27512等にオリジナルバイナリを前半、パッチ済みバイナリを後半に置いて焼き、27512のA15を5VとGNDにスイッチで切り替えられるようにし、オリジナルバイナリとパッチ済みバイナリを切り替えて使ってください。

## 謝辞
　基板の作成に当たり以下のデータを使わせていただきました。ありがとうございました。

　Arduino Pro Mini

　　https://github.com/g200kg/kicad-lib-arduino

　AE-microSD-LLCNV

　　https://github.com/kuninet/PC-8001-SD-8kRAM

## 追記
　2022.10.26 SD-CARDに対応できないハード、ソフトについて加筆しました。

　　　　　　 FコマンドにもDI追加。

　2022.10.27 MODE5対応テストについて追記しました。

　2022.10.28 MODE5対応テストで不具合の出る可能性を追記しました。あくまでテストですので了承ください。

　2022.10.29 CMTload終了処理にCMTsave終了エントリをCallしているソフトへの対策をArduinoプログラムに追加。MODE5用と統合。

　　　　　　 MODE5対応テストにおいてMONITOR Rコマンドには未対応であることを追記。

　2022.10.31 MODE5対応用にBASIC-ROMを差し替えるときには27512を使うことを追記。

　　　　　　 U5 2764用プログラムのMODE1～MODE4用とMODE5用を統合。統合に伴ってArduinoプログラムも修正。BASIC-ROMの内容がオリジナルであればMODE1～MODE4用、修正されていればMODE1～MODE5用として動作。

　　　　　　 BASIC-ROMを差し替えていなければ2764、Arduinoとも更新の必要なし。

　2023. 3. 4 MODE5においてMONITOR Rコマンドが機能するためには、最初に何らかのBASICプログラムが必要であることを追記。

　　　　　　 AUTO STARTの選択肢をy/c/nとし、CLOADも実行しない選択を追加

　　　　　　 CLOAD、CSAVEがLOAD、SAVEと誤表記されていたものを修正

　2024.1.15 SDカードは8GB以下が望ましいことを追記。

　2024.3.12 電源が入ったままでSD-CARDを抜くと再度SD-CARDを挿入してもSD-CARDにアクセスできない問題を解消した。

　2025.3.20 P6形式が使えることが伝わりにくい表記を修正した。

　2025.3.29 ピーガー伝説➋代さんにご指摘いただいた「LBUFをRS232Cバッファ」に修正。ファイルリスト表示時にB(前頁表示)を押し続けると期待した動作をしない、basic起動時にキーを押しているとOUTコマンドが正常に発行されないという問題が解消されます。
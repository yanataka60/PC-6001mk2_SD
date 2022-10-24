//
#include "SdFat.h"
#include <SPI.h>
SdFat SD;
unsigned long r_count=0,s_count=0;
unsigned long f_length=0;
char m_name[40];
byte s_data[260];
char f_name[40];
char c_name[40];
char new_name[40];
char as_str[80];
File file;
unsigned int s_adrs,e_adrs,w_length,w_len1,w_len2,s_adrs1,s_adrs2,b_length,b_mode,b_page,as_len;
boolean eflg,basic_d3;

#define CABLESELECTPIN  (10)
#define CHKPIN          (15)
#define PB0PIN          (2)
#define PB1PIN          (3)
#define PB2PIN          (4)
#define PB3PIN          (5)
#define PB4PIN          (6)
#define PB5PIN          (7)
#define PB6PIN          (8)
#define PB7PIN          (9)
#define FLGPIN          (14)
#define PA0PIN          (16)
#define PA1PIN          (17)
#define PA2PIN          (18)
#define PA3PIN          (19)
// ファイル名は、ロングファイルネーム形式対応

void setup(){
////    Serial.begin(9600);
// CS=pin10
// pin10 output

  pinMode(CABLESELECTPIN,OUTPUT);
  pinMode( CHKPIN,INPUT);  //CHK
  pinMode( PB0PIN,OUTPUT); //送信データ
  pinMode( PB1PIN,OUTPUT); //送信データ
  pinMode( PB2PIN,OUTPUT); //送信データ
  pinMode( PB3PIN,OUTPUT); //送信データ
  pinMode( PB4PIN,OUTPUT); //送信データ
  pinMode( PB5PIN,OUTPUT); //送信データ
  pinMode( PB6PIN,OUTPUT); //送信データ
  pinMode( PB7PIN,OUTPUT); //送信データ
  pinMode( FLGPIN,OUTPUT); //FLG

  pinMode( PA0PIN,INPUT_PULLUP); //受信データ
  pinMode( PA1PIN,INPUT_PULLUP); //受信データ
  pinMode( PA2PIN,INPUT_PULLUP); //受信データ
  pinMode( PA3PIN,INPUT_PULLUP); //受信データ

  digitalWrite(PB0PIN,LOW);
  digitalWrite(PB1PIN,LOW);
  digitalWrite(PB2PIN,LOW);
  digitalWrite(PB3PIN,LOW);
  digitalWrite(PB4PIN,LOW);
  digitalWrite(PB5PIN,LOW);
  digitalWrite(PB6PIN,LOW);
  digitalWrite(PB7PIN,LOW);
  digitalWrite(FLGPIN,LOW);

  delay(500);

  // SD初期化
  if( !SD.begin(CABLESELECTPIN,8) )
  {
////    Serial.println("Failed : SD.begin");
    eflg = true;
  } else {
////    Serial.println("OK : SD.begin");
    eflg = false;
  }
////    Serial.println("START");
}

//4BIT受信
byte rcv4bit(void){
//HIGHになるまでループ
  while(digitalRead(CHKPIN) != HIGH){
  }
//受信
  byte j_data = digitalRead(PA0PIN)+digitalRead(PA1PIN)*2+digitalRead(PA2PIN)*4+digitalRead(PA3PIN)*8;
//FLGをセット
  digitalWrite(FLGPIN,HIGH);
//LOWになるまでループ
  while(digitalRead(CHKPIN) == HIGH){
  }
//FLGをリセット
  digitalWrite(FLGPIN,LOW);
  return(j_data);
}

//1BYTE受信
byte rcv1byte(void){
  byte i_data = 0;
  i_data=rcv4bit()*16;
  i_data=i_data+rcv4bit();
  return(i_data);
}

//1BYTE送信
void snd1byte(byte i_data){
//下位ビットから8ビット分をセット
  digitalWrite(PB0PIN,(i_data)&0x01);
  digitalWrite(PB1PIN,(i_data>>1)&0x01);
  digitalWrite(PB2PIN,(i_data>>2)&0x01);
  digitalWrite(PB3PIN,(i_data>>3)&0x01);
  digitalWrite(PB4PIN,(i_data>>4)&0x01);
  digitalWrite(PB5PIN,(i_data>>5)&0x01);
  digitalWrite(PB6PIN,(i_data>>6)&0x01);
  digitalWrite(PB7PIN,(i_data>>7)&0x01);
  digitalWrite(FLGPIN,HIGH);
//HIGHになるまでループ
  while(digitalRead(CHKPIN) != HIGH){
  }
  digitalWrite(FLGPIN,LOW);
//LOWになるまでループ
  while(digitalRead(CHKPIN) == HIGH){
  }
}

//小文字->大文字
char upper(char c){
  if('a' <= c && c <= 'z'){
    c = c - ('a' - 'A');
  }
  return c;
}

//ファイル名の最後が「.p6t」でなければ付加
void addp6t(char *f_name,char *m_name){
  unsigned int lp1=0;
  while (f_name[lp1] != 0x00){
    m_name[lp1] = f_name[lp1];
    lp1++;
  }
  if (f_name[lp1-4]!='.' ||
    ( f_name[lp1-3]!='P' &&
      f_name[lp1-3]!='p' ) ||
    ( f_name[lp1-2]!='6' ) ||
    ( f_name[lp1-1]!='T' &&
      f_name[lp1-1]!='t' ) ){
         m_name[lp1++] = '.';
         m_name[lp1++] = 'p';
         m_name[lp1++] = '6';
         m_name[lp1++] = 't';
  }
  m_name[lp1] = 0x00;
}

//ファイル名の最後が「.p6」ならそのまま、「.p6」でもなく「.cas」でもなければ「.cas」を付加
void addcas(char *f_name,char *m_name){
  unsigned int lp1=0;
  while (f_name[lp1] != 0x00){
    m_name[lp1] = f_name[lp1];
    lp1++;
  }
  if ( ( f_name[lp1-3]!='.') ||
       ( f_name[lp1-2]!='P' &&
         f_name[lp1-2]!='p' ) ||
       ( f_name[lp1-1]!='6') ){
    if (f_name[lp1-4]!='.' ||
      ( f_name[lp1-3]!='c' &&
        f_name[lp1-3]!='C' ) ||
      ( f_name[lp1-2]!='a' &&
        f_name[lp1-2]!='A' ) ||
      ( f_name[lp1-1]!='s' &&
        f_name[lp1-1]!='S' ) ){
           m_name[lp1++] = '.';
           m_name[lp1++] = 'c';
           m_name[lp1++] = 'a';
           m_name[lp1++] = 's';
    }
  }
  m_name[lp1] = 0x00;
}

//比較文字列取得 32+1文字まで取得、ただしダブルコーテーションは無視する
void receive_name(char *f_name){
char r_data;
  unsigned int lp2 = 0;
  for (unsigned int lp1 = 0;lp1 <= 32;lp1++){
    r_data = rcv1byte();
    if (r_data != 0x22){
      f_name[lp2] = r_data;
      lp2++;
    }
  }
}

// p6 LOADコマンド .p6 LOAD
void P6_load(void){
  boolean flg = false;
//DOSファイル名取得
  receive_name(m_name);
  addcas(m_name,f_name);
//ファイルが存在しなければERROR
  if (SD.exists(f_name) == true){
//    if (f_length != r_count){
//      file.close();
//    }
//ファイルオープン
    file = SD.open( f_name, FILE_READ );

    if( true == file ){
//f_length設定、r_count初期化
      f_length = file.size();
      r_count = 0;
//状態コード送信(OK)
      snd1byte(0x00);
      flg = true;
    } else {
      snd1byte(0xf0);
      flg = false;
    }
  }else{
    snd1byte(0xf1);
    flg = false;
  }
}

// p6t LOADコマンド .p6t LOAD
void cmt_load(void){
  boolean flg = false;
//DOSファイル名取得
  receive_name(m_name);
//ファイル名の指定があるか
  if (m_name[0]!=0x00){
    addp6t(m_name,f_name);
  
//指定があった場合
//ファイルが存在しなければERROR
    if (SD.exists(f_name) == true){
//      if (f_length != r_count){
//        file.close();
//      }
//ファイルオープン
      file = SD.open( f_name, FILE_READ );

      if( true == file ){
//f_length設定、r_count初期化
        f_length = file.size();
        r_count = 0;
//状態コード送信(OK)
        snd1byte(0x00);
        flg = true;
      } else {
        snd1byte(0xf0);
        flg = false;
      }
    }else{
      snd1byte(0xf1);
      flg = false;
    }
    if (flg == true){
//p6t_info取得
        p6t_info();
    }
  }
}

//p6tファイルからMODE、FILES、自動実行文字列を抽出
void p6t_info(void){
//f_length設定、r_count初期化
  f_length = file.size();
  r_count = 2;
  if ((file.read()=='P') && (file.read()=='6')){
// v1なら先頭に付加されている
    p6t_v1();
  } else{
// v2は最後に付いている
    p6t_v2();
  }
}

//p6t v1ファイルからMODE、FILES、自動実行文字列を抽出
void p6t_v1(void){
  int rdata = 0;
  snd1byte(0x00); 
  rdata=file.read();
  r_count++;
  rdata=file.read();
  r_count++;
//BASICモード
  b_mode = file.read();
  r_count++;
  snd1byte(b_mode);
////  Serial.println(b_mode,HEX);
//// MODE1～MODE4の時だけ実行可
  if(b_mode!=0 && b_mode!=5 && b_mode!=6){
//ページ数
    b_page = file.read();
    r_count++;
    snd1byte(b_page);
////  Serial.println(b_page,HEX);
//オートスタートコマンド文字数(2Byte目は読み飛ばし,80文字以上は想定しない)
    as_len = file.read();
    r_count++;
    rdata = file.read();
    r_count++;
    snd1byte(as_len);
////  Serial.println(as_len);
//オートスタート文字列取得
    int lp1=0;
    while (lp1<as_len){
      as_str[lp1]=file.read();
      r_count++;
      snd1byte(as_str[lp1]);
////    Serial.print(as_str[lp1],HEX);
      lp1++;
    }
    as_str[lp1]=0x00;
////  Serial.println();
////  Serial.println(as_str);
//BASICヘッダーが出てくるまで読み飛ばし
    while (rdata != 0xd3) {
      rdata = file.read();
      r_count++;
    }
    r_count--;
    file.seek(r_count);
  }
}

//p6t v2ファイルからMODE、FILES、自動実行文字列を抽出
void p6t_v2(void){
  int rdata = 0;
  int rdata2 = 0;
  int zcnt = 0;
  int zdata = 1;
  boolean flg = true;
////  Serial.println("check 1");
//識別子'P6'の'P'が出てくるまで読み飛ばし
  while (rdata != 'P' && flg == true) {
//まずBASICヘッダーが出てくるまで読み飛ばし
    while (rdata != 0xd3) {
      rdata = file.read();
      r_count++;
    }
////  Serial.println("check 2");
    zcnt = 0;
    zdata = 1;
//プログラムエンド(0x00が9個続く)まで読み飛ばし
    while (zcnt < 9) {
      rdata = file.read();
      r_count++;
      if (rdata == 0x00){
        zcnt++;
        if (zdata != 0){
          zcnt = 0;
        }
      }
      zdata = rdata;
    }
////  Serial.println("check 3");
    rdata = 0;
    rdata2 = 0;
    zcnt = 0;
    zdata = 0;
//識別子'P6'又は次のブロックのヘッダー(0xd3が9個続く)が出てくるまで読み飛ばし
    while (!(rdata == 'P' && rdata2 == '6') && zcnt < 9 && flg == true) {
//    while (!(rdata == 'P' && rdata2 == '6')) {
      rdata = rdata2;
      rdata2 = file.read();
      r_count++;
      if (rdata2 == 0xd3){
        zcnt++;
        if (zdata != 0xd3){
          zcnt = 0;
        }
      }
      zdata = rdata2;
////      Serial.println(rdata2,HEX);
      if (r_count >= f_length){
        flg = false;
      }
    }
  }
  if (flg == true){
    snd1byte(0x00); 

////  Serial.println("check 4");
//p6tバージョン読み飛ばし
    rdata = file.read();
//含まれるDATAブロック数読み飛ばし
    rdata = file.read();
//オートスタートフラグ(0:無効 1:有効)読み飛ばし(有効固定)
    rdata = file.read();
//BASICモード
    b_mode = file.read();
    snd1byte(b_mode);
////  Serial.println(b_mode,HEX);
//// MODE1～MODE4の時だけ実行可
    if(b_mode!=0 && b_mode!=5 && b_mode!=6){
//ページ数
      b_page = file.read();
      snd1byte(b_page);
////  Serial.println(b_page,HEX);
//オートスタートコマンド文字数(2Byte目は読み飛ばし,80文字以上は想定しない)
      as_len = file.read();
      rdata = file.read();
      snd1byte(as_len);
////  Serial.println(as_len);
//オートスタート文字列取得
      int lp1=0;
      while (lp1<as_len){
        as_str[lp1]=file.read();
        snd1byte(as_str[lp1]);
////    Serial.print(as_str[lp1],HEX);
        lp1++;
      }
      as_str[lp1]=0x00;
////  Serial.println();
////  Serial.println(as_str);
      file.seek(0);
      r_count = 0;
    }
  } else{
    snd1byte(0xf0);
    file.seek(0);
    r_count = 0;
  }
}

//LOAD ONE BYTE、OPENしているファイルの続きから1Byteを読み込み、送信
void load1byte(void){
  int rdata = file.read();
  r_count++;
  snd1byte(rdata);
//ファイルエンドまで達していればFILE CLOSE
  if (f_length == r_count){
    file.close();
  }      
}

// SD-CARDのFILELIST
void dirlist(void){
//比較文字列取得 32+1文字まで

  for (unsigned int lp1 = 0;lp1 <= 32;lp1++){
    c_name[lp1] = rcv1byte();
  }
//
  File file = SD.open( "/" );
  if( true == file ){
//状態コード送信(OK)
    snd1byte(0x00);

    File entry =  file.openNextFile();
    int cntl2 = 0;
    unsigned int br_chk =0;
    int page = 1;
//全件出力の場合には10件出力したところで一時停止、キー入力により継続、打ち切りを選択
    while (br_chk == 0) {
      if(entry){
        entry.getName(f_name,36);
        unsigned int lp1=0;
//一件送信
//比較文字列でファイルネームを先頭10文字まで比較して一致するものだけを出力
        if (f_match(f_name,c_name)){
          while (lp1<=36 && f_name[lp1]!=0x00){
          snd1byte(upper(f_name[lp1]));
          lp1++;
          }
          snd1byte(0x0D);
          snd1byte(0x00);
          cntl2++;
        }
      }
      if (!entry || cntl2 > 9){
//継続・打ち切り選択指示要求
        snd1byte(0xfe);

//選択指示受信(0:継続 B:前ページ 以外:打ち切り)
        br_chk = rcv1byte();
//前ページ処理
        if (br_chk==0x42){
//先頭ファイルへ
          file.rewindDirectory();
//entry値更新
          entry =  file.openNextFile();
//もう一度先頭ファイルへ
          file.rewindDirectory();
          if(page <= 2){
//現在ページが1ページ又は2ページなら1ページ目に戻る処理
            page = 0;
          } else {
//現在ページが3ページ以降なら前々ページまでのファイルを読み飛ばす
            page = page -2;
            cntl2=0;
            while(cntl2 < page*10){
              entry =  file.openNextFile();
              if (f_match(f_name,c_name)){
                cntl2++;
              }
            }
          }
          br_chk=0;
        }
        page++;
        cntl2 = 0;
      }
//ファイルがまだあるなら次読み込み、なければ打ち切り指示
      if (entry){
        entry =  file.openNextFile();
      }else{
        br_chk=1;
      }
//FDLの結果が10件未満なら継続指示要求せずにそのまま終了
      if (!entry && cntl2 < 10 && page ==1){
        break;
      }
    }
//処理終了指示
    snd1byte(0xFF);
    snd1byte(0x00);
  }else{
    snd1byte(0xf1);
  }
}

//f_nameとc_nameをc_nameに0x00が出るまで比較
//FILENAME COMPARE
boolean f_match(char *f_name,char *c_name){
  boolean flg1 = true;
  unsigned int lp1 = 0;
  while (lp1 <=32 && c_name[0] != 0x00 && flg1 == true){
    if (upper(f_name[lp1]) != c_name[lp1]){
      flg1 = false;
    }
    lp1++;
    if (c_name[lp1]==0x00){
      break;
    }
  }
  return flg1;
}

//BASICプログラムのSAVE開始処理
void bas_save_ini(void){
//DOSファイル名取得
////  Serial.println("test1");
  receive_name(m_name);
////  Serial.println(m_name);
//ファイル名の指定が無ければエラー
  if (m_name[0]!=0x00){
    addcas(m_name,f_name);
////  Serial.println(f_name);
  
//ファイルが存在すればdelete
    if (SD.exists(f_name) == true){
      SD.remove(f_name);
    }
//ファイルオープン
    file = SD.open( f_name, FILE_WRITE );
    if( true == file ){
      s_count=0;
      basic_d3=false;
//状態コード送信(OK)
      snd1byte(0x00);
    } else {
      snd1byte(0xf0);
    }
  }else{
    snd1byte(0xf1);
  }
}

//BASICプログラムの1Byte受信処理
void save1byte(void){
//1Byte受信、書き込み
    int rdata = rcv1byte();
    s_count++;
    if(s_count==1 && rdata==0xd3){
      basic_d3=true;
    }else{
      if(s_count<11 && basic_d3==true && rdata==0x00){
        rdata=0xd3;
      }
    }
    file.write(rdata);
    
////  Serial.println(rdata,HEX);
//  file.write(rcv1byte());
  
}

//BASICプログラムのSAVE終了処理
void bas_save_end(void){
  file.close();
}

//BASICプログラムのLOAD処理
void bas_load(void){
  boolean flg = false;
//DOSファイル名取得
  receive_name(m_name);
//ファイル名の指定があるか
  if (m_name[0]!=0x00){
    addp6t(m_name,f_name);
  
//指定があった場合
//ファイルが存在しなければERROR
    if (SD.exists(f_name) == true){
//ファイルオープン
      file = SD.open( f_name, FILE_READ );
      if( true == file ){
//f_length設定、r_count初期化
        f_length = file.size();
        r_count = 0;
//状態コード送信(OK)
        snd1byte(0x00);
        flg = true;
      } else {
        snd1byte(0xf0);
        flg = false;
      }
    }else{
      snd1byte(0xf1);
      flg = false;
    }
  } else{
//ファイル名の指定がなかった場合
//ファイルエンドになっていないか
    if (f_length > r_count){
      snd1byte(0x00);
      flg = true;
    }else{
      snd1byte(0xf1);
      flg = false;
    }
  }
//良ければファイルエンドまで読み込みを続行する
  if (flg == true){
    int rdata = 0;
      
//ヘッダーが出てくるまで読み飛ばし
    while (rdata != 0x3a && rdata != 0xd3) {
      rdata = file.read();
      r_count++;
    }
//ヘッダー送信
    snd1byte(rdata);
//ヘッダーが0xd3なら続行、違えばエラー
    if (rdata == 0xd3){
      while (rdata == 0xd3) {
        rdata = file.read();
        r_count++;
      }

//実データ送信
      int zcnt = 0;
      int zdata = 1;

      snd1byte(rdata);

//0x00が11個続くまで読み込み、送信
      while (zcnt < 11) {
        rdata = file.read();
        r_count++;
        snd1byte(rdata);
        if (rdata == 0x00){
          zcnt++;
          if (zdata != 0){
            zcnt = 0;
          }
        }
        zdata = rdata;
      }

//ファイルエンドに達していたらFILE CLOSE
      if (f_length == r_count){
        file.close();
      }      
    }else{
        file.close();
    }
  }
}

//BASICプログラムのKILL処理
void bas_kill(void){
unsigned int lp1;

//DOSファイル名取得
  receive_name(m_name);
//ファイル名の指定が無ければエラー
  if (m_name[0]!=0x00){
    addp6t(m_name,f_name);
  
//状態コード送信(OK)
      snd1byte(0x00);
//ファイルが存在すればdelete
    if (SD.exists(f_name) == true){
      SD.remove(f_name);
//状態コード送信(OK)
      snd1byte(0x00);
    }else{
      snd1byte(0xf1);
    }
  }else{
    snd1byte(0xf1);
  }
}


void loop()
{
  digitalWrite(PB0PIN,LOW);
  digitalWrite(PB1PIN,LOW);
  digitalWrite(PB2PIN,LOW);
  digitalWrite(PB3PIN,LOW);
  digitalWrite(PB4PIN,LOW);
  digitalWrite(PB5PIN,LOW);
  digitalWrite(PB6PIN,LOW);
  digitalWrite(PB7PIN,LOW);
  digitalWrite(FLGPIN,LOW);
//コマンド取得待ち
////    Serial.println("COMMAND WAIT");
  byte cmd = rcv1byte();
////    Serial.println(cmd,HEX);
  if (eflg == false){
    switch(cmd) {
//61hでファイルリスト出力
      case 0x61:
////    Serial.println("FILE LIST START");
//状態コード送信(OK)
        snd1byte(0x00);
        dirlist();
        break;
//62h:PC-6001 p6tファイル LOAD
      case 0x62:
////    Serial.println("p6t LOAD START");
//状態コード送信(OK)
        snd1byte(0x00);
        cmt_load();
////  delay(1500);
        break;
//63h:PC-6001 P6ファイル LOAD
      case 0x63:
////    Serial.println("p6 LOAD START");
//状態コード送信(OK)
        snd1byte(0x00);
        P6_load();
////  delay(1500);
        break;
//64h:PC-6001 LOAD ONE BYTE FROM CMT
      case 0x64:
////    Serial.println("LOAD 1BYTE START");
//  delay(1);
//状態コード送信(OK)
        snd1byte(0x00);
        load1byte();
        break;
//67h:PC-6001 BASIC SAVE開始
      case 0x67:
////    Serial.println("BASIC SAVE START");
//状態コード送信(OK)
        snd1byte(0x00);
        bas_save_ini();
////  delay(1500);
        break;
//68h:PC-6001 BASIC 1Byte 受信
      case 0x68:
////    Serial.println("BASIC SAVE 1 Byte");
//  delay(1);
//状態コード送信(OK)
        snd1byte(0x00);
        save1byte();
////  delay(1500);
        break;
//69h:PC-6001 BASIC SAVE終了
      case 0x69:
////    Serial.println("BASIC SAVE END");
//状態コード送信(OK)
        snd1byte(0x00);
        bas_save_end();
////  delay(1500);
        break;

      default:
//状態コード送信(CMD ERROR)
        snd1byte(0xF4);
    }
  } else {
//状態コード送信(ERROR)
    snd1byte(0xF0);
  }
}

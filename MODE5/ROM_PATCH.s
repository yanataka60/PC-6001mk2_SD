AZLCNV		EQU		0BEFH		;小文字->大文字変換
CONOUT		EQU		1075H		;CRTへの1バイト出力
MSGOUT		EQU		30CFH		;文字列の出力
LINPUT		EQU		28F9H		;スクリーン・エディタ
TBLOAD		EQU		0FAA7H		;LOADコマンドジャンプアドレス
TBSAVE		EQU		0FAA9H		;SAVEコマンドジャンプアドレス
TBLLIST		EQU		0FA91H		;LLISTコマンドジャンプアドレス
LBUF		EQU		0FBB9H
MONCLF		EQU		2739H		;CRコード及びLFコードの表示
KYSCAN		EQU		0FBCH		;リアルタイム・キーボード・スキャニング
MONBHX		EQU		397AH		;Aレジスタの内容を10進数として表示
DISPBL		EQU		1BCDH		;ベルコードの出力
FUNC8		EQU		0FB75H		;F8 KEY 定義領域
KEYIN		EQU		0FC4H		;1文字入力
STOPFLG		EQU		0FA18H		;STOP ESC KEY FLG
FNAME		EQU		0FECBH		;CMT FILE NAME


;PC-6001
PPI_A		EQU		07CH

PPI_B		EQU		PPI_A+1
PPI_C		EQU		PPI_A+2
PPI_R		EQU		PPI_A+3

;PC-6001
;8255 PORT アドレス 7CH～7FH
;07CH PORTA 送信データ(下位4ビット)
;07DH PORTB 受信データ(8ビット)
;07EH PORTC Bit

;7 IN  CHK
;6 IN
;5 IN
;4 IN 
;3 OUT
;2 OUT FLG
;1 OUT
;0 OUT
;
;7FH コントロールレジスタ

;DIRLISTコマンド		61H
;p6t LOAD コマンド	62H
;p6 LOAD コマンド	63H
;LOAD1BYTE コマンド	64H

;BASIC LOAD START	65H
;BASIC LOAD END		66H

;BASIC SAVE START	67H
;SAVE1BYTE			68H
;BASIC SAVE END		69H


		ORG		5812H

		JP		LOADINI
		JP		LOAD1BYTE
		JP		SAVEINI
		JP		SAVE1BYTE
		JP		SAVEEND
		
;**** 1BYTE受信 ****
;受信DATAをAレジスタにセットしてリターン
RCVBYTE:
		CALL	F1CHK             ;PORTC BIT7が1になるまでLOOP
		IN		A,(PPI_B)         ;PORTB -> A
		PUSH 	AF
		LD		A,05H
		OUT		(PPI_R),A         ;PORTC BIT2 <- 1
		CALL	F2CHK             ;PORTC BIT7が0になるまでLOOP
		LD		A,04H
		OUT		(PPI_R),A         ;PORTC BIT2 <- 0
		POP 	AF
		RET
		
;**** 1BYTE送信 ****
;Aレジスタの内容をPORTA下位4BITに4BITずつ送信
SNDBYTE:
		PUSH	AF
		RRA
		RRA
		RRA
		RRA
		AND		0FH
		CALL	SND4BIT
		POP		AF
		AND		0FH
		CALL	SND4BIT
		RET

;**** 4BIT送信 ****
;Aレジスタ下位4ビットを送信する
SND4BIT:
		OUT		(PPI_A),A
		LD		A,05H
		OUT		(PPI_R),A          ;PORTC BIT2 <- 1
		CALL	F1CHK             ;PORTC BIT7が1になるまでLOOP
		LD		A,04H
		OUT		(PPI_R),A          ;PORTC BIT2 <- 0
		CALL	F2CHK
		RET
		
;**** BUSYをCHECK(1) ****
; 82H BIT7が1になるまでLOP
F1CHK:	IN		A,(PPI_C)
		AND		80H               ;PORTC BIT7 = 1?
		JR		Z,F1CHK
		RET

;**** BUSYをCHECK(0) ****
; 82H BIT7が0になるまでLOOP
F2CHK:	IN		A,(PPI_C)
		AND		80H               ;PORTC BIT7 = 0?
		JR		NZ,F2CHK
		RET

LOADINI:
		DI
		XOR		A
		LD		(FNAME+6),A
		LD		HL,FNAME
		LD		A,(HL)
		AND		A
		RET		Z
		DEC		HL
		LD		A,63H            ;コマンド63Hを送信
		CALL	STCMD
		JR		NZ,LINI1
		XOR		A
		JR		LINI2
LINI1:	LD		A,03H
LINI2:	LD		(STOPFLG),A
		XOR		A
		LD		(FNAME),A
;		EI
		RET

;********** LOAD ONE BYTE FROM SD *********
LOAD1BYTE:
		DI
		PUSH	BC
		PUSH	DE
		PUSH	HL
		LD		A,(STOPFLG)
		CP		00H
		JR		NZ,L1B1
		LD		A,65H			;LOAD1BYTE コマンド65Hを送信
		CALL	STCD
		CALL	RCVBYTE			;1Byteのみ受信
		LD		B,A
		XOR		A				;Z FLGをクリア
		LD		A,B
		POP		HL
		POP		DE
		POP		BC
		RET
L1B1:	POP		HL
		POP		DE
		POP		BC
		CALL	34CEH
		RET

SAVEINI:
		DI
		LD		HL,MS_SAVE
		CALL	MSGOUT
		CALL	MONCLF
		XOR		A
		LD		(FNAME+6),A
		LD		HL,FNAME-1
		LD		A,67H            ;コマンド67Hを送信
		CALL	STCMD
		JR		NZ,SINI1
		XOR		A
		JR		SINI2
SINI1:	LD		A,03H
SINI2:	LD		(STOPFLG),A
;		EI
		RET

SAVE1BYTE:
		DI
		PUSH	BC
		PUSH	DE
		PUSH	HL
		PUSH	AF
		LD		A,66H			;SAVE1BYTE コマンド66Hを送信
		CALL	STCD
		POP		AF
		CALL	SNDBYTE			;1Byteのみ受信
		POP		HL
		POP		DE
		POP		BC
;		EI
		RET

SAVEEND:
		DI
		LD		A,69H
		CALL	STCD
		RET

;**** コマンド送信 (IN:A コマンドコード)****
STCD:	CALL	SNDBYTE          ;Aレジスタのコマンドコードを送信
		CALL	RCVBYTE          ;状態取得(00H=OK)
		RET

;**** コマンド、ファイル名送信 (IN:A コマンドコード HL:ファイルネームの先頭)****
STCMD:	INC		HL
		CALL	STFN             ;空白除去
		PUSH	HL
		CALL	STCD             ;コマンドコード送信
		POP		HL
		AND		A                ;00以外ならERROR
		JP		NZ,SDERR
		CALL	STFS             ;ファイルネーム送信
		AND		A                ;00以外ならERROR
		JP		NZ,SDERR
		RET

;**** ファイルネーム送信(IN:HL ファイルネームの先頭) ******
STFS:	LD		B,20H
STFS1:	LD		A,(HL)           ;FNAME送信
		CP		22H
		JR		NZ,STFS2
		INC		HL
		JR		STFS1
STFS2:	CALL	SNDBYTE
		INC		HL
		DEC		B
		JR		NZ,STFS1
		LD		A,0DH
		CALL	SNDBYTE
		CALL	RCVBYTE          ;状態取得(00H=OK)
		RET

;****** FILE NAMEが取得できるまでスペース、ダブルコーテーションを読み飛ばし (IN:HL コマンド文字の次の文字 OUT:HL ファイルネームの先頭)*********
STFN:	PUSH	AF
STFN1:	LD		A,(HL)
		CP		20H
		JR		Z,STFN2
		CP		22H
		JR		NZ,STFN3
STFN2:	INC		HL               ;ファイルネームまでスペース読み飛ばし
		JR		STFN1
STFN3:	POP		AF
		RET

;************** エラー内容表示 *****************************
SDERR:
		PUSH	AF
		CP		0F0H
		JR		NZ,ERR3
		LD		HL,MSG_F0        ;SD-CARD INITIALIZE ERROR
		JR		ERRMSG
ERR3:	CP		0F1H
		JR		NZ,ERR4
		LD		HL,MSG_F1        ;NOT FIND FILE
		JR		ERRMSG
ERR4:	CP		0F3H
		JR		NZ,ERR5
		LD		HL,MSG_F3        ;FILE EXIST
		JR		ERRMSG
ERR5:	CP		0F6H
		JR		NZ,ERR99
		LD		HL,MSG_FNAME     ;PARAMETER FAILED
		JR		ERRMSG
ERR99:	CALL	MONBHX
		LD		HL,MSG99         ;その他ERROR
ERRMSG:	CALL	MSGOUT
		CALL	MONCLF
		CALL	DISPBL
		LD		A,03H
		LD		(STOPFLG),A
		POP		AF
		RET

MS_SAVE
		DB		'Saving ',00H

MSG_FNAME:
		DB		'PARAMETAR FAILED!'
		DB		00H
		
MSG_F0:
		DB		'SD-CARD INITIALIZE ERROR'
		DB		00H
		
MSG_F1:
		DB		'NOT FIND FILE'
		DB		00H
		
MSG_F2:
		DB		'NOT OBJECT FILE'
		DB		00H
		
MSG_F3:
		DB		'FILE EXIST'
		DB		00H
		
MSG_F5:
		DB		'NO PROGRAM!!'
		DB		00H
		
MSG_F6:
		DB		'NOT BASIC PROGRAM'
		DB		0DH,0AH,00H

MSG_F7:
		DB		'NOT P6T FILE?'
		DB		0DH,0AH,00H
		
MSG_F8:
		DB		'MODE5 MODE6 NOT EXECUTE'
		DB		0DH,0AH,00H
		
MSG_F9:
		DB		'MODE0 NOT EXECUTE'
		DB		0DH,0AH,00H
		
MSG99:
		DB		' ERROR'
		DB		00H

		END

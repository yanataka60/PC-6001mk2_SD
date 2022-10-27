AZLCNV		EQU		0BEFH		;������->�啶���ϊ�
CONOUT		EQU		1075H		;CRT�ւ�1�o�C�g�o��
MSGOUT		EQU		30CFH		;������̏o��
LINPUT		EQU		28F9H		;�X�N���[���E�G�f�B�^
TBLOAD		EQU		0FAA7H		;LOAD�R�}���h�W�����v�A�h���X
TBSAVE		EQU		0FAA9H		;SAVE�R�}���h�W�����v�A�h���X
TBLLIST		EQU		0FA91H		;LLIST�R�}���h�W�����v�A�h���X
LBUF		EQU		0FBB9H
MONCLF		EQU		2739H		;CR�R�[�h�y��LF�R�[�h�̕\��
KYSCAN		EQU		0FBCH		;���A���^�C���E�L�[�{�[�h�E�X�L���j���O
MONBHX		EQU		397AH		;A���W�X�^�̓��e��10�i���Ƃ��ĕ\��
DISPBL		EQU		1BCDH		;�x���R�[�h�̏o��
FUNC8		EQU		0FB75H		;F8 KEY ��`�̈�
KEYIN		EQU		0FC4H		;1��������
STOPFLG		EQU		0FA18H		;STOP ESC KEY FLG
FNAME		EQU		0FECBH		;CMT FILE NAME


;PC-6001
PPI_A		EQU		07CH

PPI_B		EQU		PPI_A+1
PPI_C		EQU		PPI_A+2
PPI_R		EQU		PPI_A+3

;PC-6001
;8255 PORT �A�h���X 7CH�`7FH
;07CH PORTA ���M�f�[�^(����4�r�b�g)
;07DH PORTB ��M�f�[�^(8�r�b�g)
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
;7FH �R���g���[�����W�X�^

;DIRLIST�R�}���h		61H
;p6t LOAD �R�}���h	62H
;p6 LOAD �R�}���h	63H
;LOAD1BYTE �R�}���h	64H

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
		
;**** 1BYTE��M ****
;��MDATA��A���W�X�^�ɃZ�b�g���ă��^�[��
RCVBYTE:
		CALL	F1CHK             ;PORTC BIT7��1�ɂȂ�܂�LOOP
		IN		A,(PPI_B)         ;PORTB -> A
		PUSH 	AF
		LD		A,05H
		OUT		(PPI_R),A         ;PORTC BIT2 <- 1
		CALL	F2CHK             ;PORTC BIT7��0�ɂȂ�܂�LOOP
		LD		A,04H
		OUT		(PPI_R),A         ;PORTC BIT2 <- 0
		POP 	AF
		RET
		
;**** 1BYTE���M ****
;A���W�X�^�̓��e��PORTA����4BIT��4BIT�����M
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

;**** 4BIT���M ****
;A���W�X�^����4�r�b�g�𑗐M����
SND4BIT:
		OUT		(PPI_A),A
		LD		A,05H
		OUT		(PPI_R),A          ;PORTC BIT2 <- 1
		CALL	F1CHK             ;PORTC BIT7��1�ɂȂ�܂�LOOP
		LD		A,04H
		OUT		(PPI_R),A          ;PORTC BIT2 <- 0
		CALL	F2CHK
		RET
		
;**** BUSY��CHECK(1) ****
; 82H BIT7��1�ɂȂ�܂�LOP
F1CHK:	IN		A,(PPI_C)
		AND		80H               ;PORTC BIT7 = 1?
		JR		Z,F1CHK
		RET

;**** BUSY��CHECK(0) ****
; 82H BIT7��0�ɂȂ�܂�LOOP
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
		LD		A,63H            ;�R�}���h63H�𑗐M
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
		LD		A,65H			;LOAD1BYTE �R�}���h65H�𑗐M
		CALL	STCD
		CALL	RCVBYTE			;1Byte�̂ݎ�M
		LD		B,A
		XOR		A				;Z FLG���N���A
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
		LD		A,67H            ;�R�}���h67H�𑗐M
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
		LD		A,66H			;SAVE1BYTE �R�}���h66H�𑗐M
		CALL	STCD
		POP		AF
		CALL	SNDBYTE			;1Byte�̂ݎ�M
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

;**** �R�}���h���M (IN:A �R�}���h�R�[�h)****
STCD:	CALL	SNDBYTE          ;A���W�X�^�̃R�}���h�R�[�h�𑗐M
		CALL	RCVBYTE          ;��Ԏ擾(00H=OK)
		RET

;**** �R�}���h�A�t�@�C�������M (IN:A �R�}���h�R�[�h HL:�t�@�C���l�[���̐擪)****
STCMD:	INC		HL
		CALL	STFN             ;�󔒏���
		PUSH	HL
		CALL	STCD             ;�R�}���h�R�[�h���M
		POP		HL
		AND		A                ;00�ȊO�Ȃ�ERROR
		JP		NZ,SDERR
		CALL	STFS             ;�t�@�C���l�[�����M
		AND		A                ;00�ȊO�Ȃ�ERROR
		JP		NZ,SDERR
		RET

;**** �t�@�C���l�[�����M(IN:HL �t�@�C���l�[���̐擪) ******
STFS:	LD		B,20H
STFS1:	LD		A,(HL)           ;FNAME���M
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
		CALL	RCVBYTE          ;��Ԏ擾(00H=OK)
		RET

;****** FILE NAME���擾�ł���܂ŃX�y�[�X�A�_�u���R�[�e�[�V������ǂݔ�΂� (IN:HL �R�}���h�����̎��̕��� OUT:HL �t�@�C���l�[���̐擪)*********
STFN:	PUSH	AF
STFN1:	LD		A,(HL)
		CP		20H
		JR		Z,STFN2
		CP		22H
		JR		NZ,STFN3
STFN2:	INC		HL               ;�t�@�C���l�[���܂ŃX�y�[�X�ǂݔ�΂�
		JR		STFN1
STFN3:	POP		AF
		RET

;************** �G���[���e�\�� *****************************
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
		LD		HL,MSG99         ;���̑�ERROR
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

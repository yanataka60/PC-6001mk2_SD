;2022.10.26 F�R�}���h�ɂ�DI�ǉ��B
;2022.10.29 MSG_F8����MODE5�̕������폜�B
;2022.10.31 MODE1�`MODE4�AMODE5�𓝍�
;2023. 3. 4 AUTO START�̑I������y/c/n�Ƃ��ACLOAD�����s���Ȃ��I����ǉ�

AZLCNV		EQU		0BEFH			;������->�啶���ϊ�
KYSCAN		EQU		0FBCH			;���A���^�C���E�L�[�{�[�h�E�X�L���j���O
KEYIN		EQU		0FC4H			;1��������
CONOUT		EQU		1075H			;CRT�ւ�1�o�C�g�o��
DISPBL		EQU		1BCDH			;�x���R�[�h�̏o��
MONCLF		EQU		2739H			;CR�R�[�h�y��LF�R�[�h�̕\��
LINPUT		EQU		28F9H			;�X�N���[���E�G�f�B�^
MSGOUT		EQU		30CFH			;������̏o��
MONBHX		EQU		397AH			;A���W�X�^�̓��e��10�i���Ƃ��ĕ\��
STOPFLG		EQU		0FA18H			;STOP ESC KEY FLG
ASTRLEN		EQU		0FA32H			;�������s������
FUNC8		EQU		0FB75H			;F8 KEY ��`�̈�
ASTRSTRG	EQU		0FB8DH			;�������s������i�[�ꏊ
LBUF		EQU		0FBB9H			;�s�o�b�t�@�y�ю������s������i�[��
FNAME		EQU		0FECBH			;CMT FILE NAME
MODEFLG		EQU		0FF4EH			;MODE�ݒ�WORK


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

;DIRLIST�R�}���h	61H
;p6t LOAD �R�}���h	62H
;p6 LOAD �R�}���h	63H
;LOAD1BYTE �R�}���h	64H

;BASIC LOAD START	65H
;BASIC LOAD END		66H

;BASIC SAVE START	67H
;SAVE1BYTE			68H
;BASIC SAVE END		69H

        ORG		6000H

		DB		'C','D'				;�g��ROM�F���R�[�h

		DW		INIT				;POWER ON��8255���������ALuncher�N��
		
		JP		LOADINI
		JP		LOAD1BYTE
		JP		SAVEINI
		JP		SAVE1BYTE
		JP		SAVEEND

;**** 8255������ ****
;PORTC����BIT��OUTPUT�A���BIT��INPUT�APORTB��INPUT�APORTA��OUTPUT
INIT:
		LD		A,8AH
		OUT		(PPI_R),A
;�o��BIT�����Z�b�g
		XOR		A					;PORTA <- 0
		OUT		(PPI_A),A
		OUT		(PPI_C),A			;PORTC <- 0

		LD		HL,TITLE_MSG
		CALL	MSGOUT
CMD1:	LD		A,'*'
		CALL	CONOUT
		CALL	LINPUT
		RET		C					;STOP��BASIC�ɕ��A
CMD2:
		INC		HL
		LD		A,(HL)
		CP		'*'					;���͎��ƃX�N���[���G�f�B�b�g����IBUF�ɓ���ʒu���ς�邽�߂̑Ώ��A�u*�v�Ȃ�|�C���^��i�߂�
		JR		Z,CMD2
		CALL	AZLCNV				;�啶���ϊ�
		CP		'B'
		RET		Z					;B�R�}���h�ł�BASIC�ɕ��A
		CP		'1'
		JR		Z,BRET				;MODE1
		CP		'2'
		JR		Z,BRET				;MODE2
		CP		'3'
		JR		Z,BRET				;MODE3
		CP		'4'
		JR		Z,BRET				;MODE4
		CP		'F'
		JP		Z,STLT				;F�R�}���h
		CP		'L'
		JP		Z,MONLOAD			;L�R�}���h
		LD		B,A
		LD		A,(1A61H)			;ROM���C������Ă����MODE5�Ή�
		CP		0C3H
		JR		NZ,CMD3
		LD		A,B
		CP		'5'					;ROM���C������Ă����MODE5�Ή�
		JR		Z,BRET

CMD3:	LD		HL,MSG_CMD1
		CALL	MSGOUT				;�R�}���h�G���[9�s���o��
		LD		HL,MSG_CMD2
		CALL	MSGOUT
		LD		HL,MSG_CMD3
		CALL	MSGOUT
		LD		HL,MSG_CMD4
		CALL	MSGOUT
		LD		HL,MSG_CMD5
		CALL	MSGOUT
		LD		HL,MSG_CMD6
		CALL	MSGOUT
		LD		HL,MSG_CMD7
		CALL	MSGOUT
		LD		A,(1A61H)			;ROM���C������Ă����MODE5�Ή�
		CP		0C3H
		JR		NZ,CMD4
		LD		HL,MSG_CMD8
		CALL	MSGOUT
CMD4:	LD		HL,MSG_CMD9
		CALL	MSGOUT
		LD		HL,MSG_CMDA
		CALL	MSGOUT
		JP		CMD1

BRET:
		SUB		31H
		LD		(MODEFLG),A			;MODE�ݒ�
		PUSH	AF

BRET2:	CALL	MONCLF
		LD		HL,PG_SEL			;PAGE�I��\��
		CALL	MSGOUT
		CALL	KEYIN				;1��������(1-4)
		CALL	CONOUT
		CP		'1'
		JR		C,BRET2
		CP		'5'
		JR		NC,BRET2

		LD		HL,LBUF				;AUTOSTART������i�[�ꏊ
		LD		(ASTRSTRG),HL
		LD		(HL),A				;PAGE��������
		CALL	MONCLF
		INC		HL
		LD		A,0DH
		LD		(HL),A
		INC		HL

		LD		A,15				;AUTOSTART������
		LD		(ASTRLEN),A

		POP		AF
		LD		B,13
		CP		02H					;MODE1 MODE2
		JR		NC,BRET3
		LD		DE,MODE12
		JR		BRET4
BRET3:
		CP		04H					;MODE3 MODE4
		JR		NC,BRET31
		LD		DE,MODE34
		JR		BRET4
BRET31:
		LD		A,2				;AUTOSTART������
		LD		(ASTRLEN),A
		RET
		
BRET4:	LD		A,(DE)
		LD		(HL),A
		INC		HL
		INC		DE
		DJNZ	BRET4
		CALL	SDCHG1
		JR		SDCHG3
		
SDCHG1:	LD		A,55H				;0000H�`3FFFH�̏����ݐ�����RAM�ɐ؂�ւ�
		OUT		(0F2H),A
		LD		HL,0000H			;BASIC ROM�����RAM�ɃR�s�[
		LD		DE,0000H
		LD		BC,4000H
		LDIR
		RET

SDCHG3:	LD		A,0C3H				;���̑�SD�Ή��p�b�`����
		LD		(1A61H),A
		LD		HL,LOADINI
		LD		(1A62H),HL
		LD		A,0C3H
		LD		(1A70H),A
		LD		HL,LOAD1BYTE
		LD		(1A71H),HL
		LD		A,0C3H
		LD		(1AB8H),A
		LD		HL,SAVEINI
		LD		(1AB9H),HL
		LD		A,0C3H
		LD		(1ACCH),A
		LD		HL,SAVE1BYTE
		LD		(1ACDH),HL
		LD		A,0C3H
		LD		(1B06H),A
		LD		HL,SAVEEND
		LD		(1B07H),HL
		RET

TITLE_MSG:
		DB		'  ** PC-6001mk2_SD Launcher **',0AH,0DH,00H

;**** 1BYTE��M ****
;��MDATA��A���W�X�^�ɃZ�b�g���ă��^�[��
RCVBYTE:
		CALL	F1CHK 				;PORTC BIT7��1�ɂȂ�܂�LOOP
		IN		A,(PPI_B)			;PORTB -> A
		PUSH 	AF
		LD		A,05H
		OUT		(PPI_R),A			;PORTC BIT2 <- 1
		CALL	F2CHK				;PORTC BIT7��0�ɂȂ�܂�LOOP
		LD		A,04H
		OUT		(PPI_R),A			;PORTC BIT2 <- 0
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
		OUT		(PPI_R),A			;PORTC BIT2 <- 1
		CALL	F1CHK				;PORTC BIT7��1�ɂȂ�܂�LOOP
		LD		A,04H
		OUT		(PPI_R),A			;PORTC BIT2 <- 0
		CALL	F2CHK
		RET
		
;**** BUSY��CHECK(1) ****
; 82H BIT7��1�ɂȂ�܂�LOP
F1CHK:	IN		A,(PPI_C)
		AND		80H					;PORTC BIT7 = 1?
		JR		Z,F1CHK
		RET

;**** BUSY��CHECK(0) ****
; 82H BIT7��0�ɂȂ�܂�LOOP
F2CHK:	IN		A,(PPI_C)
		AND		80H					;PORTC BIT7 = 0?
		JR		NZ,F2CHK
		RET

;************ F�R�}���h DIRLIST **********************
STLT:
		DI
		INC		HL
		CALL	STFN				;����������𑗐M
		EX		DE,HL
		LD		HL,DEFDIR			;�s����'*L '��t���邱�ƂŃJ�[�\�����ړ��������^�[���Ŏ��s�ł���悤��
		LD		BC,DEND-DEFDIR
		CALL	DIRLIST				;DIRLIST�{�̂��R�[��
		AND		A					;00�ȊO�Ȃ�ERROR
		CALL	NZ,SDERR
;		EI
		JP		CMD1


;**** DIRLIST�{�� (HL=�s���ɕt�����镶����̐擪�A�h���X BC=�s���ɕt�����镶����̒���) ****
;****              �߂�l A=�G���[�R�[�h ****
DIRLIST:
		LD		A,61H				;DIRLIST�R�}���h61H�𑗐M
		CALL	STCD				;�R�}���h�R�[�h���M
		AND		A					;00�ȊO�Ȃ�ERROR
		JP		NZ,DLRET
		
		PUSH	BC
		LD		B,21H				;�t�@�C���l�[������������33�������𑗐M
STLT1:	LD		A,(DE)
		AND		A
		JR		NZ,STLT2
		XOR		A
STLT2:	CALL	AZLCNV				;�啶���ɕϊ�
		CP		22H					;�_�u���R�[�e�[�V�����ǂݔ�΂�
		JR		NZ,STLT3
		INC		DE
		JR		STLT1
STLT3:	CALL	SNDBYTE				;�t�@�C���l�[������������𑗐M
		INC		DE
		DEC		B
		JR		NZ,STLT1
		POP		BC

		CALL	RCVBYTE				;��Ԏ擾(00H=OK)
		AND		A					;00�ȊO�Ȃ�ERROR
		JP		NZ,DLRET

DL1:
		PUSH	HL
		PUSH	BC
		LD		DE,LBUF
		LDIR
		EX		DE,HL
DL2:	CALL	RCVBYTE				;'00H'����M����܂ł���s�Ƃ���
		AND		A
		JR		Z,DL3
		CP		0FFH				;'0FFH'����M������I��
		JR		Z,DL4
		CP		0FEH				;'0FEH'����M������ꎞ��~���Ĉꕶ�����͑҂�
		JR		Z,DL5
		LD		(HL),A
		INC		HL
		JR		DL2
DL3:	LD		(HL),00H
		LD		HL,LBUF				;'00H'����M�������s����\�����ĉ��s
DL31:	LD		A,(HL)
		AND		A
		JR		Z,DL33
		CALL	CONOUT
		INC		HL
		JR		DL31
DL33:	CALL	MONCLF
		POP		BC
		POP		HL
		JR		DL1
DL4:	CALL	RCVBYTE				;��Ԏ擾(00H=OK)
		POP		BC
		POP		HL
		JR		DLRET

DL5:	PUSH	HL
		LD		HL,MSG_KEY1			;HIT ANT KEY�\��
		CALL	MSGOUT
		CALL	MONCLF
		POP		HL
DL6:	CALL	KYSCAN				;1�������͑҂�
		JR		Z,DL6
		CALL	AZLCNV
		CP		1BH					;ESC�őł��؂�
		JR		Z,DL7
		CP		1EH					;�J�[�\�����őł��؂�
		JR		Z,DL7
		CP		42H					;�uB�v�őO�y�[�W
		JR		Z,DL8
		XOR		A					;����ȊO�Ōp��
		JR		DL8
DL7:	LD		A,0FFH				;0FFH���f�R�[�h�𑗐M
DL8:	CALL	SNDBYTE
		JP		DL2
		
DLRET:	RET
		
;************ L�R�}���h p6t LOAD *************************
MONLOAD:
;		DI
		CALL	P6CHK
		CP		01H
		JP		Z,P6LOAD
		LD		A,62H				;p6t LOAD �R�}���h62H�𑗐M
		CALL	STCMD
		JP		NZ,CMD1
		

		CALL	RCVBYTE				;p6t���ǂݏo������X�e�[�^�X��M
		AND		A
		JR		Z,ML0
		LD		HL,MSG_F7			;p6t�t�@�C���ł͂Ȃ�
		CALL	MSGOUT
		JP		CMD1

ML0:	CALL	RCVBYTE				;MODE��M
		AND		A
		JR		NZ,ML00
		LD		HL,MSG_F9			;MODE0�ُ͈�l
		CALL	MSGOUT
		JP		CMD1

ML00:	LD		B,A
		LD		A,(1A61H)			;ROM���C������Ă����MODE5�Ή�
		CP		0C3H
		LD		A,B
		JR		NZ,ML01
		CP		06H
		JR		C,ML1
		LD		HL,MSG_F8			;MODE6�ȏ�͎��s�s��
		CALL	MSGOUT
		JP		CMD1
ML01:
		CP		05H
		JR		C,ML1
		LD		HL,MSG_F81			;MODE5�ȏ�͎��s�s��
		CALL	MSGOUT
;p6t���͑����Ă��Ă��܂����ߋ�ǂ�
		CALL	RCVBYTE				;PAGE��M
		CALL	RCVBYTE				;p6t�t�@�C�����̃I�[�g�X�^�[�g�����񐔎�M
		LD		B,A
		AND		A					;p6t�t�@�C�����̃I�[�g�X�^�[�g�����񂪖����Ȃ�X�L�b�v
		JR		Z,ML02
ML03:	CALL	RCVBYTE				;�I�[�g�X�^�[�g�������M
		DJNZ	ML03
ML02:	JP		CMD1
		
ML1:	DEC		A
		LD		(MODEFLG),A			;MODE��������
		LD		HL,LBUF				;AUTOSTART������i�[�ꏊ
		LD		(ASTRSTRG),HL

		PUSH	AF
		CALL	RCVBYTE				;PAGE��M
		ADD		A,30H
		LD		(HL),A				;PAGE��������
		INC		HL
		LD		A,0DH
		LD		(HL),A
		INC		HL
		POP		AF
		
		LD		B,13
		CP		02H					;MODE1 MODE2
		JR		NC,MD3
		LD		DE,MODE12
		JR		ML2
MD3:
		CP		04H					;MODE3 MODE4
		JR		NC,MD31
		LD		DE,MODE34			;MODE3 MODE4
		JR		ML2

MD31:	LD		DE,MODE5			;MODE5

ML2:	LD		A,(DE)
		LD		(HL),A
		INC		HL
		INC		DE
		DJNZ	ML2

ML21:	CALL	RCVBYTE				;p6t�t�@�C�����̃I�[�g�X�^�[�g�����񐔎�M
		LD		B,A

		ADD		A,15				;AUTOSTART������
		LD		(ASTRLEN),A

		LD		A,B
		AND		A					;p6t�t�@�C�����̃I�[�g�X�^�[�g�����񂪖����Ȃ�X�L�b�v
		JR		Z,ML5
ML3:	CALL	RCVBYTE				;�I�[�g�X�^�[�g�������M
		CP		0AH					;0AH->0DH�ɏC�����ď�������
		JR		NZ,ML4
		LD		A,0DH
ML4:	LD		(HL),A
		INC		HL
		DJNZ	ML3
ML5:
		LD		A,(MODEFLG)			;MODE5�Ȃ�RAM�ւ̃R�s�[�ARAM�ւ̃p�b�`���Ă͂��Ȃ��B
		CP		04H
		RET		NC
		CALL	SDCHG1				;SD�p�p�b�`���ă��[�`����
		JP		SDCHG3

		
MODE12:
		DB		'OUT&HF0,&H7D',0DH	;0000H�`3FFFH:����RAM 4000�`7FFFH:�O��ROM
MODE34:
		DB		'OUT&HF0,&HAD',0DH	;0000H�`3FFFH:����RAM 4000�`5FFFH:BASIC 6000H�`7FFFH:�O��ROM
MODE5:
		DB		'            ',0DH	;NO OPARATION

MS_MODE:
		DB		'Mode?(1-5)',00H
MS_MODE2:
		DB		'Mode?(1-4)',00H
PG_SEL:
		DB		'How Many Pages?(1-4)',00H
AS_SEL:
		DB		'Auto Run?(y/c/n)',00H
MS_SAVE
		DB		'Saving ',00H
ATSTR:
		DB		'CLOAD',0DH,'RUN',0DH
ATSTR_END:
ATSTR2:
		DB		'CLOAD',0DH
ATSTR2_END:

;***** P6 LOAD *****************
P6LOAD:
		LD		A,63H				;p6 LOAD �R�}���h63H�𑗐M
		CALL	STCMD
		JP		NZ,CMD1
		LD		A,(1A61H)			;ROM���C������Ă����MODE5�Ή�
		CP		0C3H
		JR		NZ,PL11
PL1:	CALL	MONCLF				;MODE5�Ή�
		LD		HL,MS_MODE			;MODE�I��\��
		CALL	MSGOUT
		CALL	KEYIN				;1��������(1-5)
		CALL	CONOUT
		CP		'1'
		JR		C,PL1
		CP		'6'
		JR		NC,PL1
		JR		PL12
		
PL11:	CALL	MONCLF				;MODE5��Ή�
		LD		HL,MS_MODE2			;MODE�I��\��
		CALL	MSGOUT
		CALL	KEYIN				;1��������(1-4)
		CALL	CONOUT
		CP		'1'
		JR		C,PL11
		CP		'5'
		JR		NC,PL11

PL12:	SUB		31H
		LD		(MODEFLG),A			;MODE��������

		PUSH	AF
PL2:	CALL	MONCLF
		LD		HL,PG_SEL			;PAGE�I��\��
		CALL	MSGOUT
		CALL	KEYIN				;1��������(1-4)
		CALL	CONOUT
		CP		'1'
		JR		C,PL2
		CP		'5'
		JR		NC,PL2

		LD		HL,LBUF				;AUTOSTART������i�[�ꏊ
		LD		(ASTRSTRG),HL
		LD		(HL),A				;PAGE��������
		CALL	MONCLF
		INC		HL
		LD		A,0DH
		LD		(HL),A
		INC		HL

		PUSH	HL
		LD		HL,AS_SEL			;AUTO START�I��\��
		CALL	MSGOUT
		CALL	KEYIN				;Y:AUTO START C:�I�������t�@�C�����Z�b�g����BASIC�N�����CLOAD N:�I�������t�@�C�����Z�b�g����BASIC�N�� 
		CALL	AZLCNV
		POP		HL
		CALL	CONOUT
		CP		'Y'
		JR		Z,P67
		CP		'C'
		JR		Z,P671
		LD		A,15				;N�I��:AUTOSTART������
		JR		P68
P671:	LD		A,21				;C�I��:AUTOSTART������
		JR		P68
P67:	LD		A,25				;Y�I��:AUTOSTART������
P68:	LD		(ASTRLEN),A

		POP		AF
		LD		B,13
		CP		02H					;MODE1 MODE2
		JR		NC,P62
		LD		DE,MODE12
		JR		P63
P62:
		CP		04H					;MODE3 MODE4
		JR		NC,P631
		LD		DE,MODE34			;MODE3 MODE4
		JR		P63
P631:
		LD		DE,MODE5			;MODE5
		
P63:	LD		A,(DE)
		LD		(HL),A
		INC		HL
		INC		DE
		DJNZ	P63

		LD		A,(ASTRLEN)

		CP		21
		JR		Z,P66
		CP		15
		JR		Z,P661
		LD		B,ATSTR_END-ATSTR
		LD		DE,ATSTR
		JR		P65
P66:	LD		B,ATSTR2_END-ATSTR2
		LD		DE,ATSTR2
P65:	LD		A,(DE)
		LD		(HL),A
		INC		HL
		INC		DE
		DJNZ	P65
P661:	LD		A,(MODEFLG)			;MODE5�Ȃ�RAM�ւ̃R�s�[�ARAM�ւ̃p�b�`���Ă͂��Ȃ��B
		CP		04H
		RET		NC
		CALL	SDCHG1				;SD�p�p�b�`���ă��[�`����
		JP		SDCHG3

;********** LOAD ONE BYTE FROM SD *********
LOAD1BYTE:
		DI
		PUSH	BC
		PUSH	DE
		PUSH	HL
		LD		A,(STOPFLG)
		CP		00H
		JR		NZ,L1B1
		LD		A,64H				;LOAD1BYTE �R�}���h64H�𑗐M
		CALL	STCD
		CALL	RCVBYTE				;1Byte�̂ݎ�M
		LD		B,A
		XOR		A					;Z FLG���N���A
		LD		A,B
		POP		HL
		POP		DE
		POP		BC
		RET
L1B1:	POP		HL
		POP		DE
		POP		BC
		CALL	34CEH
;		EI
		JP		274DH

;****** FILE NAME���擾�ł���܂ŃX�y�[�X�A�_�u���R�[�e�[�V������ǂݔ�΂� (IN:HL �R�}���h�����̎��̕��� OUT:HL �t�@�C���l�[���̐擪)*********
STFN:	PUSH	AF
STFN1:	LD		A,(HL)
		CP		20H
		JR		Z,STFN2
		CP		22H
		JR		NZ,STFN3
STFN2:	INC		HL					;�t�@�C���l�[���܂ŃX�y�[�X�ǂݔ�΂�
		JR		STFN1
STFN3:	POP		AF
		RET

DEFDIR:
		DB		'*L '
DEND:

;**** �R�}���h���M (IN:A �R�}���h�R�[�h)****
STCD:	CALL	SNDBYTE				;A���W�X�^�̃R�}���h�R�[�h�𑗐M
		CALL	RCVBYTE				;��Ԏ擾(00H=OK)
		RET

;**** �R�}���h�A�t�@�C�������M (IN:A �R�}���h�R�[�h HL:�t�@�C���l�[���̐擪)****
STCMD:	INC		HL
		CALL	STFN				;�󔒏���
		PUSH	HL
		CALL	STCD				;�R�}���h�R�[�h���M
		POP		HL
		AND		A					;00�ȊO�Ȃ�ERROR
		JP		NZ,SDERR
		CALL	STFS				;�t�@�C���l�[�����M
		AND		A					;00�ȊO�Ȃ�ERROR
		JP		NZ,SDERR
		RET

;**** �t�@�C���l�[�����M(IN:HL �t�@�C���l�[���̐擪) ******
STFS:	LD		B,20H
STFS1:	LD		A,(HL)				;FNAME���M
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
		CALL	RCVBYTE				;��Ԏ擾(00H=OK)
		RET

;**** .p6 or cas check ******
P6CHK:	PUSH	HL
		INC		HL
		CALL	STFN				;�󔒏���
		LD		B,20H
P6CHK1:	LD		A,(HL)
		AND		A
		JR		Z,P6CHK2
		INC		HL
		DEC		B
		JR		NZ,P6CHK1
P6CHK2:	DEC		HL
		LD		A,(HL)
		CP		'6'
		JR		NZ,P6CHK5
		DEC		HL
		LD		A,(HL)
		CALL	AZLCNV
		CP		'P'
		JR		NZ,P6CHK3
		DEC		HL
		LD		A,(HL)
		CP		'.'
		JR		NZ,P6CHK3
		LD		A,01H
		JR		P6CHK4
P6CHK3:	XOR		A
P6CHK4:	POP		HL
		RET
		
P6CHK5:	CALL	AZLCNV
		CP		'S'
		JR		NZ,P6CHK3
		DEC		HL
		LD		A,(HL)
		CALL	AZLCNV
		CP		'A'
		JR		NZ,P6CHK3
		DEC		HL
		LD		A,(HL)
		CALL	AZLCNV
		CP		'C'
		JR		NZ,P6CHK3
		LD		A,01H
		JR		P6CHK4

;************** �G���[���e�\�� *****************************
SDERR:
		PUSH	AF
		CP		0F0H
		JR		NZ,ERR3
		LD		HL,MSG_F0			;SD-CARD INITIALIZE ERROR
		JR		ERRMSG
ERR3:	CP		0F1H
		JR		NZ,ERR4
		LD		HL,MSG_F1			;NOT FIND FILE
		JR		ERRMSG
ERR4:	CP		0F3H
		JR		NZ,ERR5
		LD		HL,MSG_F3			;FILE EXIST
		JR		ERRMSG
ERR5:	CP		0F6H
		JR		NZ,ERR99
		LD		HL,MSG_FNAME		;PARAMETER FAILED
		JR		ERRMSG
ERR99:	CALL	MONBHX
		LD		HL,MSG99			;���̑�ERROR
ERRMSG:	CALL	MSGOUT
		CALL	MONCLF
		CALL	DISPBL
		LD		A,03H
		LD		(STOPFLG),A
		POP		AF
		RET

MSG_CMD1:
		DB		'COMMAND FAILED!',0DH,0AH,00H
MSG_CMD2:
		DB		' STOP: Return Basic(Not Use SD)',0DH,0AH,00H
MSG_CMD3:
		DB		' B   : Return Basic(Not Use SD)',0DH,0AH,00H
MSG_CMD4:
		DB		' 1   : MODE 1 N60 BASIC(SD)',0DH,0AH,00H
MSG_CMD5:
		DB		' 2   : MODE 2 N60 BASIC(SD)',0DH,0AH,00H
MSG_CMD6:
		DB		' 3   : MODE 3 N60 EXT BASIC(SD)',0DH,0AH,00H
MSG_CMD7:
		DB		' 4   : MODE 4 N60 EXT BASIC(SD)',0DH,0AH,00H
MSG_CMD8:
		DB		' 5   : MODE 5 N60m BASIC(SD)',0DH,0AH,00H
MSG_CMD9:
		DB		' F x : Find SD File',0DH,0AH,00H
MSG_CMDA:
		DB		' L x : Load From SD',0DH,0AH,00H

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
		DB		'MODE6 NOT EXECUTE'
		DB		0DH,0AH,00H
		
MSG_F81:
		DB		'MODE5 MODE6 NOT EXECUTE'
		DB		0DH,0AH,00H
		
MSG_F9:
		DB		'MODE0 NOT EXECUTE'
		DB		0DH,0AH,00H
		
MSG99:
		DB		' ERROR'
		DB		00H
		

MSG_KEY1:
		DB		'NEXT:ANY BACK:B BREAK:UP OR ESC'
		DB		00H

MSG_FNAME:
		DB		'PARAMETAR FAILED!'
		DB		00H
		

SAVEINI:
		DI
		LD		HL,MS_SAVE
		CALL	MSGOUT
		CALL	MONCLF
		XOR		A
		LD		(FNAME+6),A
		LD		HL,FNAME-1
		LD		A,67H				;�R�}���h67H�𑗐M
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
		LD		A,68H				;SAVE1BYTE �R�}���h68H�𑗐M
		CALL	STCD
		POP		AF
		CALL	SNDBYTE				;1Byte�̂ݎ�M
		POP		HL
		POP		DE
		POP		BC
;		EI
		RET

SAVEEND:
		LD		A,69H
		CALL	STCD
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
		LD		A,63H				;�R�}���h63H�𑗐M
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

		END

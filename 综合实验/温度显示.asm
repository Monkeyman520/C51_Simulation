
TEMPER_L   EQU 	41H     ;��Ŷ����¶ȵ�λ����
TEMPER_H   EQU 	40H     ;��Ŷ����¶ȸ�λ����
TEMPER_NUM EQU 	60H     ;���ת������¶�ֵ
FLAG1      BIT   10H
DQ         BIT  P3.3    ;һ�����߿��ƶ˿�;����ת������¶�ֵ
led0 equ 0fff0h
led1 equ 0fff1h
ledbuff equ 30h     
ORG 0000H
	MOV SP,#10H
	 MOV dptr,#led1     ;ָ�������
        MOV A,#00H         ;6��8λ��ʾ
        MOVX @dptr,a       ;��ʽ��д��
        MOV A,#32H         ;���Ƶ��ֵ
        MOVX @dptr,a       ;��Ƶ��д��
        MOV A,#0DFH        ;����������
        MOVX @dptr,a       ;�ر���ʾ��
	MOV ledbuff ,#10H
		MOV ledbuff+1,#10H
		MOV ledbuff+2,#10H
		MOV ledbuff+3,#10H
		MOV ledbuff+4,#10H
		MOV ledbuff+5,#10H
mloop:   LCALL GET_TEMPER
         LCALL TEMPER_COV
	 mov a,TEMPER_NUM
	 mov b,a
	 swap a
	 anl a,#0fh
	 anl b,#0fh
	 MOV LedBuff,b
	 MOV LedBuff+1,a
	 LCALL DISP
	 SJMP mloop
GET_TEMPER:
        SETB DQ         ;��ʱ���
BCD:    LCALL INIT_1820
        JB FLAG1,S22
        LJMP BCD        ;��DS18B20�������򷵻�
S22:    LCALL DISP
        MOV A,#0CCH     ;����ROMƥ��------0CC
        LCALL WRITE_1820
        MOV A,#44H      ;�����¶�ת������
        LCALL WRITE_1820
        NOP
        LCALL DISP
CBA:    LCALL INIT_1820
        JB FLAG1,ABC
        LJMP CBA
ABC:    LCALL DISP
        MOV A,#0CCH     ;����ROMƥ��
        LCALL WRITE_1820
        MOV A,#0BEH     ;�������¶�����
        LCALL WRITE_1820
        LCALL READ_18200
        RET
	
;дDS18B20�ĳ���
WRITE_1820:
        MOV R2,#8
        CLR C
WR1:    CLR DQ
        MOV R3,#3
        DJNZ R3,$
        RRC A
        MOV DQ,C
        MOV R3,#11
        DJNZ R3,$
        SETB DQ
        NOP
        DJNZ R2,WR1
        SETB DQ
        RET

READ_18200:
        MOV R4,#2       ;���¶ȸ�λ�͵�λ��DS18B20�ж���
        MOV R1,#TEMPER_L     ;��λ����41H(TEMPER_L),��λ����40H(TEMPER_H)
RE00:   MOV R2,#8
RE01:   CLR C
        SETB DQ
        NOP
        NOP
        CLR DQ
        NOP
        NOP
        NOP
        SETB DQ
        MOV R3,#3
        DJNZ R3,$
        MOV C,DQ
        MOV R3,#16H
        DJNZ R3,$
        RRC A
        DJNZ R2,RE01
        MOV @R1,A
        DEC R1
        DJNZ R4,RE00
        RET
TEMPER_COV:
        MOV A,#0F0H
        ANL A,TEMPER_L  ;��ȥ�¶ȵ�λ��С��������λ�¶���ֵ
        SWAP A
        MOV TEMPER_NUM,A
        MOV A,TEMPER_L
        JNB ACC.3,TEMPER_COV1 ;��������ȥ�¶�ֵ
        INC TEMPER_NUM
TEMPER_COV1:
        MOV A,TEMPER_H
        ANL A,#07H
        SWAP A
        ADD A,TEMPER_NUM
        MOV TEMPER_NUM,A ; ����任����¶�����
        LCALL BIN_BCD
        RET
BIN_BCD:MOV DPTR,#TEMP_TAB
        MOV A,TEMPER_NUM
        MOVC A,@A+DPTR
        MOV TEMPER_NUM,A
        RET

TEMP_TAB:
        DB 00H,01H,02H,03H,04H,05H,06H,07H
        DB 08H,09H,10H,11H,12H,13H,14H,15H
        DB 16H,17H,18H,19H,20H,21H,22H,23H
        DB 24H,25H,26H,27H,28H,29H,30H,31H
        DB 32H,33H,34H,35H,36H,37H,38H,39H
        DB 40H,41H,42H,43H,44H,45H,46H,47H
        DB 48H,49H,50H,51H,52H,53H,54H,55H
        DB 56H,57H,58H,59H,60H,61H,62H,63H
        DB 64H,65H,66H,67H,68H,69H,70H,71H
        DB 72H,73H,74H,75H,76H,77H,78H,79H
        DB 80H,81H,82H,83H,84H,85H,86H,87H
        DB 88H,89H,90H,91H,92H,93H,94H,95H
        DB 96H,97H,98H,99H
INIT_1820:
        SETB DQ
        NOP
        CLR DQ
        MOV R0,#0EEh
TSR1:   DJNZ R0,TSR1    ;��ʱ
        SETB DQ
        MOV R0,#25h     ;96us
TSR2:   DJNZ R0,TSR2
        JNB DQ,TSR3
        LJMP TSR4       ;��ʱ
TSR3:   SETB FLAG1      ;�ñ�־λ,��ʾDS1820����
        LJMP TSR5
TSR4:   CLR FLAG1       ;���־λ,��ʾDS1820������
        LJMP TSR7
TSR5:   MOV R0,#6Bh     ;200us
TSR6:   DJNZ R0,TSR6    ;��ʱ
TSR7:   SETB DQ
        RET
;��ʾ�ӳ���
DISP:mov r1,#35h        ;�Ӹ�λ��ʼ
        mov 38h,#85h
dilex:  mov dptr,#led1     ;����λ����
        mov a,38h
        movx @dptr,a
        mov dptr,#ZOE0     ;�����δ���
        mov a,@r1
        movc a,@a+dptr
        mov dptr,#led0     ;�͵�ǰ����
        movx @dptr,a
        dec 38h
        dec r1
        cjne r1,#2fh,dilex ;ĩ����λת
        ret

ZOE0:   DB 0ch,9fh,4ah,0bh,99h,29h,28h,8fh,08h,09h,88h
;          0   1   2   3   4   5   6   7   8   9   a
        DB 38h,6ch,1ah,68h,0e8h,0ffh,0c0h
;          b   c   d   e   f    

        END

;++++++++++++++++++++++++++++++++++++++++++++++++++++++
;             @xianwu   2020/6/29                     
;             coding:   GBK                                        
;��Ҫ��Ϊ������:1���8279���м���ɨ�裬�������ʾ           
;             2����DS18B20��ȡ�¶ȣ��ı��¶�ֵ           
;             3�����¶�����DAC0832����DAת�����Ƶ��     
;
;�������ʾ�����ҵ�1��2λ��ʾ������ֵ��3��4λ��ʾ������ֵ
;                 5��6λ��ʾ��ǰ�¶�ֵ
;����F1�ı������ֵ��F2�ı������ֵ         
;
;++++++++++++++++++++++++++++++++++++++++++++++++++++

;======================Ԥ����==============================
TEMPER_L   EQU 	41H     ;��Ŷ����¶ȵ�λ����
TEMPER_H   EQU 	40H     ;��Ŷ����¶ȸ�λ����
TH	   EQU	42H     ;����¶����Ԥ��ֵ
TL	   EQU  43H     ;����¶����Ԥ��ֵ
TEMPER_NUM EQU 	60H     ;���ת������¶�ֵ
FLAG1      BIT  10H     ;ds18B20���ڱ�־λ
DQ         BIT  P3.3    ;һ�����߿��ƶ˿�;����ת������¶�ֵ
LED0       EQU  0FFF0H  ;8279����ͨ��
LED1       EQU  0FFF1H  ;8279����ͨ��
LEDBUFF    EQU  30H     ;����ͷ��ַ30-35
DAC0832    EQU  0300H   ;��ڵ�ַ
;==========================================================

;===============��ʼ��======================================
ORG 0000H
	MOV SP,#10H
	MOV DPTR,#LED1     ;ָ�������
        MOV A,#00H         ;6��8λ��ʾ
        MOVX @DPTR,A       ;��ʽ��д��
        MOV A,#32H         ;���Ƶ��ֵ
        MOVX @DPTR,A       ;��Ƶ��д��
        MOV A,#0DFH        ;����������
        MOVX @DPTR,A       ;�ر���ʾ��
	MOV TEMPER_NUM,#27H
	MOV LEDBUFF , #10H
	MOV LEDBUFF+1,#10H
	MOV LEDBUFF+2,#10H
	MOV LEDBUFF+3,#10H
	MOV LEDBUFF+4,#10H
	MOV LEDBUFF+5,#10H
	MOV TH,	      #30H ;����¸���ֵ
	LCALL GET_TEMPER   ;��ȡ�¶Ȳ���ʼ��ds1820
	MOV TL,	      #27H ;����³�ֵ
	LCALL RE_CONFIG    ;д����ֵ
	LJMP MLOOP
;===============��ʼ��======================================
	
;=================������====================================	
	ORG 0100H
MLOOP:   
	 LCALL GET_TEMPER ;��ȡ�¶�
         LCALL TEMPER_COV ;�¶�ת��
         LCALL XMON       ;�������+��д�¶���ֵ����
	 LCALL NEW_CACHE  ;ˢ������
	 LCALL TEMP_CACHE ;�������
	 LCALL DISP
	 SJMP MLOOP
;===================END====================================



;==================8279������ʾ=============================
;----------------------------------------------------------
;ɨ����̣���⹦�ܼ��Ƿ���
XMON:   CALL DIKEY         ;����ʾ��ɨ
        CJNE A,#20H,JUGE   ;���ް�������
	RET                ;�ް����򷵻�
JUGE:   CJNE A,#10H,KRDS   ;�а������жϹ��ܼ��������ּ�
KRDS:   jnc KRDY           ;ת���ܼ�����
	RET                ;���ּ���Ч����
;���ܼ�����д����»��Ǹ���
KRDY:   ANL A, #01H   ;11H,10H��Ӧ����f1,f0��ֻ��Ҫ�жϺ�1λ
	JNZ WRIT_TL   ;1Ϊ�ڶ�����������������
;д�������ֵ
WRIT_TH:
	MOV R5, TH         ;����ԭֵ
	MOV TH, 00H        ;���
	LCALL NEW_CACHE;ˢ������
	LCALL DISP
	LCALL LKEY         ;��鰴��
	ANL A, #0FH
	MOV R6, A
	
	MOV LEDBuff+5,A   ;��һ��λ����(ʮλ��
	LCALL DISP
	
	LCALL LKEY        ;��鰴��
	ANL A, #0FH
	MOV R7, A	
	MOV LEDBUFF+4,A   ;�ڶ���λ����(��λ��
	LCALL DISP

	MOV A, R6          ;�ϲ�Ϊһ���¶ȷ����ݴ���
	SWAP A             ;����ʹ�õ���BCD���ʾ�¶�
	ORL A, R7
	CJNE A, TL, OKH     ;�������ֵ����Сֵ�Ƚ�
OKH:    JC  ERRORH          ;С����Сֵ�����벻����
	MOV TL, A           ;�������
	LCALL RE_CONFIG    ;��д�������¶�
	RET
ERRORH: MOV TH, R5         ;װ��ԭֵ
        RET
;д�������ֵ
WRIT_TL:
	MOV R5, TL         ;����ԭֵ
	MOV TL, 00H        ;���
	LCALL NEW_CACHE    ;ˢ������
	LCALL DISP
	LCALL LKEY         ;��鰴��
	ANL A, #0FH        ;�����λ
	MOV R6, A
	MOV LEDBUFF+3,A   ;��һ��λ����(ʮλ��
	LCALL DISP
	
	LCALL LKEY        ;��鰴��
	MOV LEDBUFF+2,A   ;�ڶ���λ����(��λ��
	ANL A, #0FH
	MOV R7, A
	LCALL DISP
	
	MOV A, R6          ;�ϲ�Ϊһ���¶ȷ����ݴ���
	SWAP A             ;����ʹ�õ���BCD���ʾ�¶�
	ORL A, R7
	CJNE A, TH, OKL     ;������Сֵ�����ֵ�Ƚ�
OKL:    JNC  ERRORL         ;�������ֵ���벻����
	MOV TL, A          ;�������
	LCALL RE_CONFIG    ;��д�������¶�
	RET
ERRORL: MOV TL, R5         ;װ��ԭֵ
        RET
	
;����ɨ�裬ѭ�����һ�����ּ�--------------------------------------------
LKEY:
        LCALL DIKEY         ;����ʾ��ɨ
        CJNE A,#10H,JUGE0  ;�ް����͹��ܼ����������� 
JUGE0:	JNC LKEY           ;�����ּ�,�򲻶ϼ�� 
        RET

;����ɨ���ӳ���-------------------------------------------------------
DIKEY:  MOV R4,#00H        ;��˼�����
DIKRD:  MOV DPTR,#LED1     ;ָ8279״̬�˿�
        MOVX A,@DPTR       ;�����̱�־
        ANL A,#07H         ;������3λ�������8279FIFO����������
;�Ƿ������ݣ��а������¾�������
        JNZ KEYS           ;�м�����ת
        dJNZ R4,dikRd      ;δ�������
        MOV A,#20H         ;�����޼���
        RET                ;����
KEYS:   MOV A, #40H
        MOVX @DPTR, A      ;��8279FIFORAM����
MOV DPTR,#LED0             ;ָ��8279���ݶ˿�
        MOVX A,@DPTR       ;����ǰ����
        MOV R2,A           ;�浱ǰ����
        ANL A,#03H         ;�����Ͷ�λ������ֵ����4�У���ֵ��00-11
        xcH A,R2           ;ȡ��ǰ����
        ANL A,#38H         ;������Чλ��ȡ��ֵ����5�У���ֵ��000-100
        RR A               ;�����ѹ��������ֵ����ֵ����ֵ��ɣ���Χ��00000-10011
        oRl A,R2           ;��Ͷ�ƴ��
        MOV DPTR,#GOJZ     ;ָ�������
        MOVc A,@A+DPTR     ;�����ֵ
        RET                ;����
;-----------------------------------------------------------
;��ʾ�ӳ���
DISP:   MOV R1,#35H        ;�Ӹ�λ��ʼ
        MOV 38H,#85H
DILEX:  MOV DPTR,#LED1     ;����λ����
        MOV A,38H
        MOVX @DPTR,A
        MOV DPTR,#ZOE0     ;�����δ���
        MOV A,@R1
        MOVc A,@A+DPTR
        MOV DPTR,#LED0     ;�͵�ǰ����
        MOVX @DPTR,A
        DEC 38H
        DEC R1
        CJNE R1,#2fH,DILEX ;ĩ����λת
        RET

;-----------------------------------------------------------	
;------���δ���
ZOE0:   DB 0cH,9fH,4AH,0BH,99H,29H,28H,8fH,08H,09H,88H
;          0   1   2   3   4   5   6   7   8   9   A
        DB 38H,6cH,1AH,68H,0e8H,0ffH,0c0H
;          B   c   d   e   f    �ر�  p.
;------��������(20HΪ�����)
GOJZ:   DB 20H,20H,11H,10H,20H,20H,20H,20H,20H,03H  ;��Ӧ����f3,f2,f1,f0,d,c,B,A,e,3�ļ���
        DB 06H,09H,20H,02H,05H,08H,00H,01H,04H,07H   ;��Ӧ����6,9,f,2,5,8,0,1,4,7�ļ���
        DB 20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H;�ް������µļ���
;------������Ӧ��ֵ
;       0e0H,0e1H,0d9H,0d1H,0e2H,0dAH,0d2H,0e3H,0DBH,0d3H
;       0    1    2    3    4    5    6    7    8    9
;       0cBH,0cAH,0c9H,0c8H,0d0H,0d8H,0c3H,0c2H,0c1H,0c0H
;       A    B    c    d    e    f    10   11   12   13
;--------------------------------------------------------
;==========================END==============================


;===============ds18b20�¶�===================================
;�ṹ�ο�https://blog.csdn.net/yannanxiu/article/details/43916515

;��ȡ�¶�---------------------------------------------------
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
;-----------------------------------------------------------
;��дʱ��ο�https://blog.csdn.net/yannanxiu/article/details/43916515����ĩβ
;----------------------------------------------------------
;��DS18B20�ĳ���,��DS18B20�ж���һ���ֽڵ�����-----------------
READ_1820:
        MOV R2,#8
RE1:    CLR C
        SETB DQ
        NOP
        NOP
        CLR DQ
        NOP
        NOP
        NOP
        SETB DQ
        MOV R3,#8
        DJNZ R3,$
        MOV C,DQ
        MOV R3,#21
        DJNZ R3,$
        RRC A
        DJNZ R2,RE1
        RET
	
;дDS18B20�ĳ���-----------------------------------------------
WRITE_1820:
        MOV R2,#8
        CLR C
WR1:    CLR DQ
        MOV R3,#5
        DJNZ R3,$
        RRC A
        MOV DQ,C
        MOV R3,#21
        DJNZ R3,$
        SETB DQ
        NOP
        DJNZ R2,WR1
        SETB DQ
        RET
	
;��DS18B20�ĳ���,��DS18B20�ж��������ֽڵ��¶�����-------------------
READ_18200:
        MOV R4,#2            ;���¶ȸ�λ�͵�λ��DS18B20�ж���
        MOV R1,#TEMPER_L     ;��λ����TEMPER_L,��λ��TEMPER_H
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
        MOV R3,#8
        DJNZ R3,$
        MOV C,DQ
        MOV R3,#21
        DJNZ R3,$
        RRC A
        DJNZ R2,RE01
        MOV @R1,A
        DEC R1
        DJNZ R4,RE00
        RET
	
;����DS18B20�ж������¶����ݽ���ת��--------------------------------
;��DS18B20����ʱ�ֱ��ʱ�����Ϊ12λ���ȣ�����7λ������ֵ ���ֽڵ�4λ�Ǿ���ֵ
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
	
;��16���Ƶ��¶�����ת����ѹ��BCD��------------------------------------
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
	
;DS18B20��ʼ������----------------------------------------------
INIT_1820: 
		SETB DQ ;��λ��ʼ���ӳ���
		NOP
		CLR DQ
		MOV R1,#3;��ʱ537US
TSR1: 	MOV R0,#107
		DJNZ R0,$
		DJNZ R1,TSR1
		SETB DQ;Ȼ������������
		NOP
		NOP
		NOP
		MOV R0,#25H
TSR2: 	JNB DQ,TSR3;�ȴ�DS18B20��Ӧ
		DJNZ R0,TSR2
		LJMP TSR4;��ʱ
TSR3: 	SETB FLAG1
		LJMP TSR5
TSR4: 	CLR FLAG1
		LJMP TSR7
TSR5: 	MOV R0,#70
TSR6: 	DJNZ R0,TSR6
TSR7: 	SETB DQ
		RET
;-----------------------------------------------------------
;����дDS18B20�ݴ�洢���趨ֵ
RE_CONFIG:
        JB FLAG1,RE_CONFIG1 ;��DS18B20����,תRE_CONFIG1
        RET

RE_CONFIG1:
        MOV A,#0CCH     ;��SKIP ROM����
        LCALL WRITE_1820
        MOV A,#4EH      ;��д�ݴ�洢������
        LCALL WRITE_1820

        MOV A,TH      ;TH(��������)��д��00H ;�ǰ���Bcd��д����
        LCALL WRITE_1820
        MOV A,TL      ;TL(��������)��д��00H
        LCALL WRITE_1820
        MOV A,#7FH      ;ѡ��12λ�¶ȷֱ���
        LCALL WRITE_1820
        RET	 
;===================END=====================================


;============DAC0832 DAת�����Ƶ��===========================
TEMP_CACHE:
      MOV A, TH
      CJNE A, TEMPER_NUM,NEX1  
NEX1: JC MAX			;�������ֵ��ת
      ;С�����ֵ����Сֵ�Ƚ�
      MOV A, TL
      CJNE A, TEMPER_NUM,NEX2   
NEX2: JC MID                     ;С�����ֵ������Сֵ��ͣת
      ;С�������Сֵ��ת
 
;С����Сֵ��ת�����������
MIN:
      MOV DPTR,#DAC0832;dAc8032�����ַ
      MOV A,#00H;-5v
      MOVX @DPTR,A
      CLR P3.2;����
      LJMP EXT
;�м�ֵͣ����
MID:
      MOV DPTR,#DAC0832
      MOV A,#07FH;0v
      MOVX @DPTR,A
      SETB P3.2
      LJMP EXT
;���ֵ��ת
MAX:
      MOV DPTR,#DAC0832
      MOV A,#0FFH;+5v
      MOVX @DPTR,A
      SETB P3.2
EXT:  RET

;===================END===================================



;=============���µ�Ƭ����������============================
;ˢ����ʾ�������ݣ����ֵ�����ֵ����ǰֵ
NEW_CACHE:	 
	 MOV A,TEMPER_NUM
	 MOV B,A
	 SWAP A
	 ANL A,#0fH
	 ANL B,#0fH
	 MOV LEDBUFF,B
	 MOV LEDBUFF+1,A
	 MOV A,TL
	 MOV B,A
	 SWAP A
	 ANL A,#0fH
	 ANL B,#0fH
	 MOV LEDBUFF+2,B
	 MOV LEDBUFF+3,A
	 MOV A,TH
	 MOV B,A
	 SWAP A
	 ANL A,#0fH
	 ANL B,#0fH
	 MOV LEDBUFF+4,B
	 MOV LEDBUFF+5,A
	 RET
;=============END=======================================
END


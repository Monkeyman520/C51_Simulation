CS0809  EQU 0300H
        org 0

start:  MOV DPTR,#CS0809
	;����ͨѶ�ж�
ADC:    MOVX @DPTR,A    ;0809��ͨ��0����
        nop
        nop
        nop
        nop
        nop
        MOVX A,@DPTR    ;ȡ������ֵ
        cpl a
        mov p1,a
        MOV  R7,#00H    ;��ʱ    
        DJNZ R7,$
        SJMP ADC        ;ѭ��

        END

;100% 11111111
;80%  11001100
;60%  10011001
;40%  01100110
;20%  00110011
;0%   00000000
68
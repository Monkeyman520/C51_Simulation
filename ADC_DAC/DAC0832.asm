;ֱ���������ʵ��

;ʵ������
;1) DA0832��Ԫ��CS���Ӷ˿ڵ�ַ300CS
;2) DA0832��Ԫ��AOUT����ֱ�����INV

CS0832  EQU 0300H
DA0V    EQU 00H
DA2V5   EQU 7FH
DA5V    EQU 0FFH

        org 0
        mov dptr,#CS0832

;mloop:;����
 ;       mov a,#DA0V
 ;       movx @dptr,a
 ;       mov r7,#3
  ;      call delay
  ;      
  ;      mov a,#DA5V
  ;      movx @dptr,a
  ;      mov r7,#3
 ;     call delay
 ;       sjmp mloop

mloop:  mov a,#DA0v
loop: ;���  
	movx @dptr, a
	inc a
	sjmp loop
	
delay:  mov r6,#00h
dl1:    mov r5,#00h
        djnz r5,$
        djnz r6,dl1
        djnz r7,delay
        ret

        END


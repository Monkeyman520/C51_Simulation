        ORG 0000H
        AJMP START
	
	ORG 0023H       ;�����ж��ӳ���
RTXD:	
	 PUSH PSW	;�����ֳ�
	PUSH ACC
	 AJMP SBR1
	  	  
	 ORG 0100H
SBR1:	 
      ;�ж��ǽ��ܻ��Ƿ����ж�
       JNB RI, SEND ;����
SIN:	;��������
        CLR RI
        MOV A,SBUF
        ORL A,#0F0H
        SWAP A
        MOV P1,A
        SJMP NEXT
SEND:	;��������
        CLR TI
        MOV A,P1	;������һ������
        ANL A,#0FH
        MOV SBUF,A
NEXT:	;�жϽ���
	POP ACC		;�ָ��ֳ�
	POP PSW
	RETI
	 
	ORG 0200H
START:  MOV SP,#60H     ;����ջָ�븳��ֵ
        MOV TMOD,#20H   ;����T1Ϊ��ʽ2
        MOV SCON,#50H   ;���ô��ڹ�����ʽ1
        MOV TH1,#0FDH   ;���ò�����Ϊ9600
        MOV TL1,#0FDH
        MOV PCON,#00H
        SETB TR1        ;��ʱ��1��ʼ����
	
	MOV A,P1	;���͵�һ������
	ANL A,#0FH
        MOV SBUF,A
	
	SETB ES         ;�޸ģ����ж�
	SETB EA
	SJMP $
        END

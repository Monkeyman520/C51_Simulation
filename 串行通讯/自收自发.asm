        ORG 0000H
        AJMP START
        ORG 0100H
START:  MOV SP,#60H     ;����ջָ�븳��ֵ
        MOV TMOD,#20H   ;����T1Ϊ��ʽ2
        MOV SCON,#50H   ;���ô��ڹ�����ʽ1
        MOV TH1,#0FDH   ;���ò�����Ϊ9600
        MOV TL1,#0FDH
        MOV PCON,#00H
        SETB TR1        ;��ʱ��1��ʼ����
MLOOP:  MOV A,P1
        ANL A,#0FH
        MOV SBUF,A
        JNB TI,$
        CLR TI
        JNB RI,$
        CLR RI
        MOV A,SBUF
        ORL A,#0F0H
        SWAP A
        MOV P1,A
        SJMP MLOOP
	END

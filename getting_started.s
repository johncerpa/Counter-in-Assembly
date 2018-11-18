.equ ADDR_7SEG, 0x10000020 /* 7-SEG DISPLAYS */
.equ SWITCHES, 0x10000040
.equ FEQ1, 3095975 /*0.5 Hz*/
.equ FEQ2, 733993 /*2 Hz*/

.global _start

_start:

	movia sp, 0x007FFFFC /* Setup the stack pointer */  
 	
	movia r5, ADDR_7SEG /* Initializing 7-segment display */
	movia r10, SWITCHES /* Initializing switches */
    
	movi r8, 0b00000
    
    /* 0.5 Hz */
    /* INCREMENT BY 1, 2 or 3 */
	movi r11, 0b00000
	movi r12, 0b00001
	movi r13, 0b00010
	movi r14, 0b00100
    
    /* DECREMENT */
    movi r15, 0b01001
 	movi r16, 0b01010 
	movi r17, 0b01100
    
    movi r18, 0	/* Initialize COUNTER to 0 */
    
    /* 2 Hz */
    /* INCREMENT BY 1, 2 or 3 */
	movi r19, 0b10001
	movi r20, 0b10010
	movi r21, 0b10100
    
    /* DECREMENT */
    movi r22, 0b11001
 	movi r23, 0b11010 
	movi r24, 0b11100
     
SWITCH_CHECK:
	
	ldbio r8, 0(r10) /* Loads content of switches */
    
    andi r8, r8, 0b11111
    
    beq r8, r11, LOOP
    
    beq r8, r12, INC1
    beq r8, r13, INC2
    beq r8, r14, INC3
    beq r8, r15, DEC1
    beq r8, r16, DEC2
    beq r8, r17, DEC3
    
    beq r8, r19, INC1_2
    beq r8, r20, INC2_2
    beq r8, r21, INC3_2
    beq r8, r22, DEC1_2
    beq r8, r23, DEC2_2
    beq r8, r24, DEC3_2
    
/* INCREMENT OR DECREMENT FEQ: 0.5 Hz */
INC1:
	add r4, r18, r0
  	call DISPLAY
	addi r18, r18, 1
    movia r9, FEQ1 /* FREQUENCY */
    br DELAY

INC2:
	add r4, r18, r0
    call DISPLAY
    addi r18, r18, 2
    movia r9, FEQ1
    br DELAY

INC3:
	add r4, r18, r0
    call DISPLAY
    addi r18, r18, 3
    movia r9, FEQ1
    br DELAY

DEC1:
	add r4, r18, r0
    call DISPLAY
    subi r18, r18, 1
    movia r9, FEQ1
    br DELAY

DEC2:
	add r4, r18, r0
    call DISPLAY
    subi r18, r18, 2
    movia r9, FEQ1
    br DELAY
    
DEC3:
	add r4, r18, r0
    call DISPLAY
    subi r18, r18, 3
    movia r9, FEQ1
    br DELAY

/* INCREMENT OR DECREMENT FEQ: 2 Hz */
INC1_2:
	add r4, r18, r0
  	call DISPLAY
	addi r18, r18, 1
    movia r9, FEQ2 /* FREQUENCY */
    br DELAY

INC2_2:
	add r4, r18, r0
    call DISPLAY
    addi r18, r18, 2
    movia r9, FEQ2
    br DELAY

INC3_2:
	add r4, r18, r0
    call DISPLAY
    addi r18, r18, 3
    movia r9, FEQ2
    br DELAY

DEC1_2:
	add r4, r18, r0
    call DISPLAY
    subi r18, r18, 1
    movia r9, FEQ2
    br DELAY

DEC2_2:
	add r4, r18, r0
    call DISPLAY
    subi r18, r18, 2
    movia r9, FEQ2
    br DELAY
    
DEC3_2:
	add r4, r18, r0
    call DISPLAY
    subi r18, r18, 3
    movia r9, FEQ2
    br DELAY
    
LOOP:   
    br SWITCH_CHECK
    
DELAY:
	subi r9, r9, 1
	bne r9, r0, DELAY
	br LOOP

/* 
	DISPLAY subroutine
	want to take a number of the form 0x1234 and display it on the HEX displays
	Assuming the input number to the function is in R4
	Assuming the address of the HEX display to be in R5 (it is either 0x10000020 or 0x10000030)
	R7: the number to be written to the 7-Seg, R2: counter of the loop. counts from 0 to 3
*/
DISPLAY:

	addi sp, sp, -24		/* store r2-r7 and restore them in the end */
	stw r2, 0(sp)		  /* storing r2 on the stack */
	stw r3, 4(sp)		  /* storing r3 on the stack */
	stw r4, 8(sp)		  /* storing r4 on the stack */
	stw r5, 12(sp)		/* storing r5 on the stack */
	stw r6, 16(sp)		/* storing r6 on the stack */
	stw r7, 20(sp)		/* storing r7 on the stack */

	add r2, r0, r0		/* r2 = counter of the loop = 0 */
	add r7, r0, r0		/* r11 will be the number to be written to the 7-Seg */
	
LOOP2:
	addi r6, r0, 2
	bge r2, r6, DONE
	
	beq r2, r0, NO_SHIFT
	srli r4, r4, 4
	
NO_SHIFT:
	andi r3, r4, 0x000f	/* masked 0x1234 ---> 0x0004 */
	
	beq r3, r0, ZERO /* if r3 is 0, branch to ZERO */
	
	cmpeqi r6, r3, 0x01	/* compare r3 with 0x1 */
	bne r6, r0, ONE		/* if r3 is 1, branch to ONE */
	
	cmpeqi r6, r3, 0x02	/* compare r3 with 0x2 */
	bne r6, r0, TWO		/* if r3 is 1, branch to TWO */
	
	cmpeqi r6, r3, 0x03	/* compare r3 with 0x3 */
	bne r6, r0, THREE	/* if r3 is 1, branch to THREE */
	
	cmpeqi r6, r3, 0x04	/* compare r3 with 0x4 */
	bne r6, r0, FOUR	/* if r3 is 1, branch to FOUR */
	
	cmpeqi r6,r3,0x05	/* compare r3 with 0x5 */
	bne r6,r0,FIVE		/* if r3 is 1, branch to FIVE */
	
	cmpeqi r6,r3,0x06	/* compare r3 with 0x6 */
	bne r6,r0,SIX		/* if r3 is 1, branch to SIX */
	
	cmpeqi r6,r3,0x07	/* compare r3 with 0x7 */
	bne r6,r0,SEVEN		/* if r3 is 1, branch to SEVEN */
	
	cmpeqi r6,r3,0x08	/* compare r3 with 0x8 */
	bne r6,r0,EIGHT		/* if r3 is 1, branch to EIGHT */
	
	cmpeqi r6, r3, 0x09	/* compare r3 with 0x9 */
	bne r6,r0,NINE		/* if r3 is 1, branch to NINE */
	
	cmpeqi r6, r3, 0x0a	/* compare r3 with 0xa */
	bne r6, r0, A		/* if r3 is 1, branch to A */
	
	cmpeqi r6, r3, 0x0b	/* compare r3 with 0xb */
	bne r6, r0, B		/* if r3 is 1, branch to B */
	
	cmpeqi r6, r3, 0x0c	/* compare r3 with 0xc */
	bne r6,r0,C			/* if r3 is 1, branch to C */
	
	cmpeqi r6, r3, 0x0d	/* compare r3 with 0xd */
	bne r6, r0, D		/* if r3 is 1, branch to D */
	
	cmpeqi r6, r3, 0x0e	/* compare r3 with 0xe */
	bne r6, r0, E		/* if r3 is 1, branch to E */
	
	cmpeqi r6, r3, 0x0f	/* compare r3 with 0xf */
	bne r6, r0 ,F		/* if r3 is 1, branch to F */
	
	
	subi r2, r0, 1		/* return -1 on error */
	stwio r2, 0(r5)		/* show FFFF on HEX display for Errors */
	ret
DONE:
	stwio r7, 0(r5)

	ldw r2, 0(sp)		/* loading r2 from the stack */
	ldw r3, 4(sp)		/* loading r3 from the stack */
	ldw r4, 8(sp)		/* loading r4 from the stack */
	ldw r5, 12(sp)		/* loading r5 from the stack */
	ldw r6, 16(sp)		/* loading r6 from the stack */
	ldw r7, 20(sp)		/* loading r7 from the stack */
	addi sp, sp, 24		/* take the stack pointer to its initial point */
	ret
ZERO:
	addi r2,r2,1
	movia r6, 0x3f000000
	srli r7,r7,8
	or r7,r7,r6
	br LOOP2
ONE:
	addi r2,r2,1
	movia r6, 0x06000000
	srli r7,r7,8
	or r7,r7,r6
	br LOOP2
TWO:
	addi r2,r2,1
	movia r6, 0x5b000000
	srli r7,r7,8
	or r7,r7,r6
	br LOOP2
THREE:
	addi r2,r2,1
	movia r6, 0x4f000000
	srli r7,r7,8
	or r7,r7,r6
	br LOOP2
FOUR:
	addi r2,r2,1
	movia r6, 0x66000000
	srli r7,r7,8
	or r7,r7,r6
	br LOOP2
FIVE:
	addi r2,r2,1
	movia r6, 0x6d000000
	srli r7,r7,8
	or r7,r7,r6
	br LOOP2
SIX:
	addi r2,r2,1
	movia r6, 0x7d000000
	srli r7,r7,8
	or r7,r7,r6
	br LOOP2
SEVEN:
	addi r2,r2,1
	movia r6, 0x07000000
	srli r7,r7,8
	or r7,r7,r6
	br LOOP2
EIGHT:
	addi r2,r2,1
	movia r6, 0xff000000
	srli r7,r7,8
	or r7,r7,r6
	br LOOP2
NINE:
	addi r2,r2,1
	movia r6, 0x6f000000
	srli r7,r7,8
	or r7,r7,r6
	br LOOP2
A:	
	addi r2,r2,1
	movia r6, 0x77000000
	srli r7,r7,8
	or r7,r7,r6
	br LOOP2
B:	
	addi r2,r2,1
	movia r6, 0xfc000000
	srli r7,r7,8
	or r7,r7,r6
	br LOOP2
C:	
	addi r2,r2,1
	movia r6, 0x39000000
	srli r7,r7,8
	or r7,r7,r6
	br LOOP2
D:	
	addi r2,r2,1
	movia r6, 0x5e000000
	srli r7,r7,8
	or r7,r7,r6
	br LOOP2
E:	
	addi r2,r2,1
	movia r6, 0xf9000000
	srli r7,r7,8
	or r7,r7,r6
	br LOOP2
F:	
	addi r2,r2,1
	movia r6, 0xf1000000
	srli r7,r7,8
	or r7,r7,r6
	br LOOP2
	
/**** END ****/

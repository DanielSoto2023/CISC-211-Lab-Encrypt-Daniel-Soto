/*** asmEncrypt.s   ***/

#include <xc.h>

/* Declare the following to be in data memory */
.data  

/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Daniel Soto"  
.align
 
/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

/* Define the globals so that the C code can access them */
/* (in this lab we return the pointer, so strictly speaking, */
/* does not really need to be defined as global) */
/* .global cipherText */
.type cipherText,%gnu_unique_object

.align
 
@ NOTE: THIS .equ MUST MATCH THE #DEFINE IN main.c !!!!!
@ TODO: create a .h file that handles both C and assembly syntax for this definition
.equ CIPHER_TEXT_LEN, 200
 
/* space allocated for cipherText: 200 bytes, prefilled with 0x2A */
cipherText: .space CIPHER_TEXT_LEN,0x2A  

.align
 
.global cipherTextPtr
.type cipherTextPtr,%gnu_unique_object
cipherTextPtr: .word cipherText

/* Tell the assembler that what follows is in instruction memory     */
.text
.align

/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

    
/********************************************************************
function name: asmEncrypt
function description:
     pointerToCipherText = asmEncrypt ( ptrToInputText , key )
     
where:
     input:
     ptrToInputText: location of first character in null-terminated
                     input string. Per calling convention, passed in via r0.
     key:            shift value (K). Range 0-25. Passed in via r1.
     
     output:
     pointerToCipherText: mem location (address) of first character of
                          encrypted text. Returned in r0
     
     function description: asmEncrypt reads each character of an input
                           string, uses a shifted alphabet to encrypt it,
                           and stores the new character value in memory
                           location beginning at "cipherText". After copying
                           a character to cipherText, a pointer is incremented 
                           so that the next letter is stored in the bext byte.
                           Only encrypt characters in the range [a-zA-Z].
                           Any other characters should just be copied as-is
                           without modifications
                           Stop processing the input string when a NULL (0)
                           byte is reached. Make sure to add the NULL at the
                           end of the cipherText string.
     
     notes:
        The return value will always be the mem location defined by
        the label "cipherText".
     
     
********************************************************************/    
.global asmEncrypt
.type asmEncrypt,%function
asmEncrypt:   

    /* save the caller's registers, as required by the ARM calling convention */
    push {r4-r11,LR}
    
    /* YOUR asmEncrypt CODE BELOW THIS LINE! VVVVVVVVVVVVVVVVVVVVV  */
    /*r0 pointer, r1 shift num*/
    MOV r11,r0
    LDR r6, =cipherText
    loop:
    LDR R12, =0
    LDRB r3,[r0],1 /*Grab the first character and then increment*/
    CMP R12,r3
    BEQ done
    
    LDR R12, =65
    CMP r3,r12
    BLO storeChar /*If its lower than A then we dont touch it*/
    
    LDR R12,=122
    CMP R3,r12
    BHI storeChar /*If its higher than a then we dont touch it*/
    
    LDR r12, =90 /*check for lowercase*/
    CMP R3,r12
    BLS upperCase

    LDR r12, =97 /*Check if its lowercase*/
    CMP R3,r12
    BHS lowerCase
    B storeChar /*If it is the special characters between uppercase and lowercase dont touch*/
    
    upperCase: /*Adds shift then if it overflows past Z it loops back*/
    ADD r3,r3,r1
    LDR r12, =90
    CMP r3,r12
    BHI overFlow /*Branches if it goes past Z*/
    B storeChar
    
    lowerCase:
    ADD r3,r3,r1
    LDR r12, =122
    CMP r3,r12
    BHI overFlow /*Branches if it goes past z*/
    B storeChar
    
    overFlow:
    SUB r3,r3,26
    B storeChar
    
    storeChar: /*stores the char*/
    STRB r3, [r6],1
    B loop
    
    
    
    done:
    LDR r12, =0
    STRB r12,[r6]
    LDR r0, =cipherText
    /* YOUR asmEncrypt CODE ABOVE THIS LINE! ^^^^^^^^^^^^^^^^^^^^^  */

    /* restore the caller's registers, as required by the ARM calling convention */
    pop {r4-r11,LR}

    mov pc, lr	 /* asmEncrypt return to caller */
   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           





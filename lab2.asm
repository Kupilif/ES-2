#include "p16f84.inc" 

org 0x2100
string de "BSUIR"
org 0x0

BEGIN:
    GOTO TASK1

; ---------- TASK 1 ----------

c_string_start_in_eeprom set 0x0
c_string_start_in_memory set 0x10
c_string_length set 0x5
v_bytes_to_read equ 0x0c

; ***** EEPROM Read Routine *****
FN_READ_FROM_EEPROM:
    BCF STATUS, RP0

    MOVLW c_string_length ;
    MOVWF v_bytes_to_read ; Initialize loop counter

    MOVLW c_string_start_in_eeprom ;
    MOVWF EEADR                    ; Initialize ee_str address

    MOvLW c_string_start_in_memory ;
    MOVWF FSR                      ; Initialize mem_str address

T1_FN_READ_LOOP:
    BSF STATUS, RP0  ; Select Bank 1
    BSF EECON1, RD   ; Initialize EE Read
    BCF STATUS, RP0  ; Select Bank 0

    MOVF EEDATA, W   ; W = EEDATA
    MOVWF INDF       ; INDF = W

    DECFSZ v_bytes_to_read, F
    GOTO T1_FN_READ_LOOP_END
    GOTO T1_FN_END

T1_FN_READ_LOOP_END:
    INCF FSR, F          ;
    INCF EEADR, F        ; move strings addresses
    GOTO T1_FN_READ_LOOP
   
T1_FN_END:
    RETURN
; ***** ********** *****

TASK1:
    CALL FN_READ_FROM_EEPROM

    GOTO PREND

; ---------- ---------- ----------

PREND:
    end
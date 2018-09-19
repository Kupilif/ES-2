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
v_bytes_count_to_read equ 0x0c

; ***** EEPROM Read Routine *****
FN_READ_FROM_EEPROM:
    BCF STATUS, RP0 ; Select Bank 0

    MOVLW c_string_length       ;
    MOVWF v_bytes_count_to_read ; Initialize loop counter

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

    DECFSZ v_bytes_count_to_read, F ; v_bytes_to_read - 1 == 0 ?
    GOTO T1_FN_READ_LOOP_END        ; no
    GOTO FN_READ_FROM_EEPROM_END    ; yes

T1_FN_READ_LOOP_END:
    INCF FSR, F          ;
    INCF EEADR, F        ; move strings addresses
    GOTO T1_FN_READ_LOOP
   
FN_READ_FROM_EEPROM_END:
    RETURN
; ***** ********** *****

TASK1:
    CALL FN_READ_FROM_EEPROM

    GOTO PREND

; ---------- ---------- ----------

; ---------- TASK 2 ----------

c_array_start_in_eeprom set 0x10
c_array_start_in_memory set 0x20
c_array_length set 0x20
v_bytes_count_to_write equ 0x0d

v_current_value equ 0xce

; ***** EEPROM Write Routine *****
FN_WRITE_TO_EEPROM:
    BCF STATUS, RP0 ; Select Bank 0

    MOVLW c_array_length         ;
    MOVWF v_bytes_count_to_write ; Initialize loop counter

    MOVLW c_array_start_in_eeprom ;
    MOVWF EEADR                   ; Initialize ee_array address

    MOVLW c_array_start_in_memory ;
    MOVWF FSR                     ; Initialize mem_array address

T2_FN_WRITE_LOOP:
    MOVF INDF, W
    MOVWF EEDATA

    ; PIC16F8X docs : Page 34
    BSF STATUS, RP0         ; Select Bank 1
    BCF EECON1, EEIF        ; Clear EEPROM Write Operation Interrupt Flag bit
    BCF INTCON, GIE         ; Disable INTs.
    BSF EECON1, WREN        ; Enable Write

    MOVLW 0x55              ;
    MOVWF EECON2            ; Write 55h to EECON2
    MOVLW 0xAA              ;
    MOVWF EECON2            ; Write AAh to EECON2
    BSF EECON1,WR           ; Set WR bit - Begin Write

T2_WAIT_FOR_WRITE_END:          ;
    BTFSC EECON1, WR            ;
    GOTO T2_WAIT_FOR_WRITE_END  ; Wait for write complete

    BCF EECON1, WREN        ; Disable Write
    BSF INTCON, GIE         ; Enable INTs.
    BCF EECON1, EEIF        ; Clear EEPROM Write Operation Interrupt Flag bit
    BCF STATUS, RP0         ; Select Bank 0

    DECFSZ v_bytes_count_to_write, F      ; v_bytes_to_read - 1 == 0 ?
    GOTO T2_FN_WRITE_LOOP_END             ; no
    GOTO FN_WRITE_TO_EEPROM_END           ; yes

T2_FN_WRITE_LOOP_END:
    INCF FSR, F          ;
    INCF EEADR, F        ; move strings addresses
    GOTO T2_FN_WRITE_LOOP

FN_WRITE_TO_EEPROM_END:
    RETURN
; ***** ********** *****

TASK2:
    BCF STATUS, RP0 ; Select Bank 0

    MOVLW c_array_length  ;
    MOVWF v_current_value ; Initialize loop counter

    MOVLW c_array_start_in_memory + c_array_length ;
    MOVWF FSR                                      ; Initialize addres to write

T2_ARRAY_INIT_LOOP:
    DECF FSR

    MOVF v_current_value, W ;
    MOVWF INDF              ; Write v_current_value to current array element

    DECFSZ v_current_value  ; v_current_value - 1 == 0 ?
    GOTO T2_ARRAY_INIT_LOOP ; no
                            ; yes
    CALL FN_WRITE_TO_EEPROM

    GOTO PREND

; ---------- ---------- ----------

PREND:
    end
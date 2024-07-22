.macro ver
    .sbyte '0.02'
.endm  
DSWRIT = $80
DSREAD = $40
DEVIDN = $70
slot=4


.macro gosio
    mva #_dev DDEVIC
    mva #_dunit DUNIT
    mva #_dcmnd DCMND
    mva #_dstats DSTATS
    mwa #big_buffer DBUFA
    mva #_dtimlo DTIMLO
    mwa #_dbyt DBYT
    mva #_daux1 DAUX1
    mva #_daux2 DAUX2
    JSR SIOV
.endm

    icl 'lib/ATARISYS.ASM'
    icl 'lib/MACRO.ASM'
    
    org $2000
start
    
    lda #<DCB_close_directory
    ldy #>DCB_close_directory
    jsr DOSIOV
            
    lda #<DCB_mount_host
    ldy #>DCB_mount_host
    jsr DOSIOV
  
    lda #<DCB_open_directory
    ldy #>DCB_open_directory
    jsr DOSIOV

loop
    lda #<DCB_read_dir    
    ldy #>DCB_read_dir
    jsr DOSIOV
    lda $bc40
    cmp #$7f
    bne loop

    ;halt %00000111
    rts

    
DOSIOV: STA DODCBL+1    ; Set source address
    STY DODCBL+2
    LDY #$0B            ; 12 bytes
DODCBL  LDA $FFFF,Y     ; Changed above.
    STA DCB,Y           ; To DCB table
    DEY                 ; Count down
    BPL DODCBL          ; Until done

SIOVDST:    
    JSR SIOV            ; Call SIOV
    LDY DSTATS          ; Get STATUS in Y
    RTS         
    
    
directory_path
    .by "/games/" 0, 0, 0, 0, 0

DCB_open_directory
    .BYTE   DEVIDN          ; DDEVIC
    .BYTE   $1              ; DUNIT
    .BYTE   $f7             ; DCOMND
    .BYTE   DSWRIT          ; DSTATS
    .WORD   directory_path  ; DBUFA
    .BYTE   $0F             ; DTIMLO
    .BYTE   $00             ; DRESVD reserved
    .WORD   $100            ; DBYT
    .BYTE   slot            ; DAUX1
    .BYTE   1               ; DAUX2


    ; close DIR

DCB_close_directory
    .BYTE   DEVIDN          ; DDEVIC
    .BYTE   $1              ; DUNIT
    .BYTE   $f5             ; DCOMND
    .BYTE   0               ; DSTATS
    .WORD   0               ; DBUFA
    .BYTE   $0f             ; DTIMLO
    .BYTE   0               ; DRESVD reserved
    .WORD   0               ; DBYT
    .BYTE   slot            ; DAUX1
    .BYTE   0               ; DAUX2

DCB_mount_host
    .BYTE   DEVIDN          ; DDEVIC
    .BYTE   $1              ; DUNIT
    .BYTE   $f9             ; DCOMND
    .BYTE   0               ; DSTATS
    .WORD   0               ; DBUFA
    .BYTE   $0f             ; DTIMLO
    .BYTE   0               ; DRESVD reserved
    .WORD   0               ; DBYT
    .BYTE   slot            ; DAUX1
    .BYTE   0               ; DAUX2


DCB_read_dir
    .BYTE   DEVIDN          ; DDEVIC
    .BYTE   $1              ; DUNIT
    .BYTE   $f6             ; DCOMND
    .BYTE   DSREAD          ; DSTATS
    .WORD   $bc40           ; DBUFA
    .BYTE   $0f             ; DTIMLO
    .BYTE   0               ; DRESVD reserved
    .WORD   40              ; DBYT
    .BYTE   41              ; DAUX1
    .BYTE   $80             ; DAUX2



small_buffer
    :100 .by 0  ;.ds $100
big_buffer
    run start

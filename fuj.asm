.macro ver
    .sbyte '0.03'
.endm  
DSWRIT = $80
DSREAD = $40
DEVIDN = $70
slot=4

    icl 'lib/ATARISYS.ASM'
    icl 'lib/MACRO.ASM'
    
    org $2000
start
    
    mwa #DCB_close_dir DCB_ADDR
    jsr DOSIOV
            
    mwa #DCB_mount_host DCB_ADDR
    jsr DOSIOV
  
    mwa #DCB_open_dir DCB_ADDR
    jsr DOSIOV

loop
    mwa DCB_read_dir DCB_ADDR    
    jsr DOSIOV
    lda $bc40
    cmp #$7f
    bne loop

    ;halt %00000111
    rts

    
DOSIOV
    LDY #$0B                ; 12 bytes
@   LDA DCB_ADDR:$FFFF,Y    ; Changed above.
      STA DCB,Y             ; To DCB table
      DEY                   ; Count down
    BPL @-                  ; Until done
SIOVDST:    
    JSR SIOV                ; Call SIOV
    LDY DSTATS              ; Get STATUS in Y
    RTS         
    
    
dir_path
    .by "/games/" 0

DCB_open_dir
    .BYTE   DEVIDN          ; DDEVIC
    .BYTE   $1              ; DUNIT
    .BYTE   $f7             ; DCOMND
    .BYTE   DSWRIT          ; DSTATS
    .WORD   dir_path  ; DBUFA
    .BYTE   $0F             ; DTIMLO
    .BYTE   $00             ; DRESVD reserved
    .WORD   $100            ; DBYT
    .BYTE   slot            ; DAUX1
    .BYTE   1               ; DAUX2

DCB_close_dir
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
    .ds $100
big_buffer
    run start

.macro ver
    .sbyte '0.06'
.endm
.macro dosio DCB_BLOCK
    mwa #:DCB_BLOCK DCB_ADDR
    jsr DOSIOV
.endm  

    .zpvar src_ptr  .word = $80
    .zpvar dest_ptr .word
    .zpvar temp1    .word
    
screen = $bc40
DSWRIT = $80
DSREAD = $40
DEVIDN = $70
slot = 4
dir_entry_len = 10+38  ; because it is easier to multiply by 48=32+16

    icl 'lib/ATARISYS.ASM'
    icl 'lib/MACRO.ASM'
    
    org $2000
dl
    .byte SKIP8, SKIP8, SKIP8
    .byte LMS+MODE2 
    .word screen
    :20 .byte MODE2
    .byte JVB
    .word dl
    
start
    ;vdl dl
    
    
    dosio DCB_close_dir
            
    dosio DCB_mount_host
  
    dosio DCB_open_dir

    ; ----------------------------------------
    ; read directory to buffer
    ; ----------------------------------------
    mwa #0 dir_entry_displayed
    mwa #0 dir_entry_selected
    mwa #-1 dir_entry_counter 
    mwa #(big_buffer-dir_entry_len) DCB_read_dir_dbufa
loop
    inw dir_entry_counter
    adw DCB_read_dir_dbufa #dir_entry_len

    dosio DCB_read_dir
    
    jsr print_entry
    
    ; check for end of directory
    mwa DCB_read_dir_dbufa check_buf
    lda check_buf:$FFFF
    cmp #$7f
    bne loop

    rts


; ----------------------------------------
print_entry
; ----------------------------------------
    cpw dir_entry_displayed dir_entry_counter
    jcs do_not_print
    cpw dir_entry_displayed #20 
    jcs do_not_print
    
;print
    ;src dir entry addr = dir_entry_counter*48 + big_buffer +10
    mwa dir_entry_counter src_ptr
    :4 ASLW src_ptr         ;*16
    mwa src_ptr temp1    ;save
    ASLW src_ptr
    adw src_ptr temp1    ;*48
    adw src_ptr #big_buffer+10 ;text spurce skipping additional file attribs
    
    ;dest addr = dir_entry_displayed*40 + screenaddr
    mwa dir_entry_displayed dest_ptr
    :3 ASLW dest_ptr
    mwa dest_ptr temp1
    ASLW dest_ptr
    adw dest_ptr temp1  ;*40
    adw dest_ptr SAVMSC ; + screen addr

    ldy #38
@
    lda (src_ptr),y
    ;convert ATASCII to INTERNAL
    asl
    adc #$c0
    spl:eor #$40
    lsr
    scc:eor #$80
    sta (dest_ptr),y
    dey
    bpl @-

    inw dir_entry_displayed        
do_not_print
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
    .by "/games/", 0, 0     ;DOES NOT WORK WITH ONE ZERO!!!!

DCB_open_dir
    .BYTE   DEVIDN          ; DDEVIC
    .BYTE   $1              ; DUNIT
    .BYTE   $f7             ; DCOMND
    .BYTE   DSWRIT          ; DSTATS
    .WORD   dir_path        ; DBUFA
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
DCB_read_dir_dbufa
    .WORD   big_buffer      ; DBUFA
    .BYTE   $0f             ; DTIMLO
    .BYTE   0               ; DRESVD reserved
    .WORD   dir_entry_len   ; DBYT, # of bytes to return in directory entry, with additional details
    .BYTE   dir_entry_len   ; DAUX1, Maximum length of entry response
    .BYTE   $80             ; DAUX2, additional file details


dir_entry_counter   .ds 2
dir_entry_displayed .ds 2
dir_entry_selected  .ds 2

big_buffer
    run start

.macro ver
    .sbyte '0.01'
.endm  

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
    .local
    _dev = $70      ; FJ itself
    _dtimlo = $0f   ; timeout in s
    _dunit = 1      ; device #
    _dbyt = $100    ; buffer length

    _dcmnd = $F4    ; command
    _dstats = $40   ; read/write
    _daux1 = $ff    
    _daux2 = $ff
    gosio    
    .endl
    
    .local
    ; close DIR
    _dev = $70      ; FJ itself
    _dtimlo = $0f   ; timeout in s
    _dunit = 1      ; device #

    _dcmnd = $F5
    _dbyt = 0
    _dstats = 0
    _daux1 = 4      ; slot
    _daux2 = 0
    gosio
    .endl
    
    .local
    ; mount host
    _dev = $70      ; FN itself
    _dtimlo = $0f   ; timeout in s
    _dunit = 1      ; device #

    _dcmnd = $F9
    _dbyt = 0
    _dstats = 0
    _daux1 = 4      ;slot
    _daux2 = 0
    gosio
    .endl
    
    .local
    ; open DIR
    _dev = $70      ; FN itself
    _dtimlo = $0f   ; timeout in s
    _dunit = 1      ; device #
    _dbyt = $100    ; buffer length

    _dcmnd = $F7
    _dstats = $80
    _dbufa = directory_path
    _daux1 = 4
    _daux2 = 1
    gosio
    .endl

    .local 
    ; read DIR
    _dev = $70      ; FN itself
    _dtimlo = $0f   ; timeout in s
    _dunit = 1      ; device #
    _dbyt = 38+10   ; buffer length (screen width + 10 status bytes)

    _dcmnd = $F6    ; read dir
    _dstats = $40
    _dbufa = $bc40  ;small_buffer
    _daux1 = 38+10  ; max dir entry length
    _daux2 = $80    ; with file status bytes
    gosio
    
	.endl


    ;halt %00000111
    rts
directory_path
    .byte '/games/', 0
small_buffer
    :100 .by 0  ;.ds $100
big_buffer
    run start
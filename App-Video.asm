;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@                                                                            @
;@                               S y m P l a y                                @
;@                                                                            @
;@             (c) 2004-2014 by Prodatron / SymbiosiS (Jörn Mika)             @
;@                                                                            @
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;todo

relocate_start

;==============================================================================
;### CODE-TEIL ################################################################
;==============================================================================

;### PROGRAMM-KOPF ############################################################

prgdatcod       equ 0           ;Länge Code-Teil (Pos+Len beliebig; inklusive Kopf!)
prgdatdat       equ 2           ;Länge Daten-Teil (innerhalb 16K Block)
prgdattra       equ 4           ;Länge Transfer-Teil (ab #C000)
prgdatorg       equ 6           ;Original-Origin
prgdatrel       equ 8           ;Anzahl Einträge Relocator-Tabelle
prgdatstk       equ 10          ;Länge Stack (Transfer-Teil beginnt immer mit Stack)
prgdatrsv       equ 12          ;*reserved* (3 bytes)
prgdatnam       equ 15          ;program name (24+1[0] chars)
prgdatflg       equ 40          ;flags (+1=16colour icon available)
prgdat16i       equ 41          ;file offset of 16colour icon
prgdatrs2       equ 43          ;*reserved* (5 bytes)
prgdatidn       equ 48          ;"SymExe10"
prgdatcex       equ 56          ;zusätzlicher Speicher für Code-Bereich
prgdatdex       equ 58          ;zusätzlicher Speicher für Data-Bereich
prgdattex       equ 60          ;zusätzlicher Speicher für Transfer-Bereich
prgdatres       equ 62          ;*reserviert* (26 bytes)
prgdatver       equ 88          ;required minimum OS version (minor, major)
prgdatism       equ 90          ;Icon (klein)
prgdatibg       equ 109         ;Icon (gross)
prgdatlen       equ 256         ;Datensatzlänge

prgpstdat       equ 6           ;Adresse Daten-Teil
prgpsttra       equ 8           ;Adresse Transfer-Teil
prgpstspz       equ 10          ;zusätzliche Prozessnummern (4*1)
prgpstbnk       equ 14          ;Bank (1-8)
prgpstmem       equ 48          ;zusätzliche Memory-Bereiche (8*5)
prgpstnum       equ 88          ;Programm-Nummer
prgpstprz       equ 89          ;Prozess-Nummer

prgcodbeg   dw prgdatbeg-prgcodbeg  ;Länge Code-Teil
            dw prgtrnbeg-prgdatbeg  ;Länge Daten-Teil
            dw prgtrnend-prgtrnbeg  ;Länge Transfer-Teil
prgdatadr   dw #1000                ;Original-Origin                    POST Adresse Daten-Teil
prgtrnadr   dw relocate_count       ;Anzahl Einträge Relocator-Tabelle  POST Adresse Transfer-Teil
prgprztab   dw prgstk-prgtrnbeg     ;Länge Stack                        POST Tabelle Prozesse
            dw 0                    ;*reserved*
prgbnknum   db 0                    ;*reserved*                         POST bank number
            db "SymPlay":ds 17:db 0 ;Name
            db 1                    ;flags (+1=16c icon)
            dw prgicn16c-prgcodbeg  ;16 colour icon offset
            ds 5                    ;*reserved*
prgmemtab   db "SymExe10"           ;SymbOS-EXE-Kennung                 POST Tabelle Speicherbereiche
            dw 0                    ;zusätzlicher Code-Speicher
            dw 0                    ;zusätzlicher Data-Speicher
            dw 0                    ;zusätzlicher Transfer-Speicher
            ds 26                   ;*reserviert*
            db 1,1                  ;requires SymbOS 1.1 or higher
prgicnsml   db 2,8,8,#32,#8C,#65,#4E,#DA,#AF,#96,#D7,#9E,#D6,#DE,#BC,#67,#68,#33,#C0
prgicnbig   db 6,24,24
            db #00,#00,#72,#AE,#00,#00,#00,#11,#F5,#5F,#08,#00,#00,#72,#FA,#AF,#AE,#00,#00,#F5,#F5,#5F,#5F,#00,#10,#FA,#8F,#0F,#AF,#88,#31,#E5,#0F,#0F,#5F,#4C,#32,#CB,#0F,#0F,#2F,#8C,#75,#87,#C7,#0F,#1F,#4E
            db #72,#8F,#F1,#0F,#0F,#AE,#F5,#0F,#F0,#C7,#0F,#5F,#FA,#0F,#F0,#F1,#0F,#AF,#F5,#0F,#F0,#F0,#C7,#5F,#FF,#0F,#F0,#F0,#C7,#F0,#FF,#0F,#F0,#F1,#0F,#F0,#FF,#0F,#F0,#C7,#0F,#F0,#77,#8F,#F1,#0F,#1E,#E0
            db #77,#8F,#C7,#0F,#1E,#E0,#33,#CF,#0F,#0F,#3C,#C0,#33,#EF,#0F,#0F,#78,#C0,#11,#FF,#8F,#1E,#F0,#80,#00,#FF,#FF,#F0,#F0,#00,#00,#77,#FF,#F0,#E0,#00,#00,#11,#FF,#F0,#80,#00,#00,#00,#77,#E0,#00,#00


movcnvt0    ;CPC nach MSX
db #00,#02,#08,#0A,#20,#22,#28,#2A,#80,#82,#88,#8A,#A0,#A2,#A8,#AA,#01,#03,#09,#0B,#21,#23,#29,#2B,#81,#83,#89,#8B,#A1,#A3,#A9,#AB
db #04,#06,#0C,#0E,#24,#26,#2C,#2E,#84,#86,#8C,#8E,#A4,#A6,#AC,#AE,#05,#07,#0D,#0F,#25,#27,#2D,#2F,#85,#87,#8D,#8F,#A5,#A7,#AD,#AF
db #10,#12,#18,#1A,#30,#32,#38,#3A,#90,#92,#98,#9A,#B0,#B2,#B8,#BA,#11,#13,#19,#1B,#31,#33,#39,#3B,#91,#93,#99,#9B,#B1,#B3,#B9,#BB
db #14,#16,#1C,#1E,#34,#36,#3C,#3E,#94,#96,#9C,#9E,#B4,#B6,#BC,#BE,#15,#17,#1D,#1F,#35,#37,#3D,#3F,#95,#97,#9D,#9F,#B5,#B7,#BD,#BF
db #40,#42,#48,#4A,#60,#62,#68,#6A,#C0,#C2,#C8,#CA,#E0,#E2,#E8,#EA,#41,#43,#49,#4B,#61,#63,#69,#6B,#C1,#C3,#C9,#CB,#E1,#E3,#E9,#EB
db #44,#46,#4C,#4E,#64,#66,#6C,#6E,#C4,#C6,#CC,#CE,#E4,#E6,#EC,#EE,#45,#47,#4D,#4F,#65,#67,#6D,#6F,#C5,#C7,#CD,#CF,#E5,#E7,#ED,#EF
db #50,#52,#58,#5A,#70,#72,#78,#7A,#D0,#D2,#D8,#DA,#F0,#F2,#F8,#FA,#51,#53,#59,#5B,#71,#73,#79,#7B,#D1,#D3,#D9,#DB,#F1,#F3,#F9,#FB
db #54,#56,#5C,#5E,#74,#76,#7C,#7E,#D4,#D6,#DC,#DE,#F4,#F6,#FC,#FE,#55,#57,#5D,#5F,#75,#77,#7D,#7F,#D5,#D7,#DD,#DF,#F5,#F7,#FD,#FF
movcnvt1    ;MSX nach CPC
db #00,#10,#01,#11,#20,#30,#21,#31,#02,#12,#03,#13,#22,#32,#23,#33,#40,#50,#41,#51,#60,#70,#61,#71,#42,#52,#43,#53,#62,#72,#63,#73
db #04,#14,#05,#15,#24,#34,#25,#35,#06,#16,#07,#17,#26,#36,#27,#37,#44,#54,#45,#55,#64,#74,#65,#75,#46,#56,#47,#57,#66,#76,#67,#77
db #80,#90,#81,#91,#A0,#B0,#A1,#B1,#82,#92,#83,#93,#A2,#B2,#A3,#B3,#C0,#D0,#C1,#D1,#E0,#F0,#E1,#F1,#C2,#D2,#C3,#D3,#E2,#F2,#E3,#F3
db #84,#94,#85,#95,#A4,#B4,#A5,#B5,#86,#96,#87,#97,#A6,#B6,#A7,#B7,#C4,#D4,#C5,#D5,#E4,#F4,#E5,#F5,#C6,#D6,#C7,#D7,#E6,#F6,#E7,#F7
db #08,#18,#09,#19,#28,#38,#29,#39,#0A,#1A,#0B,#1B,#2A,#3A,#2B,#3B,#48,#58,#49,#59,#68,#78,#69,#79,#4A,#5A,#4B,#5B,#6A,#7A,#6B,#7B
db #0C,#1C,#0D,#1D,#2C,#3C,#2D,#3D,#0E,#1E,#0F,#1F,#2E,#3E,#2F,#3F,#4C,#5C,#4D,#5D,#6C,#7C,#6D,#7D,#4E,#5E,#4F,#5F,#6E,#7E,#6F,#7F
db #88,#98,#89,#99,#A8,#B8,#A9,#B9,#8A,#9A,#8B,#9B,#AA,#BA,#AB,#BB,#C8,#D8,#C9,#D9,#E8,#F8,#E9,#F9,#CA,#DA,#CB,#DB,#EA,#FA,#EB,#FB
db #8C,#9C,#8D,#9D,#AC,#BC,#AD,#BD,#8E,#9E,#8F,#9F,#AE,#BE,#AF,#BF,#CC,#DC,#CD,#DD,#EC,#FC,#ED,#FD,#CE,#DE,#CF,#DF,#EE,#FE,#EF,#FF


;### PRGPRZ -> Programm-Prozess
dskprzn     db 2
sysprzn     db 3
windatprz   equ 3   ;Prozeßnummer
windatsup   equ 51  ;Nummer des Superfensters+1 oder 0
prgwin      db 0    ;Nummer des Haupt-Fensters
diawin      db 0

prgprz  call SySystem_HLPINI
        ld a,(prgprzn)
        ld (prgwindat+windatprz),a
        ld (prgwinopt+windatprz),a
        ld (confrmwin+windatprz),a
        ld (copmovwin+windatprz),a

        ld bc,256*DSK_SRC_SCRCNV+MSC_DSK_DSKSRV
        ld de,gfxcnvtab
        ld hl,(prgbnknum)
        call msgsnd
        rst #30

        ld hl,jmp_sysinf        ;*** Computer-Typ holen
        ld de,256*1+5
        ld ix,cfgcpctyp
        ld iy,66+2+6+8
        rst #28
        ld a,(cfgcpctyp)
        rla
        ld e,0
        ld bc,movcnvt1+"M"
        ld hl,"X"*256+"S"
        jr nc,prgprz4
        inc e
        ld bc,movcnvt0+"C"
        ld hl,"C"*256+"P"
prgprz4 ld a,e
        ld (movcnv7+1),a
        ld (movlod4+1),a
        ld a,b
        ld (movcnv6+1),a
        ld a,c
        ld (confrmtxt1a),a
        ld (confrmtxt1a+1),hl

        ld c,MSC_DSK_WINOPN
        ld a,(prgbnknum)
        ld b,a
        ld de,prgwindat
        call msgsnd             ;Fenster aufbauen
prgprz1 call msgdsk             ;Message holen -> IXL=Status, IXH=Absender-Prozeß
        cp MSR_DSK_WOPNER
        jp z,prgend             ;kein Speicher für Fenster -> Prozeß beenden
        cp MSR_DSK_WOPNOK
        jr nz,prgprz1           ;andere Message als "Fenster geöffnet" -> ignorieren
        ld a,(prgmsgb+4)
        ld (prgwin),a           ;Fenster wurde geöffnet -> Nummer merken

        jp optfil               ;angehängtes Video suchen

prgprz0 call msgget             ;!ACHTUNG! wird gepatched
        jr nc,prgprz0
        cp MSR_SYS_SELOPN       ;*** Browse-Fenster wurde geschlossen
        jp z,prgbrc
        cp MSR_DSK_WCLICK       ;*** Fenster-Aktion wurde geklickt
        jr nz,prgprz0
        ld e,(iy+1)
        ld a,(prgwin)
        cp e
        jr z,prgprz3
        ld a,(diawin)
        cp e
        jr nz,prgprz0
        ld a,(iy+2)             ;*** DIALOG-FENSTER
        cp DSK_ACT_CLOSE        ;*** Close wurde geklickt
        jp z,diainpc
prgprz3 ld a,(iy+2)             ;*** HAUPT-FENSTER
        cp DSK_ACT_CLOSE        ;*** Close wurde geklickt
        jp z,prgend
        cp DSK_ACT_MENU         ;*** Menü wurde geklickt
        jr z,prgprz2
        cp DSK_ACT_KEY          ;*** Taste wurde gedrückt
        jr z,prgkey
        cp DSK_ACT_CONTENT      ;*** Inhalt wurde geklickt
        jr nz,prgprz0
prgprz2 ld l,(iy+8)
        ld h,(iy+9)
        ld a,l
        or h
        jr z,prgprz0
        ld a,(iy+3)             ;A=Klick-Typ (0/1/2=Maus links/rechts/doppelt, 7=Tastatur)
        jp (hl)

;### PRGKEY -> Taste auswerten
prgkeya equ 9
prgkeyt db  15:dw movopn    ;Ctrl+O = Open
        db  16:dw optopn    ;Ctrl+P = Optionen
        db "Z":dw movbeg
        db "X":dw movrew
        db "C":dw movctl
        db "V":dw movfwd
        db "B":dw movend
        db  32:dw movctl
        db  13:dw movctl

prgkey  ld hl,prgkeyt
        ld b,prgkeya
        ld de,3
        ld a,(iy+4)
        call clcucs
prgkey1 cp (hl)
        jr z,prgkey2
        add hl,de
        djnz prgkey1
        jp prgprz0
prgkey2 inc hl
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a
        ld a,7
        jp (hl)

;### PRGEND -> Programm beenden
prgend  call movdel
        ld a,(prgprzn)
        db #dd:ld l,a
        ld a,(sysprzn)
        db #dd:ld h,a
        ld iy,prgmsgb
        ld (iy+0),MSC_SYS_PRGEND
        ld a,(prgcodbeg+prgpstnum)
        ld (iy+1),a
        rst #10
prgend0 rst #30
        jr prgend0

;### PRGINF -> Info-Fenster anzeigen
prginf  ld hl,prgmsginf         ;*** Info-Fenster
        ld b,1+128
prginf0 call prginf1
        jp prgprz0
prginf1 ld (prgmsgb+1),hl
        ld a,(prgbnknum)
        ld c,a
        ld (prgmsgb+3),bc
        ld a,MSC_SYS_SYSWRN
        ld (prgmsgb),a
prginf2 ld a,(prgprzn)
        db #dd:ld l,a
        ld a,(sysprzn)
        db #dd:ld h,a
        ld iy,prgmsgb
        rst #10
        ret

;### PRGERR -> Disc-Error-Fenster anzeigen
;### Eingabe    A=Fehler -> 0=Fehler beim Laden, 1=unbekanntes Format, 2=nicht unterstütztes Video, 3=Speicher voll, 4=kein 16 Farbsupport für CPC
prgmsgerrtb dw prgmsgerr00,prgmsgerr01,prgmsgerr02,prgmsgerr03,prgmsgerr04

prgerr  xor a
prgerr0 add a
        ld l,a
        ld h,0
        ld de,prgmsgerrtb
        add hl,de
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a
prgerr1 ld (prgmsgerra),hl
        ld b,1
        ld hl,prgmsgerr
        call prginf1
        jp movdel


;==============================================================================
;### SUB-ROUTINEN #############################################################
;==============================================================================

SySystem_HLPFLG db 0    ;flag, if HLP-path is valid
SySystem_HLPPTH db "%help.exe "
SySystem_HLPPTH1 ds 128
SySHInX db ".HLP",0

SySystem_HLPINI
        ld hl,(prgcodbeg)
        ld de,prgcodbeg
        dec h
        add hl,de                   ;HL = CodeEnd = Command line
        ld de,SySystem_HLPPTH1
        ld bc,0
        db #dd:ld l,128
SySHIn1 ld a,(hl)
        or a
        jr z,SySHIn3
        cp " "
        jr z,SySHIn3
        cp "."
        jr nz,SySHIn2
        ld c,e
        ld b,d
SySHIn2 ld (de),a
        inc hl
        inc de
        db #dd:dec l
        ret z
        jr SySHIn1
SySHIn3 ld a,c
        or b
        ret z
        ld e,c
        ld d,b
        ld hl,SySHInX
        ld bc,5
        ldir
        ld a,1
        ld (SySystem_HLPFLG),a
        ret

hlpopn  ld a,(SySystem_HLPFLG)
        or a
        jp z,prgprz0
        ld a,(prgbnknum)
        ld d,a
        ld a,PRC_ID_SYSTEM
        ld c,MSC_SYS_PRGRUN
        ld hl,SySystem_HLPPTH
        ld b,l
        ld e,h
        call msgsnd1
        jp prgprz0

;### PRGBRO -> Browse-Fenster öffnen
;### Eingabe    A=Typ (1=Source), HL=Textinput
prgbron db 0
prgbro  ld e,a
        ld a,(prgbron)
        or a
        ret nz
        ld a,e
        ld (prgbron),a
        ld (prgmsgb+8),hl
        ld hl,(prgbnknum)
        ld h,8
        ld (prgmsgb+6),hl
        ld hl,100
        ld (prgmsgb+10),hl
        ld hl,5000
        ld (prgmsgb+12),hl
        ld l,MSC_SYS_SELOPN
        ld (prgmsgb),hl
        jp prginf2

;### PRGBRC -> Browse-Fenster schließen
;### Eingabe    P1=Typ (0=Ok, 1=Abbruch, 2=FileAuswahl bereits in Benutzung, 3=kein Speicher frei, 4=kein Fenster frei), P2=PfadLänge
prgbrc  ld hl,(prgmsgb+1)
        inc l
        jr z,prgbrc2
        dec l
        ld hl,prgbron
        ld e,(hl)
        ld (hl),0
        jp nz,prgprz0
        ld a,(movctlm)
        or a
        call nz,movctl0
        call movlod
        jp prgprz0
prgbrc2 ld a,h
        ld (prgwindat+windatsup),a
        jp prgprz0

;### MSGPLY -> Message für Programm abholen und parallel Video abspielen
;### Ausgabe    CF=0 -> keine Message, CF=1, IXH=Absender, (recmsgb)=Message, A=(recmsgb+0), IY=recmsgb
;### Veraendert 
msgply  call movply
        ret nc
        ld a,(prgprzn)
        db #dd:ld l,a           ;IXL=Rechner-Prozeß-Nummer
        db #dd:ld h,-1
        ld iy,prgmsgb           ;IY=Messagebuffer
        rst #18                 ;Message holen -> IXL=Status, IXH=Absender-Prozeß
        db #dd:dec l
        jr nz,msgply
        ld iy,prgmsgb
        ld a,(iy+0)
        or a
        jp z,prgend
        scf
        ret

;### MSGGET -> Message für Programm abholen
;### Ausgabe    CF=0 -> keine Message vorhanden, CF=1 -> IXH=Absender, (recmsgb)=Message, A=(recmsgb+0), IY=recmsgb
;### Veraendert 
msgget  ld a,(prgprzn)
        db #dd:ld l,a           ;IXL=Rechner-Prozeß-Nummer
        db #dd:ld h,-1
        ld iy,prgmsgb           ;IY=Messagebuffer
        rst #08                 ;Message holen -> IXL=Status, IXH=Absender-Prozeß
        or a
        db #dd:dec l
        ret nz
        ld iy,prgmsgb
        ld a,(iy+0)
        or a
        jp z,prgend
        scf
        ret

;### MSGDSK -> Message für Programm von Desktop-Prozess abholen
;### Ausgabe    CF=0 -> keine Message vorhanden, CF=1 -> IXH=Absender, (recmsgb)=Message, A=(recmsgb+0), IY=recmsgb
;### Veraendert 
msgdsk  call msgget
        jr nc,msgdsk            ;keine Message
        ld a,(dskprzn)
        db #dd:cp h
        jr nz,msgdsk            ;Message von anderem als Desktop-Prozeß -> ignorieren
        ld a,(prgmsgb)
        ret

;### MSGSND -> Message an Desktop-Prozess senden
;### Eingabe    C=Kommando, B/E/D/L/H=Parameter1/2/3/4/5
msgsnd0 ld c,MSC_DSK_WINDIN
msgsnd2 ld a,(prgwin)
        ld b,a
msgsnd  ld a,(dskprzn)
msgsnd1 db #dd:ld h,a
        ld a,(prgprzn)
        db #dd:ld l,a
        ld iy,prgmsgb
        ld (iy+0),c
        ld (iy+1),b
        ld (iy+2),e
        ld (iy+3),d
        ld (iy+4),l
        ld (iy+5),h
        rst #10
        ret

;### SYSCLX -> Betriebssystem-Funktion aufrufen
;### Eingabe    (SP)=Modul/Funktion, AF,BC,DE,HL,IX,IY=Register
;### Ausgabe    AF,BC,DE,HL,IX,IY=Register
sysclx  ld (prgmsgb+04),bc      ;Register in Message-Buffer kopieren
        ld (prgmsgb+06),de
        ld (prgmsgb+08),hl
        ld (prgmsgb+10),ix
        ld (prgmsgb+12),iy
        push af
        pop hl
        ld (prgmsgb+02),hl
        pop hl
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
        push hl
        ld (prgmsgb+00),de      ;Modul und Funktion in Message-Buffer kopieren
        ld a,e
        ld (sysclln),a
        ld iy,prgmsgb
        ld a,(prgprzn)          ;Desktop und System-Prozessnummer holen
        db #dd:ld l,a
        ld a,(sysprzn)
        db #dd:ld h,a
        rst #10                 ;Message senden
sysclx1 rst #30
        ld iy,prgmsgb
        ld a,(prgprzn)
        db #dd:ld l,a
        ld a,(sysprzn)
        db #dd:ld h,a
        rst #18                 ;auf Antwort warten
        db #dd:dec l
        jr nz,sysclx1
        ld a,(prgmsgb)
        sub 128
        ld e,a
        ld a,(sysclln)
        cp e
        jr nz,sysclx1
        ld hl,(prgmsgb+02)      ;Register aus Message-Buffer holen
        push hl
        pop af
        ld bc,(prgmsgb+04)
        ld de,(prgmsgb+06)
        ld hl,(prgmsgb+08)
        ld ix,(prgmsgb+10)
        ld iy,(prgmsgb+12)
        ret

;### SYSCLL -> Betriebssystem-Funktion aufrufen
;### Eingabe    (SP)=Modul/Funktion, AF,BC,DE,HL,IX,IY=Register
;### Ausgabe    AF,BC,DE,HL,IX,IY=Register
sysclln db 0
syscllt db 0
syscll  ld (prgmsgb+04),bc      ;Register in Message-Buffer kopieren
        ld (prgmsgb+06),de
        ld (prgmsgb+08),hl
        ld (prgmsgb+10),ix
        ld (prgmsgb+12),iy
        push af
        pop hl
        ld (prgmsgb+02),hl
        pop hl
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
        push hl
        ld (prgmsgb+00),de      ;Modul und Funktion in Message-Buffer kopieren
        ld a,e
        ld (sysclln),a
        ld iy,prgmsgb
        ld a,(prgprzn)          ;Desktop und System-Prozessnummer holen
        db #dd:ld l,a
        ld a,(sysprzn)
        db #dd:ld h,a
        rst #10                 ;Message senden
        ld a,5
        ld (syscllt),a
syscll1 rst #30
        ld iy,prgmsgb
        ld a,(prgprzn)
        db #dd:ld l,a
        ld a,(sysprzn)
        db #dd:ld h,a
        rst #18                 ;auf Antwort warten
        db #dd:dec l
syscll4 ld a,-1
        scf
        ret nz
        ld a,(prgmsgb)
        sub 128
        ld e,a
        ld a,(sysclln)
        cp e
        jr z,syscll2
        call syscll3
        jr nz,syscll1
        ld a,-1
        scf
        ret
syscll3 ld iy,prgmsgb           ;Message an sich selbst schicken
        ld a,(sysprzn)
        db #dd:ld l,a
        ld a,(prgprzn)
        db #dd:ld h,a
        rst #10
        ld hl,syscllt
        dec (hl)
        ret
syscll2 ld hl,(prgmsgb+02)      ;Register aus Message-Buffer holen
        push hl
        pop af
        ld bc,(prgmsgb+04)
        ld de,(prgmsgb+06)
        ld hl,(prgmsgb+08)
        ld ix,(prgmsgb+10)
        ld iy,(prgmsgb+12)
        ret

;### STRLEN -> Ermittelt Länge eines Strings
;### Eingabe    HL=String
;### Ausgabe    HL=Stringende (0), BC=Länge (maximal 255)
;### Verändert  -
strlen  push af
        xor a
        ld bc,255
        cpir
        ld a,254
        sub c
        ld c,a
        dec hl
        pop af
        ret

;### STRINP -> Initialisiert Input-Control
;### Eingabe    IX=Control
;### Ausgabe    BC=String-Länge (maximal 255)
;### Verändert  HL,BC
strinp  ld l,(ix+0)
        ld h,(ix+1)
        call strlen
        ld (ix+2),0
        ld (ix+3),0
        ld (ix+4),c
        ld (ix+5),b
        ld (ix+6),0
        ld (ix+7),0
        ld (ix+8),c
        ld (ix+9),b
        ret

;### CLCDEZ -> Rechnet Byte in zwei Dezimalziffern um
;### Eingabe    A=Wert
;### Ausgabe    L=10er-Ascii-Ziffer, H=1er-Ascii-Ziffer
;### Veraendert AF
clcdez  ld l,0
clcdez1 sub 10
        jr c,clcdez2
        inc l
        jr clcdez1
clcdez2 add "0"+10
        ld h,a
        ld a,"0"
        add l
        ld l,a
        ret

;### CLCM16 -> Multipliziert zwei Werte (16bit)
;### Eingabe    A=Wert1, DE=Wert2
;### Ausgabe    HL=Wert1*Wert2 (16bit)
;### Veraendert AF,DE
clcm16  ld hl,0
        or a
clcm161 rra
        jr nc,clcm162
        add hl,de
clcm162 sla e
        rl d
        or a
        jr nz,clcm161
        ret

;### CLCMUL -> Multipliziert zwei Werte (24bit)
;### Eingabe    BC=Wert1, DE=Wert2
;### Ausgabe    A,HL=Wert1*Wert2 (24bit)
;### Veraendert F,BC,DE,IX
clcmul  ld ix,0
        ld hl,0
clcmul1 ld a,c
        or b
        jr z,clcmul3
        srl b
        rr c
        jr nc,clcmul2
        add ix,de
        ld a,h
        adc l
        ld h,a
clcmul2 sla e
        rl d
        rl l
        jr clcmul1
clcmul3 ld a,h
        db #dd:ld e,l
        db #dd:ld d,h
        ex de,hl
        ret

;### CLCD16 -> Dividiert zwei Werte (16bit)
;### Eingabe    BC=Wert1, DE=Wert2
;### Ausgabe    HL=Wert1/Wert2, DE=Wert1 MOD Wert2
;### Veraendert AF,BC,DE
clcd16  ld a,e
        or d
        ld hl,0
        ret z
        ld a,b
        ld b,16
clcd161 rl c
        rla
        rl l
        rl h
        sbc hl,de
        jr nc,clcd162
        add hl,de
clcd162 ccf
        djnz clcd161
        ex de,hl
        rl c
        rla
        ld h,a
        ld l,c
        ret

;### CLCDIV -> Dividiert zwei Werte (24bit)
;### Eingabe    A,BC=Wert1, DE=Wert2
;### Ausgabe    HL=Wert1/Wert2, DE=Wert1 MOD Wert2
;### Veraendert AF,BC,DE,IX,IYL
clcdiv  db #dd:ld l,e
        db #dd:ld h,d   ;IX=Wert2(Nenner)
        ld e,a          ;E,BC=Wert1(Zaehler)
        ld hl,0
        db #dd:ld a,l
        db #dd:or h
        ret z
        ld d,l          ;D,HL=RechenVar
        db #fd:ld l,24  ;IYL=Counter
clcdiv1 rl c
        rl b
        rl e
        rl l
        rl h
        rl d
        ld a,l
        db #dd:sub l
        ld l,a
        ld a,h
        db #dd:sbc h
        ld h,a
        ld a,d
        sbc 0
        ld d,a          ;D,HL=D,HL-IX
        jr nc,clcdiv2
        ld a,l
        db #dd:add l
        ld l,a
        ld a,h
        db #dd:adc h
        ld h,a
        ld a,d
        adc 0
        ld d,a
        scf
clcdiv2 ccf
        db #fd:dec l
        jr nz,clcdiv1
        ex de,hl        ;DE=Wert1 MOD Wert2
        rl c
        rl b
        ld l,c
        ld h,b          ;HL=Wert1 DIV Wert2
        ret

;### CLCUCS -> Wandelt Klein- in Großbuchstaben um
;### Eingabe    A=Zeichen
;### Ausgabe    A=ucase(Zeichen)
;### Verändert  F
clcucs  cp "a"
        ret c
        cp "z"+1
        ret nc
        add "A"-"a"
        ret

;### CLCN32 -> Wandelt 32Bit-Zahl in ASCII-String um (mit 0 abgeschlossen)
;### Eingabe    DE,IX=Wert, IY=Adresse
;### Ausgabe    IY=Adresse letztes Zeichen
;### Veraendert AF,BC,DE,HL,IX,IY
clcn32t dw 1,0,     10,0,     100,0,     1000,0,     10000,0
        dw #86a0,1, #4240,#f, #9680,#98, #e100,#5f5, #ca00,#3b9a
clcn32z ds 4

clcn32  ld (clcn32z),ix
        ld (clcn32z+2),de
        ld ix,clcn32t+36
        ld b,9
        ld c,0
clcn321 ld a,"0"
        or a
clcn322 ld e,(ix+0):ld d,(ix+1):ld hl,(clcn32z):  sbc hl,de:ld (clcn32z),hl
        ld e,(ix+2):ld d,(ix+3):ld hl,(clcn32z+2):sbc hl,de:ld (clcn32z+2),hl
        jr c,clcn325
        inc c
        inc a
        jr clcn322
clcn325 ld e,(ix+0):ld d,(ix+1):ld hl,(clcn32z):  add hl,de:ld (clcn32z),hl
        ld e,(ix+2):ld d,(ix+3):ld hl,(clcn32z+2):adc hl,de:ld (clcn32z+2),hl
        ld de,-4
        add ix,de
        inc c
        dec c
        jr z,clcn323
        ld (iy+0),a
        inc iy
clcn323 djnz clcn321
        ld a,(clcn32z)
        add "0"
        ld (iy+0),a
        ld (iy+1),0
        ret

;### DIAINP -> Dialog-Fenster aufbauen
;### Eingabe    DE=Fenster
diainp  ld c,MSC_DSK_WINOPN     ;Fenster aufbauen
        ld a,(prgbnknum)
        ld b,a
        call msgsnd
diainp3 call msgdsk             ;Message holen -> IXL=Status, IXH=Absender-Prozeß
        cp MSR_DSK_WOPNER
        ret z                   ;kein Speicher für Fenster -> dann halt nicht
        cp MSR_DSK_WOPNOK
        jr nz,diainp3           ;andere Message als "Fenster geöffnet" -> ignorieren
        ld a,(prgmsgb+4)
        ld (diawin),a           ;Fenster wurde geöffnet -> Nummer merken
        inc a
        ld (prgwindat+windatsup),a
        ret

;### DIAINPC -> Dialog-Fenster schließen
diainpc call diainp4            ;*** CANCEL
        jp prgprz0
diainp4 call movctl4
        ld c,MSC_DSK_WINCLS     ;Dialog-Fenster schliessen
        ld a,(diawin)
        ld b,a
        jp msgsnd


;==============================================================================
;### OPTIONS ROUTINEN #########################################################
;==============================================================================

optopna dw movtxttit0+00,movtxttit0+32,movsrc1,movtxtfrm0,movtxtfps0,movtxtfil0,movtxtrat0,movtxtlen0,movtxtsiz0
optopnb dw movtxtnon,movtxtnon0,movtxtnul,movtxtnul,movtxtnul,movtxtnul,movtxtnul,movtxtnul,movtxtnul
optopnt db " kBit/s",0
optopnp db " pixels"
optopnc db " colours",0

optopn  call movexi
        ld hl,optopnb
        jp z,optopn1
        ld hl,movtitnam         ;** Name eintragen
        ld de,movtxttit0
        ld bc,64
        ldir
        ld a,(movinffps)        ;** FPS eintragen
        ld e,a
        call clcdez
        ld (movtxtfps0),hl
        ld d,0                  ;** Bitrate eintragen
        ld hl,(movinfsiz)
        sla l
        ld a,h
        rla                 ;A=Framegröße/128 = Framegröße/1024*8
        call clcm16
        push hl
        pop ix
        ld de,0
        ld iy,movtxtrat0
        call clcn32
        db #fd:ld e,l
        db #fd:ld d,h
        inc de
        ld hl,optopnt
        ld bc,8
        ldir
        ld ix,(movinfxln)       ;** Bildgröße eintragen
        ld de,0
        ld iy,movtxtsiz0
        call clcn32
        ld (iy+1)," "
        ld (iy+2),"x"
        ld (iy+3)," "
        ld de,4
        add iy,de
        ld e,0
        ld ix,(movinfyln)
        call clcn32
        ld (iy+1),","           ;** Farben eintragen
        ld (iy+2)," "
        ld (iy+3),"4"
        ld a,(movinfmod)
        cp 7
        jr nz,optopn3
        ld (iy+3),"1"
        ld (iy+4),"6"
        inc iy
optopn3 db #fd:ld e,l
        db #fd:ld d,h
        inc de:inc de:inc de:inc de
        ld hl,optopnc
        ld bc,9
        ldir
        ld bc,(movinflen)       ;** Dauer eintragen
        ld a,(movinflen+2)
        ld de,(movinffps)
        ld d,0
        call clcdiv         ;HL=Sekunden
        ld c,l
        ld b,h
        ld de,60
        call clcd16         ;HL=Minuten, DE=Rest-Sekunden
        ld c,l
        ld b,h
        ld a,e
        call clcdez
        ld (movtxtlen0+6),hl ;Sekunde eintragen
        ld de,60
        call clcd16         ;HL=Stunden, DE=Rest-Minuten
        ld a,l
        call clcdez
        ld (movtxtlen0+0),hl ;Stunden eintragen
        ld a,e
        call clcdez
        ld (movtxtlen0+3),hl ;Minuten eintragen
        ld hl,(movinflen)       ;** Filegröße eintragen
        ld a,(movinflen+2)
        ld e,a
        call movset3
        srl l:rr d:rr e     ;LDE=Größe in KB
        db #dd:ld l,e
        db #dd:ld h,d
        ld e,l
        ld d,0
        ld iy,movtxtfil0
        call clcn32
        ld (iy+1)," "
        ld (iy+2),"K"
        ld (iy+3),"B"
        ld (iy+4),0
        ld hl,optopna
optopn1 ld b,9
        ld ix,prgobjopt2
        ld de,8
optopn2 ld a,(hl)
        inc hl
        ld (ix+0),a
        ld a,(hl)
        inc hl
        ld (ix+1),a
        add ix,de
        djnz optopn2
        ld de,prgwinopt         ;Fenster öffnen
        call diainp
        jp prgprz0

;### OPTFIL -> Angehängtes File suchen
optfil  ld hl,(prgcodbeg)       ;nach angehängtem File suchen
        ld de,prgcodbeg
        dec h
        add hl,de               ;HL=CodeEnde=Pfad
        ld b,255
optfil1 ld a,(hl)
        or a
        jp z,prgprz0
        cp 32
        jr z,optfil2
        inc hl
        djnz optfil1
        jp prgprz0
optfil2 inc hl
        ld de,movsrc1
        ld bc,256
        ldir
        call movlod
        jp prgprz0


;==============================================================================
;### MOVIE ROUTINEN ###########################################################
;==============================================================================

;### 512 byte main header
movinfbeg
                ;*** general
movinfide   db "SymVid10"   ;identifier
movinfflg   db 0    ;flag field; if one flag is set, the regarding information is given in a 128byte header in each single frame,
                    ;if one flag is not set, the regarding information is given in this main header or nowhere;
                    ;if this byte is 0, all frames do not contain an additional header but only the screen data
                    ;0 (+1) -> size                                                                 *** NOT SUPPORTED ***
                    ;1 (+2) -> number of colours (mode 0/1/2)                                       *** NOT SUPPORTED ***
                    ;2 (+4) -> colour definition                                                    *** IGNORED ***
                    ;3 (+8) -> key controls
                    ;4(+16) -> subtitles
movinfcrn   db 0    ;crunch type (0=frames are not crunched)                                        *** MUST BE 0 ***
movinffps   db 0    ;frames per second (1-100)
movinflen   ds 3    ;total number of frames (24bit); the total number of seconds must not be above 65535
                ;*** frame specific
movinfxln   dw 0    ;frame width  (only valid, if movinfdyn[bit0]==0)
movinfyln   dw 0    ;frame height (only valid, if movinfdyn[bit0]==0)
movinfmod   db 0    ;screen mode  (only valid, if movinfdyn[bit1]==0) [1=4colours, 7=16colours]     *** MUST BE 1 ***
movinfcol   ds 2*16 ;colour table -> 16 x 12bit cpc plus colours (only valid, if movinfdyn[bit2]==0)*** IGNORED ***
movinfsiz   dw 0    ;size of each frame in bytes without header  (only valid, if movinfcrn==0);
                    ;total size with optional header MUST be divideable by 512!
                ;*** subtitles
movtitnum   db 0    ;number of presented languages (1-8; 0=no subtitles)
movtitdat   ds 8*16 ;8 x name (16 bytes, 0=terminator) of the language with ID 0-7
movtitnam   ds 32   ;movie name (terminated by 0)
movtitinf   ds 32   ;additional information (terminated by 0)
movinfenc   db 0    ;encoding type (0=CPC oder 16Farben, 1=MSX)

movinfend   ds 512-movinfend+movinfbeg

;### 128 byte frame header
frminfbeg
frminfxln   dw 0    ;frame width  (only valid, if movinfdyn[bit0]==1)
frminfyln   dw 0    ;frame height (only valid, if movinfdyn[bit0]==1)
frminfmod   db 0    ;screen mode  (only valid, if movinfdyn[bit1]==1)
frminfcol   ds 2*16 ;colour table -> 16 x 12bit cpc plus colours (only valid, if movinfdyn[bit2]==1)
frminfsiz   dw 0    ;size of this frame in bytes without header  (only valid, if movinfcrn!=0)
frminfact   ds 4    ;byte0=action -> 0=continue playing, 1=stop movie here (byte1=reason), 2=jump to frame [byte1-3]
frmkeynum   db 0    ;number of possible keys (0-8)
frmkeyfrm   ds 8*4  ;keycode (1byte) + destination frame (24bit)
frmtitact   db 0    ;0=don't change last subtitle, 1=delete last subtitle
frmtitdat   ds 128-frmtitdat+frminfbeg  ;subtitle data (maximum is about 50 bytes)
                    ;-> 1 byte=text length (0=data terminator), 1 byte=language id, x bytes=text


movfilhnd   db -1   ;file handler (-1=kein file offen)
movfilpos   ds 4    ;aktuelle frame position (24bit)
movfilfrm   db 0,0  ;gesamte Framegröße/512
movfiladr   dw 0,0  ;lade-adresse
movfilhd1   dw 0,0  ;adresse header 1
movfilhd2   dw 0,0  ;adresse header 2
movfilfps   dw 0    ;100/fps

;### MOVOPN -> Movie-Fileauswahl öffnen
movopn  ld a,1
        ld hl,movsrc
        call prgbro
        jp prgprz0

;### MOVLOD -> Ausgewählten Movie laden
movlodi db "SymVid10"
movlod  ld hl,movsrc1
        ld de,prgwintit1
        ld bc,256
        ldir
        ld c,MSC_DSK_WINTIT
        call msgsnd2
        call movdel
        ld hl,movsrc1           ;*** Movie öffnen
        ld a,(prgbnknum)
        db #dd:ld h,a
        call syscll
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILOPN
        jp c,prgerr             ;Fehler beim Öffnen
        ld (movfilhnd),a
        ld de,(prgbnknum)       ;*** Kopf laden
        ld hl,movinfbeg
        ld bc,512
        call syscll
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILINP
        jp c,prgerr
        ld hl,movlodi           ;Kennung überprüfen
        ld de,movinfide
        ld b,8
movlod1 ld a,(de)
        cp (hl)
        ld a,1
        jp nz,prgerr0
        inc hl
        inc de
        djnz movlod1

        ld a,(movinfmod)
        cp 7
        jr z,movlodb
        ld a,(movinfenc)        ;Test, ob falsches Encoding
movlod4 cp 0
        jp nz,movcnv
        jr movlod9
movlodb ld a,(cfgcpctyp)
        rla
        jr c,movlod9
        ld a,4
        jp prgerr0              ;kein Screen7 support für CPC/EP

movlod9 ld e,2
        ld a,(movinfflg)
        ld d,a                  ;D=movinfflg
        and 3
        ld a,e
        jp nz,prgerr0           ;dynamische Größe und Mode wird nicht unterstützt
        ld a,(movinfcrn)
        or a
        ld a,e
        jp nz,prgerr0           ;gecrunchte Frames werden nicht unterstützt
        ld a,(movinfmod)
        cp 7
        jr z,movlod6
        dec a
        ld a,e
        jp nz,prgerr0           ;nur Mode 1 und 7 werden unterstützt
movlod6 ld hl,(movinfsiz)
        ld a,d
        or a
        jr z,movlod2
        ld de,128
        add hl,de
movlod2 ld (movinfsiz),hl
        ld e,a                  ;E=movinfflg
        ld a,h
        srl a
        ld (movfilfrm),a
        ld a,e
        or a
        jr nz,movlod3
        ld e,10                 ;Grafik-Header zusätzlich reservieren, wenn keine Frame-Header vorhanden
        add hl,de
movlod3 ld c,l
        ld b,h
        xor a
        ld e,1
        push bc
        rst #20:dw jmp_memget   ;Frame-Buffer (1) in beliebiger Bank reservieren
        pop bc
        ld e,a
        ld a,3
        jp c,prgerr0
        ld a,e
        ld (prgmemtab+5),a
        ld (prgmemtab+6),hl
        ld (prgmemtab+8),bc
        ld (movfilhd1+2),hl
        xor a
        ld e,1
        push bc
        rst #20:dw jmp_memget   ;Frame-Buffer (2) in beliebiger Bank reservieren
        pop bc
        jr nc,movlodc
        call movdel1
        ld a,3
        scf
        jp prgerr0
movlodc ld (prgmemtab+0),a
        ld (prgmemtab+1),hl
        ld (prgmemtab+3),bc

        ld a,(movinfflg)
        or a
;        jr nz,...........header, nur sprite-pos setzen
        ld de,(movinfxln)       ;Sprite-Kopf setzen
        ld a,d
        or a
;        jr nz,...........zwei sprite-header
        ld (movfilhd1),hl
        push hl
        ld b,e
        srl b
        ld a,(movinfmod)
        cp 7
        jr nz,movlod7
        ld a,(prgmemtab+0)      ;* Kopf für 16 Farb-Video
        rst #20:dw jmp_bnkwbt
        ld b,e
        rst #20:dw jmp_bnkwbt
        ld bc,(movinfyln-1)
        rst #20:dw jmp_bnkwbt
        ex de,hl
        ld hl,7
        add hl,de
        ld c,l
        ld b,h
        ex de,hl
        push bc
        rst #20:dw jmp_bnkwwd
        pop bc
        dec bc
        rst #20:dw jmp_bnkwwd
        ld bc,1
        rst #20:dw jmp_bnkwwd   ;größe=1, da keine konvertierung nötig!
        ld b,5
        rst #20:dw jmp_bnkwbt
        jr movlod8

movlod7 srl b                   ;* Kopf für 4 Farb-Video
        ld a,(cfgcpctyp)
        rla
        jr nc,movlod5
        set 7,b
movlod5 ld a,(prgmemtab+0)
        rst #20:dw jmp_bnkwbt
        ld b,e
        rst #20:dw jmp_bnkwbt
        ld bc,(movinfyln-1)
        rst #20:dw jmp_bnkwbt

movlod8 ld (movfiladr),hl
        ld de,(prgmemtab+6)
        add hl,de
        ld bc,(prgmemtab+1)
        or a
        sbc hl,bc
        ld (movfiladr+2),hl
        push hl
        ld l,c
        ld h,b
        ld a,(prgmemtab+5)
        add a:add a:add a:add a
        ld c,a
        ld a,(prgmemtab+0)
        or c
        ld bc,256
        rst #20:dw jmp_bnkcop   ;kopf in zweiten frame-buffer kopieren
        pop hl

        ld a,(movinfmod)
        cp 7
        jr nz,movlodd

        ld a,(prgmemtab+5)
        ld c,l
        ld b,h
        ld de,-7
        add hl,de
        push bc
        rst #20:dw jmp_bnkwwd
        pop bc
        dec bc
        rst #20:dw jmp_bnkwwd

movlodd pop hl
        ld (prgwinobj2+4),hl
        ld bc,100               ;*** Zeit in 1/100 Sekunden pro Frame berechnen
        ld a,(movinffps)
        ld e,a
        ld d,0
        call clcd16
        ld (movfilfps),hl
        call movctl4
        ld hl,(movinfxln)       ;*** Fenstergröße anpassen
        ld (prgwinclc+16+8),hl
        ld bc,2
        add hl,bc
        ld (prgwindat+16),hl
        ex de,hl
        ld hl,(movinfyln)
        ld (prgwinclc+16+12),hl
        ld bc,32
        add hl,bc
        ld (prgwindat+18),hl
        ld c,MSC_DSK_WINSIZ
        call msgsnd2
        rst #30
        ld hl,(prgmemtab-1)     ;H=Bank
        ld l,8
        ld a,(movinfmod)
        cp 7
        jr nz,movloda
        ld l,10
movloda ld (prgwinobj2+2),hl
        ld a,64
        ld (prgwinobj0+2),a
        ld (prgwinobj2+16+2),a
        jp movbeg0

;### MOVEXI -> Test, ob Movie vorhanden
;### Ausgabe    ZF=1 kein Movie geladen
movexi  ld a,(movfilhnd)
        cp -1
        ret

;### MOVSET -> Movie auf bestimmten Frame setzen
;### Eingabe    E,HL=Frame-Nummer
movset  call movset0
        call movset3
        ld a,l
        sla e:rl d:rla      ;ADE=Position*2
        db #dd:ld l,0
        db #dd:ld h,e
        db #fd:ld l,d
        db #fd:ld h,a       ;IY,IX=Position*512 -> Filepointer
        ld a,(movfilhnd)
        ld c,0
        call syscll         ;Filepointer setzen
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILPOI
        jp c,prgerr
        call movsld         ;Slider updaten
        jp movshw           ;aktuellen Frame zeigen
;E,HL=Frame -> Frame setzen -> CF=1 Ende überschritten
movset0 ld d,0
        ld (movfilpos+0),hl
        ld (movfilpos+2),de
        push hl
        push de
        ld bc,(movinflen)
        or a
        sbc hl,bc
        ex de,hl
        ld bc,(movinflen+2)
        ld b,0
        sbc hl,bc
        pop de
        pop hl
        ccf
        ret nc
        ld hl,(movinflen)
        ld de,(movinflen+2)
        ld d,b
        ld bc,-1
        add hl,bc
        jr c,movset2
        dec e
        scf
movset2 ld (movfilpos+0),hl
        ld (movfilpos+2),de
        ret
;E,HL=Frame -> LDE=Sektornummer bis Frame
movset3 push hl
        ld a,e
        ld de,(movfilfrm)
        call clcm16         ;HL=Position/65536
        ex (sp),hl
        ex de,hl
        ld bc,(movfilfrm)
        call clcmul         ;A,HL=Position MOD 65536
        ex de,hl
        ld c,a
        ld b,0              ;BC,DE=Position MOD 65536
        pop hl              ;HL=Position/65536
        add hl,bc           ;HL,DE=Position
        inc de
        ld a,e
        or d
        jr nz,movset1
        inc l               ;Position + 1 (wegen Header)
movset1 ret

;### MOVBEG -> Movie an den Anfang setzen
movbeg  call movexi
        jp z,prgprz0
        call movbeg0
        jp prgprz0
movbeg0 ld hl,0
        ld e,l
        jp movset

;### MOVEND -> Movie an das Ende setzen
movend  call movexi
        jp z,prgprz0
        ld hl,-1
        ld e,255
movend1 call movset
        jp prgprz0

;### MOVREW -> Movie 5 Sekunden zurückspulen
movrew  call movexi
        jp z,prgprz0
        call movfwd1
        ex de,hl
        ld hl,(movfilpos+0)
        or a
        sbc hl,de
        ex de,hl
        ld hl,(movfilpos+2)
        ld bc,0
        sbc hl,bc
        ex de,hl
        bit 7,d
        jr nz,movbeg
        jr movend1

;### MOVFWD -> Movie 5 Sekunden vorspulen
movfwd  call movexi
        jp z,prgprz0
        call movfwd1
        ld bc,(movfilpos+0)
        add hl,bc
        ex de,hl
        ld hl,(movfilpos+2)
        ld bc,0
        adc hl,bc
        ex de,hl
        jr movend1
movfwd1 ld a,(movinffps)
        ld de,5
        jp clcm16

;### MOVPOS -> Klick auf Positionsleiste
movpos  call movexi
        jp z,prgprz0
        ld hl,(movinflen)
        ld de,(movinflen+2)
        call movsld2        ;BC=movinflen runtergeshiftet, D=anzahl shifts
        push de
        ld l,(iy+4)
        ld h,(iy+5)
        ld de,-42
        add hl,de           ;HL=Xpos auf Slider
        jr c,movpos1
        ld hl,0
movpos1 ex de,hl
        call clcmul         ;A,HL=Xpos*MovLen
        ld c,l
        ld b,h
        ld hl,(prgwindat+8)
        ld de,-84
        add hl,de           ;HL=Xmax
        ex de,hl
        call clcdiv         ;HL=Xpos*Movlen/Xmax
        pop af
        ld e,0
        or a
        jr z,movend1
movpos2 sla l:rl h:rl e
        dec a
        jr nz,movpos2
        jp movend1

;### MOVCTL -> Movie abspielen/anhalten
movctlm db 0                ;0=Pause, 1=Play
movctl  call movexi
        jp z,prgprz0
        ld a,(movctlm)
        or a
        push af
        call z,movctl1
        pop af
        call nz,movctl0
        jp prgprz0
movctl0 ld hl,"-"*256+"-"   ;*** Movie stoppen
        ld (dscfpstxt),hl
        call movsld
        xor a
        ld hl,gfxbutply
        ld de,msgget
        jr movctl2
movctl1 ld hl,(movfilpos)   ;*** Movie starten
        ld de,1
        add hl,de
        ld a,(movfilpos+2)
        adc 0
        ld e,a
        ld a,(movinflen+2)  ;Test, ob Position auf Ende steht
        sub e
        jr nz,movctl3
        ld de,(movinflen)
        sbc hl,de
        call z,movbeg0      ;Ja -> zuerst auf Anfang setzen
movctl3 ld a,1
        ld hl,gfxbutpau
        ld de,msgply
movctl2 ld (movctlm),a
        ld (prgwinobj1+4),hl
        ld (prgprz0+1),de
        ld hl,jmp_mtgcnt:rst #28
        ld (movplys),ix
        call movctl4
        ld e,4
        jp msgsnd0
movctl4 xor a
        ld (movplyk),a
        ld l,a
        ld h,a
        ld (movplyd),hl
        ld (movplyt),hl
        ret

;### MOVDEL -> Aktuellen Movie löschen
movdel  ld a,64                 ;Display löschen
        ld (prgwinobj2+2),a
        ld (prgwinobj2+16+2),a
        xor a
        ld (prgwinobj0+2),a
        ld e,1
        call msgsnd0
        ld a,(movfilhnd)        ;File schließen
        cp -1
        jr z,movdel1
        call syscll
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILCLO
        ld a,-1
        ld (movfilhnd),a
movdel1 ld ix,prgmemtab+0       ;Speicher freigeben
        call movdel2
        ld ix,prgmemtab+5
movdel2 ld a,(ix+0)
        or a
        ret z
        ld l,(ix+1)
        ld h,(ix+2)
        ld c,(ix+3)
        ld b,(ix+4)
        rst #20:dw jmp_memfre
        xor a
        ld (ix+0),a
        ld (ix+3),a
        ld (ix+4),a
        ret

;### MOVCNV -> Aktuelles Movie convertieren
movcnvm dw 0
movcnvz db 0

cmdcnc  jp prgprz0

movcnv  ld de,confrmwin
        jp diainp
movcnvc call diainp4
        call movdel
        jp prgprz0

movcnv0 call diainp4
        xor a
        ld (movcnvz),a
        ld (copmovdat1+1),a
        ld de,copmovwin
        call diainp

        ld ix,0
        ld iy,0
        ld c,2
        ld a,(movfilhnd)
        call sysclx
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILPOI
        ld (movcnvm),iy
        ld ix,512
        ld iy,0
        ld c,0
        ld a,(movfilhnd)
        call sysclx
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILPOI

movcnv7 ld a,1
        ld (movinfenc),a
        ld hl,512
        ld (movcnv4+1),hl
movcnv1 ld ix,-512
        ld iy,-1
        ld c,1
        ld a,(movfilhnd)        ;aktuellen Sektor anfahren
        call sysclx
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILPOI

        ld hl,movcnvz           ;Fortschritt alle 128K anzeigen
        dec (hl)
        jr nz,movcnv5
        db #fd:ld a,h
        db #fd:ld b,l
        ld c,0
        ld de,(movcnvm)
        call clcdiv
        ld a,l
        ld (copmovdat1+1),a
        ld e,2
        ld a,(diawin)
        ld b,a
        ld c,MSC_DSK_WINDIN
        call msgsnd

        ld a,(prgprzn)
        db #dd:ld l,a
        ld a,(dskprzn)
        db #dd:ld h,a
        ld iy,prgmsgb
        rst #18
        or a
        db #dd:dec l            ;Test, ob Cancel gedrückt wurde
        jr nz,movcnv5
        ld hl,(prgmsgb+8)
        ld bc,cmdcnc
        or a
        sbc hl,bc
        jr z,movcnv3

movcnv5 ld a,(movfilhnd)        ;aktuellen Sektor schreiben
        ld de,(prgbnknum)
        ld hl,movinfbeg
movcnv4 ld bc,512
        call sysclx
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILOUT
        ld a,(movfilhnd)        ;nächsten Sektor laden
        ld de,(prgbnknum)
        ld hl,movinfbeg
        ld bc,512
        call sysclx
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILINP
        jr c,movcnv3
        ld a,b
        or c
        jr z,movcnv3
        ld (movcnv4+1),bc
movcnv6 ld b,0                  ;Sektor convertieren
        ld hl,movinfbeg
        ld de,512
movcnv2 ld c,(hl)
        ld a,(bc)
        ld (hl),a
        inc hl
        dec e
        jr nz,movcnv2
        dec d
        jr nz,movcnv2
        jp movcnv1
movcnv3 push af
        call diainp4
        pop af
        ld a,0
        jp c,prgerr
        call movdel
        call movlod
        jp prgprz0

;### MOVSLD -> Slider-Position und Zeit updaten
movsld  ld hl,(movfilpos)           ;*** Slider
        ld de,(movfilpos+2) ;Movielänge auf 16bit heruntershiften
        call movsld2
        push de             ;D=Anzahl Shifts
        ld hl,(prgwindat+8)
        ld de,-84 ;-3
        add hl,de           ;HL=Xmax
        ex de,hl
        call clcmul         ;A,HL=movpos*sldlen
        ld c,l
        ld b,h
        ld h,a              ;jetzt in H,BC
        ld de,(movinflen)
        ld a,(movinflen+2)
        ld l,a
        pop af
        or a
        jr z,movsld4
movsld3 srl l:rr d:rr e
        dec a
        jr nz,movsld3
movsld4 ld a,h
        call clcdiv         ;HL=movpos*sldlen/movlen=sldpos
        ld de,42
        add hl,de
        ld de,(prgwinclc1a)
        ld (prgwinclc1a),hl
        ld (prgwinclc1b+6),hl
        ld iy,prgmsgb
        ld hl,(prgwindat+18)
        ld bc,-28
        add hl,bc
        ld (iy+6),l
        ld (iy+7),h
        ld (iy+8),4
        ld (iy+9),0
        ld (iy+10),6
        ld (iy+11),0
        ex de,hl
        ld de,256*7+256-2
        ld c,MSC_DSK_WINPIN
        call msgsnd2
        ld bc,(movfilpos)           ;*** Zeit
        ld a,(movfilpos+2)
        ld de,(movinffps)
        ld d,0
        call clcdiv         ;HL=Sekunden
        ld c,l
        ld b,h
        ld de,60
        call clcd16         ;HL=Minuten, DE=Rest-Sekunden
        ld c,l
        ld b,h
        ld a,e
        call clcdez
        ld (dsctimtxt+6),hl ;Sekunde eintragen
        ld de,60
        call clcd16         ;HL=Stunden, DE=Rest-Minuten
        ld a,l
        call clcdez
        ld (dsctimtxt+0),hl ;Stunden eintragen
        ld a,e
        call clcdez
        ld (dsctimtxt+3),hl ;Minuten eintragen
        ld de,256*9+256-3
        jp msgsnd0
movsld2 ld a,(movinflen+2)
        ld d,0
        or a
        jr z,movsld5
movsld1 inc d
        srl e:rr h:rr l
        srl a
        jr nz,movsld1
movsld5 ld c,l
        ld b,h              ;BC=geshiftete Moviepos
        ret

;### MOVSHW -> Frame laden und anzeigen
movshw  ld de,(prgmemtab+0) ;Laden
        ld hl,(movfiladr)
        ld bc,(movinfsiz)
        ld a,(movfilhnd)
        call syscll
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILINP
        ;...                        ;*** Error testen und ggf. stoppen
        xor a
        ld (movplyp),a
        call movplym
        ld de,256*14+256-2
        jp msgsnd0

;### MOVPLY -> Einen Frame abspielen
;### Ausgabe    CF=0 Abbruch, CF=1 Ok
movplys dw 0            ;100stel Sekundencounter
movplyd dw 0            ;vergangene 100stel
movplyk db 0            ;Anzahl geskippter Frames pro Sekunde (real_fps=orig_fps-x)
movplyt dw 0            ;abgelaufene 100stel
movplyp db 0            ;flip-flag
movply  ld a,(prgwindat+4)
        add 2
        and 7
        jr z,movply0
        ld de,(prgwindat+4)         ;*** Fensterposition optimieren
        ld hl,(prgwindat+6)
        inc de
        inc de
        ld a,e
        and #f8
        ld e,a
        dec de
        dec de
        ld c,MSC_DSK_WINMOV
        call msgsnd2
movply0 ld a,(movplyd+1)
        rla
        jr nc,movply7
        call movply8                ;*** Warten
        ld (movplyd),hl
        bit 7,h
        jr z,movply7
        rst #30
        scf
        ret
movply7 ld iy,prgmsgb               ;*** aktuellen Frame anzeigen
        ld (iy+0),MSC_DSK_WINDIN
        ld a,(prgwin)
        ld (iy+1),a
        ld (iy+2),-2
        ld (iy+3),14
        ld a,(prgprzn)
        db #dd:ld l,a
        ld a,(dskprzn)
        db #dd:ld h,a
        rst #10
        ld a,(movfilhnd)            ;*** neuen Frame laden
        ld (prgmsgb+03),a
        ld hl,movplyp
        inc (hl)
        bit 0,(hl)
        jr nz,movplyh
        ld a,(prgmemtab+0)
        ld hl,(movfiladr)
        jr movplyi
movplyh ld a,(prgmemtab+5)
        ld hl,(movfiladr+2)
movplyi ld (prgmsgb+06),a
        ld (prgmsgb+08),hl
        ld hl,(movinfsiz)
        ld (prgmsgb+04),hl
        ld hl,FNC_FIL_FILINP*256+MSC_SYS_SYSFIL
        ld (prgmsgb+00),hl
        ld iy,prgmsgb
        ld a,(prgprzn)      ;App- und System-Prozessnummer holen
        db #dd:ld l,a
        ld a,(sysprzn)
        db #dd:ld h,a
        rst #10             ;Message senden
        ld a,5
        ld (syscllt),a
movply1 di:exx:inc e:exx    ;keine niedrigeren Prios zulassen
        rst #30
        ld iy,prgmsgb
        ld a,(prgprzn)
        db #dd:ld l,a
        ld a,(sysprzn)
        db #dd:ld h,a
        rst #18             ;auf Antwort warten
        db #dd:dec l
        scf
        ld a,-1
        jr nz,movplyc       ;keine Message vorhanden -> Fehler
        ld a,(prgmsgb)
        cp 128+MSC_SYS_SYSFIL
        jr z,movplye
        call syscll3
        jr nz,movply1
        scf
        ld a,-1
        jr movplyc
movplye ld hl,(prgmsgb+02)  ;Register aus Message-Buffer holen
        push hl
        pop af
movplyc ;...                        ;*** Error testen und ggf. stoppen
        call movplym        ;flipping
        call movply8                ;*** Timing ggf. korrigieren
        ld bc,1
        ld a,(optflgskp)
        dec a
        jr z,movply9
        ld a,(movfilfps)
        ld c,a
        ld b,0
        or a
        sbc hl,bc
        bit 7,h
        jr z,movply2
        ld (movplyd),hl             ;*** Zu schnell -> Warten
        ld c,1
        jr movply9
movply2 inc h:dec h
        jr z,movply4
        ld hl,255           ;L=Verzögerung
movply4 dec a
        cp l
        jr c,movply5
        ld (movplyd),hl             ;*** Timing korrekt
        ld c,1
        jr movply9
movply5 inc a                       ;*** Zu langsam -> Frame(s) überspringen
        ld b,a              ;B=zeit pro frame
        ld de,(movinfsiz)   ;DE=framegröße in bytes
        ld ix,0
        ld h,0              ;H,IX=versatz
        ld c,1              ;C=Anzahl abgespielter + geskipter Frames
movply6 add ix,de
        ld a,h
        adc 0
        ld h,a
        inc c
        ld a,l
        sub b
        jr c,movplya
        ld l,a
        cp b
        jr nc,movply6       ;H,IX=Versatz, C=Anzahl Frames
movplya ld a,(movplyk)
        add c
        dec a
        ld (movplyk),a
        ld a,h
        db #fd:ld l,a
        db #fd:ld h,0
        ld h,0
        ld (movplyd),hl     ;korrigierte Verzögerung eintragen
        ld b,h
        push bc
        ld a,(movfilhnd)
        ld c,1
        call syscll         ;Filepointer vorschieben
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILPOI
        pop bc
movply9 ld hl,(movfilpos+0)         ;*** Framecounter hochzählen und auf Ende testen
        add hl,bc
        ld a,(movfilpos+2)
        adc 0
        ld e,a
        call movset0
        jr nc,movply3
        ld a,(optflglop)
        or a
        jr nz,movplyf
        call movctl0
        or a
        ret
movplyf call movbeg0
movply3 ld hl,(movplyt)             ;*** pro Sekunde Positionsanzeige updaten
        ld bc,100
        or a
        sbc hl,bc
        ret c
        ld (movplyt),hl
        ld hl,movplyk
        ld a,(movinffps)
        sub (hl)
        ld (hl),0
        jr nc,movplyb
        xor a
movplyb call clcdez
        ld a,(optflgskp)
        or a
        jr z,movplyg
        ld hl,"-"*256+"-"
movplyg ld (dscfpstxt),hl
        call movsld
        scf
        ret
movply8 ld hl,jmp_mtgcnt:rst #28    ;*** verbleibende Verzögerung holen
        db #dd:ld e,l
        db #dd:ld d,h       ;DE=neuer Systemcounter
        ld hl,(movplys)
        ex de,hl
        ld (movplys),hl
        or a
        sbc hl,de           ;HL=Anzahl vergangener 100stel Sekunden
        ex de,hl
        ld hl,(movplyt)
        add hl,de
        ld (movplyt),hl
        ex de,hl
        ld de,(movplyd)
        add hl,de           ;HL=verbleibende Verzögerung -> 0 <= HL < movfilfps
        ret

movplym ld a,(movplyp)              ;*** Frameflipping
        rra
        jr c,movplyj
        ld a,(prgmemtab+0)
        ld hl,(movfilhd1)
        jr movplyl
movplyj ld a,(prgmemtab+5)
        ld hl,(movfilhd1+2)
movplyl ld (prgwinobj2+3),a
        ld (prgwinobj2+4),hl
        ret


;==============================================================================
;### DATEN-TEIL ###############################################################
;==============================================================================

prgdatbeg

prgicn16c db 12,24,24:dw $+7:dw $+4,12*24:db 5
db #88,#88,#88,#88,#8F,#FF,#99,#98,#88,#88,#88,#88,#88,#88,#88,#8F,#FF,#FF,#99,#99,#98,#88,#88,#88,#88,#88,#8F,#FF,#FF,#FF,#99,#99,#99,#98,#88,#88,#88,#88,#FF,#FF,#FF,#FF,#99,#99,#99,#99,#88,#88
db #88,#8F,#FF,#FF,#F4,#44,#44,#44,#99,#99,#98,#88,#88,#FF,#FF,#F4,#44,#44,#44,#44,#49,#99,#99,#88,#88,#FF,#FF,#44,#44,#44,#44,#44,#44,#99,#99,#88,#8F,#FF,#F4,#44,#55,#44,#44,#44,#44,#49,#99,#98
db #8F,#FF,#F4,#44,#55,#55,#44,#44,#44,#44,#99,#98,#FF,#FF,#44,#44,#55,#55,#55,#44,#44,#44,#99,#99,#FF,#FF,#44,#44,#55,#55,#55,#55,#44,#44,#99,#99,#FF,#FF,#44,#44,#55,#55,#55,#55,#55,#44,#99,#99
db #77,#77,#44,#44,#55,#55,#55,#55,#55,#44,#22,#22,#77,#77,#44,#44,#55,#55,#55,#55,#44,#44,#22,#22,#77,#77,#44,#44,#55,#55,#55,#44,#44,#44,#22,#22,#87,#77,#74,#44,#55,#55,#44,#44,#44,#42,#22,#28
db #87,#77,#74,#44,#55,#44,#44,#44,#44,#42,#22,#28,#88,#77,#77,#44,#44,#44,#44,#44,#44,#22,#22,#88,#88,#77,#77,#74,#44,#44,#44,#44,#42,#22,#22,#88,#88,#87,#77,#77,#74,#44,#44,#42,#22,#22,#28,#88
db #88,#88,#77,#77,#77,#77,#22,#22,#22,#22,#88,#88,#88,#88,#87,#77,#77,#77,#22,#22,#22,#28,#88,#88,#88,#88,#88,#87,#77,#77,#22,#22,#28,#88,#88,#88,#88,#88,#88,#88,#87,#77,#22,#28,#88,#88,#88,#88

gfxcnvtab
dw gfxbutbeg0,gfxbutbeg+9:db 8,16,16,16*4
dw gfxbutrew0,gfxbutrew+9:db 8,16,16,16*4
dw gfxbutply0,gfxbutply+9:db 8,16,16,16*4
dw gfxbutpau0,gfxbutpau+9:db 8,16,16,16*4
dw gfxbutfwd0,gfxbutfwd+9:db 8,16,16,16*4
dw gfxbutend0,gfxbutend+9:db 8,16,16,16*4
dw gfxfrmlft0,gfxfrmlft+9:db 16,32,16,16*8
dw gfxfrmrgt0,gfxfrmrgt+9:db 16,32,16,16*8
dw 0

;### Steuer-Buttons
gfxbutbeg db 4,16,16:dw gfxbutbeg+10,gfxbutbeg+9,4*16:db 0:ds 4*16
gfxbutbeg0
db #0F,#1E,#E1,#0F,#0F,#79,#FE,#87,#0F,#F7,#FF,#CB,#1E,#FF,#FF,#ED,#1E,#FC,#F6,#E5,#3D,#EC,#E4,#F6,#3D,#EC,#C0,#F6,#3D,#EC,#C0,#F6
db #3D,#EC,#E4,#F6,#1E,#FC,#F6,#E5,#1E,#FF,#FF,#ED,#0F,#F7,#FF,#CB,#0F,#79,#FE,#87,#0F,#1E,#E1,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F

gfxbutrew db 4,16,16:dw gfxbutrew+10,gfxbutrew+9,4*16:db 0:ds 4*16
gfxbutrew0
db #0F,#78,#E1,#0F,#1E,#F7,#FE,#87,#3D,#FF,#FF,#CB,#7B,#FF,#FF,#ED,#7B,#FC,#FC,#ED,#F7,#D8,#D8,#FE,#F7,#90,#90,#FE,#F6,#10,#10,#FE
db #F6,#10,#10,#FE,#F7,#90,#90,#FE,#F7,#D8,#D8,#FE,#7B,#FC,#FC,#ED,#7B,#FF,#FF,#ED,#3D,#FF,#FF,#CB,#1E,#F7,#FE,#87,#0F,#78,#E1,#0F

gfxbutply db 4,16,16:dw gfxbutply+10,gfxbutply+9,4*16:db 0:ds 4*16
gfxbutply0
db #0F,#78,#E1,#0F,#1E,#F7,#FE,#87,#3D,#FF,#FF,#CB,#7B,#FF,#FF,#ED,#7B,#F1,#FF,#ED,#F7,#90,#F7,#FE,#F7,#80,#71,#FE,#F7,#80,#10,#FE
db #F7,#80,#10,#FE,#F7,#80,#71,#FE,#F7,#90,#F7,#FE,#7B,#F1,#FF,#ED,#7B,#FF,#FF,#ED,#3D,#FF,#FF,#CB,#1E,#F7,#FE,#87,#0F,#78,#E1,#0F

gfxbutpau db 4,16,16:dw gfxbutpau+10,gfxbutpau+9,4*16:db 0:ds 4*16
gfxbutpau0
db #0F,#78,#E1,#0F,#1E,#F7,#FE,#87,#3D,#FF,#FF,#CB,#7B,#FF,#FF,#ED,#7B,#F0,#F0,#ED,#F7,#90,#90,#FE,#F7,#90,#90,#FE,#F7,#90,#90,#FE
db #F7,#90,#90,#FE,#F7,#90,#90,#FE,#F7,#90,#90,#FE,#7B,#F0,#F0,#ED,#7B,#FF,#FF,#ED,#3D,#FF,#FF,#CB,#1E,#F7,#FE,#87,#0F,#78,#E1,#0F

gfxbutfwd db 4,16,16:dw gfxbutfwd+10,gfxbutfwd+9,4*16:db 0:ds 4*16
gfxbutfwd0
db #0F,#78,#E1,#0F,#1E,#F7,#FE,#87,#3D,#FF,#FF,#CB,#7B,#FF,#FF,#ED,#7B,#F3,#F3,#ED,#F7,#B1,#B1,#FE,#F7,#90,#90,#FE,#F7,#80,#80,#F6
db #F7,#80,#80,#F6,#F7,#90,#90,#FE,#F7,#B1,#B1,#FE,#7B,#F3,#F3,#ED,#7B,#FF,#FF,#ED,#3D,#FF,#FF,#CB,#1E,#F7,#FE,#87,#0F,#78,#E1,#0F

gfxbutend db 4,16,16:dw gfxbutend+10,gfxbutend+9,4*16:db 0:ds 4*16
gfxbutend0
db #0F,#78,#87,#0F,#1E,#F7,#E9,#0F,#3D,#FF,#FE,#0F,#7B,#FF,#FF,#87,#7A,#F6,#F3,#87,#F6,#72,#73,#CB,#F6,#30,#73,#CB,#F6,#30,#73,#CB
db #F6,#72,#73,#CB,#7A,#F6,#F3,#87,#7B,#FF,#FF,#87,#3D,#FF,#FE,#0F,#1E,#F7,#E9,#0F,#0F,#78,#87,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F

gfxfrmlft db 8,32,16:dw gfxfrmlft+10,gfxfrmlft+9,8*16:db 0:ds 8*16
gfxfrmlft0
db #87,#0F,#0F,#0F,#0F,#1E,#C3,#0F
db #87,#0F,#0F,#0F,#0F,#79,#FC,#0F
db #CB,#0F,#0F,#0F,#0F,#F4,#F1,#87
db #ED,#0F,#0F,#0F,#0F,#E4,#31,#87
db #FE,#0F,#0F,#0F,#1E,#FC,#71,#CB
db #FF,#87,#0F,#0F,#1E,#FE,#73,#CB
db #FF,#E9,#0F,#0F,#1E,#FC,#71,#CB
db #FF,#FE,#87,#0F,#0F,#E4,#31,#87
db #FF,#FF,#E9,#0F,#0F,#F4,#F1,#87
db #FF,#FF,#FE,#87,#0F,#79,#FC,#0F
db #FF,#FF,#FF,#F8,#0F,#1E,#C3,#0F
db #FF,#FF,#FF,#FF,#F0,#0F,#0F,#0F
db #FF,#FF,#FF,#FF,#FF,#F0,#0F,#0F
db #FF,#FF,#FF,#FF,#FF,#FF,#F0,#0F
db #FF,#FF,#FF,#FF,#FF,#FF,#FF,#F0
db #FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF

gfxfrmrgt db 8,32,16:dw gfxfrmrgt+10,gfxfrmrgt+9,8*16:db 0:ds 8*16
gfxfrmrgt0
db #0F,#3C,#87,#0F,#0F,#0F,#0F,#1E
db #0F,#F3,#E9,#0F,#0F,#0F,#0F,#1E
db #1E,#FE,#FE,#0F,#0F,#0F,#0F,#3D
db #1E,#EC,#F6,#0F,#0F,#0F,#0F,#7B
db #3D,#C8,#73,#87,#0F,#0F,#0F,#F7
db #3D,#F8,#F3,#87,#0F,#0F,#1E,#FF
db #3D,#C8,#73,#87,#0F,#0F,#79,#FF
db #1E,#F8,#F2,#0F,#0F,#1E,#F7,#FF
db #1E,#FF,#FE,#0F,#0F,#79,#FF,#FF
db #0F,#F3,#E9,#0F,#1E,#F7,#FF,#FF
db #0F,#3C,#87,#0F,#F1,#FF,#FF,#FF
db #0F,#0F,#0F,#F0,#FF,#FF,#FF,#FF
db #0F,#0F,#F0,#FF,#FF,#FF,#FF,#FF
db #0F,#F0,#FF,#FF,#FF,#FF,#FF,#FF
db #F0,#FF,#FF,#FF,#FF,#FF,#FF,#FF
db #FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF

;### Info
prgmsginf1  db "SymPlay 1.3 (Build 140908pdt)",0
prgmsginf2  db " Copyright <c> 2014 SymbiosiS",0
prgmsginf3  db " Many thanx to TrebMint!",0

;### Hauptfenster
prgwintit   db "SymPlay - "
prgwintit1  db "[no movie loaded]":ds 256-17
dsctimtxt   db "00:00:00 ",0
dscfpstxt   db "-- fps ",0

;### Options
prgtitopt   db "Options",0
prgbutabo   db "About",0
prgbuthlp   db "Help",0
prgbutoky   db "Close",0
prgtxtyes   db "Yes",0
prgtxtno    db "No",0
prgtxtcnc   db "Cancel",0

movtxttit   db "Movie information",0
movtxttit0  ds 64
movtxtsrc   db "Source:",0
movtxtfrm   db "Format:",0
movtxtfrm0  db "SymbOS video (VID)",0
movtxtfps   db "FPS:",0
movtxtfps0  db "00",0
movtxtfil   db "File size:",0
movtxtfil0  ds 16
movtxtrat   db "Data rate:",0
movtxtrat0  ds 16
movtxtlen   db "Duration:",0
movtxtlen0  db "00:00:00",0
movtxtsiz   db "Frame size:",0
movtxtsiz0  ds 32
movtxtnul   db "-",0
movtxtnon   db "[no movie loaded]"
movtxtnon0  db 0

opttxttit   db "Settings",0
opttxtlop   db "Loop",0
opttxtskp   db "Don't skip frames",0

confrmtxt1  db "This video is "
confrmtxt1a db "CPC encoded and can't",0
confrmtxt2  db "be played. Do you want to convert it?",0
copmovtxt1  db "Converting video file...",0

;### Error Messages
prgmsgerr00 db "A disc error occured",0
prgmsgerr01 db "Unknown file format",0
prgmsgerr02 db "Unsupported video stream",0
prgmsgerr03 db "Not enough memory",0
prgmsgerr04 db "No CPC 16colour support",0

prgmsgerr1  db "Can't load movie file:"
prgmsgerr0  db 0


;==============================================================================
;### TRANSFER-TEIL ############################################################
;==============================================================================

prgtrnbeg
;### PRGPRZS -> Stack für Programm-Prozess
        ds 128
prgstk  ds 6*2
        dw prgprz
prgprzn db 0
prgmsgb ds 14

;*** Verschiedenes

movsrc  db "vid",0
movsrc1 ds 256

;### INFO-FENSTER #############################################################

prgmsginf  dw prgmsginf1,4*1+2,prgmsginf2,4*1+2,prgmsginf3,4*1+2,prgicnbig

;### ERROR-FENSTER ############################################################

prgmsgerr  dw prgmsgerr1,4*1+2
prgmsgerra dw prgmsgerr0,4*1+2,prgmsgerr0,4*1+2

;### CONVERT-CONFIRM FENSTER ##################################################

confrmwin   dw #1401,4+16,079,062,160,46,0,0,160,46,160,46,160,46,0,prgwintit,0,0,confrmgrp,0,0:ds 136+14
confrmgrp   db 5,0:dw confrmdat,0,0,256*5+4,0,0,00
confrmdat
dw      00,         0,2,        0,0,1000,1000,0         ;00=Hintergrund
dw      00,255*256+ 1,confrmdsc1,05,05,150, 8,0         ;01=Beschreibung1
dw      00,255*256+ 1,confrmdsc2,05,15,150, 8,0         ;02=Beschreibung2
dw movcnv0,255*256+16,prgtxtyes, 31,29, 48,12,0         ;03="Yes"-Button
dw movcnvc,255*256+16,prgtxtno , 81,29, 48,12,0         ;04="No" -Button

confrmdsc1  dw confrmtxt1,2+4
confrmdsc2  dw confrmtxt2,2+4

;### CONVERT-PROGRESS FENSTER #################################################

copmovwin   dw #1401,4+16,079,070,160,44,0,0,160,44,160,44,160,44,0,prgwintit,0,0,copmovgrp,0,0:ds 136+14
copmovgrp   db 4,0:dw copmovdat,0,0,256*4+0,0,0,00
copmovdat
dw      00,         0,2,         0,0,1000,1000,0        ;00=Hintergrund
dw      00,255*256+ 1,copmovdsc1, 05,03,150, 8,0        ;01=Beschreibung
dw      00,255*256+ 4
copmovdat1 dw     256*000+1+4+48, 05,14,150,10,0        ;02=Fortschrittsbalken
dw cmdcnc ,255*256+16,prgtxtcnc,  56,28, 48,12,0        ;03="Cancel"-Button

copmovdsc1  dw copmovtxt1,2+4+512

;### HAUPT-FENSTER ############################################################

prgwindat dw #1501,03,62,01,190,173,0,0,190,173,100,40,1000,1000,prgicnsml,prgwintit,0,0,prgwingrp,0,0:ds 136+14

prgwingrp db 17,0:dw prgwinobj,prgwinclc,0,256*00+00,0,0,00
prgwinobj
dw     00,255*256+00,2         ,0,0,0,0,0   ;00=Hintergrund
prgwinobj0
dw     00,255*256+00,1         ,0,0,0,0,0   ;01=leere Anzeige
dw movbeg,255*256+10,gfxbutbeg ,0,0,0,0,0   ;02=Button Anfang
dw movrew,255*256+10,gfxbutrew ,0,0,0,0,0   ;03=Button Zurück
prgwinobj1
dw movctl,255*256+10,gfxbutply ,0,0,0,0,0   ;04=Button Play/Pause
dw movfwd,255*256+10,gfxbutfwd ,0,0,0,0,0   ;05=Button Vorwärts
dw movend,255*256+10,gfxbutend ,0,0,0,0,0   ;06=Button Ende
dw     00,255*256+02,1+12+0+64 ,0,0,0,0,0   ;07=Rahmen Positionsanzeige
dw movpos,255*256+02,1+4+64+32 ,0,0,0,0,0   ;08=Positionsleiste
prgwinclc1b
dw     00,255*256+02,48+1+4+64 ,0,0,0,0,0   ;09=Slider
dw     00,255*256+01,dsctimobj ,0,0,0,0,0   ;10=Zeitanzeige
dw     00,255*256+01,dscfpsobj ,0,0,0,0,0   ;11=FPS-Anzeige
dw optopn,255*256+10,gfxfrmlft ,0,0,0,0,0   ;12=Rahmen links + Infobutton
dw movopn,255*256+10,gfxfrmrgt ,0,0,0,0,0   ;13=Rahmen rechts+ Openbutton
prgwinobj2
dw     00,255*256+64,0000      ,0,0,0,0,0   ;14=Movie1
dw     00,255*256+64,0000      ,0,0,0,0,0   ;15=Movie2
dw     00,255*256+02,1+4       ,0,0,0,0,0   ;16=Strich unten

prgwinclc
dw 0,0,0,0,1000,0,1000,0
dw 1,0,1,0, 188,0, 141,0
dw -48,256*2+1,-18,256*1+1,16,0,16,0
dw -28,256*2+1,-18,256*1+1,16,0,16,0
dw -08,256*2+1,-18,256*1+1,16,0,16,0
dw  12,256*2+1,-18,256*1+1,16,0,16,0
dw  32,256*2+1,-18,256*1+1,16,0,16,0
dw  01,0      ,-30,256*1+1,-2,256*1+1,10,0
dw  42,0      ,-27,256*1+1,-84,256*1+1,4,0
prgwinclc1a
dw  42,0      ,-28,256*1+1,4,0,6,0
dw  04,0      ,-29,256*1+1,36,0,8,0
dw -30,256*1+1,-29,256*1+1,36,0,8,0
dw  00,256*1+0,-16,256*1+1,32,0,16,0
dw -32,256*1+1,-16,256*1+1,32,0,16,0
dw 001,0,1,0, 1,0, 1,0
dw 253,0,1,0, 1,0, 1,0
dw  32,0      ,-01,256*1+1,-64,256*1+1,1,0

dsctimobj dw dsctimtxt,4
dscfpsobj dw dscfpstxt,4

;### OPTIONS ##################################################################

prgwinopt   dw #1501,4+16,96,15,160,151,0,0,160,151,160,151,160,151, prgicnsml,prgtitopt,0,0,prggrpopt,0,0:ds 136+14
prggrpopt   db 25,0:dw prgdatopt,0,0,256*4+4,0,0,0
prgdatopt
dw 00,     255*256+0, 2,0,0,1000,1000,0                 ;00=Hintergrund
dw prginf, 255*256+16,prgbutabo,   31,136, 40,12,0      ;01=Button "About"
dw hlpopn, 255*256+16,prgbuthlp,   74,136, 40,12,0      ;02=Button "Help"
dw diainpc,255*256+16,prgbutoky,  117,136, 40,12,0      ;03=Button "Close"
dw 00,     255*256+3, prgobjopt1,   0,  1,160,110,0     ;04=Rahmen Movie Infos
dw 00,     255*256+1, prgobjopt2,   8, 13,144,  8,0     ;05=Name
dw 00,     255*256+1, prgobjopt3,   8, 23,144,  8,0     ;06=Zusatz
dw 00,     255*256+0, 1,            8, 33,144,  1,0     ;07=Linie
dw 00,     255*256+1, prgobjopt4,   8, 36, 48,  8,0     ;08=Source Text
dw 00,     255*256+1, prgobjopt40, 60, 36, 92,  8,0     ;09=Source Info
dw 00,     255*256+1, prgobjopt5,   8, 46, 48,  8,0     ;10=Format Text
dw 00,     255*256+1, prgobjopt50, 60, 46, 92,  8,0     ;11=Format Info
dw 00,     255*256+1, prgobjopt6,   8, 56, 48,  8,0     ;12=FPS Text
dw 00,     255*256+1, prgobjopt60, 60, 56, 92,  8,0     ;13=FPS Info
dw 00,     255*256+1, prgobjopt7,   8, 66, 48,  8,0     ;14=File size Text
dw 00,     255*256+1, prgobjopt70, 60, 66, 92,  8,0     ;15=File size Info
dw 00,     255*256+1, prgobjopt8,   8, 76, 48,  8,0     ;16=Data rate Text
dw 00,     255*256+1, prgobjopt80, 60, 76, 92,  8,0     ;17=Data rate Info
dw 00,     255*256+1, prgobjopt9,   8, 86, 48,  8,0     ;18=Length Text
dw 00,     255*256+1, prgobjopt90, 60, 86, 92,  8,0     ;19=Length Info
dw 00,     255*256+1, prgobjopta,   8, 96, 48,  8,0     ;20=Frame size Text
dw 00,     255*256+1, prgobjopta0, 60, 96, 92,  8,0     ;21=Frame size Info
dw 00,     255*256+3, prgobjoptb,   0,111,160, 24,0     ;22=Rahmen Settings
dw 00,     255*256+17,prgobjoptc,   8,120, 48,  8,0     ;23=Loop
dw 00,     255*256+17,prgobjoptd,  60,120, 92,  8,0     ;24=Skip Frames

prgobjopt2  dw movtxttit0+00,2+4+512
prgobjopt1  dw movtxttit,2+4
prgobjopt3  dw movtxttit0+32,2+4+512
prgobjopt4  dw movtxtsrc,2+4+256
prgobjopt40 dw movsrc1,2+4+128
prgobjopt5  dw movtxtfrm,2+4+256
prgobjopt50 dw movtxtfrm0,2+4
prgobjopt6  dw movtxtfps,2+4+256
prgobjopt60 dw movtxtfps0,2+4
prgobjopt7  dw movtxtfil,2+4+256
prgobjopt70 dw movtxtfil0,2+4
prgobjopt8  dw movtxtrat,2+4+256
prgobjopt80 dw movtxtrat0,2+4
prgobjopt9  dw movtxtlen,2+4+256
prgobjopt90 dw movtxtlen0,2+4
prgobjopta  dw movtxtsiz,2+4+256
prgobjopta0 dw movtxtsiz0,2+4

prgobjoptb  dw opttxttit,2+4
prgobjoptc  dw optflglop,opttxtlop,2+4
optflglop   db 1
prgobjoptd  dw optflgskp,opttxtskp,2+4
optflgskp   db 0

cfgcpctyp   db 0

prgtrnend

relocate_table
relocate_end

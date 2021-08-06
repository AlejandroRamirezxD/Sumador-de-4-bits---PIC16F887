 ; Archivo    :	  MainDeFinalDeLab1.s  
 ; Dispositivo:	  PIC16F887
 ; Autor      :	  Alejandro Ramírez
 ; Compilador :	  MPLAB V5.4
 ; Programa   :	  Dos contadores independientes,con opción a suma de sus valores
 ; Hardware   :	  5 push bottons y 13 leds.

 ; Última modificación: 5 de agosto del 2021
  
 PROCESSOR 16F887
 #include <xc.inc>
 
 ; Configuración de pines
 CONFIG FOSC=INTRC_NOCLKOUT	// Oscillador Interno sin salidas
 CONFIG WDTE=OFF    // WDT disabled 
 CONFIG PWRTE=ON    // PWRT enabled 
 CONFIG MCLRE=OFF   // El pin de MCLR se utiliza como I/O
 CONFIG CP=OFF	    // Sin protección de código
 CONFIG CPD=OFF	    // Sin protección de datos

 CONFIG BOREN=OFF   // Sin reinicio cuando el voltaje de alimentación baja de 4V
 CONFIG IESO=OFF    // Reinicio sin cambio de reloj de interno a externo
 CONFIG FCMEN=OFF   // Cambio de reloj externo a interno en caso de fallo
 CONFIG LVP=ON	    // programación en bajo voltaje permitida

 CONFIG WRT=OFF	    // Protección de autoescritura por el programa desactivada
 CONFIG BOR4V=BOR40V// Reinicio abajo de 4V, (BOR21V=2.1V)
 
 ;Varaible cont con 2 byts
 PSECT udata_bank0 ;
    cont:	DS  2
    
 PSECT resVect, class=CODE, abs, delta=2
 
 ;--------------VECTOR RESET--------------
 ORG 00h	;	Zona 0000h para el vector reset
 resetVec:
     PAGESEL main
     goto main
 
 ;  Inicio del código
 PSECT code, delta=2, abs
 ORG 100h	

 ;-------------CONFIGURACIÓN--------------
 main:
    call    config_io
    call    config_reloj
    banksel PORTA   ;	
  
 ;-----------LOOP--------------
 loop:
    btfsc   PORTB, 0	
    call    inc_porta	;   Cuando RB0 sea 1, incrementar el puerto A
    
    btfsc   PORTB, 1
    call    dec_porta	;   Cuando RB1 sea 1, decrecer el puerto A
    
    btfsc   PORTB, 2
    call    inc_portc	;   Cuando RB2 sea 1, incrementar el puerto C
    
    btfsc   PORTB,  3
    call    dec_portc	;   Cuando RB3 sea 1, decrecer el puerto C
    
    
    btfss   PORTB, 4
    call    sumaAyC	;   Cuando RB4 sea 0, sumar los valores de A y C
    
    goto    loop		   
    
 ;-----------SUB RUTINAS--------------
 inc_porta:
    ;	Antirrebote de RB0
    call    delay_small	  
    btfsc   PORTB, 0	  
    goto    $-1
    
    ;	Si es 0 el RB0 incrementar PORTA
    incf    PORTA
    
    ;	Cuando el 5to. bit del PORTA sea 1 setear PORTA como 0000
    btfsc   PORTA, 4
    clrf    PORTA
    return
 
 dec_porta:
    ;	Antirrebote de RB1
    call    delay_small
    btfsc   PORTB, 1
    goto    $-1
    
    ;	Si es 0 el RB1 decrecer PORTA
    decf    PORTA
    
    ;	Cuando el 5to. bit del PORTA sea 1 setear PORTA como 0000
    btfsc   PORTA,4
    call    Maximo_Val_A
    return
    
  inc_portc:
    ;	Antirrebote de RB2
    call    delay_small
    btfsc   PORTB, 2
    goto    $-1
    
    ;	Si es 0 el RB2 incrementar PORTC
    incf    PORTC
    
    ;	Cuando el 5to. bit del PORTC sea 1 setear PORTC como 0000
    btfsc   PORTC, 4
    clrf    PORTC
    return
    
  dec_portc:
    ;	Antirrebote de RB3
    call    delay_small
    btfsc   PORTB, 3
    goto    $-1
    
    ;	Si es 0 el RB3 decrecer PORTC	
    decf    PORTC
    
    ;	Cuando el 5to. bit del PORTC sea 1 setear PORTC como 0000
    btfsc   PORTC,4
    call    Maximo_Val_C
    return
 
 ;  Sumar los valores del puerto A y C
 sumaAyC:
    call    delay_small
    btfss   PORTB, 4	;   Antirregote - btfss pues el botón de suma es PULL UP
    goto    $-1		
    
    Movf	PORTA,w	;   Copiar los valores del puerto A a w    
    addwf	PORTC,w	;   Sumar los valores del puerto c a w
    Movwf	PORTD	;   Mover los valores de w al puerto D
    return
  
  ; Setear el valor máximo del puerto A de 4bits
  Maximo_Val_A:
    clrf    PORTA
    bsf	    PORTA, 0
    bsf	    PORTA, 1
    bsf	    PORTA, 2
    bsf	    PORTA, 3
    return  
 
  ; Setear el valor máximo del puerto C de 4bits
  Maximo_Val_C:
    clrf    PORTC
    bsf	    PORTC, 0
    bsf	    PORTC, 1
    bsf	    PORTC, 2
    bsf	    PORTC, 3
    return
 
  ; Configuración de los registros
  config_io:  
    banksel ANSEL   ;	Abrir registros	
    banksel ANSELH  
    
    clrf    ANSEL   ;	Limpiar los registros
    clrf    ANSELH  ;	P.Digitales
    
    banksel TRISA   ;	Abrir registros
    banksel TRISC   
    banksel TRISD
    
    clrf    TRISA   ;	Port A - salida
    clrf    TRISC   ;	Port C - salida
    clrf    TRISD   ;	Port D - salida
    
    banksel PORTA   ;	Abrir registros
    banksel PORTC
    banksel PORTD
    
    clrf    PORTA   ;	Iniciar con los puertos en 0	
    clrf    PORTC   ;
    clrf    PORTD   ;
                       
    bsf	    TRISB, 0	;	Rb0 declarada como entradas
    bsf	    TRISB, 1	;	Rb1 declarada como entradas
    bsf	    TRISB, 2	;	Rb2 declarada como entradas
    bsf	    TRISB, 3	;	Rb3 declarada como entradas
    bsf	    TRISB, 4	;	Rb4 declarada como entradas
    
    return
    
    ;	Setear reloj a 1MHz
config_reloj:
    banksel OSCCON
    bsf	    IRCF2	    ; OSCCON, bit 6
    bcf	    IRCF1	    ; OSCCON, bit 5
    bcf	    IRCF0	    ; OSCCON, bit 4
    bsf	    SCS		    ; OSCCON, bit 0
    return
    
    ;	Delay grande
 delay_big:
    movlw   50		    ; Valor inicial del contador en w
    movwf   cont+1	    ; Mover el valor de w un file arriba de cont
    call    delay_small	    ; Rutina de delay small
    decfsz  cont+1, 1	    ; Decrementar el contador
    goto    $-2		    ; Ejecutar dos líneas atrás
    return
    
    ;	Delay pequeño
 delay_small:
    movlw   150		    ; Valor inicial del contador
    movwf   cont	    ; Mover el valor de w a cont
    decfsz  cont, 1	    ; Decrementar el contador
    goto    $-1		    ; Ejecutar línea anterior
    return
    
 END








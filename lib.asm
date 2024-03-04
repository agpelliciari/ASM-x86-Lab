extern malloc
extern free
extern intClone
extern intCmp
extern intDelete
extern listDelete
extern fprintf
extern intPrint
extern listPrint
extern listNew
extern listAddFirst
extern getCloneFunction
extern getDeleteFunction
extern getPrintFunction
extern listClone

ptrNulo db 'NULL', 0
guion db '-', 0

global strClone
global strPrint
global strCmp
global strLen
global strDelete

%define SIZE_ARRAY 16
%define OFFSET_TYPE 0
%define OFFSET_SIZE 4
%define OFFSET_CAPACITY 5
%define OFFSET_PTR_DATA 6

global arrayNew
global arrayDelete
global arrayPrint
global arrayGetSize
global arrayAddLast
global arrayGet
global arrayRemove
global arraySwap

%define SIZE_CARD 24
%define SIZE_PTR 8
%define OFFSET_SUIT 0
%define OFFSET_NUMBER 8
%define OFFSET_CARD_STACK 16

llaveAbierta db '{', 0
llaveCerrada db '}', 0

corcheteAbierto db '[', 0
corcheteCerrado db ']', 0
coma db ',', 0

global cardCmp
global cardClone
global cardAddStacked
global cardDelete
global cardGetSuit
global cardGetNumber
global cardGetStacked
global cardPrint
global cardNew

section .text

; ** String **

; char* strClone(char* a)
;  rax             rdi
strClone:                           
     push rbp                          ; pila alineada
     mov rbp, rsp

     push r12                          ; pila desalineada
     push r13                          ; pila alineada
     push rbx                          ; pila desalineada

     sub rsp, 8                        ; pila alineada

     mov r12, rdi                      ; guardo rdi en el registro r12
     mov rdi, r12
     call strLen                       ; se obtiene la longitud de la cadena y se almacena en rax 

     inc rax                           ; rax = longitud de cadena + lugar para el '/0'
     mov r13, rax                      ; guardo longitud de cadena en r13

     mov rdi, r13                      ; rdi = r13 ya que es el que utiliza malloc(rdi)
     call malloc                       ; se obtiene el ptr necesario para guardar el puntero pasado por referencia y se almacena en rax

     mov rsi, r12                       ; puntero fuente->contenido de r12
     mov rdi, rax                       ; puntero destino->memoria reservada por malloc
     mov rcx, r13                       ; longitud de cadena

     rep movsb                          ; mientras rcx no sea cero copia la cadena byte por byte

     add rsp, 8
     pop rbx
     pop r13
     pop r12
     pop rbp
     ret

; void strPrint(char* a, FILE* pFile)
;                  rdi        rsi
strPrint:
xor al, al                             ; seteo al = 0

     push rbp                          ; pila alineada
     mov rbp, rsp

     push r12                          ; pila desalineada

     sub rsp, 8                        ; pila alineada

     mov r12, rdi

     mov rdi, r12
     call strLen
     cmp rax, 0
     je .strVacio
     
     mov rdi, rsi                      ; cambio los valores entre rdi y rsi ya que fprintf(pfile = rsi, *a = rdi)
     mov rsi, r12                      ;                                                      rdi           rsi
     call fprintf
     jmp .retorno

.strVacio:
     mov rdi, rsi                     
     mov rsi, ptrNulo
     call fprintf

.retorno:
     add rsp, 8
     pop r12
     pop rbp
     ret

; int32_t strCmp(char* a, char* b)
;   rax             rdi      rsi
strCmp:
xor rax, rax                           ; seteo rax = 0

.condicion:
     mov al, [rdi]                     ; al = rdi[i]
     mov bl, [rsi]                     ; bl = rsi[j]

     cmp al, bl                        ; comparo los dos caracteres 
     jne .corte                        ; si no son iguales, chequeo que condicion se cumple

     cmp al, 0                         ; si alguna cadena se termina, chequeo que condicion se cumple.
     jz .corte

     inc rsi                           ; incremento el valor de rsi en 1, recorro el arreglo rsi de chars = 1 byte
     inc rdi                           ; incremento el valor de rdi en 1, recorro el arreglo rdi de chars = 1 byte
     jmp .condicion                    ; vuelvo a chequear la condicion de comparacion.

.corte:
     jg .mayor_a                       ; si rdi > rsi, salto a la etiqueta que devuelve el valor 1.
     jl .mayor_b                       ; si rdi < rsi, salto a la etiqueta que devuelve el valor -1.
     
     ret                               ; devuelve el valor de rax = 0 si no entra en ninguno de los 2 saltos

.mayor_a:
     mov rax, -1                       ; seteo rax = 1
     ret                               ; devuelve el valor de rax = -1.

.mayor_b:
     mov rax, 1                        ; seteo rax = -1
     ret                               ; devuelve el valor de rax = 1.

; void strDelete(char* a)
strDelete:
     push rbp                          ; pila alineada
     mov rbp, rsp

     push r12                          ; pila desalineada

     sub rsp, 8                        ; pila alineada

     mov r12, rdi

     mov rdi, r12
     call free

     add rsp, 8
     pop r12
     pop rbp
     ret

; uint32_t strLen(char* a)
;   rax             rdi
strLen:
xor rax, rax                           ; seteo rax en cero

.condicion:
     cmp byte [rdi], 0                 ; comparo el caracter de la posicion rdi con cero: recorrido del puntero pasado por parametro.
     jz .retorno                       ; si es cero, salto a la etiqueta que devuelve el valor.

     inc rax                           ; si no es cero, incremento el valor de rax en 1.
     inc rdi                           ; si no es cero, incremento el valor de rdi en 1, recorro el arreglo rdi de chars = 1 byte
     jmp .condicion                    ; vuelvo a chequear la condicion de comparacion.

.retorno:
     ret                               ; devuelve el valor de rax.

; ** Array **

; uint8_t arrayGetSize(array_t* a)
;   rax                    rdi
arrayGetSize:
     mov rax, [rdi + OFFSET_SIZE]     ; guardo en rax la posicion de memoria donde se encuentra el tamaño del array 
     ret

; void arrayAddLast(array_t* a, void* data)
;                      rdi          rsi
arrayAddLast:
     push rbp
     mov rbp, rsp

     push r12
     push r13
     push r14
     push r15
     push rbx
     sub rsp, 8

     mov r12, rdi                      ; guardo en r12 el ptr a array
     mov r13, rsi                      ; guardo en r13 el ptr al dato
     xor rbx, rbx
     xor r14, r14
     xor rbp, rbp
     
     mov bl, byte [r12 + OFFSET_SIZE]  ; bl tiene la cantidad de datos
     movzx rbx, bl                     ; extender bl a un registro de 64bits                

     mov sil, byte [r12 + OFFSET_CAPACITY] ; bl tiene la capacidad del array
     movzx rsi, sil                    ; extender sil a un registro de 64bits

     cmp rsi, rbx                      ; comparo capacidad con cantidad de datos
     je .retorno                       ; si son iguales no se pueden agregar mas datos

     mov rbp, rbx                      ; muevo a rbp la cantidad de datos

     mov rdi, [r12 + OFFSET_TYPE]
     call getCloneFunction

     mov rdi, r13
     call rax                          ; rax tiene la funcion que clona un *type

     mov r15, rax                      ; guardo dato clonado (*type) en r15
     
     imul rbp, SIZE_PTR

     mov rdi, [r12 + OFFSET_PTR_DATA]  ; rdi tiene el **data

     mov r14, [rdi]                    ; r14 tiene el contenido de **data

     mov [r14 + rbp], r15              ; guardo en r14 el ptr al dato clonado con el offset

     mov [r12 + OFFSET_PTR_DATA], rdi  ; actualizo valores de **data

     inc bl
     mov [r12 + OFFSET_SIZE], bl       ; actualizo tamaño de size 

.retorno:
     add rsp, 8
     pop rbx
     pop r15
     pop r14
     pop r13
     pop r12
     pop rbp
     ret

; void* arrayGet(array_t* a, uint8_t i)
;  rax               rdi         rsi
arrayGet:
     push rbp
     mov rbp, rsp

     push r12
     push r13
     push r14
     push r15
     push rbx
     sub rsp, 8

     mov r12, rdi                      ; guardo en r12 el ptr al array
     movzx rsi, sil                    ; extender sil a un registro de 64bits
     mov r13, rsi                      ; guardo en r13 el indice buscado

     mov bl, byte [r12 + OFFSET_SIZE]  ; bl tiene la cantidad de datos
     movzx rbx, bl                     ; extender bl a un registro de 64bits

     cmp rbx, r13
     je .indiceInvalido                ; si indice = cantidad de datos, el valor no se encuentra en el rango
     jl .indiceInvalido                ; si indice > cantidad de datos, el valor no se encuentra en el rango

     mov r14, [r12 + OFFSET_PTR_DATA]  ; guardo en r14 **data

     mov r15, [r14]                    ; guardo en r15 el contenido de **data

     imul r13, SIZE_PTR                ; cuantos bytes me debo mover en el array para buscar el dato deseado

     add r15, r13

     mov rax, [r15]                    ; guardo en rax el puntero del valor buscado

     jmp .retorno

.indiceInvalido:
     xor rax, rax                      ; seteo valor de retorno en 0
     jmp .retorno                

.retorno:
     add rsp, 8
     pop rbx
     pop r15
     pop r14
     pop r13
     pop r12
     pop rbp
     ret

; array_t* arrayNew(type_t t, uint8_t capacity)
;    rax               rdi          rsi
arrayNew:
     push rbp
     mov rbp, rsp

     push r12
     push r13
     push r14
     push r15
     push rbx
     sub rsp, 8

     mov r12, rdi                      ; guardo type t en r12
     mov r13, rsi                      ; guardo capacidad en r13
     xor r15, r15

     mov rdi, SIZE_ARRAY               ; muevo a rdi los bytes que necesito para el arreglo
     call malloc

     mov rbx, rax                      ; memoria para el arreglo en rbx

     mov [rbx + OFFSET_TYPE], r12      ; guardo tipo

     mov [rbx + OFFSET_SIZE], r15      ; guardo tamaño

     mov [rbx + OFFSET_CAPACITY], r13  ; guardo capacidad

     mov rdi, SIZE_PTR                 ; obtengo puntero a arreglo
     call malloc

     mov r14, rax                      ; memoria para **data

     mov r15, SIZE_PTR

     imul r15, r13                     ; tamaño de un puntero * cantidad de datos

     mov rdi, r15                      ; reservo memoria para x cantidad de datos (punteros)
     call malloc

     mov [r14], rax                    ; guardo la direccion dentro de **data

     mov [rbx + OFFSET_PTR_DATA], r14  ; guardo puntero a array en la memoria reservada para **data

     mov rax, rbx

     add rsp, 8
     pop rbx
     pop r15
     pop r14
     pop r13
     pop r12
     pop rbp
     ret

; void* arrayRemove(array_t* a, uint8_t i)
;   rax                rdi         rsi
arrayRemove:
     push rbp
     mov rbp, rsp

     push r12
     push r13
     push r14
     push r15
     push rbx
     sub rsp, 8

     mov r12, rdi                      ; guardo en r12 el ptr al array
     movzx rsi, sil                    ; extender sil a un registro de 64bits
     mov r13, rsi                      ; guardo en r13 el indice buscado
     xor rbx, rbx

     mov bl, byte [r12 + OFFSET_SIZE]  ; bl tiene la cantidad de datos
     movzx rbx, bl                     ; extender bl a un registro de 64bits

     cmp rbx, r13
     je .indiceInvalido                ; si indice = cantidad de datos, el valor no se encuentra en el rango
     jl .indiceInvalido                ; si indice > cantidad de datos, el valor no se encuentra en el rango

     xor r14, r14
     xor r15, r15
     xor rbp, rbp

     mov r14, [r12 + OFFSET_PTR_DATA]  ; guardo en r14 **data

     cmp rbx, 1
     je .casoUnDato

     mov rbp, rbx
     dec rbp
     cmp rbp, rsi                      ; si cantidad datos - 1 es igual al indice, el eliminado es el ultimo
     je .casoUltimoElemento

.loop:
     mov rdi, r12
     mov rsi, r13                   
     add r13, 1
     mov rdx, r13
     call arraySwap                    ; intercambio el elemento a eliminar con el siguiente

     cmp r13, rbp
     jne .loop                         ; el loop termina cuando r13 llega al indice del ultimo elemento

.casoUltimoElemento:
     imul rbp, SIZE_PTR

     mov r15, [r14]                    ; guardo en r15 el contenido de **data
     
     add r15, rbp                      ; me muevo a la posicion del ultimo elemento

     mov rax, [r15]                    ; guardo en rax el contenido del dato a eliminar 

     jmp .actualizarValores

.casoUnDato:
     mov r15, [r14]                    ; guardo en r15 el contenido de **data
     
     mov rax, [r15]                    ; guardo en rax el contenido del dato a eliminar                                                                                             

     jmp .actualizarValores
     

.indiceInvalido:
     xor rax, rax                      ; seteo valor de retorno en 0
     jmp .alinearPila                

.actualizarValores:
     mov [r15], rbp                    ; vacio el contenido del dato a eliminar, rbp = 0

     mov [r12 + OFFSET_PTR_DATA], r14  ; actualizo contenido del array

     dec bl
     mov [r12 + OFFSET_SIZE], bl       ; actualizo tamaño de size

     jmp .alinearPila  

.alinearPila:
     add rsp, 8
     pop rbx
     pop r15
     pop r14
     pop r13
     pop r12
     pop rbp
     ret

; void arraySwap(array_t* a, uint8_t i, uint8_t j)
;                    rdi        rsi        rdx
arraySwap:
     push rbp
     mov rbp, rsp

     push r12
     push r13
     push r14
     push r15
     push rbx
     sub rsp, 8

     mov r12, rdi                      ; guardo en r12 el ptr al array
     movzx rsi, sil                    ; extender sil a un registro de 64bits
     mov r13, rsi                      ; guardo en r13 el indice i
     movzx rdx, dl                     ; extender dl a un registro de 64bits
     mov r14, rdx                      ; guardo en r14 el indice j

     mov bl, byte [r12 + OFFSET_SIZE]  ; bl tiene la cantidad de datos
     movzx rbx, bl                     ; extender bl a un registro de 64bits

     cmp rbx, r13
     je .indiceInvalido                ; si indice = cantidad de datos, el valor no se encuentra en el rango
     jl .indiceInvalido                ; si indice > cantidad de datos, el valor no se encuentra en el rango
     cmp rbx, rdx
     je .indiceInvalido                ; si indice = cantidad de datos, el valor no se encuentra en el rango
     jl .indiceInvalido                ; si indice > cantidad de datos, el valor no se encuentra en el rango

     xor rbx, rbx
     xor rax, rax

     mov rbp, [r12 + OFFSET_PTR_DATA]  ; guardo en rbp **data

     mov r15, [rbp]                    ; guardo en r15 el contenido de **data

     imul r13, SIZE_PTR
     mov rbx, [r15 + r13]              ; muevo a rbx el valor del puntero de indice i
     
     imul r14, SIZE_PTR
     mov rax, [r15 + r14]              ; muevo a rax el valor del puntero de indice j

     mov [r15 + r13], rax              ; muevo rax al indice i
     mov [r15 + r14], rbx              ; muevo rbx al indice j

     mov [rbp], r15                    ; actualizo los valores

     mov [r12 + OFFSET_PTR_DATA], rbp

     jmp .retorno  

.indiceInvalido:
     jmp .retorno

.retorno:
     add rsp, 8
     pop rbx
     pop r15
     pop r14
     pop r13
     pop r12
     pop rbp
     ret

; void arrayDelete(array_t* a)
;                      rdi
arrayDelete:
     push rbp
     mov rbp, rsp

     push r12
     push r13
     push r14
     push r15
     push rbx
     sub rsp, 8

     mov r12, rdi                      ; guardo ptr a array en r12
     mov r13, [r12 + OFFSET_PTR_DATA]  ; guardo **data en r13

     xor rbx, rbx
     mov bl, byte [r12 + OFFSET_SIZE]  ; bl tiene la cantidad de datos
     movzx rbx, bl                     ; extender bl a un registro de 64bits

     mov r14, [r12 + OFFSET_TYPE]      ; guardo tipo en r14

     mov rdi, r14
     call getDeleteFunction

     mov r15, rax                      ; guardo funcion que libera memoria en r15

     cmp rbx, 0                        ; comparo para ver si es un array vacio
     je .retorno 

     mov rbp, [r13]                    ; contenido de **data

.loop:                                 ; loop para eliminar memoria del contenido de **data 
     mov rdi, [rbp]             
     call r15

     add rbp, SIZE_PTR                 ; me muevo dentro del array 8 posiciones
     dec rbx
     cmp rbx, 0
     jne .loop

.retorno:
     mov rdi, [r13]                    ; libero memoria reservada para el contenido de **data = (capacidad) bytes
     call free

     mov rdi, r13                      ; libero memoria reservada para **data
     call free

     mov rdi, r12
     call free                         ; libero memoria reservada para el array
     
     add rsp, 8
     pop rbx
     pop r15
     pop r14
     pop r13
     pop r12
     pop rbp
     ret

;void arrayPrint(array_t* a, FILE* pFile)
;                   rdi          rsi
arrayPrint:
     push rbp
     mov rbp, rsp

     push r12
     push r13
     push r14
     push r15
     push rbx
     sub rsp, 8

     mov r12, rdi                      ; guardo ptr al array en r12
     mov r13, rsi                      ; guardo ptr al archivo en r13
     
     xor rbx, rbx
     mov bl, byte [r12 + OFFSET_SIZE]  ; bl tiene la cantidad de datos
     movzx rbx, bl                     ; extender bl a un registro de 64bits 

     mov rdi, corcheteAbierto
     mov rsi, r13 
     call strPrint                     ; imprimo en el archivo '['

     cmp rbx, 0                        ; comparo para ver si es un array vacio
     je .retorno        

     mov rdi, [r12 + OFFSET_TYPE]      ; muevo a rdi el type del array
     call getPrintFunction
     mov rbp, rax                      ; rbp tiene la funcion que imprime dependiendo el type

     mov r14, [r12 + OFFSET_PTR_DATA]  ; muevo a r14 **data

     mov r15, [r14]                    ; muevo a r15 el contenido de **data

.loop:
     mov rdi, [r15]                    
     mov rsi, r13
     call rbp                          ; imprimo en el archivo el valor del puntero del array que contiene **data
     
     add r15, SIZE_PTR                 ; me muevo dentro del array 8 posiciones
     
     cmp rbx, 1                        ; comparo con 1 para ver si es el ultimo elemento
     jne .agregarSeparador             ; si no es uno imprimo en el archivo ','

     dec rbx
     
     cmp rbx, 0                        ; comparo con 0 para ver si quedan elementos en el array
     jne .loop
     jmp .retorno

.retorno:
     mov rdi, corcheteCerrado
     mov rsi, r13 
     call strPrint                     ; imprimo en el archivo ']'     

     add rsp, 8
     pop rbx
     pop r15
     pop r14
     pop r13
     pop r12
     pop rbp
     ret

.agregarSeparador:
     mov rdi, coma
     mov rsi, r13 
     call strPrint                     ; imprimo en el archivo ']'

     dec rbx
     jmp .loop

; ** Card **

; card_t* cardNew(char* suit, int32_t* number)
;   rax               rdi            rsi
cardNew:
     push rbp
     mov rbp, rsp

     push r12
     push r13
     push r14
     push r15
     push rbx

     sub rsp, 8

     mov r12, rdi                      ; guardo rdi en r12    
     mov r13, rsi                      ; guardo rsi en r13

     mov rdi, SIZE_CARD                ; reservo 24 bytes para el struct card en rdi ya que es el parametro que usa malloc
     call malloc

     mov rbx, rax                      ; guardo puntero al struct card en rbx

     mov rdi, r12
     call strClone

     mov r14, rax                      ; guardo puntero a suit en r14

     mov rdi, r13
     call intClone

     mov r15, rax                      ; guardo puntero a number en r15

     mov [rbx + OFFSET_SUIT], r14      ; guardo puntero a suit en la memoria reservada para la struct con el corrimiento adecuado

     mov [rbx + OFFSET_NUMBER], r15    ; guardo puntero a number en la memoria reservada para la struct

     mov rdi, 3                        ; obtengo puntero a lista
     call listNew

     mov [rbx + OFFSET_CARD_STACK], rax ; guardo puntero a lista en la memoria reservada para la struct

     mov rax, rbx                      ; guardo puntero al struct card en rax (valor de retorno)

     add rsp, 8
     pop rbx
     pop r15
     pop r14
     pop r13
     pop r12
     pop rbp
     
     ret

;char* cardGetSuit(card_t* c)
;  rax                rdi
cardGetSuit:
     mov rax, [rdi + OFFSET_SUIT]      ; guardo en rax la posicion de memoria donde se encuentra el suit
     ret

;int32_t* cardGetNumber(card_t* c)
;  rax                rdi
cardGetNumber:
     mov rax, [rdi + OFFSET_NUMBER]    ; guardo en rax la posicion de memoria donde se encuentra el numero   
     ret

;list_t* cardGetStacked(card_t* c)
;   rax                     rdi
cardGetStacked:
     mov rax, [rdi + OFFSET_CARD_STACK] ; guardo en rax la posicion de memoria donde se encuentra la lista de cartas 
     ret


;void cardPrint(card_t* c, FILE* pFile)
;                   rdi         rsi
cardPrint:
     push rbp
     mov rbp, rsp

     push r12
     push r13

     mov r12, rdi                      ; guardo ptr a la carta pasada por parametro
     mov r13, rsi                      ; guardo ptr al archivo pasada por parametro

     mov rdi, llaveAbierta
     mov rsi, r13 
     call strPrint

     mov rdi, r12
     call cardGetSuit                  ; obtengo el puntero a suit de la carta pasada por parametro
     
     mov rdi, rax
     mov rsi, r13                      
     call strPrint                     ; lo escribo en el archivo

     mov rdi, guion
     mov rsi, r13 
     call strPrint

     mov rdi, r12
     call cardGetNumber                ; obtengo el puntero a number de la carta pasada por parametro
     
     mov rdi, rax
     mov rsi, r13
     call intPrint                     ; lo escribo en el archivo

     mov rdi, guion
     mov rsi, r13 
     call strPrint

     mov rdi, r12
     call cardGetStacked              ; obtengo el puntero a number de la carta pasada por parametro

     mov rdi, rax                      
     mov rsi, r13
     call listPrint                   ; lo escribo en el archivo

     mov rdi, llaveCerrada
     mov rsi, r13 
     call strPrint

     pop r13
     pop r12
     pop rbp
     ret


;int32_t cardCmp(card_t* a, card_t* b)
;   rax             rdi         rsi
cardCmp:
     push rbp
     mov rbp, rsp

     push r12
     push r13

     mov r12, rdi                      ; guardo en r12 el puntero a la carta 'a'
     mov r13, rsi                      ; guardo en r13 el puntero a la carta 'b'

     mov rdi, [r12 + OFFSET_SUIT]      ; guardo en rdi la posicion de memoria donde se encuentra el suit de la carta 'a'
     mov rsi, [r13 + OFFSET_SUIT]      ; guardo en rsi la posicion de memoria donde se encuentra el suit de la carta 'b'
     
     call strCmp

     cmp rax, 0
     jnz .corte                        ; si es cero hago la comparacion de los numeros de la carta

     mov rdi, [r12 + OFFSET_NUMBER]    ; guardo en rdi la posicion de memoria donde se encuentra el numero de la carta 'a'
     mov rsi, [r13 + OFFSET_NUMBER]    ; guardo en rsi la posicion de memoria donde se encuentra el numero de la carta 'b'

     call intCmp

     jmp .corte

.corte:                                ; alineo la pila e retorno el valor de rax
     pop r13
     pop r12
     pop rbp

     ret

;card_t* cardClone(card_t* c)
;  rax                 rdi
cardClone:
     push rbp                          ; pila alineada
     mov rbp, rsp

     push r12                          ; pila desalineada
     push rbx                          ; pila alineada

     mov r12, rdi                      ; guardo ptr a carta en r12

     mov rdi, SIZE_CARD                ; reservo 24 bytes para el clon de la nueva carta
     call malloc

     mov rbx, rax                      ; guardo memoria reservada por malloc en rbx

     mov rdi, r12
     call cardGetSuit                  ; obtengo el ptr a suit de la carta pasada por parametro

     mov rdi, rax
     call strClone
     mov [rbx + OFFSET_SUIT], rax      ; guardo el clon del ptr a suit en la carta clonada

     mov rdi, r12
     call cardGetNumber                ; obtengo el ptr a number de la carta pasada por parametro

     mov rdi, rax
     call intClone
     mov [rbx + OFFSET_NUMBER], rax    ; guardo el clon del ptr a number en la carta clonada

     mov rdi, r12
     call cardGetStacked               ; obtengo el ptr a lista de la carta pasada por parametro

     mov rdi, rax
     call listClone
     mov [rbx + OFFSET_CARD_STACK], rax ; guardo el clon del ptr a lista en la carta clonada

     mov rax, rbx

     pop rbx
     pop r12
     pop rbp
     ret

;void cardAddStacked(card_t* c, card_t* card)
;                       rdi         rsi
cardAddStacked:
     push rbp                          ; pila alineada
     mov rbp, rsp

     push r12                          ; pila desalineada
     push r13                          ; pila alineada

     mov r12, rdi                      ; guardo ptr de carta 
     mov r13, rsi                      ; guardo ptr de carta a agregar a la lista
     
     mov rdi, r12
     call cardGetStacked
     
     mov rbp, rax                      ; guardo en r14 el ptr a la lista de cartas de c

     mov rdi, rbp                      
     mov rsi, r13
     call listAddFirst

     pop r13
     pop r12
     pop rbp
     ret

;void cardDelete(card_t* c)
;                   rdi
cardDelete:
     push rbp                          ; pila alineada
     mov rbp, rsp

     push r12                          ; pila desalineada

     sub rsp, 8                        ; pila alineada

     mov r12, rdi                      ; guardo en r12 la carta pasada por parametro

     mov rdi, r12
     call cardGetSuit                  ; obtengo el ptr al suit de la carta
     
     mov rdi, rax
     call strDelete                    ; libero memoria reservada para el suit de la carta

     mov rdi, r12
     call cardGetNumber                ; obtengo el ptr al numero de la carta
     
     mov rdi, rax
     call intDelete                    ; libero memoria reservada para el numero de la carta

     mov rdi, r12
     call cardGetStacked              ; obtengo el ptr al stack de la carta
     
     mov rdi, rax
     call listDelete                  ; libero memoria reservada para la lista de cartas de la carta

     mov rdi, r12
     call free                         ; libero memoria reservada para la carta pasada por parametro

     add rsp, 8
     pop r12
     pop rbp
     ret

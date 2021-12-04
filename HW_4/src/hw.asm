; Обозначение основных типов транспорта
global car
global truck
global bus

extern  atoi
extern  fopen
extern  fclose
extern  fscanf
extern  fprintf
extern  printf
extern  stdout
extern  time
extern  clock
extern  CLOCKS_PER_SEC
extern  srand
extern  rand
extern  strcmp



; Оформление выводов

%macro  PrintStr    2
    section .data
        %%arg1  db  %1,0        
    section .text               
        mov rdi, %2
        mov rsi, %%arg1
        mov rax, 0              
        call fprintf
%endmacro


%macro  PrintStrLn    2
    section .data
        %%arg1  db  %1,10,0     
    section .text               
        mov rdi, %2
        mov rsi, %%arg1
        mov rax, 0              
        call fprintf
%endmacro


%macro  PrintInt    2
    section .data
        %%arg1  db  "%d",0      
    section .text               
        mov rdi, %2
        mov rsi, %%arg1
        mov rdx, %1
        mov rax, 0              
        call fprintf
%endmacro


%macro  PrintDouble    2
    section .data
        %%arg1  db  "%g",0     
    section .text              
        mov rdi, %2
        mov rsi, %%arg1
        movsd xmm0, %1
        mov rax, 1              
        call fprintf
%endmacro


%macro  PrintLLUns    2
    section .data
        %%arg1  db  "%llu",0     
    section .text               
        mov rdi, %2
        mov rsi, %%arg1
        mov rdx, %1
        mov rax, 0             
        call fprintf
%endmacro


%macro  PrintContainer    3
    mov     rdi, %1
    mov     esi, %2
    mov     rdx, %3
    mov     rax, 0              
    call    WriteContainer
%endmacro


%macro	PrintStrBuf 2
        mov rdi, %2
        mov rsi, %1
        xor rax, rax
        call fprintf
%endmacro


; Работа с файлом

%macro  FileOpen   3
section .data
    %%rw  db  %2,0          
section .text               
    mov     rdi, %1         
    lea     rsi, [%%rw]       
    mov     rax, 0          
    call    fopen
    mov     [%3], rax
%endmacro


%macro  FileClose   1
    mov     rdi, %1             
    mov     rax, 0              
    call    fclose
%endmacro

section .data
    formatting db "%g %g <= %g", 10, 0
    car dd 1
    truck dd 2
    bus dd 3
    fileGen  db "-f", 0 
    rndGen  db "-n", 7
    errMessage db  "некорректные данные"
    vehNumber         dd  0          
section .bss
    argc        resd    1
    num         resd    1
    readF        resq    1       
    outputF1       resq    1  
    outputF2       resq    1  
    cont        resb    100000  ; Главный массив
section .text
    global main
main:
section .bss
    .left       resd    1
    .middle     resd    1
    .right      resd    1
    .left_iter  resd    1
    .right_iter resd    1
    .tmp_cont   resb    200000
    .tmp_vehNumber    resd    1
section .text
push rbp
mov rbp,rsp
    
    mov dword [argc], edi
    mov r12, rdi
    mov r13, rsi
    
.validate_argc:
    cmp r12, 5 
    je .fill_cont
    PrintStrBuf errMessage, [stdout]
    jmp .return
.fill_cont:
    mov rdi, fileGen
    mov rsi, [r13+8]    
    call strcmp
    cmp rax, 0          
    je .fill_file
    mov rdi, rndGen
    mov rsi, [r13+8]    
    call strcmp
    cmp rax, 0          
    je .fill_rand
    PrintStrBuf errMessage, [stdout]
    jmp .return
.fill_file:
    FileOpen [r13+16], "r", readF
    ; Обработка cont
    mov     rdi, cont   
    mov     rsi, vehNumber  
    mov     rdx, [readF]  
    xor     rax, rax
    call    AddingContainer ; Заполнение.
    FileClose [readF]
    jmp .task
.fill_rand:
     
    mov rdi, [r13+16]
    call atoi
    mov [num], eax
    PrintInt [num], [stdout]
    PrintStrLn "", [stdout]
    mov eax, [num]
    cmp eax, 1
    jl .incorrect_number
    cmp eax, 10000
    jg .incorrect_number
    xor     rdi, rdi
    xor     rax, rax
    call    time
    mov     rdi, rax
    xor     rax, rax
    call    srand
    mov     rdi, cont 
    mov     rsi, vehNumber  
    mov     edx, [num] 
    call    ContainerGen
    jmp .task
    
.incorrect_number:
    ; Вывод сообщения об ошибке.
    PrintStr "некорректный ввод  данных", [stdout]
    
.task:
    ; Вывод1
    FileOpen [r13+24], "w", outputF1
    PrintStrLn "Контейнер:", [outputF1]
    PrintContainer cont, [vehNumber], [outputF1]
    FileClose [outputF1]
    
    ; Сортировка straight merge (№9)
    mov ebx, 1
.loop1:
    cmp ebx, [vehNumber]
    jge .break_loop1
    
    mov ecx, 0
    .loop2:
        xor eax, eax
        mov eax, [vehNumber]
        sub eax, ebx
        cmp ecx, eax
        jge .break_loop2
        
        mov [.left], ecx
        
        mov [.middle], ebx
        add [.middle], ecx
        mov edx, ebx
        
        
        
        shl edx, 1
        add edx, ecx
        cmp edx, [vehNumber]
        jg .false
            mov [.right], edx
            jmp .endif
        .false:
            mov edx, [vehNumber]
            mov [.right], edx
        .endif:
        xor eax, eax
        mov [.left_iter], eax
        mov [.right_iter], eax
        
        mov eax, [.right]
        sub eax, [.left]
        mov [.tmp_vehNumber], eax
        
        .while1:
            mov eax, [.left]
            add eax, [.left_iter]
            cmp eax, [.middle]
            
            jge .break_while1
            
            mov eax, [.middle]
            add eax, [.right_iter]
            cmp eax, [.right]
            jge .break_while1
            
            mov eax, [.left]
            add eax, [.left_iter]
            mov edx, 20
            
            mul edx
            mov ebp, cont
            add ebp, eax
            mov ebp, [ebp + 4]
            
            mov eax, [.middle]
            add eax, [.right_iter]
            mov edx, 20
            
            mul edx
            mov esi, cont
            add esi, eax
            mov esi, [esi + 4]
            
            cmp ebp, esi
            jg .false1
                mov eax, [.left_iter]
                add eax, [.right_iter]
                mov edx, 20
                
                mul edx
                mov ebp, .tmp_cont
                add ebp, eax
                
                mov eax, [.left]
                add eax, [.left_iter]
                mov edx, 20
                
                mul edx
                mov esi, cont
                add esi, eax
                
                mov eax, ebp
                mov edx, [esi]
                mov [eax], edx
                
                mov edx, [esi + 4]
                mov [eax + 4], edx
                
                mov edx, [esi + 8]
                mov [eax + 8], edx
                
                mov edx, [esi + 12]
                mov [eax + 12], edx
                
                mov edx, [esi + 16]
                mov [eax + 16], edx
                
                mov eax, [.left_iter]
                inc eax
                mov [.left_iter], eax
                
                jmp .endif1
            .false1:
                mov eax, [.left_iter]
                add eax, [.right_iter]
                mov edx, 20
                
                mul edx
                mov ebp, .tmp_cont
                add ebp, eax
                
                mov eax, [.middle]
                add eax, [.right_iter]
                mov edx, 20
                
                mul edx
                
                mov esi, cont
                add esi, eax
                
                mov eax, ebp
                mov edx, [esi]
                mov [eax], edx
                
                mov edx, [esi + 4]
                mov [eax + 4], edx
                
                mov edx, [esi + 8]
                mov [eax + 8], edx
                
                mov edx, [esi + 12]
                mov [eax + 12], edx
                
                mov edx, [esi + 16]
                mov [eax + 16], edx

                mov eax, [.right_iter]
                inc eax
                mov [.right_iter], eax
            .endif1:
         jmp .while1
        .break_while1:
        .while2:
            mov eax, [.left]
            add eax, [.left_iter]
            cmp eax, [.middle]
            
            jge .break_while2
            
            mov eax, [.left_iter]
            add eax, [.right_iter]
            mov edx, 20
            mul edx
            
            mov ebp, .tmp_cont
            add ebp, eax
            
            mov eax, [.left]
            add eax, [.left_iter]
            mov edx, 20
            mul edx
            mov esi, cont
            add esi, eax
                
            mov eax, ebp
            mov edx, [esi]
            mov [eax], edx
            mov edx, [esi + 4]
            mov [eax + 4], edx
            
            mov edx, [esi + 8]
            mov [eax + 8], edx
            
            mov edx, [esi + 12]
            mov [eax + 12], edx
            
            mov edx, [esi + 16]
            mov [eax + 16], edx
                
            mov eax, [.left_iter]
            inc eax
            mov [.left_iter], eax
            
            jmp .while2
        .break_while2:
        .while3:
            mov eax, [.middle]
            add eax, [.right_iter]
            cmp eax, [.right]
            jge .break_while3
            mov eax, [.left_iter]
            add eax, [.right_iter]
            mov edx, 20
            mul edx
            
            mov ebp, .tmp_cont
            add ebp, eax
            mov eax, [.middle]
            add eax, [.right_iter]
            mov edx, 20
            mul edx
            mov esi, cont
            add esi, eax
                
            mov eax, ebp
            mov edx, [esi]
            mov [eax], edx
            
            mov edx, [esi + 4]
            mov [eax + 4], edx
            
            mov edx, [esi + 8]
            mov [eax + 8], edx
            
            mov edx, [esi + 12]
            mov [eax + 12], edx
            
            mov edx, [esi + 16]
            mov [eax + 16], edx

            mov eax, [.right_iter]
            inc eax
            mov [.right_iter], eax
            
            jmp .while3
        .break_while3:
        
        mov edi, 0
        .loop3:
        mov eax, [.left_iter]
        add eax, [.right_iter]
        cmp eax, edi
        jle .break_loop3
        
        mov eax, [.left]
        add eax, edi
        mov edx, 20
        mul edx
        mov ebp, cont
        add ebp, eax
        
        mov eax, edi
        mov edx, 20
        mul edx
        mov esi, .tmp_cont
        add esi, eax
        
        mov eax, ebp
        mov edx, [esi]
        mov [eax], edx
        mov edx, [esi + 4]
        mov [eax + 4], edx
        mov edx, [esi + 8]
        mov [eax + 8], edx
        mov edx, [esi + 12]
        mov [eax + 12], edx
        mov edx, [esi + 16]
        mov [eax + 16], edx
        
        inc edi
        jmp .loop3
        .break_loop3:
        
        xor eax, eax
        mov eax, ebx
        shl eax, 1
        add ecx, eax
        jmp .loop2
    .break_loop2:
    
    shl ebx, 1
    jmp .loop1
.break_loop1:
    
    ; Вывод
    FileOpen [r13+32], "w", outputF2
    PrintStrLn "Контейнер:", [outputF2]
    PrintContainer cont, [vehNumber], [outputF2]
    FileClose [outputF2]
    
.return:   
mov     rax, 60
xor     rdi, rdi
syscall

; Добавление элементов
global AddingCar
AddingCar:
section .data
    .formattingForInput db "%d%d",0
section .bss
    .FILE  resq    1 
    .carpth  resq    1   ; Адрес автомобиля  (car)
section .text
push rbp
mov rbp, rsp

    mov     [.carpth], rdi  
    mov     [.FILE], rsi  
 
    mov     rdi, [.FILE]
    mov     rsi, .formattingForInput 
    mov     rdx, [.carpth] ; Ссылка на вместимость.
    mov     rcx, [.carpth]
    add     rcx, 4          ; Ссылка на расход топлива.            
    mov     r8, [.carpth]
    add     r8, 8           ; Ссылка на доп параметр.
    mov     rax, 0     
    call    fscanf

leave
ret

global AddingTruck
AddingTruck:
section .data
    .formattingForInput db "%d%d%d%d",0
section .bss
    .FILE       resq    1  
    .truckpth    resq    1  
section .text
push rbp
mov rbp, rsp
    mov     [.truckpth], rdi 
    mov     [.FILE], rsi  

    
    mov     rdi, [.FILE]
    mov     rsi, .formattingForInput  
    mov     rdx, [.truckpth] ; Ссылка на вместимость.
    mov     rcx, [.truckpth]
    add     rcx, 4          ; Ссылка на расход топлива.           
    mov     r8, [.truckpth]
    add     r8, 8           ; Ссылка на доп параметр.
    mov     rax, 0           
    call    fscanf

leave
ret

global AddingBus
AddingBus:
section .data
    .formattingForInput db "%d%d",0
section .bss
    .FILE       resq    1
    .buspth     resq    1 
section .text
push rbp
mov rbp, rsp
    mov     [.buspth], rdi 
    mov     [.FILE], rsi 

    ; Ввод car из файла
    mov     rdi, [.FILE]
    mov     rsi, .formattingForInput 
    
    mov     rdx, [.buspth] 
    mov     rcx, [.buspth]
    add     rcx, 4         
    mov     r8, [.buspth]
    mov     rax, 0          
    call    fscanf
leave
ret
; Добавление основного и частных видов транспорта.
global AddingVehicle
AddingVehicle:
section .data
    .tagFormat   db      "%d",0
    .tagformatting   db     10,0
section .bss
    .FILE       resq    1 
    .vehiclepth    resq    1 
    .shapeTag   resd    1 
section .text
push rbp
mov rbp, rsp

   
    mov     [.vehiclepth], rdi  
    mov     [.FILE], rsi  

   ; Процесс типизации.
    mov     rdi, [.FILE]
    mov     rsi, .tagFormat
    mov     rdx, [.vehiclepth]  
    xor     rax, rax 
    call    fscanf

    mov rcx, [.vehiclepth] 
    mov eax, [rcx] 
    cmp eax, [car]
    je .addingCar
    cmp eax, [truck]
    je .addingTruck
    cmp eax, [bus]
    je .addingBus
    xor eax, eax 
    jmp     .return
.addingCar:
    mov     rdi, [.vehiclepth]
    add     rdi, 4
    mov     rsi, [.FILE]
    call    AddingCar
    mov     rax, 1
    jmp     .return
.addingTruck:
    mov     rdi, [.vehiclepth]
    add     rdi, 4
    mov     rsi, [.FILE]
    call    AddingTruck
    mov     rax, 1 
    jmp     .return
.addingBus:
    mov     rdi, [.vehiclepth]
    add     rdi, 4
    mov     rsi, [.FILE]
    call    AddingBus
    mov     rax, 1  
.return:
leave
ret

global AddingContainer
AddingContainer:
section .bss
    .conteinerpth      resq    1  
    .vehNumberpth       resq    1   
    .FILE       resq    1  
section .text
push rbp
mov rbp, rsp

    mov [.conteinerpth], rdi 
    mov [.vehNumberpth], rsi 
    mov [.FILE], rdx    
    
    xor rbx, rbx 
    mov rsi, rdx 
.loop:
   
    push rdi
    push rbx

    mov rsi, [.FILE]
    mov rax, 0  
    
    call AddingVehicle 
    cmp rax, 0  
    jle  .return

    pop rbx
    inc rbx

    pop rdi
    
    add rdi, 20

    jmp .loop
.return:
    mov rax, [.vehNumberpth]
    mov [rax], ebx
leave
ret

; Функции случайного ввода
; Генерация случайного чила
global Random
Random:
section .data
    .i100       dq      100
    .formatRandomNumTo  db "Random number = %d",10,0
section .text
push rbp
mov rbp, rsp

    xor     rax, rax    
    call    rand   
    xor     rdx, rdx 
    idiv    qword[.i100]
    mov     rax, rdx
    inc     rax

leave
ret

global RandomDistance
RandomDistance:
section .data
    .i22600     dq      22600
    .formatRandomNumTo  db "Random number = %d",10,0
section .text
push rbp
mov rbp, rsp

    xor     rax, rax    
    call    rand        
    xor     rdx, rdx   
    idiv    qword[.i22600]
    mov     rax, rdx
    inc     rax
leave
ret
global RandomKey
RandomKey:
section .data
    .i3         dq      3
    .formatRandomNumTo  db "Random number = %d",10,0
section .text
push rbp
mov rbp, rsp

    xor     rax, rax
    call    rand 
    xor     rdx, rdx  
    idiv    qword[.i3]
    mov     rax, rdx
    inc     rax

leave
ret

global CarGen
CarGen:
section .bss
    .carpth resq 1
section .text
push rbp
mov rbp, rsp

    mov     [.carpth], rdi
    
    call    RandomDistance
    mov     rbx, [.carpth]
    mov     [rbx], eax
    call    Random
    mov     rbx, [.carpth]
    mov     [rbx+4], eax
    call    Random
    mov     rbx, [.carpth]
    mov     [rbx+8], eax  
    call    Random
    mov     rbx, [.carpth]
    mov     [rbx+12], eax  

leave
ret

global TruckGen
TruckGen:
section .bss
    .truckpth  resq 1   ; Адрес параллелепипеда.
section .text
push rbp
mov rbp, rsp

    mov     [.truckpth], rdi
    
    ; Генерация параметров параллелепипеда.
    call    RandomDistance
    mov     rbx, [.truckpth]
    mov     [rbx], eax
    call    Random
    mov     rbx, [.truckpth]
    mov     [rbx+4], eax
    call    Random
    mov     rbx, [.truckpth]
    mov     [rbx+8], eax  
    call    Random
    mov     rbx, [.truckpth]
    mov     [rbx+12], eax  


leave
ret

global BusGen
BusGen:
section .bss
    .buspth  resq 1   ; Адрес правильного тетраэдра.
section .text
push rbp
mov rbp, rsp

    mov     [.buspth], rdi
    
    call    RandomDistance
    mov     rbx, [.buspth]
    mov     [rbx], eax
    call    Random
    mov     rbx, [.buspth]
    mov     [rbx+4], eax
    call    Random
    mov     rbx, [.buspth]
    mov     [rbx+8], eax  
    call    Random
    mov     rbx, [.buspth]
    mov     [rbx+12], eax  

leave
ret
; Генерация каждого вида транспорта.
global VehicleGen
VehicleGen:
section .data
    .formatRandomNumTo db "Random number = %d",10,0
section .bss
    .vehiclepth   resq    1   
    .key       resd    1  
section .text
push rbp
mov rbp, rsp
    mov [.vehiclepth], rdi
    xor     rax, rax    
    call    RandomKey
    
    mov     rdi, [.vehiclepth]
    mov     [rdi], eax      
    cmp eax, [car]
    je .addingRandomCar
    cmp eax, [truck]
    je .addingRandomTruck
    cmp eax, [bus]
    je .addingRandomBus
    xor eax, eax            
    jmp     .return
.addingRandomCar:
    add     rdi, 4
    call    CarGen
    mov     eax, 1          
    jmp     .return
.addingRandomTruck:
    add     rdi, 4
    call    TruckGen
    mov     eax, 1          
    jmp     .return
.addingRandomBus:
    add     rdi, 4
    call    BusGen
    mov     eax, 1         
.return:
leave
ret

global ContainerGen
ContainerGen:
section .bss
    .conteinerpth  resq    1       
    .vehNumberpth   resq    1   ; (vehNumberpth - vehicle number path)
    .sizepth  resd    1   
section .text
push rbp
mov rbp, rsp

    mov [.conteinerpth], rdi       
    mov [.vehNumberpth], rsi        ; (vehNumberpth - vehicle number path)
    mov [.sizepth], edx      
    
    xor ebx, ebx
.loop:
    cmp ebx, edx
    jge     .return 
    push rdi
    push rbx
    push rdx

    call    VehicleGen     
    cmp rax, 0 
        jle  .return 

    pop rdx
    pop rbx
    inc rbx

    pop rdi
    add rdi, 20  

    jmp .loop
.return:
    mov rax, [.vehNumberpth] 
    mov [rax], ebx  
leave
ret

; Функции вывода:

global WriteCar
WriteCar:
section .data
    .formatting db "Car: TankSize = %d, Expenditure = %d, MaxSpeed = %d, Distance = %g",10,0
section .bss
    .carpth  resq  1
    .FILE   resq  1   
    .distance     resq  1       ; Расстояние
section .text
push rbp
mov rbp, rsp

   
    mov     [.carpth], rdi  
    mov     [.FILE], rsi   
 
    call    Distancecar
    movsd   [.distance], xmm0

 
    mov     rdi, [.FILE]
    mov     rsi, .formatting  
    mov     rax, [.carpth]    
    mov     edx, [rax]      ; Вместимость.
    mov     ecx, [rax+4]    ; Расход.
    mov     r8, [rax+8]     ;Частный принак
    mov     r9, [rax+12]
    movsd   xmm0, [.distance]
    mov     rax, 1   
    call    fprintf

leave
ret

global WriteTruck
WriteTruck:
section .data
    .formatting db "Truck: TankSize = %d, Expenditure = %d, CarryingCapacity = %d, Distance = %g",10,0
section .bss
    .ptrian  resq  1
    .FILE   resq  1   
    .distance     resq  1       ; Расстояние
section .text
push rbp
mov rbp, rsp

   
    mov [.ptrian], rdi       
    mov [.FILE], rsi 

 
    call     Distancetruck
    movsd   [.distance], xmm0 

 
    mov     rdi, [.FILE]
    mov     rsi, .formatting 
    mov     rax, [.ptrian] 
    mov     edx, [rax]      ; Вестимость.
    mov     ecx, [rax+4]    ; Расход топлива.
    mov     r8, [rax+8]     ; Признак.
 
    movsd   xmm0, [.distance]
    mov     rax, 1  
    call    fprintf

leave
ret

global WriteBus
WriteBus:
section .data
    .formatting db "Bus: TankSize = %d, Expenditure = %d, Capacity = %d, Distance = %g",10,0
section .bss
    .buspth  resq  1
    .FILE   resq  1  
    .distance     resq  1       ; Максимальное расстояние.
section .text
push rbp
mov rbp, rsp

 
    mov     [.buspth], rdi  
    mov     [.FILE], rsi   

 
    call    Distancebus
    movsd   [.distance], xmm0
    mov     rdi, [.FILE]
    
    
    ; Форрматирование.
    mov     rsi, .formatting    
    mov     rax, [.buspth]  
    mov     edx, [rax]      
    mov     ecx, [rax+4]    
    mov     r8, [rax+8]
    movsd   xmm0, [.distance]
    mov     rax, 1          
    call    fprintf

leave
ret
 
global WriteVehicle
WriteVehicle:
section .data
    .erFigure db "Неверный ввод",10,0
section .text
push rbp
mov rbp, rsp
    mov eax, [rdi]
    cmp eax, [car]
    je .writeCar
    cmp eax, [truck]
    je .writeTruck
    cmp eax, [bus]
    je .writeBus
    mov rdi, .erFigure
    mov rax, 0
    call fprintf
    jmp .return
    
    ; Выводы для разных видов транспорта
.writeCar:
    add     rdi, 4
    call    WriteCar
    jmp     .return
.writeTruck:
    add     rdi, 4
    call    WriteTruck
    jmp     .return
.writeBus:
    add     rdi, 4
    call    WriteBus
    jmp     .return
.return:
leave
ret

global WriteContainer
WriteContainer:
section .data
    numFmt  db  "%d: ",0
section .bss

; Указание на cont (главный массив)
    .conteinerpth  resq    1   
    .vehNumber    resd    1    
    .FILE   resq    1    
section .text
push rbp
mov rbp, rsp

    mov [.conteinerpth], rdi  
    
    ; Количество транспортных средств
    mov [.vehNumber],   esi   
    mov [.FILE],  rdx    

    
    mov rbx, rsi       
    xor ecx, ecx        
    mov rsi, rdx        
.loop:
    cmp ecx, ebx 
           
    ; Конец цикла
    jge .return         

    push rbx
    push rcx

   
    mov rdi, [.FILE]    
    mov rsi, numFmt      
    mov edx, ecx        
    xor rax, rax,     
    call fprintf

    ; Вывод текущей фигуры.
    mov     rdi, [.conteinerpth]
    mov     rsi, [.FILE]
    call WriteVehicle     

    pop rcx
    pop rbx
    inc ecx            
    mov     rax, [.conteinerpth]
    add     rax, 20    
    ; Для следующдего шага
    mov     [.conteinerpth], rax
    jmp .loop
.return:
leave
ret

; Расчёт максимального расстояния.

global Distancecar
Distancecar:
section .data
alg dq 100
section .text
push rbp
mov rbp, rsp
    mov eax, [rdi+4]
    mov ecx, [rdi+4]

    cvtsi2sd xmm0, eax
    cvtsi2sd xmm1, ecx
    
    movsd xmm3,[alg]
    mulsd xmm0, xmm3

leave
ret

global Distancetruck
Distancetruck:
section .text
push rbp
mov rbp, rsp

    
    
    cvtsi2sd xmm0, eax

leave
ret

global Distancebus
Distancebus:
section .text
push rbp
mov rbp, rsp
    mulsd xmm0, xmm3

leave
ret

global DistanceFigure
DistanceFigure:
section .text
push rbp
mov rbp, rsp
    cvtsi2sd    xmm0, eax
    jmp     .return
.carDistance:
    add     rdi, 4
    call    Distancecar
    jmp     .return
.truckDistance:
    add     rdi, 4
    call    Distancetruck
    jmp     .return
.busDistance:
    add     rdi, 4
    call    Distancebus
    jmp     .return
.return:
leave
ret
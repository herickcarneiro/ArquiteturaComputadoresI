
;==========================================
; UNIVERSIDADE FEDERAL DA PARAÍBA - UFPB  |  
; CENTRO DE INFORMATICA - CI              |  
; DISCIPLINA: ARQUITETURA DE COMPUTADORES |
; PROFESSOR: EWERTON MONTEIRO SALVADOR    |
; DUPLA: GUILHERME MUNIZ | HERICK DE LIMA |
; PROJETO  - LINGUAGEM ASSEMBLY.          |
;==========================================


.686
.model flat, stdcall
option casemap: none
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\masm32.lib

include \masm32\include\msvcrt.inc
includelib \masm32\lib\msvcrt.lib
include \masm32\macros\macros.asm

.data
  arquivoEntrada db 256 dup(0)
  arquivoSaida db 256 dup(0)

  bytes_totais db 54 dup(0)
  largura_imagem dd 1
  linha_imagem db 6480 dup(0)

  inputHandle dd 0
  outputHandle dd 0
  inputFileHandle dd 0
  outputFileHandle dd 0
  readCount dd 0
  writeCount dd 0
  coordenadaX dd 0
  coordenadaY dd 0
  largura dd 0
  altura dd 0
  string1 db 32 dup(0)
  string2 db 32 dup(0)
  string3 db 32 dup(0)
  string4 db 32 dup(0)
  contador dd 0
  byte_imagem dd 0
  ultimo_byte dd 0

  promptArquivoEntrada db "Qual nome do arquivo de entrada? ", 0
  promptArquivoSaida db "Qual nome do arquivo de saida? ", 0
  promptCoordenadaX db "Digite o valor da coordenada X: ", 0
  promptCoordenadaY db "Digite o valor da coordenada Y: ", 0
  promptLargura db "Digite o valor da largura: ", 0
  promptAltura db "Digite o valor da altura: ", 0

.code
start:
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov inputHandle, eax
    
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax

    invoke WriteConsole, outputHandle, addr promptArquivoEntrada, sizeof promptArquivoEntrada, addr writeCount, NULL
    invoke ReadConsole, inputHandle, addr arquivoEntrada, sizeof arquivoEntrada, addr readCount, NULL
    mov esi, offset arquivoEntrada
    proximo5:                      ; Tratamento do nome do arquivo de entrada
        mov al, [esi]
        inc esi
        cmp al, 13
        jne proximo5
        dec esi
        xor al, al
        mov [esi], al

    invoke CreateFile, addr arquivoEntrada, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL ; criando arquivo de entrada
    mov inputFileHandle, eax

    invoke WriteConsole, outputHandle, addr promptCoordenadaX, sizeof promptCoordenadaX, addr writeCount, NULL
    invoke ReadConsole, inputHandle, addr string1, sizeof string1, addr readCount, NULL
    mov esi, offset string1
    proximo1:
        mov al, [esi]
        inc esi
        cmp al, 13
        jne proximo1
        dec esi
        xor al, al
        mov [esi], al
    invoke atodw, addr string1
    mov coordenadaX, eax

    invoke WriteConsole, outputHandle, addr promptCoordenadaY, sizeof promptCoordenadaY, addr writeCount, NULL
    invoke ReadConsole, inputHandle, addr string2, sizeof string2, addr readCount, NULL
    mov esi, offset string2
    proximo2:
        mov al, [esi]
        inc esi
        cmp al, 13
        jne proximo2
        dec esi
        xor al, al
        mov [esi], al
    invoke atodw, addr string2
    mov coordenadaY, eax

    invoke WriteConsole, outputHandle, addr promptLargura, sizeof promptLargura, addr writeCount, NULL
    invoke ReadConsole, inputHandle, addr string3, sizeof string3, addr readCount, NULL
    mov esi, offset string3
    proximo3:
        mov al, [esi]
        inc esi
        cmp al, 13
        jne proximo3
        dec esi
        xor al, al
        mov [esi], al
    invoke atodw, addr string3
    mov largura, eax

    invoke WriteConsole, outputHandle, addr promptAltura, sizeof promptAltura, addr writeCount, NULL
    invoke ReadConsole, inputHandle, addr string4, sizeof string4, addr readCount, NULL
    mov esi, offset string4
    proximo4:
        mov al, [esi]
        inc esi
        cmp al, 13
        jne proximo4
        dec esi
        xor al, al
        mov [esi], al
    invoke atodw, addr string4
    mov altura, eax

    invoke WriteConsole, outputHandle, addr promptArquivoSaida, sizeof promptArquivoSaida, addr writeCount, NULL
    invoke ReadConsole, inputHandle, addr arquivoSaida, sizeof arquivoSaida, addr readCount, NULL
    mov esi, offset arquivoSaida
    proximo6:
        mov al, [esi]
        inc esi
        cmp al, 13
        jne proximo6
        dec esi
        xor al, al
        mov [esi], al

    invoke CreateFile, addr arquivoSaida, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL ; arquivo de saída
    mov outputFileHandle, eax

    invoke ReadFile, inputFileHandle, addr bytes_totais, 18, addr readCount, NULL
    invoke WriteFile, outputFileHandle, addr bytes_totais, 18, addr writeCount, NULL

    invoke ReadFile, inputFileHandle, addr largura_imagem, 4, addr readCount, NULL
    invoke WriteFile, outputFileHandle, addr largura_imagem, 4, addr writeCount, NULL

    invoke ReadFile, inputFileHandle, addr bytes_totais, 32, addr readCount, NULL
    invoke WriteFile, outputFileHandle, addr bytes_totais, 32, addr writeCount, NULL

    mov eax, largura_imagem
    add eax, largura_imagem
    add eax, largura_imagem
    mov byte_imagem, eax     ; Descubro quantos bytes tem em uma linha da imagem

loop_start:
    invoke ReadFile, inputFileHandle, addr linha_imagem, byte_imagem, addr readCount, NULL
    cmp readCount, 0  ; Verifica se a leitura foi concluida (saber se chegou na ultima linha)
    je fim_loop

    mov eax, contador
    cmp eax, coordenadaY
    jl escreve_linha
    jmp compara_altura   ; Caso a minha linha seja maior que a coordenadaY, outra verificação é necessária ser feita

inicia_pilha:
    push offset linha_imagem
    push coordenadaX
    push largura
    call chama_funcao

escreve_linha:
    invoke WriteFile, outputFileHandle, addr linha_imagem, byte_imagem, addr readCount, NULL
    inc contador       ; Próxima linha
    jmp loop_start

compara_altura:
    mov eax, coordenadaY  ; Sempre que a linha for maior que a coordenadaY
    add eax, altura       ; esse trecho verifica se a linha eh menor ou igual a altura (ou seja, se está dentro da área a ser censurada)
    cmp contador, eax
    jge escreve_linha
    jmp inicia_pilha

chama_funcao:
     push ebp
     mov ebp, esp
     sub esp, 12
     mov eax, dword ptr [ebp+16]
     mov dword ptr [ebp-4], eax
     mov eax, dword ptr [ebp+12]
     mov dword ptr [ebp-8], eax
     mov eax, dword ptr [ebp+8]
     mov dword ptr [ebp-12], eax
       
     mov ecx, dword ptr [ebp-8] 
     add ecx, dword ptr [ebp-8]  
     add ecx, dword ptr [ebp-8]
     mov edi, dword ptr [ebp+16]
     mov ebx, dword ptr [ebp-12]
     add ebx, dword ptr [ebp-12]
     add ebx, dword ptr [ebp-12]
     add ebx, ecx
     mov ultimo_byte, ebx       ; Multiplico por 3 a coordenadaX e multiplico por 3 a largura e somo para saber qual o ultimo byte a ser censurado

alterar_pixel:
    mov byte ptr [edi + ecx], 0       ; Endereço base do array (recebido como parâmetro) e índice do pixel 
    mov byte ptr [edi + ecx + 1], 0 
    mov byte ptr [edi + ecx + 2], 0 
    add ecx, 3
    cmp ecx, ultimo_byte   ; Verifico se o ultimo byte foi censurado
    jg fim_preencher
    jmp alterar_pixel

fim_preencher:
    mov esp, ebp
    pop ebp
    ret 12

fim_loop:
   invoke CloseHandle, inputFileHandle
   invoke CloseHandle, outputFileHandle
   invoke ExitProcess, 0
   end start
  


   
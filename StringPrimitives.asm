TITLE String Primitives and Macros (StringPrimitives.asm)

; Author: Lisa Bettcher
; Last Modified: 03/16/2021
; Description: This program prompts the user to enter 10 signed decimal integers
;     small enough to fit in a 32 bit register. Then the program displays a list
;     of the integers, the sum, and the average. It is assumed that the total
;     sum of the valid numbers will fit inside a 32 bit register.


INCLUDE Irvine32.inc


; ----------------------------------------------------------------------------
; Name: mGetString
;
; Displays a prompt and gets a string from the user.
;
; Preconditions: do not use eax, ebx, ecx, edx as arguments; mDisplayString
;     is implemented and receives the address of a string to display.
;
; Receives:
;     prompt     = address of prompt (string)
;     buffer     = address of buffer 
;     bufferSize = buffer size
;     byteCount  = address of byteCount, to store number of characters
;
; Returns:
;     buffer     = address containing user input string
;     byteCount  = address containing number of characters entered
; ----------------------------------------------------------------------------
mGetString MACRO prompt:REQ, buffer:REQ, bufferSize:REQ, byteCount:REQ
  push  eax
  push  ebx
  push  ecx
  push  edx

  ; display a prompt
  mDisplayString prompt

  ; get user keyboard input into memory location buffer
  mov   edx, buffer
  mov   ecx, bufferSize
  call  ReadString
  mov   ebx, byteCount              ; number of bytes read (length of string)
  mov   [ebx], eax

  pop   edx
  pop   ecx
  pop   ebx
  pop   eax
ENDM


; ----------------------------------------------------------------------------
; Name: mDisplayString
;
; Prints a string stored in a specified memory location.
;
; Preconditions: do not use edx as an argument.
;
; Receives:
;     buffer = address of string to print
; ----------------------------------------------------------------------------
; buffer reference to string to print (input parameter, by reference)
mDisplayString MACRO buffer:REQ
  push  edx
  mov   edx, buffer
  call  WriteString
  pop   edx
ENDM


NUMS            =       10
NUMS_STR        TEXTEQU <">, %NUMS, <">


.data
  titleName     BYTE    "Designing low-level I/O procedures",
                        13,10,"Written by: Lisa Bettcher",13,10,13,10,0
  instruct      BYTE    "Please provide ",NUMS_STR," signed decimal integers.",13,10,
                        "Each number needs to be small enough to fit inside a 32 ",
                        "bit register.",13,10,"After you finish inputting the raw numbers ",
                        "I will display a list of",13,10,"the integers, their sum, ",
                        "and their average value.",13,10,13,10,0
  prompt        BYTE    "Please enter a signed number: ",0
  errorMsg      BYTE    "ERROR: You did not enter a signed number ",
                        "or your number was too big.",13,10,0
  reprompt      BYTE    "Please try again: ",0
  enteredTitle  BYTE    13,10,13,10,"You entered the following numbers:",13,10,0
  sumTitle      BYTE    13,10,"The sum of these numbers is: ",0
  averageTitle  BYTE    13,10,"The rounded (floor) average is: ",0
  closingMsg    BYTE    13,10,13,10,"Thanks for playing!",0
  commaSpace    BYTE    ", ",0
  stringBuffer  BYTE    32 DUP(?)
  reverseBuffer BYTE    32 DUP(?)
  charCount     DWORD   ?           ; number of bytes entered by user
  userNumber    SDWORD  ?           ; user string converted to number
  numArray      SDWORD  NUMS DUP(?) ; user entered numbers
  sum           SDWORD  ?

  ; EC1
  extraCredit1  BYTE    "**EC 1: Number each line of user input and display a ",
                        "running subtotal.",13,10,13,10,0
  dotSubtotal   BYTE    ". Subtotal: ",0
  dotSpace      BYTE    ". ",0

.code
main PROC

  ; introduction
  mDisplayString OFFSET titleName
  mDisplayString OFFSET extraCredit1
  mDisplayString OFFSET instruct

  ; get 10 valid integers from user, store in array
  mov   sum, 0
  mov   edi, OFFSET numArray
  mov   ecx, LENGTHOF numArray

_GetNumbers:
  ; EC1: number Line of input and display subtotal using WriteVal
  push  OFFSET stringBuffer
  push  OFFSET reverseBuffer
  mov   ebx, NUMS+1
  sub   ebx, ecx
  push  ebx
  call  WriteVal                    ; display number line of input
  mDisplayString OFFSET dotSubtotal
  push  OFFSET stringBuffer
  push  OFFSET reverseBuffer
  push  sum
  call  WriteVal                    ; display subtotal
  mDisplayString OFFSET dotSpace

  ; get number from user
  push  OFFSET reverseBuffer        ; [ebp+72] EC1: use with WriteVal
  push  ebx                         ; [ebp+68] EC1: input line number
  push  OFFSET dotSpace             ; [ebp+64] EC1: print ". " after line number
  push  OFFSET reprompt
  push  OFFSET userNumber
  push  OFFSET errorMsg
  push  OFFSET charCount
  push  SIZEOF stringBuffer
  push  OFFSET stringBuffer
  push  OFFSET prompt
  call  ReadVal
  mov   eax, userNumber
  add   sum, eax
  mov   [edi], eax                  ; store number in array
  add   edi, TYPE numArray
  dec   ecx
  cmp   ecx, 0
  jz    _DisplayNumbers
  jmp   _GetNumbers

_DisplayNumbers:
  ; display the numbers
  mDisplayString OFFSET enteredTitle
  mov   esi, OFFSET numArray
  mov   ecx, LENGTHOF numArray
_DisplayNumbersLoop:
  push  OFFSET stringBuffer
  push  OFFSET reverseBuffer
  push  [esi]                       ; number in array
  call  WriteVal
  add   esi, TYPE numArray
  cmp   ecx, 1
  je    _SkipComma                  ; no comma after last number
  mDisplayString OFFSET commaSpace
_SkipComma:
  loop  _DisplayNumbersLoop

  ; display sum
  mDisplayString OFFSET sumTitle
  push  OFFSET stringBuffer
  push  OFFSET reverseBuffer
  push  sum
  call  WriteVal

  ; display rounded average (floor)
  mDisplayString OFFSET averageTitle
  mov   eax, sum
  cdq
  mov   ebx, NUMS
  idiv  ebx
  cmp   edx, 0                      ; if negative remainder, floor rounds down
  jge   _DisplayAverage
  dec   eax

_DisplayAverage:
  push  OFFSET stringBuffer
  push  OFFSET reverseBuffer
  push  eax                         ; quotient = rounded average floor for pos
  call  WriteVal

  ; display closing message
  mDisplayString OFFSET closingMsg

  INVOKE ExitProcess,0
main ENDP


; ----------------------------------------------------------------------------
; Name: ReadVal
;
; Gets user input string and convert to numeric value representation (SDWORD).
;
; Preconditions: mGetString is implemented and receives the address of prompt,
;     the address of stringBuffer, size of stringBuffer, and address of
;     charCount. WriteVal is implemented to display input line number (EC1).
;
; Postconditions: none.
;
; Receives:
;     [ebp+36]  = reference to prompt
;     [ebp+40]  = reference to stringBuffer
;     [ebp+44]  = size of stringBuffer
;     [ebp+48]  = reference to charCount
;     [ebp+52]  = reference to errorMsg
;     [ebp+56]  = reference to userNumber
;     [ebp+60]  = reference to reprompt
;     [epb+64]  = reference to dotSpace
;     [epb+68]  = value of input line number to print
;     [epb+72]  = reference to reverseBuffer
;
; Returns: valid numeric value in userNumber
; ----------------------------------------------------------------------------
ReadVal PROC
  pushad
  mov   ebp, esp

  ; @prompt, @stringBuffer, sizeof stringBuffer, @charCount
  mGetString [ebp+36], [ebp+40], [ebp+44], [ebp+48]

  ; validate and convert string to numeric value (SDWORD)
_ProcessInput:
  mov   esi, [ebp+40]               ; reference to stringBuffer
  mov   edx, [ebp+48]               ; reference to charCount
  mov   ecx, [edx]                  ; charCount value
  mov   edi, 0                      ; accumulate integer value
  mov   ebx, 0                      ; 0 is positive, 1 is negative

  ; validate
  ; check for empty input
  cmp   ecx, 0
  jz    _Invalid

  ; check size for 32-bit register
  cmp   ecx, 11                     ; max value is 10 digits and a possible sign
  jg    _Invalid

  cld
  ; check first char for + and -
  lodsb
  cmp   al, 43                      ; +
  je    _FirstSign
  cmp   al, 45                      ; -
  je    _Negative
  ; first char is not a sign, set pointer back to load first char again
  dec   esi
  ; check size for 32-bit register
  cmp   ecx, 10                     ; max value is 10 digits without sign
  jg    _Invalid
  jmp   _CharToInt

_Negative:
  inc   ebx                         ; 1 is negative

_FirstSign:
  dec   ecx                         ; dec loop counter for sign char

_CharToInt:
  lodsb
  cmp   al, 48                      ; 0
  jl    _Invalid
  cmp   al, 57                      ; 9
  jg    _Invalid
  sub   al, 48                      ; numInt = 10 * numInt + (numChar - 48)
  imul  edi, 10
  movsx eax, al
  cmp   ebx, 0                      ; add or subtract, ebx = 0 positive (add)
  je    _Add
  sub   edi, eax
  jmp   _CheckOverflow

_Add:
  add   edi, eax

_CheckOverflow:
  jo    _Invalid
  loop  _CharToInt

  jmp   _StoreNumber

_Invalid:
  mDisplayString [ebp+52]           ; error message

  ; EC1: display input line number with WriteVal
  push  [ebp+40]
  push  [ebp+72]
  push  [ebp+68]
  call  WriteVal
  mDisplayString [ebp+64]           ; print dotSpace

  ; @reprompt, @stringBuffer, sizeof stringBuffer, @charCount
  mGetString [ebp+60], [ebp+40], [ebp+44], [ebp+48]
  jmp   _ProcessInput

_StoreNumber:
  mov   edx, [ebp+56]               ; reference to userNumber variable
  mov   [edx], edi                  ; store integer value at userNumber

  popad
  ret   40
ReadVal ENDP

; ----------------------------------------------------------------------------
; Name: WriteVal
;
; Converts numeric SDWORD value to string of ascii digits and displays the string.
;
; Preconditions: mDisplayString is implemented and receives the address of a
;     string to display.
;
; Receives:
;     [ebp+36] = numeric SDWORD value
;     [ebp+40] = reference to reverseBuffer
;     [ebp+44] = reference to stringBuffer
; ----------------------------------------------------------------------------
WriteVal PROC
  pushad
  mov   ebp, esp

  mov   eax, [ebp+36]
  mov   edi, [ebp+40]
  mov   esi, 0                      ; number is pos/neg (0 pos, else neg)
  mov   ecx, 0                      ; count how many chars are written

  cld
  cmp   eax, 0                      ; check if number is pos/neg
  jge   _IntToString
  dec   esi                         ; neg number esi = -1

_IntToString:
  ; divide number by 10 and store remainder until quotient is 0
  cdq
  mov   ebx, 10
  idiv  ebx
  cmp   esi, 0                      ; esi = 0 means positive number
  jz    _IntToChar
  neg   edx                         ; change negative remainder to positive
_IntToChar:
  add   edx, 48                     ; remainder + 48 = ascii for "0" to "9"
  push  eax                         ; save quotient
  mov   eax, edx
  stosb
  inc   ecx
  pop   eax                         ; restore quotient
  cmp   eax, 0                      ; stop if quotient is 0
  jnz   _IntToString
  cmp   esi, 0
  jz    _ReverseString
  mov   al, "-"                     ; store "-" if neg
  stosb
  inc   ecx

_ReverseString:
  mov   esi, edi                    ; reverse string is now source
  dec   esi                         ; pointer was one past the end
  mov   edi, [ebp+44]
_ReverseLoop:
  std                               ; read esi in reverse
  lodsb
  cld                               ; write edi forward
  stosb
  loop  _ReverseLoop
  mov   al, 0                       ; add null terminator to stringBuffer
  stosb
  mDisplayString [ebp+44]

  popad
  ret   12
WriteVal ENDP

END main

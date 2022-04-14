TITLE Macro Project 6     (Proj6_baxterju.asm)

; Author: Justin Baxter
; Last Modified: 3/13/2022
; OSU email address: baxterju@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:         6        Due Date: 3/13/2022
; Description: This program will ask the user to input 10 integers which will be input 
;              as strings. The program will then convert the ASCII character to a valid 
;			   number value. The program will then calculate the sum and truncated average 
;			   of the 10 values. Finally it will convert the 10 numbers, sum and truncated 
;              average back to a string and display it to the screen.


INCLUDE Irvine32.inc

; --------------------------------------------------------------------------------- 
; Name: mGetString 
; 
; Gets a string of numbers from user
; 
; Preconditions: ReadVal must be called by main and then invoke macro
; 
; Receives: 
; prompt = prompt for user input
; buffer = empty string to store input
; maxSize = max number of characters user can input
; 
; returns: user input as string
; --------------------------------------------------------------------------------- 
mGetString	MACRO  prompt, buffer, maxSize

	mov		EDX, prompt
	call	WriteString
	mov		EDX, buffer
	MOV		ECX, maxSize
	call	ReadString
	
ENDM

; --------------------------------------------------------------------------------- 
; Name: mDisplayString
; 
; Displays numbers as strings
; 
; Preconditions: WriteVal must have converted numbers back to string and invoke macro
; 
; Receives: 
; string = number converted to string
; 
; returns: string displayed to screen
; --------------------------------------------------------------------------------- 
mDisplayString	MACRO	string
	push	EDX
	mov		EDX, string
	call	WriteString
	pop		edx

ENDM
.data
buffer		BYTE 32 DUP(?)						; input buffer 
maxCount	DWORD	20							;max input size of string
rules1		BYTE	"Please enter 10 signed integers", 10, 13, 0
rules2		BYTE	"Each number needs to be small enough to fit inside a 32 bit register. After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value.",13,10,0
prompt		BYTE	"Please enter a signed integer: ",0
numList		SDWORD	10 DUP(?)					;array to be filled with the numerical values
numInt		SDWORD	0							;used to hold the converted number
numsEntered	BYTE	"The numbers you entered are: ",13,10,0
sum			DWORD	0
sumDisplay	BYTE	13,10,"The sum of your numbers is: ",13,10,0
average		DWORD	0
avgDisplay	BYTE	13,10,"The truncated average is: ",13,10,0
invalid		BYTE	"String is invalid.",13,10,0
goodbye		BYTE	"Thanks for playing! Goodbye",13,10,0
myNum		SDWORD	?
.code
main PROC
	mov		EDX, offset rules1
	call	WriteString
	mov		EDX, offset rules2
	call	WriteString
	mov		ECX, 10								;set counter to 10 for total numbers to be read
	mov		edi, offset numList					;move array to hold converted numbers to edi
	_read:
	push	offset invalid						
	push	numInt
	push	offset prompt
	push	offset buffer
	push	maxCount
	call	ReadVal	
	mov		[edi], edx							;move the converted number into the array of integers
	add		edi, TYPE numList					;point to next index in array
	loop	_read
	push	offset numList
	call	sumNums								;get the sum of all the numbers
	mov		sum, eax
	push	sum
	call	avgNums								;get the average of all the numbers
	mov		average, eax
	mov		EDX, offset numsEntered
	call	WriteString							
	mov		ECX, LENGTHOF numList				
	;mov		esi, offset numList
	mov		ebx, 0
	_write:
	push	numList[ebx*4]						;push each value and call WriteVal to convert number to string
	call	WriteVal
	mov		al, ' '
	call	WriteChar
	inc		ebx
	loop	_write
	push	sum
	mov		edx, offset sumDisplay
	call	WriteString
	call	WriteVal							;display sum as a string
	push	average
	mov		edx, offset avgDisplay
	call	WriteString
	call	WriteVal							;display average as a string

	
	INVOKE ExitProcess, 0	;exit to operating system
main ENDP

; -- ReadVal --
; Procedure to get the users input and convert it to number
; preconditions: Main must pass the parameters to stack and call procedure
; postconditions: EDX changed to value of number
; receives: prompt for invalid input, variable to hold each number, prompt to enter input, buffer string and maxCount
; returns: user inputed string converted to a number
ReadVal	PROC
	push	ebp
	mov		ebp, esp
	push	ebx
	push	ecx
	_getString:
	mGetString	[ebp+16], [ebp+12], [ebp+8]		;invoke the macro to get the user's input as a string
	push	eax									;push number of bytes entered to stack
	mov		esi, edx							;string offset into ESI
	mov		ecx, eax							;number of characters entered into ECX
	mov		ebx, 0								;EBX will be used as count, initialize to 0
	mov		EDX, [ebp+20]						;move numInt into EDX
	push	EDX									
	mov		al, [esi]
	cmp		eax, 43								;check if first char in string is +
	je		_positive
	cmp		eax, 45								;check if first char in string is -
	je		_negative							
_convertChar:
	pop		EDX									;pop current value of numInt to EDX
	mov		al, [esi + ebx*1]					;move each char to al and make sure it's within 0 and 9, no other characters allowed
	cmp		eax, 48
	jl		_invalid
	cmp		eax, 57
	jg		_invalid
	sub		EAX, 48								;convert to dec from ASCII string	 
	push	EAX									;push converted decimal value to stack
	mov		EAX, EDX							;move current value of numInt to EAX
	mov		EDX, 10								
	mul		EDX									;multiply numInt by 10
	pop		EDX									;pop converted decimal value to EDX
	add		EAX, EDX							;add current value of numInt to converted decimal value
	inc		ebx
	push	EAX									
	xor		EAX, EAX							;zero out the EAX register 
	cmp		ebx, ecx							;increment EBX and continue displaying elements until EBX=ECX
	jl		_convertChar
	jmp		_exit
_positive:
	inc		ebx									;if the first char entered is +, drop the + and convert string as normal
	jmp		_convertChar
_negative:
	inc		ebx									;increment ebx to point to next char if first one is -
_negLoop:
	pop		EDX									;pop current value of numInt to EDX
	mov		al, [esi + ebx*1]					;move each char to al and make sure it's within 0 and 9, no other characters allowed
	cmp		eax, 48
	jl		_invalid
	cmp		eax, 57
	jg		_invalid
	sub		EAX, 48								;convert to dec from ASCII string	 
	push	EAX									;push converted decimal value to stack
	mov		EAX, EDX							;move current value of numInt to EAX
	mov		EDX, 10								
	mul		EDX									;multiply numInt by 10
	pop		EDX									;pop converted decimal value to EDX
	add		EAX, EDX							;add current value of numInt to converted decimal value
	inc		ebx
	push	EAX									
	xor		EAX, EAX							;zero out the EAX register 
	cmp		ebx, ecx							;increment EBX and continue displaying elements until EBX=ECX
	jl		_negLoop
	pop		eax
	imul	eax, -1								;negates the value in eax (should anyway, can't figure this part out)
	push	eax
	jmp		_exit
_invalid:
	mov		edx, [ebp+24]
	call	WriteString							;if char not 0 through 9, diplay prompt that input is invalid and get new input
	pop		eax
	jmp		_getString
_exit:
	pop		edx									;pop the converted number into edx, restore other registers
	pop		eax
	pop		ecx
	pop		ebx
	pop		ebp
	ret		20
ReadVal	ENDP

; -- WriteVal --
; Procedure to convert the users numbers back to string values and display to screen
; preconditions: user must have input 10 valid strings, main passes array of numbers to stack
; postconditions: numbers are changed to strings
; receives: each number passed from main
; returns: numbers converted to string and displayed to screen
WriteVal PROC
LOCAL myString[11]:BYTE						;local string variable to hold the converted values
LOCAL count:DWORD							;count to be used to determine string length
	mov		count, 0
	lea		eax, myString					;move the string so eax points at address, then move to edi
	mov		edi, eax
	push	ebx
	mov		ebx, 10							;move 10 to ebx for divide by 10 conversion
	push	ecx
	mov		ecx, 0
	mov		eax, [ebp+8]					;move the integer to eax
	_convert:
	xor		edx, edx
	div		ebx								;divide integer by 10, then push the quotient to stack
	push	eax
	mov		eax, edx						;move remainder to eax and add 48 to convert to ASCII 
	add		eax, 48
	mov		edx, eax
	pop		eax								;pop the quotient to eax
	push	edx								;push the converted remainder to stack
	inc		ecx	
	cmp		eax, 0
	jg		_convert
	cld
	_store:
	pop		eax
	inc		count							;increment count for each character stored to determine string length
	STOSB
	loop	_store
	xor		eax, eax
	mov		ebx, count
	lea		eax, myString					;move string so eax points at address and insert null terminator after last character
	mov		byte ptr [eax+ebx],0
	mDisplayString eax						;invoke the macro to display the string
	pop		ecx
	pop		ebx
	ret		4

	
WriteVal ENDP

; -- sumNums --
; Procedure to calculate sum of all numbers
; preconditions: user input must have been converted to numbers and stored in array
; postconditions: sum variable changed
; receives: array of converted numbers
; returns: sum of all numbers
sumNums	PROC
	push	ebp
	mov		ebp, esp
	mov		ecx, 10							;move 10 into ecx to loop through all numbers
	mov		esi, [ebp+8]					;move array to esi
	mov		eax, 0							;initialize sum to 0
	_sumLoop:
	add		eax, [esi]						;add each value to eax
	add		esi, 4
	loop	_sumLoop
	pop		ebp
	ret		4
sumNums	ENDP

; -- avgNums --
; Procedure to calculate truncated average of all numbers
; preconditions: sum must have been calculated
; postconditions: average variable changed
; receives: array of converted numbers
; returns: sum of all numbers
avgNums PROC
	push	ebp
	mov		ebp, esp
	mov		ebx, 10							;move 10 to divisor for number of integers
	mov		eax, [ebp+8]					;move sum to eax
	xor		edx, edx
	div		ebx								;divide sum by 10 to get truncated average
	pop		ebp
	ret		4
avgNums ENDP
END main

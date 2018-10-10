TITLE Project 6B    (proj06.asm)

; Author: Joel Herrick
; Last Modified: 5/31/18
; OSU email address: herricjo@oregonstate.edu
; Course number/section: 271-400
; Project Number: 6             Due Date: 6/10/18
; Description: Implementing low-level IO Procedures
;			   Implementing recursion
;			   Parameter passing on system stack
;			   Maintaining activation records

INCLUDE Irvine32.inc

; (insert macros here)
;-----------------------------------------
; mWriteStr
;
; MACRO to write string to console
;------------------------------------------
mWriteStr MACRO buffer
	push	edx
	mov		edx, buffer
	call	WriteString
	pop		edx
ENDM

; (insert constant definitions here)
.data
nLOWER = 3			;lower bound of n
nUPPER = 12			;upper bound of n
rLOWER = 1  		;lower bound of r
maxSize = 100   	;max size of input str

intro        BYTE   "Welcome to the Combinations Calculator",0
intro_1      BYTE   "           Implemented by Joel Herrick",0
intro_2      BYTE   "I'll give you a combinations problem.  You enter your answer, ",0
intro_3      BYTE   "and I'll let you know if you're right.",0 
prompt_1     BYTE   "Problem:",0 
prompt_2     BYTE   "Number of elements in the set: ",0
prompt_3     BYTE   "Number of elements to choose from the set: ",0
prompt_4     BYTE   "How many ways can you choose? ",0
result_1     BYTE   "There are ",0
result_2     BYTE   " combinations of ",0
result_3     BYTE   " items from a set of ",0
incorrect    BYTE   "You need more practice.",0
correct      BYTE   "You are correct!",0
inputError   BYTE   "Invalid response. ",0
repeatProb   BYTE   "Another problem? (y/n): ",0
goodbye      BYTE   "OK ... goodbye.",0

; (insert variable definitions here)

userAns		DWORD    ?                  ;place for user's answer in int form
userAnsStr  DWORD    maxSize DUP(?)     ;place for user input in str form
ansLen		DWORD	 ?                  ;place for length of user answer string
elementsN   DWORD    ?					;place for request n elements in set
chooseR		DWORD    ?                  ;place for request choose r from set of n
nminr	    DWORD    ?                  ;place for (n-r)
nFact	    DWORD    ?                  ;place for n!
rFact       DWORD    ?                  ;place for r!
nminrFact	DWORD    ?                  ;place for (n-r)!
answer      DWORD    ?           		;place for answer how many ways can choose
isCorrect	DWORD	 ?                  ;place to indicate whether answer is correct 

; (insert executable instructions here)
.code

;-----------------------------------------
; main
;
; pushes parameters and calls procedures
; Receives: n/a
; Returns: n/a
; Preconditions: n/a 
; Registers Changed: n/a 
;------------------------------------------

main PROC

	call	Randomize					;seed random # generator

	;--------INTRODUCTION------------;
	push	OFFSET intro_3				;ebp+20
	push	OFFSET intro_2				;ebp+16	
	push	OFFSET intro_1				;ebp+12
	push	OFFSET intro				;ebp+8
	call	introduction		

again:
	;--------SHOW PROBLEM------------;
	push	OFFSET chooseR				;ebp+24
	push	OFFSET elementsN			;ebp+20
	push	OFFSET prompt_3				;ebp+16
	push	OFFSET prompt_2				;ebp+12
	push	OFFSET prompt_1				;ebp+8
	call	showProblem				

	;--------GET DATA---------------;
	push	OFFSET prompt_4				;ebp+12
	push	OFFSET userAnsStr			;ebp+8
	call	getData			

	;-------COMBINATIONS------------;
	push	OFFSET answer				;ebp+20
	push	nminr						;ebp+16
	push	chooseR						;ebp+12
	push	elementsN					;ebp+8
	call	combinations

	;-------SHOW RESULT------------;
	call	CrLf
	push	OFFSET incorrect			;ebp+40
	push	OFFSET correct				;ebp+36
	push	OFFSET result_3				;ebp+32
	push	OFFSET result_2				;ebp+28
	push	OFFSET result_1				;ebp+24
	push	isCorrect					;ebp+20
	push	elementsN					;ebp+16
	push	chooseR						;ebp+12
	push	answer						;ebp+8
	call	showResults

	;-------RUN AGAIN-------------;
inpError:
	mWriteStr OFFSET repeatProb			;another problem?
	call	ReadChar					;get char input
	cmp		al, 121						;= to y?
	je		again						;if yes, repeat
	cmp		al, 110						;= to n?
	je		done						;if yes, finished
	call	CrLf
	mWriteStr OFFSET inputError			;otherwise output error
	jmp		inpError					;repeat question
done:
	;------SAY GOODBYE------------;
	call	CrLf
	mWriteStr OFFSET goodbye			;ok... goodbye
	call	CrLf

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

;-----------------------------------------
; introduction
;
; display title, programmer name, and instructions
; Receives: strings
; Returns: nothing
; Preconditions: none
; Registers Changed: edx (restored)
;------------------------------------------

introduction PROC
	push	edx				;save edx reg
	push	ebp
	mov		ebp, esp		;create stack array

	mWriteStr [ebp+8+4]		;welcome...
	call	CrLf

	mWriteStr [ebp+12+4]	;implemented by...
	call	CrLf

	mWriteStr [ebp+16+4]	;i'll give you a combinatorics problem...
	call	CrLf

	mWriteStr [ebp+20+4]	;and let you know if you're right...

	pop		ebp				;restore old ebp
	pop		edx
	ret		16				;clear stack
introduction ENDP

;-----------------------------------------
; showProblem
;
; generates the random numbers and displays the problem
; accepts addresses of n and r
; Receives: addresses of prompt strings
; Returns: none
; Preconditions: none 
; Registers Changed: eax, edx (restored)
;------------------------------------------
showProblem PROC
	push	eax					;save used registers
	push	edx
	push	ebp					;create stack array
	mov		ebp, esp

	call	CrLf
	call	CrLf

	mWriteStr [ebp+8+8]			;problem...
	call	CrLf

	mov		eax,nUPPER			;get hi
	sub		eax,nLOWER			;subtract lo
	inc		eax					;inc hi
	call	RandomRange			;call proc
	add		eax,nLOWER			;add lo
	mov		ebx, [ebp+20+8]
	mov		[ebx], eax		;move result into N var

	mWriteStr [ebp+12+8]		;# elements in set...
	call	WriteDec
	call	CrLf

	mov		eax,elementsN		;get hi
	sub		eax,rLOWER			;subtract lo
	inc		eax					;inc hi
	call	RandomRange			;call proc
	add		eax,rLOWER			;add lo
	mov		ebx, [ebp+24+8]
	mov		[ebx], eax		;move result into R var

	mWriteStr [ebp+16+8]		;# elements choose from set...
	call	WriteDec
	call	CrLf
	
	pop		ebp					;restore old ebp
	pop		edx					;restore used registers
	pop		eax
	ret		12					;clear stack
showProblem ENDP

;-----------------------------------------
; getData
;
; prompt / get the user's answer in string form
; answer should be passed to getData by address
; Receives: address of string to hold users answer, string to prompt
; Returns:  calculated correct answer, user input answer
; Preconditions: none
; Registers Changed: eax, ebx, ecx, edx, esi (restored)
;------------------------------------------
getData PROC
	push	eax					;save used registers
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	ebp					;create stack array
	mov		ebp, esp

getInput:
	mWriteStr [ebp+12+20]		;how many ways can you choose...
	mov		edx, [ebp+8+20]		;move empty string to edx
	mov		ecx, maxSize		;move max string size to ecx

	call	ReadString			;get string

	mov		ansLen, eax			;move eax to variable to hold string length
	mov		ecx, ansLen			;move variable to ecx (counter)
	mov		esi, [ebp+8+20]		;move string to esi
	mov		userAns, 0			;clear answer
	cld							;set direction

L1:
	mov		ebx,10				;move 10 to ebx
	mov		eax,userAns			;move cur answer to eax
	mul		ebx					;multiply cur answer by 10
	mov		userAns,eax			;move eax/answer back to variable
	
	xor		eax,eax				;clear eax
	lodsb						;iterate through string
	cmp		al,48				;check number lower bound
	jl		nonInt				;jump if below
	cmp		al,57				;check number upper bound
	jg		nonInt				;jump if above
	jmp		strOK				;else continue

nonInt:
	mWriteStr OFFSET inputError	;print error message
	call	CrLf
	jmp		getInput			;repeat input

strOK:
	sub		al,48				;subtract 48 (turn string into int)
	add		eax, userAns		;add prev ans to eax
	mov		userAns,eax			;move eax to cur ans
	loop	L1					;loop until done

	pop		ebp					;restore old ebp
	pop		esi					;restore used registers
	pop		edx
	pop		ecx
	pop		ebx
	pop		eax
	ret		8					;clear stack
getData ENDP

;-----------------------------------------
; combinations
;
; does the calculations
; accepts n and r by value and result by address
; calls factorial 3 times to calculate n! r! and (n-r)!
; calculates n!/(r!(n-r)!) and stores the result
; Receives: n-r, r, n
; Returns: n!, r!, n-r!
; Preconditions: none
; Registers Changed: eax, ebx, ecx, edx (restored)
;------------------------------------------
combinations PROC
	push	eax				;save used registers
	push	ebx
	push	ecx
	push	edx
	push	ebp				;create stack array
	mov		ebp,esp

	push	elementsN
	call	factorial		;get n!
	mov		nFact, edx		;store in nFact

	push	chooseR
	call	factorial		;get r!
	mov		rFact, edx		;store in rFact

	mov		eax, elementsN
	sub		eax, chooseR	;calc n-r
	mov		nminr, eax		;store in nminr
	
	push	nminr
	call	factorial		;get (n-r)!
	mov		nminrFact, edx	;store in nminrFact
	
	mov		ecx, nFact
	mov		ebx, rFact
	mov		eax, nminrFact

	mul		ebx				;calculate answer
	mov		ebx, eax
	mov		eax, ecx
	mov		edx, 0
	div		ebx

	mov		ebx, [ebp+20+16] ;set up answer
	mov		[ebx], eax		;store in answer

	pop		ebp				;restore old ebp
	pop		edx				;restore used registers
	pop		ecx	
	pop		ebx
	pop		eax
	ret		16				;clear stack
combinations ENDP

;-----------------------------------------
; factorial
;
; performs factorial calculation
; code primarily adapted from Irvine textbook
; Receives: value
; Returns: factorial of that value
; Preconditions: none
; Registers Changed: eax, ebx, edx
;------------------------------------------
factorial PROC
	push	ebp				;create stack array
	mov		ebp,esp

	mov		eax,[ebp+8]		;move number to eax
	cmp		eax,0			;if above zero
	ja		L1				;jump
	mov		eax,1			;otherwise set to 1
	jmp		L2				;jump
L1:	
	dec		eax				;decrement eax
	push	eax				;push onto stack
	call	factorial		;recursive call

ReturnFact:
	mov		ebx,[ebp+8]		;move number to ebx
	mul		ebx				;multiply

L2:
	mov		edx, eax		;save in edx

	pop		ebp				;return old ebp
	ret		4				;clear stack
factorial ENDP

;-----------------------------------------
; showResults
;
; display the students answer, calculated result
; and brief statement about performance
; accepts values of n, r, answer and result
; Receives: n, r, answer, result
; Returns: nothing
; Preconditions: none
; Registers Changed: eax (al), ebx (restored)
;------------------------------------------
showResults PROC
	push	eax				;save registers
	push	ebx
	push	ebp				;create stack array
	mov		ebp,esp

	mWriteStr [ebp+24+8]	;print out results
	mov		eax,[ebp+8+8]
	call	WriteDec	
	mWriteStr [ebp+28+8]
	mov		eax, [ebp+12+8]
	call	WriteDec
	mWriteStr [ebp+32+8]
	mov		eax, [ebp+16+8]
	call	WriteDec
	mov		al, '.'
	call	WriteChar
	call	CrLf
	
	mov		eax,userAns		;set up comparison
	mov		ebx,answer
	cmp		eax,ebx			;compare answers
	je		goodJob			;jump if equal

	mWriteStr [ebp+40+8]	;incorrect message
	call	CrLf
	call	CrLf
	jmp		theEnd

goodJob:					;correct message
	mWriteStr [ebp+36+8]
	call	CrLf
	call	CrLf

theEnd:
	pop		ebp				;return old ebp
	pop		ebx				;restore used registers
	pop		eax
	ret		36				;restore the stack
showResults ENDP

END main

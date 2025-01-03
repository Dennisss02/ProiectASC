.data
	formatLD: .asciz "%ld"
	afisareIdInt: .asciz "%ld: (%ld, %ld)\n"
	afisareInt: .asciz "(%ld, %ld)\n"
	v: .space 1025
	n: .space 4
	op: .space 4
	desc: .space 4
	dim: .space 4
	nrFis: .space 4
.text

ADD:
	lea v, %edi
	movl 4(%esp), %eax	/* dim */
	movl 8(%esp), %ebx	/* desc */

	etAdd_egal:
	movl $0, %ecx	/* i */
	etAdd_loopI:
		cmp $1024, %ecx
		jge etAdd_sfarsit

		cmpb $0, (%edi, %ecx, 1)
		jne etAdd_contLoop
		movl %ecx, %edx

		etAdd_loopJ:
			cmp $1024, %edx
			jge etAdd_sfJ		/* j >= 1024 */
			cmpb $0, (%edi, %edx, 1)
			jne etAdd_sfJ		/* v[j] != 0 */

			addl $1, %edx
			jmp etAdd_loopJ

		etAdd_sfJ:
			subl $1, %edx
			movl %edx, %esi
			subl %ecx, %edx
			addl $1, %edx	/* j = j - i + 1 */
			
			cmp %eax, %edx
			jge etAdd_else	/* j - i + 1 >= dim */

			movl %esi, %ecx		/* i = j */
			jmp etAdd_contLoop

			etAdd_else:
				movl %ecx, %edx
				addl %eax, %edx		
				subl $1, %edx	/* j = i + dim - 1 */

				etAdd_loop:
					cmp %ecx, %edx
					jl etAdd_afisare

					movb %bl, (%edi, %edx, 1)

					subl $1, %edx
					jmp etAdd_loop

				etAdd_afisare:
					movl %ecx, %edx
					addl %eax, %edx
					subl $1, %edx	/* j = i + dim - 1 */

					pushl %edx
					pushl %ecx
					pushl %ebx
					pushl $afisareIdInt
					call printf
					popl %ebx
					popl %ebx
					popl %ebx
					popl %ebx

					jmp etAdd_ret

		etAdd_contLoop:
			addl $1, %ecx 
			jmp etAdd_loopI

	etAdd_sfarsit:
		xorl %ecx, %ecx
		xorl %edx, %edx

		pushl %edx
		pushl %ecx
		pushl %ebx
		pushl $afisareIdInt
		call printf
		popl %ebx
		popl %ebx
		popl %ebx
		popl %ebx

	etAdd_ret:
		ret

GET:
	lea v, %edi
	movl 4(%esp), %eax	/* desc */
	movl $0, %ecx
	etGet_loopI:
		cmp $1024, %ecx
		jge etGet_inex

		cmp (%edi, %ecx, 1), %al
		jne etGet_contLoop

		movl %ecx, %edx
		etGet_loopJ:
			cmp (%edi, %edx, 1), %al
			jne etGet_sfJ
			addl $1, %edx
			jmp etGet_loopJ

		etGet_sfJ:
			subl $1, %edx
			etGet_afisare:
				pushl %edx
				pushl %ecx
				pushl $afisareInt
				call printf
				popl %ebx
				popl %ebx
				popl %ebx
			jmp etGet_ret

		etGet_contLoop:
			addl $1, %ecx
			jmp etGet_loopI

	etGet_inex:
		xorl %ecx, %ecx
		xorl %edx, %edx

		pushl %edx
		pushl %ecx
		pushl $afisareInt
		call printf
		popl %ebx
		popl %ebx
		popl %ebx

	etGet_ret:
		ret

DELETE:
	lea v, %edi
	movl 4(%esp), %eax
	xorl %ecx, %ecx
	etDel_loopI:
		cmp $1024, %ecx
		jge etDel_af

		cmp (%edi, %ecx, 1), %al
		jne etDel_contLoop

		movl %ecx, %edx
		etDel_loopJ:
			cmp (%edi, %edx, 1), %al
			jne etDel_af
			movb $0, (%edi, %edx, 1)	/* se sterge v[j] */
			addl $1, %edx
			jmp etDel_loopJ

		etDel_contLoop:
			addl $1, %ecx
			jmp etDel_loopI

	etDel_af:	/* s-au sters toate aparitiile lui desc */
		xorl %ecx, %ecx
		etDel_afLoopI:
			cmp $1024, %ecx
			jge etDel_ret

			cmpb $0, (%edi, %ecx, 1)
			je etDel_afContLoop		/* se sare peste elementele nule */

			movl %ecx, %edx
			xorl %eax, %eax
			movb (%edi, %ecx, 1), %al
			etDel_afLoopJ:
				cmp (%edi, %edx, 1), %al
				jne etDel_afisare 	/* v[i] != v[j] => s-a terminat secventa */
				addl $1, %edx
				jmp etDel_afLoopJ

			etDel_afisare:
				subl $1, %edx

				pushl %edx

				pushl %edx
				pushl %ecx
				pushl %eax
				pushl $afisareIdInt
				call printf
				popl %ebx
				popl %ebx
				popl %ebx
				popl %ebx

				popl %ecx		/* i = j */
				
		etDel_afContLoop:
			addl $1, %ecx
			jmp etDel_afLoopI

	etDel_ret:
		ret

DEFRAGMENTATION:
	lea v, %edi
	xorl %ecx, %ecx
	xorl %edx, %edx
	etDef_loopI:
		cmp $1024, %ecx
		jge etDef_af

		cmpb $0, (%edi, %edx, 1)
		jne etDef_else

		pushl %edx
		etDef_loopJ:
			cmp $1024, %edx
			je etDef_contLoopI

			addl $1, %edx
			movb (%edi, %edx, 1), %bl
			subl $1, %edx
			movb %bl, (%edi, %edx, 1)	/* v[j] = v[j + 1] */

			addl $1, %edx
			jmp etDef_loopJ

		etDef_else:
			addl $1, %edx
			addl $1, %ecx
			jmp etDef_loopI

	etDef_contLoopI:
		popl %edx
		addl $1, %ecx
		jmp etDef_loopI

	etDef_af:
		xorl %ecx, %ecx
		xorl %eax, %eax

		etDef_afLoopI:
			movl %ecx, %edx
			movb (%edi, %ecx, 1), %al

			cmp $1024, %ecx
			je etDef_ret
			cmpb $0, (%edi, %ecx, 1)
			je etDef_ret

			etDef_afLoopJ:
				cmpb (%edi, %edx, 1), %al
				jne etDef_afisare
				addl $1, %edx
				jmp etDef_afLoopJ

			etDef_afisare:
				subl $1, %edx

				pushl %edx

				pushl %edx
				pushl %ecx
				pushl %eax
				pushl $afisareIdInt
				call printf
				popl %ebx
				popl %ebx
				popl %ebx
				popl %ebx
				
				popl %ecx

		etDef_afContLoopI:
			addl $1, %ecx
			jmp etDef_afLoopI

	etDef_ret:
		ret

.global main
main:
	citireN:
		pushl $n
		pushl $formatLD
		call scanf
		popl %ebx
		popl %ebx

	loopN:
		cmpl $1, n
		jl etexit

		citireOp:
			pushl $op
			pushl $formatLD
			call scanf
			popl %ebx
			popl %ebx
		movl op, %ebx
		cmp $1, %ebx
		je etADD
		cmp $2, %ebx
		je etGET
		cmp $3, %ebx
		je etDELETE
		cmp $4, %ebx
		je etDEFRAGMENTATION

		etADD:
			citireNrFis:
				pushl $nrFis
				pushl $formatLD
				call scanf
				popl %ebx
				popl %ebx

			loopAddFis:
				cmpl $1, nrFis
				jl nextOp

				citireDD:
					pushl $desc
					pushl $formatLD
					call scanf
					popl %ebx
					popl %ebx

					pushl $dim
					pushl $formatLD
					call scanf
					popl %ebx
					popl %ebx

				movl dim, %eax
				xorl %edx, %edx
				movl $8, %ecx
				div %ecx		/* dim = dim / 8 */
				movl %eax, dim
				cmpl $0, %edx
				je et_call

				addl $1, dim

				et_call:
				pushl desc
				pushl dim
				call ADD
				popl %ebx
				popl %ebx
				subl $1, nrFis
				jmp loopAddFis

		etGET:
			pushl $desc
			pushl $formatLD
			call scanf
			popl %ebx
			popl %ebx

			pushl desc
			call GET
			popl %ebx
			jmp nextOp

		etDELETE:
			pushl $desc
			pushl $formatLD
			call scanf
			popl %ebx
			popl %ebx

			pushl desc
			call DELETE
			popl %ebx
			jmp nextOp

		etDEFRAGMENTATION:
			call DEFRAGMENTATION
			jmp nextOp

		nextOp:
			subl $1, n
			jmp loopN

	etexit:
		pushl $0
	    call fflush
	    popl %eax
	    
	    movl $1, %eax
	    xorl %ebx, %ebx
	    int $0x80

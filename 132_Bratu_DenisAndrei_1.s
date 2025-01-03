.data
	formatLD: .asciz "%ld"
	afisareIdInt: .asciz "%ld: ((%ld, %ld), (%ld, %ld))\n"
	afisareInt: .asciz "((%ld, %ld), (%ld, %ld))\n"
	v: .space 1048576
	n: .space 4
	op: .space 4
	desc: .space 4
	dim: .space 4
	nrFis: .space 4
.text

ADD:
	/* 4(%esp) == dim */
	/* 8(%esp) == desc */
	lea v, %edi
	xorl %eax, %eax
	xorl %ebx, %ebx

	etAdd_loopI:
		cmp $1024, %eax
		jge etAdd_sfarsit

		xorl %ecx, %ecx

		etAdd_loopJ:
			cmp $1024, %ecx
			jge etAdd_contLoopI

			movl %ebx, %esi
			addl %ecx, %esi 	/* j + 1024 * i */
			cmpb $0, (%edi, %esi, 1)	/* v[i][j] ? 0 */
			jne etAdd_contLoopJ

			movl %ecx, %edx

			etAdd_loopK:
				cmp $1024, %edx
				jge etAdd_sfK

				movl %ebx, %esi
				addl %edx, %esi
				cmpb $0, (%edi, %esi, 1)
				jne etAdd_sfK

				addl $1, %edx
				jmp etAdd_loopK

			etAdd_sfK:
				subl $1, %edx
				movl %edx, %esi
				subl %ecx, %edx
				addl $1, %edx
				
				cmp 4(%esp), %edx	/* j - i + 1 ? dim */
				jge etAdd_else

				movl %esi, %ecx
				jmp etAdd_contLoopJ

				etAdd_else:
					movl %ecx, %edx
					addl 4(%esp), %edx
					subl $1, %edx
					etAdd_loop:
						cmp %ecx, %edx
						jl etAdd_afisare

						movl %ebx, %esi
						addl %edx, %esi
						pushl %ebx
						movl 12(%esp), %ebx
						movb %bl, (%edi, %esi, 1)
						popl %ebx

						subl $1, %edx
						jmp etAdd_loop

					etAdd_afisare:
						movl %ecx, %edx
						addl 4(%esp), %edx
						subl $1, %edx
						movl 8(%esp), %esi

						pushl %edx
						pushl %eax
						pushl %ecx
						pushl %eax
						pushl %esi
						pushl $afisareIdInt
						call printf
						popl %ebx
						popl %ebx
						popl %ebx
						popl %ebx
						popl %ebx
						popl %ebx 

						jmp etAdd_ret

			etAdd_contLoopJ:
				addl $1, %ecx 
				jmp etAdd_loopJ

		etAdd_contLoopI:
			addl $1, %eax
			addl $1024, %ebx
			jmp etAdd_loopI

	etAdd_sfarsit:
		xorl %ecx, %ecx
		movl 8(%esp), %edx
		
		pushl %ecx
		pushl %ecx
		pushl %ecx
		pushl %ecx
		pushl %edx
		pushl $afisareIdInt
		call printf
		popl %ebx
		popl %ebx
		popl %ebx
		popl %ebx
		popl %ebx
		popl %ebx

	etAdd_ret:
		ret

GET:
	lea v, %edi
	movl 4(%esp), %ebx
	xorl %esi, %esi
	xorl %eax, %eax
	etGet_loopI:
		cmp $1024, %eax
		jge etGet_inex

		xorl %ecx, %ecx
		etGet_loopJ:
			cmp $1024, %ecx
			jge etGet_contLoopI

			movl %esi, %ebp
			addl %ecx, %ebp
			cmp (%edi, %ebp, 1), %bl
			jne etGet_contLoopJ

			movl %ecx, %edx
			etGet_loopK:
				cmp $1024, %edx
				jge etGet_sfK

				movl %esi, %ebp
				addl %edx, %ebp
				cmp (%edi, %ebp, 1), %bl
				jne etGet_sfK

				addl $1, %edx
				jmp etGet_loopK

			etGet_sfK:
				subl $1, %edx
				etGet_afisare:
					pushl %edx
					pushl %eax
					pushl %ecx
					pushl %eax
					pushl $afisareInt
					call printf
					popl %ebx
					popl %ebx
					popl %ebx
					popl %ebx
					popl %ebx
				jmp etGet_ret

			etGet_contLoopJ:
				addl $1, %ecx
				jmp etGet_loopJ

		etGet_contLoopI:
			addl $1, %eax
			addl $1024, %esi
			jmp etGet_loopI

	etGet_inex:
		xorl %ecx, %ecx

		pushl %ecx
		pushl %ecx
		pushl %ecx
		pushl %ecx
		pushl $afisareInt
		call printf
		popl %ebx
		popl %ebx
		popl %ebx
		popl %ebx
		popl %ebx

	etGet_ret:
		ret

DELETE:
	lea v, %edi
	movl 4(%esp), %ebx
	xorl %eax, %eax
	xorl %esi, %esi
	etDel_loopI:
		cmp $1024, %eax
		jge etDel_af

		xorl %ecx, %ecx
		etDel_loopJ:
			cmp $1024, %ecx
			jge etDel_contLoopI

			movl %esi, %ebp
			addl %ecx, %ebp
			cmpb (%edi, %ebp, 1), %bl
			jne etDel_contLoopJ

			movl %ecx, %edx
			etDel_loopK:
				cmp $1024, %edx
				jge etDel_af

				movl %esi, %ebp
				addl %edx, %ebp
				cmpb (%edi, %ebp, 1), %bl
				jne etDel_af
				movb $0, (%edi, %ebp, 1)
				addl $1, %edx
				jmp etDel_loopK

			etDel_contLoopJ:
				addl $1, %ecx
				jmp etDel_loopJ

		etDel_contLoopI:
			addl $1, %eax
			addl $1024, %esi
			jmp etDel_loopI

	etDel_af:
		xorl %eax, %eax
		xorl %esi, %esi
		etDel_afLoopI:
			cmp $1024, %eax
			jge etDel_ret

			xorl %ecx, %ecx
			etDel_afLoopJ:
				cmp $1024, %ecx
				jge etDel_afContLoopI

				movl %esi, %ebp
				addl %ecx, %ebp
				cmpb $0, (%edi, %ebp, 1)
				je etDel_afContLoopJ

				movl %ecx, %edx
				xorl %ebx, %ebx
				movb (%edi, %ebp, 1), %bl
				etDel_afLoopK:
					cmp $1024, %edx
					jge etDel_afisare

					movl %esi, %ebp
					addl %edx, %ebp
					cmp (%edi, %ebp, 1), %bl
					jne etDel_afisare

					addl $1, %edx
					jmp etDel_afLoopK

				etDel_afisare:
					subl $1, %edx

					pushl %edx
					pushl %eax

					pushl %edx
					pushl %eax
					pushl %ecx
					pushl %eax
					pushl %ebx
					pushl $afisareIdInt
					call printf
					popl %ebx
					popl %ebx
					popl %ebx
					popl %ebx
					popl %ebx
					popl %ebx

					popl %eax
					popl %ecx		/* j = k */
					
			etDel_afContLoopJ:
				addl $1, %ecx
				jmp etDel_afLoopJ

		etDel_afContLoopI:
			addl $1, %eax
			addl $1024, %esi
			jmp etDel_afLoopI

	etDel_ret:
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
			/* call DEFRAGMENTATION */
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

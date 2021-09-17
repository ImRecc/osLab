!
!	setup.s		(C) 1991 Linus Torvalds
!
! setup.s is responsible for getting the system data from the BIOS,
! and putting them into the appropriate places in system memory.
! both setup.s and system has been loaded by the bootblock.
!
! This code asks the bios for memory/disk/other parameters, and
! puts them in a "safe" place: 0x90000-0x901FF, ie where the
! boot-block used to be. It is then up to the protected mode
! system to read them from there before the area is overwritten
! for buffer-blocks.
!

! NOTE! These had better be the same as in bootsect.s!

INITSEG  = 0x9000	! we move boot here - out of the way
SYSSEG   = 0x1000	! system loaded at 0x10000 (65536).
SETUPSEG = 0x9020	! this is the current segment

.globl begtext, begdata, begbss, endtext, enddata, endbss
.text
begtext:
.data
begdata:
.bss
begbss:
.text

entry start
start:
!only one thing we should do for now is print some inane message to acclam that we are here
!check this out, we should explicit declearation that position of setup.s, or none will be print in screen
    mov ax, #SETUPSEG   !you fooking idiot, there must be a #0x9020 or #setupseg or #otherAddress 
    			  !not justAddress or 0x90200
    	mov 	es, ax
    	mov	ah,#0x03		! read cursor pos
	xor	bh,bh
	int	0x10
	
	mov	cx,#61
	mov	bx,#0x008c		! page 0, attribute i like (by me)
	mov	bp,#msg1        	! apperantly ,es:bp pointing to string which we wanna shown, in other word, ax or #initseg = 0x9000
                        ! now we know what we missing in setup.s
	mov	ax,#0x1301		! write string, move cursor
	int	0x10
!now Linus time
!cursor position, can this be a target?
!it's a hardware related argument but...
mov	ax,#INITSEG	! this is done in bootsect already, but...
	mov	ds,ax
	mov	ah,#0x03	! read cursor pos
	xor	bh,bh
	int	0x10		! save it in known place, con_init fetches
	mov	[0],dx		! it from 0x90000.
				! apperantly, ds[],
				! incase you forget what you've learned in asm

!well this could be a report material
! Get memory size (extended mem, kB)

	mov	ah,#0x88
	int	0x15
	mov	[2],ax

! Get video-card data:

	mov	ah,#0x0f
	int	0x10
	mov	[4],bx		! bh = display page
	mov	[6],ax		! al = video mode, ah = window width

! check for EGA/VGA and some config parameters

	mov	ah,#0x12
	mov	bl,#0x10
	int	0x10
	mov	[8],ax
	mov	[10],bx
	mov	[12],cx

! Get hd0 data

	mov	ax,#0x0000
	mov	ds,ax
	lds	si,[4*0x41]
	mov	ax,#INITSEG
	mov	es,ax
	mov	di,#0x0080
	mov	cx,#0x10
	rep
	movsb

! Get hd1 data

	mov	ax,#0x0000
	mov	ds,ax
	lds	si,[4*0x46]
	mov	ax,#INITSEG
	mov	es,ax
	mov	di,#0x0090
	mov	cx,#0x10
	rep
	movsb

! Check that there IS a hd1 :-)

	mov	ax,#0x01500
	mov	dl,#0x81
	int	0x13
	jc	no_disk1
	cmp	ah,#3
	je	is_disk1
no_disk1:
	mov	ax,#INITSEG
	mov	es,ax
	mov	di,#0x0090
	mov	cx,#0x10
	mov	ax,#0x00
	rep
	stosb
is_disk1:

!now it's time to read and puts
!according to the book
	mov ax, #0x9000
	mov es, ax
	
	mov ah, #0x03
	xor bh, bh
	int 0x10
	
	mov cx, #6
	mov bx, #0081
	mov bp, #0
	mov ax, #0x1301
	int 0x10
	

msg1:
    .byte 13, 10
    .ascii "now we are in setup!"
    .byte 13, 10, 13, 10
    .ascii "and this will be some arguments"
    .byte 13, 10, 13, 10
.text
endtext:
.data
enddata:
.bss
endbss:

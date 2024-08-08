module gamestate
	use, intrinsic :: iso_c_binding
	implicit none
	! Tossing this into a module fixes the availability compiler bug
	character(kind=c_char), pointer :: mapdata(:)
interface
pure &
function C_strlen(s) result(result) bind(C,name="strlen")
	import c_ptr, C_size_t
	integer(C_size_t) :: result
	type(c_ptr), value, intent(in) :: s 
end function C_strlen
end interface
contains
subroutine c_f_string(cstring, fstring)
	type(c_ptr) :: cstring
	character(kind=c_char), pointer :: fstring(:)
	!integer(kind=c_int) :: c_f_string
	call c_f_pointer(cstring, fstring, [c_strlen(cstring)])
	!c_f_string = c_strlen(cstring)
end subroutine
end module

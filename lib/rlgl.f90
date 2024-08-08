module rlgl
	use, intrinsic :: iso_c_binding
	implicit none
interface
	subroutine rl_push_matrix() bind(c, name="shim_rlPushMatrix")
	end subroutine
	subroutine rl_pop_matrix() bind(c, name="shim_rlPopMatrix")
	end subroutine
	subroutine rl_rotate_f(angle, x, y, z) bind(c, name="rlRotatef")
		import :: c_float
		real(kind=c_float), intent(in), value :: angle, x, y, z
	end subroutine
end interface
end module

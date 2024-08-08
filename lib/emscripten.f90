module emscripten
   use, intrinsic :: iso_c_binding
   implicit none
interface
    subroutine emscripten_set_main_loop(funct, timeout, emu) bind(c, name="emscripten_set_main_loop")
        import :: c_int32_t, c_funptr
        type(c_funptr), intent(in), value :: funct
        integer(c_int32_t), intent(in), value :: timeout
        integer(c_int32_t), intent(in), value :: emu
    end subroutine
end interface
end module

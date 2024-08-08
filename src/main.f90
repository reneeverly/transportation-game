! camera.f90
!
! Example program to test camera modes. Based on the raylib example
! `core_3d_camera_mode.c`.
!
! Author:  Philipp Engel
! Licence: ISC
program main
    use, intrinsic :: iso_c_binding
    use :: raylib
    use :: emscripten
    implicit none


    integer, parameter :: SCREEN_WIDTH  = 800
    integer, parameter :: SCREEN_HEIGHT = 450

    type(camera3d_type) :: camera
    type(vector3_type)  :: cube_pos

    type(model_type) :: train_engine, train_carriage

    call init_window(SCREEN_WIDTH, SCREEN_HEIGHT, 'Fortran + raylib' // c_null_char)
    call set_target_fps(60)

    ! Define camera to look into our 3-D world.
    camera%position   = vector3_type(0.0, 10.0, 10.0)
    camera%target     = vector3_type(0.0, 0.0, 0.0)
    camera%up         = vector3_type(0.0, 1.0, 0.0)
    camera%fov_y      = 45.0
    camera%projection = CAMERA_PERSPECTIVE

	! I get a weird segfault when using .obj's, so let's try .glb!
    train_engine = load_model("res/train-electric-bullet-a.glb" // c_null_char)
    train_carriage = load_model("res/train-electric-bullet-b.glb" // c_null_char)

    cube_pos = vector3_type(0.0, 0.0, 0.0)

    call emscripten_set_main_loop(c_funloc(update), 0, 1)
    ! This has to be here, or update_draw straight up isn't included in the bc file.
    call update()

contains

subroutine  update() bind(c)
   call begin_drawing()
      call clear_background(RAYWHITE)

      call begin_mode3d(camera)
         !call draw_cube(cube_pos, 2.0, 2.0, 2.0, RED)
         !call draw_cube_wires(cube_pos, 2.0, 2.0, 2.0, MAROON)
			call draw_model_ex(train_engine, vector3_type(-1.3, 0.0, 0.0), vector3_type(0.0, 1.0, 0.0), -90.0, vector3_type(1.0, 1.0, 1.0), WHITE)
			call draw_model_ex(train_carriage, vector3_type(1.3, 0.0, 0.0), vector3_type(0.0, 1.0, 0.0), -90.0, vector3_type(1.0, 1.0, 1.0), WHITE)
         call draw_grid(10, 1.0)
      call end_mode3d()

      call draw_text('Welcome to the third dimension!' // c_null_char, 10, 40, 20, DARKGRAY)
      call draw_fps(10, 10)
   call end_drawing()
end subroutine

end program main

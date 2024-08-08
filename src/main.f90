program main
    use, intrinsic :: iso_c_binding
    use :: raylib
    use :: emscripten
	 !use :: class_train
	 use :: gamestate
    implicit none

    integer, parameter :: SCREEN_WIDTH  = 1366!800
    integer, parameter :: SCREEN_HEIGHT = 768!450

    type(camera3d_type) :: camera
    type(vector3_type)  :: cube_pos

    type(model_type) :: train_engine, train_carriage, train_carriage_2

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
    train_carriage_2 = load_model("res/train-electric-bullet-c.glb" // c_null_char)

	 call c_f_string(load_file_text('res/test.map'), mapdata)
	 print *, mapdata
	 print *, size(mapdata)

    cube_pos = vector3_type(0.0, 0.0, 0.0)

    call emscripten_set_main_loop(c_funloc(update), 0, 1)
    ! This has to be here, or update_draw straight up isn't included in the bc file.
    call update()

contains

subroutine  update() bind(c)
	integer :: mapwidth, i, header_length=14, x, z

	! update gamestate first
	call update_camera(camera, CAMERA_FREE)

   call begin_drawing()
      call clear_background(RAYWHITE)

      call begin_mode3d(camera)
         !call draw_cube(cube_pos, 2.0, 2.0, 2.0, RED)
         !call draw_cube_wires(cube_pos, 2.0, 2.0, 2.0, MAROON)
			call draw_model_ex(train_engine, vector3_type(-1.3, 0.0, 0.0), vector3_type(0.0, 1.0, 0.0), 0.0, vector3_type(1.0, 1.0, 1.0), WHITE)
			call draw_model_ex(train_carriage, vector3_type(1.3, 0.0, 0.0), vector3_type(0.0, 1.0, 0.0), -90.0, vector3_type(1.0, 1.0, 1.0), WHITE)
			call draw_model_ex(train_carriage_2, vector3_type(3.9, 0.0, 0.0), vector3_type(0.0, 1.0, 0.0), -90.0, vector3_type(1.0, 1.0, 1.0), WHITE)

			! Go through the world map and render simplified forms
			mapwidth = size(mapdata)
			z = 0
			x = 0
			do i=header_length,size(mapdata)
				if (mapdata(i) .eq. achar(10)) then
					z = z + 1
					x = 0
					cycle ! It's `cycle`, not `continue` in fortran
				else if (mapdata(i) .eq. achar(13)) then
					cycle
				end if

				x = x + 1

				if (mapdata(i) .eq. '.') then
					call draw_cube(vector3_type(x, -0.5, z), 0.5, 0.5, 0.5, GREEN)
				else
					call draw_cube(vector3_type(x, -0.5, z), 0.5, 0.5, 0.5, RED)
				end if
			end do
         call draw_grid(10, 1.0)
      call end_mode3d()

      call draw_fps(10, 10)
   call end_drawing()
end subroutine

end program main

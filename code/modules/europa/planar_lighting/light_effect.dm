/obj/effect/light
	simulated = 0
	mouse_opacity = 0
	plane = DARK_PLANE

	layer = 1
	//layer 1 = base plane layer
	//layer 2 = base shadow templates
	//layer 3 = wall lighting overlays
	//layer 4 = light falloff overlay

	appearance_flags = KEEP_TOGETHER
	icon = null
	invisibility = SEE_INVISIBLE_NOLIGHTING
	pixel_x = -64
	pixel_y = -64
	glide_size = 32
	blend_mode = BLEND_ADD

	var/current_power = 1
	var/atom/movable/holder
	var/point_angle
	var/list/affecting_turfs = list()

/obj/effect/light/New(var/newholder)
	holder = newholder
	if(istype(holder, /atom))
		var/atom/A = holder
		light_range = A.light_range
		light_color = A.light_color
		color = light_color
	..(get_turf(holder))

/obj/effect/light/Destroy()
	moved_event.unregister(holder, src)
	dir_set_event.unregister(holder, src)
	destroyed_event.unregister(holder, src)

	transform = null
	appearance = null
	overlays = null

	if(holder)
		if(holder.light_obj == src)
			holder.light_obj = null
		holder = null
	for(var/thing in affecting_turfs)
		var/turf/T = thing
		T.lumcount = -1
		T.affecting_lights -= src
	affecting_turfs.Cut()
	. = .. ()

/atom/movable/Move()
	. = ..()
	if(light_obj)
		spawn()
			light_obj.follow_holder()

/atom/movable/forceMove()
	. = ..()
	if(light_obj)
		spawn()
			light_obj.follow_holder()

/atom/set_dir()
	. = ..()
	if(light_obj)
		spawn()
			light_obj.follow_holder()

/mob/living/carbon/human/set_dir()
	. = ..()
	for(var/obj/item/I in (contents-(internal_organs+organs)))
		if(I.light_obj)
			spawn()
				I.light_obj.follow_holder()

/mob/living/carbon/human/Move()
	. = ..()
	for(var/obj/item/I in (contents-(internal_organs+organs)))
		if(I.light_obj)
			spawn()
				I.light_obj.follow_holder()

/mob/living/carbon/human/forceMove()
	. = ..()
	for(var/obj/item/I in (contents-(internal_organs+organs)))
		if(I.light_obj)
			spawn()
				I.light_obj.follow_holder()

/obj/effect/light/initialize()
	..()
	if(holder)
		follow_holder()

// Applies power value to size (via Scale()) and updates the current rotation (via Turn())
// angle for directional lights. This is only ever called before cast_light() so affected turfs
// are updated elsewhere.
/obj/effect/light/proc/update_transform(var/newrange)
	if(!isnull(newrange) && current_power != newrange)
		current_power = newrange

// Orients the light to the holder's (or the holder's holder) current dir.
// Also updates rotation for directional lights when appropriate.
/obj/effect/light/proc/follow_holder_dir()
	if(holder.loc.loc && ismob(holder.loc))
		set_dir(holder.loc.dir)
	else
		set_dir(holder.dir)

// Moves the light overlay to the holder's turf and updates bleeding values accordingly.
/obj/effect/light/proc/follow_holder()
	if(lights_master)
		if(holder && holder.loc)
			if(holder.loc.loc && ismob(holder.loc))
				forceMove(holder.loc.loc)
			else
				forceMove(holder.loc)
			follow_holder_dir()
			cast_light() //lights_master.queue_light(src)
	else
		init_lights |= src

/obj/effect/light/proc/is_directional_light()
	return (holder.light_type == LIGHT_DIRECTIONAL)

/obj/effect/light/set_dir()
	..()
	switch(dir)
		if(NORTH)
			pixel_x = -(world.icon_size * light_range) + world.icon_size / 2
			pixel_y = world.icon_size
		if(SOUTH)
			pixel_x = -(world.icon_size * light_range) + world.icon_size / 2
			pixel_y = -(world.icon_size * light_range) - world.icon_size * light_range
		if(EAST)
			pixel_x = world.icon_size
			pixel_y = -(world.icon_size * light_range) + world.icon_size / 2
		if(WEST)
			pixel_x = -(world.icon_size * light_range) - (world.icon_size * light_range)
			pixel_y = -(world.icon_size * light_range) + (world.icon_size / 2)

//NOT using the existing /obj/machinery/door type, since that has some complications on its own, mainly based on its
//machineryness

/obj/structure/mineral_door
	name = "metal door"
	density = TRUE
	anchored = TRUE
	opacity = TRUE

	icon = 'icons/obj/doors/mineral_doors.dmi'
	icon_state = "metal"

	var/initial_state
	var/state = 0 //closed, 1 == open
	var/isSwitchingStates = 0
	var/close_delay = -1 //-1 if does not auto close.
	max_integrity = 200
	armor = list(melee = 10, bullet = 0, laser = 0, energy = 100, bomb = 10, bio = 100, rad = 100, fire = 50, acid = 50)
	var/sheetType = /obj/item/stack/sheet/metal
	var/sheetAmount = 7
	var/openSound = 'sound/effects/stonedoor_openclose.ogg'
	var/closeSound = 'sound/effects/stonedoor_openclose.ogg'
	var/lockSound = 'sound/effects/lock.ogg'
	var/unlockSound = 'sound/effects/unlock.ogg'
	var/rattleSound = 'sound/effects/doorrattle.ogg'
	var/islocked = FALSE
	var/locked_code = FALSE
	CanAtmosPass = ATMOS_PASS_DENSITY

/obj/structure/mineral_door/New(location)
	..()
	initial_state = icon_state
	air_update_turf(1)

/obj/structure/mineral_door/Destroy()
	density = FALSE
	air_update_turf(1)
	return ..()

/obj/structure/mineral_door/Move()
	var/turf/T = loc
	..()
	move_update_air(T)

/obj/structure/mineral_door/CollidedWith(atom/movable/AM)
	..()
	if(!state)
		return TryToSwitchState(AM)

/obj/structure/mineral_door/attack_ai(mob/user) //those aren't machinery, they're just big fucking slabs of a mineral
	if(isAI(user)) //so the AI can't open it
		return
	else if(iscyborg(user)) //but cyborgs can
		if(get_dist(user,src) <= 1) //not remotely though
			return TryToSwitchState(user)

/obj/structure/mineral_door/attack_paw(mob/user)
	return TryToSwitchState(user)

/obj/structure/mineral_door/attack_hand(mob/user)
	return TryToSwitchState(user)

/obj/structure/mineral_door/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /obj/effect/beam))
		return !opacity
	return !density

//Lock or unlock the door

/obj/structure/mineral_door/proc/Lock(mob/user)
	if(islocked)
		door_unlock()
		to_chat(user, "You unlock [src].")
	else if(state == 0)
		door_lock()
		to_chat(user, "You lock [src].")
	else
		to_chat(user, "<span class='warning'>You cannot lock [src] while it's open!</span>")

//Create a lock - called when applying a lock to the door

/obj/structure/mineral_door/proc/door_create_lock(mob/user, obj/item/weapon/lock/lock_assy/L)
	var/mob/living/carbon/human/H = user
	if(!locked_code)
		locked_code = rand(1, 200) //We generate a random code for the door (yes, some can be duplicates)
		to_chat(H, "You begin integrating the lock assembly into [src].")
		if(do_after(H, 20, target = src) && src)
			var/obj/item/weapon/lock/key/K = new /obj/item/weapon/lock/key //Create a new key
			K.keycode = locked_code // Assign that code to the new key
			K.name += " ([K.keycode])"
			K.desc += " You notice the numbers [K.keycode] engraved along its stem."
			H.put_in_hands(K) //Give the key to the person who made the lock
			qdel(L)
			to_chat(H, "You succesfully integrate the lock assembly into [src] and remove the [K].")
	else if(locked_code)
		to_chat(H, "<span class='warning'>You cannot apply a second lock to [src]!")
	else
		to_chat(H, "<span class='warning'>You cannot apply the lock to [src]!</span>")

//Lock the door

/obj/structure/mineral_door/proc/door_lock()
	islocked = TRUE
	playsound(loc, lockSound, 100, 1)

//Unlock the door

/obj/structure/mineral_door/proc/door_unlock()
	islocked = FALSE
	playsound(loc, unlockSound, 100, 1)

/obj/structure/mineral_door/proc/TryToSwitchState(atom/user)
	if(isSwitchingStates)
		return
	if(isliving(user))
		var/mob/living/M = user
		if(world.time - M.last_bumped <= 60)
			return //NOTE do we really need that?
		if(M.client)
			if(iscarbon(M))
				var/mob/living/carbon/C = M
				if(!C.handcuffed)
					SwitchState(user)
			else
				SwitchState(user)
	else if(istype(user, /obj/mecha))
		SwitchState()

/obj/structure/mineral_door/proc/SwitchState(atom/user)
	if(state)
		Close()
	else
		Open(user)

/obj/structure/mineral_door/proc/Open(atom/user)
	if(islocked == FALSE)
		isSwitchingStates = 1
		playsound(src, openSound, 100, 1)
		set_opacity(FALSE)
		flick("[initial_state]opening",src)
		sleep(10)
		density = FALSE
		state = 1
		air_update_turf(1)
		update_icon()
		isSwitchingStates = 0
	else
		playsound(src, rattleSound, 100, 1)
		to_chat(user, "<span class='warning'>The [src] is locked!</span>")

	if(close_delay != -1)
		addtimer(CALLBACK(src, .proc/Close), close_delay)

/obj/structure/mineral_door/proc/Close()
	if(isSwitchingStates || state != 1)
		return
	var/turf/T = get_turf(src)
	for(var/mob/living/L in T)
		return
	isSwitchingStates = 1
	playsound(loc, closeSound, 100, 1)
	flick("[initial_state]closing",src)
	sleep(10)
	density = TRUE
	set_opacity(TRUE)
	state = 0
	air_update_turf(1)
	update_icon()
	isSwitchingStates = 0

/obj/structure/mineral_door/update_icon()
	if(state)
		icon_state = "[initial_state]open"
	else
		icon_state = initial_state

/obj/structure/mineral_door/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/pickaxe) && state == 1)
		var/obj/item/weapon/pickaxe/digTool = W
		to_chat(user, "<span class='notice'>You start digging the [name]...</span>")
		if(do_after(user,digTool.digspeed*(1+round(max_integrity*0.01)), target = src) && src)
			to_chat(user, "<span class='notice'>You finish digging.</span>")
			deconstruct(TRUE)
	else if(istype(W, /obj/item/weapon/lock/lock_assy))
		door_create_lock(user, W)
	else if(istype(W, /obj/item/weapon/lock/key))
		var/obj/item/weapon/lock/key/C = W
		if(!C)
			return
		if(!locked_code) // There is no lock!
			to_chat(user, "<span class='warning'>There is no keyhole in which to insert your key!</span>")
			return
		else if(C.keycode == locked_code) // Key is correct
			Lock(user)
		else if(C.keycode != locked_code) // Key is incorrect
			to_chat(user, "<span class='warning'>The key refuses to turn in the lock.</span>")
	else if(user.a_intent != INTENT_HARM)
		attack_hand(user)
	else
		return ..()

/obj/structure/mineral_door/deconstruct(disassembled = TRUE)
	var/turf/T = get_turf(src)
	if(disassembled)
		new sheetType(T, sheetAmount)
	else
		new sheetType(T, max(sheetAmount - 2, 1))
	qdel(src)

/obj/structure/mineral_door/iron
	name = "iron door"
	max_integrity = 300

/obj/structure/mineral_door/silver
	name = "silver door"
	icon_state = "silver"
	sheetType = /obj/item/stack/sheet/mineral/silver
	max_integrity = 300

/obj/structure/mineral_door/gold
	name = "gold door"
	icon_state = "gold"
	sheetType = /obj/item/stack/sheet/mineral/gold

/obj/structure/mineral_door/uranium
	name = "uranium door"
	icon_state = "uranium"
	sheetType = /obj/item/stack/sheet/mineral/uranium
	max_integrity = 300
	light_range = 2

/obj/structure/mineral_door/sandstone
	name = "sandstone door"
	icon_state = "sandstone"
	sheetType = /obj/item/stack/sheet/mineral/sandstone
	max_integrity = 100

/obj/structure/mineral_door/transparent
	opacity = FALSE

/obj/structure/mineral_door/transparent/Close()
	..()
	set_opacity(FALSE)

/obj/structure/mineral_door/transparent/plasma
	name = "plasma door"
	icon_state = "plasma"
	sheetType = /obj/item/stack/sheet/mineral/plasma

/obj/structure/mineral_door/transparent/plasma/attackby(obj/item/weapon/W, mob/user, params)
	if(W.is_hot())
		var/turf/T = get_turf(src)
		message_admins("Plasma mineral door ignited by [ADMIN_LOOKUPFLW(user)] in [ADMIN_COORDJMP(T)]",0,1)
		log_game("Plasma mineral door ignited by [key_name(user)] in [COORD(T)]")
		TemperatureAct()
	else
		return ..()

/obj/structure/mineral_door/transparent/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		TemperatureAct()

/obj/structure/mineral_door/transparent/plasma/proc/TemperatureAct()
	atmos_spawn_air("plasma=500;TEMP=1000")
	deconstruct(FALSE)

/obj/structure/mineral_door/transparent/diamond
	name = "diamond door"
	icon_state = "diamond"
	sheetType = /obj/item/stack/sheet/mineral/diamond
	max_integrity = 1000

/obj/structure/mineral_door/wood
	name = "wood door"
	icon_state = "wood"
	openSound = 'sound/effects/doorcreaky.ogg'
	closeSound = 'sound/effects/doorcreaky.ogg'
	sheetType = /obj/item/stack/sheet/mineral/wood
	resistance_flags = FLAMMABLE
	max_integrity = 200

/obj/structure/mineral_door/paperframe
	name = "paper frame door"
	icon_state = "paperframe"
	openSound = 'sound/effects/doorcreaky.ogg'
	closeSound = 'sound/effects/doorcreaky.ogg'
	sheetType = /obj/item/stack/sheet/paperframes
	sheetAmount = 3
	resistance_flags = FLAMMABLE
	max_integrity = 20

/obj/structure/mineral_door/paperframe/Initialize()
	. = ..()
	queue_smooth_neighbors(src)

/obj/structure/mineral_door/paperframe/Destroy()
	queue_smooth_neighbors(src)
	return ..()

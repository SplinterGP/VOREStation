////////////////////////////////////////
// Tether custom shuttle implemnetations
////////////////////////////////////////

/obj/machinery/computer/shuttle_control/tether_backup
	name = "tether backup shuttle control console"
	shuttle_tag = "Tether Backup"
	req_one_access = list(access_heads,access_pilot)

/obj/machinery/computer/shuttle_control/multi/tether_antag_ground
	name = "land crawler control console"
	shuttle_tag = "Land Crawler"

/obj/machinery/computer/shuttle_control/multi/tether_antag_space
	name = "protoshuttle control console"
	shuttle_tag = "Proto"

/obj/machinery/computer/shuttle_control/cruiser_shuttle
	name = "cruiser shuttle control console"
	shuttle_tag = "Cruiser Shuttle"
	req_one_access = list(access_heads)

//
// "Tram" Emergency Shuttler
// Becuase the tram only has its own doors and no corresponding station doors, a docking controller is overkill.
// Just open the gosh darn doors!  Also we avoid having a physical docking controller obj for gameplay reasons.
/datum/shuttle/autodock/ferry/emergency
	var/tag_door_station = "escape_shuttle_hatch_station"
	var/tag_door_offsite = "escape_shuttle_hatch_offsite"
	var/frequency = 1380 // Why this frequency? BECAUSE! Thats what someone decided once.
	var/datum/radio_frequency/radio_connection

/datum/shuttle/autodock/ferry/emergency/New()
	radio_connection = radio_controller.add_object(src, frequency, null)
	..()

/datum/shuttle/autodock/ferry/emergency/dock()
	..()
	// Open Doorsunes
	var/datum/signal/signal = new
	signal.data["tag"] = location ? tag_door_offsite : tag_door_station
	signal.data["command"] = "secure_open"
	post_signal(signal)

/datum/shuttle/autodock/ferry/emergency/undock()
	..()
	// Close Doorsunes
	var/datum/signal/signal = new
	signal.data["tag"] = location ? tag_door_offsite : tag_door_station
	signal.data["command"] = "secure_close"
	post_signal(signal)

/datum/shuttle/autodock/ferry/emergency/proc/post_signal(datum/signal/signal, var/filter = null)
	signal.transmission_method = TRANSMISSION_RADIO
	if(radio_connection)
		return radio_connection.post_signal(src, signal, filter)
	else
		qdel(signal)

//
// The backup tether shuttle uses experimental engines and can degrade and/or crash!
//
/* //Disabling the crash mechanics per request
/datum/shuttle/ferry/tether_backup
	crash_message = "Tether shuttle distress signal received. Shuttle location is approximately 200 meters from tether base."
	category = /datum/shuttle/ferry/tether_backup // So shuttle_controller.dm doesn't try and instantiate this type as an acutal mapped in shuttle.
	var/list/engines = list()
	var/obj/machinery/computer/shuttle_control/tether_backup/computer

/datum/shuttle/ferry/tether_backup/New()
	..()
	var/area/current_area = get_location_area(location)
	for(var/obj/structure/shuttle/engine/propulsion/E in current_area)
		engines += E
	for(var/obj/machinery/computer/shuttle_control/tether_backup/comp in current_area)
		computer = comp

/datum/shuttle/ferry/tether_backup/process_longjump(var/area/origin, var/area/intended_destination)
	var/failures = engines.len
	for(var/engine in engines)
		var/obj/structure/shuttle/engine/E = engine
		failures -= E.jump()

	#define MOVE_PER(x) move_time*(x/100) SECONDS

	computer.visible_message("[bicon(computer)] <span class='notice'>Beginning flight and telemetry monitoring.</span>")
	sleep(MOVE_PER(5))

	if(failures >= 1)
		computer.visible_message("[bicon(computer)] <span class='warning'>Single engine failure, continuing flight.</span>")
		sleep(MOVE_PER(10))

	if(failures >= 2)
		computer.visible_message("[bicon(computer)] <span class='warning'>Second engine failure, unable to complete flight.</span>")
		playsound(computer,'sound/mecha/internaldmgalarm.ogg',100,0)
		sleep(MOVE_PER(10))
		computer.visible_message("[bicon(computer)] <span class='warning'>Commencing RTLS abort mode.</span>")
		sleep(MOVE_PER(20))
		if(failures < 3)
			move(area_transition,origin)
			moving_status = SHUTTLE_IDLE
			return 1

	if(failures >= 3)
		computer.visible_message("[bicon(computer)] <span class='danger'>Total engine failure, unable to complete abort mode.</span>")
		playsound(computer,'sound/mecha/internaldmgalarm.ogg',100,0)
		sleep(MOVE_PER(5))
		computer.visible_message("[bicon(computer)] <span class='danger'>Distress signal broadcast.</span>")
		playsound(computer,'sound/mecha/internaldmgalarm.ogg',100,0)
		sleep(MOVE_PER(5))
		computer.visible_message("[bicon(computer)] <span class='danger'>Stall. Stall. Stall. Stall.</span>")
		playsound(computer,'sound/mecha/internaldmgalarm.ogg',100,0)
		sleep(MOVE_PER(5))
		playsound(computer,'sound/mecha/internaldmgalarm.ogg',100,0)
		sleep(MOVE_PER(5))
		computer.visible_message("[bicon(computer)] <span class='danger'>Terrain! Pull up! Terrain! Pull up!</span>")
		playsound(computer,'sound/mecha/internaldmgalarm.ogg',100,0)
		playsound(computer,'sound/misc/bloblarm.ogg',100,0)
		sleep(MOVE_PER(10))
		do_crash(area_transition)
		return 1

	return 0

	#undef MOVE_PER
//
// The repairable engines
// TODO - These need a more advanced fixing sequence.
//
/obj/structure/shuttle/engine
	var/wear = 0

/obj/structure/shuttle/engine/proc/jump()
	. = !prob(wear)
	if(!.)
		wear = 100
	else
		wear += rand(5,20)

/obj/structure/shuttle/engine/attackby(obj/item/weapon/W as obj, mob/user as mob)
	src.add_fingerprint(user)
	if(repair_welder(user, W))
		return
	return ..()

//TODO require a multitool to diagnose and open engine panels or something

/obj/structure/shuttle/engine/proc/repair_welder(var/mob/user, var/obj/item/weapon/weldingtool/WT)
	if(!istype(WT))
		return 0
	if(wear <= 20)
		to_chat(user,"<span class='notice'>\The [src] doesn't seem to need repairs right now.</span>")
		return 1
	if(!WT.remove_fuel(0, user))
		to_chat(user,"<span class='warning'>\The [WT] must be on to complete this task.</span>")
		return 1
	playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
	user.visible_message("<span class='notice'>\The [user] begins \the [src] overhaul.</span>","<span class='notice'>You begin an overhaul of \the [src].</span>")
	if(!do_after(user, wear SECONDS, src))
		return 1
	if(!src || !WT.isOn())
		return 1
	user.visible_message("<span class='notice'>\The [user] has overhauled \the [src].</span>","<span class='notice'>You complete \the [src] overhaul.</span>")
	wear = 20
	update_icon()
	return 1
*/
////////////////////////////////////////
//////// Excursion Shuttle /////////////
////////////////////////////////////////
/obj/effect/overmap/visitable/sector/virgo3b
	name = "Virgo 3B"
	desc = "Full of phoron, and home to the NSB Adephagia, where you can dock and refuel your craft."
	base = 1
	start_x = 10
	start_y = 10
	icon_state = "globe"
	color = "#d35b5b"
	initial_generic_waypoints = list("tether_dockarm_d1a1","tether_dockarm_d1a2","tether_dockarm_d1a3","tether_dockarm_d2a1","tether_dockarm_d2a2","tether_dockarm_d1l","tether_dockarm_d2l")

// The 'shuttle' of the excursion shuttle
/datum/shuttle/autodock/overmap/excursion
	name = "Excursion Shuttle"
	warmup_time = 0
	current_location = "tether_excursion_hangar"
	docking_controller_tag = "expshuttle_docker"
	shuttle_area = /area/shuttle/excursion
	fuel_consumption = 0 //WIP

// The 'ship' of the excursion shuttle
/obj/effect/overmap/visitable/ship/landable/excursion
	name = "Excursion Shuttle"
	desc = "The traditional Excursion Shuttle. NT Approved!"
	vessel_mass = 5000
	vessel_size = SHIP_SIZE_SMALL
	shuttle = "Excursion Shuttle"

// Heist
/obj/machinery/computer/shuttle_control/web/heist
	name = "skipjack control console"
	req_access = list(access_syndicate)
	shuttle_tag = "Skipjack"

/datum/shuttle/autodock/web_shuttle/heist
	name = "Skipjack"
	current_location = "skipjack_base"
	shuttle_area = /area/shuttle/skipjack
	web_master_type = /datum/shuttle_web_master/heist
	warmup_time = 0
	can_cloak = TRUE
	cloaked = TRUE

/datum/shuttle_web_master/heist
	destination_class = /datum/shuttle_destination/heist
	starting_destination = /datum/shuttle_destination/heist/root

/datum/shuttle_destination/heist/root
	name = "Raider Outpost"
	my_landmark = "skipjack_base"
	preferred_interim_tag = "skipjack_transit"

	routes_to_make = list(
		/datum/shuttle_destination/heist/outside_tether = 1 MINUTE
	)

/datum/shuttle_destination/heist/outside_tether
	name = "NSB Adephagia - Nearby"
	my_landmark = "skipjack_outside"
	preferred_interim_tag = "skipjack_transit"

	routes_to_make = list(
		/datum/shuttle_destination/heist/root = 1 MINUTE,
		/datum/shuttle_destination/heist/docked_tether = 0
	)

/datum/shuttle_destination/heist/docked_tether
	name = "NSB Adephagia - Dockarm"
	my_landmark = "tether_dockarm_d1l"

	routes_to_make = list(
		/datum/shuttle_destination/heist/outside_tether = 0
	)

// Ninja
/obj/machinery/computer/shuttle_control/web/ninja
	name = "stealth shuttle control console"
	req_access = list(access_syndicate)
	shuttle_tag = "Ninja"

/datum/shuttle/autodock/web_shuttle/ninja
	name = "Ninja"
	visible_name = "Unknown Vessel"
	current_location = "ninja_base"
	shuttle_area = /area/shuttle/ninja
	docking_controller_tag = "ninja_shuttle"
	web_master_type = /datum/shuttle_web_master/ninja
	warmup_time = 0
	can_cloak = TRUE
	cloaked = TRUE

/datum/shuttle_web_master/ninja
	destination_class = /datum/shuttle_destination/ninja
	starting_destination = /datum/shuttle_destination/ninja/root

/datum/shuttle_destination/ninja/root
	name = "Dojo Outpost"
	my_landmark = "ninja_base"
	preferred_interim_tag = "ninja_transit"

	routes_to_make = list(
		/datum/shuttle_destination/ninja/outside_tether = 30 SECONDS
	)

/datum/shuttle_destination/ninja/outside_tether
	name = "NSB Adephagia - Nearby"
	my_landmark = "tether_space_NE"
	preferred_interim_tag = "ninja_transit"

	routes_to_make = list(
		/datum/shuttle_destination/ninja/root = 30 SECONDS,
		/datum/shuttle_destination/ninja/docked_tether = 0
	)

/datum/shuttle_destination/ninja/docked_tether
	name = "NSB Adephagia - Dockarm"
	my_landmark = "tether_dockarm_d1a3"

	routes_to_make = list(
		/datum/shuttle_destination/ninja/outside_tether = 0
	)


////////////////////////////////////
//////// Specops Shuttle ///////////
////////////////////////////////////

/obj/machinery/computer/shuttle_control/web/specialops
	name = "shuttle control console"
	shuttle_tag = "Special Operations Shuttle"
	req_access = list()
	req_one_access = list(access_cent_specops)

/datum/shuttle/autodock/web_shuttle/specialops
	name = "Special Operations Shuttle"
	visible_name = "NDV Phantom"
	current_location = "specops_base"
	shuttle_area = /area/shuttle/specialops
	docking_controller_tag = "specops_shuttle_hatch"
	web_master_type = /datum/shuttle_web_master/specialops
	can_rename = FALSE
	can_cloak = TRUE
	cloaked = FALSE

/datum/shuttle_web_master/specialops
	destination_class = /datum/shuttle_destination/specialops
	starting_destination = /datum/shuttle_destination/specialops/centcom

/datum/shuttle_destination/specialops/tether
	name = "NSB Adephagia Docking Arm 2"
	my_landmark = "tether_dockarm_d2a2"
	preferred_interim_tag = "specops_transit"

	radio_announce = 1
	announcer = "A.L.I.C.E."

	routes_to_make = list(
		/datum/shuttle_destination/specialops/centcom = 15
	)

/datum/shuttle_destination/specialops/tether/get_arrival_message()
	return "Attention, [master.my_shuttle.visible_name] has arrived at the Docking Arm 2."

/datum/shuttle_destination/specialops/tether/get_departure_message()
	return "Attention, [master.my_shuttle.visible_name] has departed from the Docking Arm 2."


/datum/shuttle_destination/specialops/centcom
	name = "Central Command"
	my_landmark = "specops_base"
	preferred_interim_tag = "specops_transit"

	routes_to_make = list(
		/datum/shuttle_destination/specialops/tether = 15
	)
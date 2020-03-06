/*
** The ship machines/computers ported from baystation expect certain procs and infrastruture that we don't have.
** I /could/ just port those computers to our code, but I actually *like* that infrastructure. But I
** don't have time (yet) to implement it fully in our codebase, so I'm shimming it here experimentally as a test
** bed for later implementing it on /obj/machinery and /obj/machinery/computer for everything.  ~Leshana (March 2020)
*/

//
// Power
//


// This will have this machine have its area eat this much power next tick, and not afterwards. Do not use for continued power draw.
/obj/machinery/proc/use_power_oneoff(var/amount, var/chan = -1)
	return use_power(amount, chan)

// Change one of the power consumption vars
/obj/machinery/proc/change_power_consumption(new_power_consumption, use_power_mode = USE_POWER_IDLE)
	switch(use_power_mode)
		if(USE_POWER_IDLE)
			idle_power_usage = new_power_consumption
		if(USE_POWER_ACTIVE)
			active_power_usage = new_power_consumption
	// No need to do anything else in our power scheme.

// Defining directly here to avoid conflicts with existing set_broken procs in our codebase that behave differently.
/obj/machinery/atmospherics/unary/engine/proc/set_broken(var/new_state, var/cause)
	if(!(stat & BROKEN) == !new_state)
		return // Nothing changed
	stat ^= BROKEN
	update_icon()


//
// Compoenents
//

/obj/machinery/proc/total_component_rating_of_type(var/part_type)
	. = 0
	for(var/thing in component_parts)
		if(istype(thing, part_type))
			var/obj/item/weapon/stock_parts/part = thing
			. += part.rating
	// Now isn't THIS a cool idea?
	// for(var/path in uncreated_component_parts)
	// 	if(ispath(path, part_type))
	// 		var/obj/item/weapon/stock_parts/comp = path
	// 		. += initial(comp.rating) * uncreated_component_parts[path]

//
// Skills
//
/obj/machinery/computer/ship
	var/core_skill = /datum/skill/devices //The skill used for skill checks for this machine (mostly so subtypes can use different skills).
	// var/operator_skill      // Machines often do all operations on Process(). This caches the user's skill while the operations are running.


//
// Topic
//

/obj/machinery/computer/engines/attack_hand(var/mob/user as mob)
	if(..())
		user.unset_machine()
		return

	if(!isAI(user))
		user.set_machine(src)

	ui_interact(user)



// NON COMPUTER STUFF - FIND A HOME


/obj/item/weapon/tank/hydrogen
	name = "hydrogen tank"
	desc = "A tank of hydrogen."
	icon_state = "hydrogen"  // TODO - Leshana - COPY THIS

/obj/item/weapon/tank/hydrogen/Initialize()
	. = ..()
	air_contents.adjust_gas("hydrogen", (8*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C))

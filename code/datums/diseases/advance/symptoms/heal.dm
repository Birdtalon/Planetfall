/datum/symptom/heal
	name = "Basic Healing (does nothing)" //warning for adminspawn viruses
	stealth = 1
	resistance = -4
	stage_speed = -4
	transmittable = -4
	level = 0 //not obtainable
	base_message_chance = 20 //here used for the overlays
	symptom_delay_min = 1
	symptom_delay_max = 1
	var/hide_healing = FALSE

/datum/symptom/heal/Start(datum/disease/advance/A)
	..()
	if(A.properties["stealth"] >= 4) //invisible healing
		hide_healing = TRUE
	if(A.properties["stage_rate"] >= 6) //stronger healing
		power = 2
	if(A.properties["stage_rate"] >= 11) //even stronger healing
		power = 3

/datum/symptom/heal/Activate(datum/disease/advance/A)
	if(!..())
		return
	 //100% chance to activate for slow but consistent healing
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(4, 5)
			Heal(M, A)
	return

/datum/symptom/heal/proc/Heal(mob/living/M, datum/disease/advance/A)
	return 1

/*
//////////////////////////////////////

Toxin Filter

	Little bit hidden.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity temrendously.
	Fatal Level.

Bonus
	Heals toxins in the affected mob's blood stream.

//////////////////////////////////////
*/

/datum/symptom/heal/toxin
	name = "Toxic Filter"
	stealth = 1
	resistance = -4
	stage_speed = -4
	transmittable = -4
	level = 6

/datum/symptom/heal/toxin/Heal(mob/living/M, datum/disease/advance/A)
	var/heal_amt = 1 * power
	if(M.toxloss > 0 && prob(base_message_chance) && !hide_healing)
		new /obj/effect/temp_visual/heal(get_turf(M), "#66FF99")
	M.adjustToxLoss(-heal_amt)
	return 1

/*
//////////////////////////////////////

Apoptosis

	Lowers resistance.
	Decreases stage speed.
	Decreases transmittablity.

Bonus
	Heals toxins in the affected mob's blood stream faster.

//////////////////////////////////////
*/

/datum/symptom/heal/toxin/plus

	name = "Apoptoxin filter"
	stealth = 0
	resistance = -2
	stage_speed = -2
	transmittable = -2
	level = 8

/datum/symptom/heal/toxin/plus/Heal(mob/living/M, datum/disease/advance/A)
	var/heal_amt = 2 * power
	if(M.toxloss > 0 && prob(base_message_chance) && !hide_healing)
		new /obj/effect/temp_visual/heal(get_turf(M), "#00FF00")
	M.adjustToxLoss(-heal_amt)
	return 1

/*
//////////////////////////////////////

Regeneration

	Little bit hidden.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity temrendously.
	Fatal Level.

Bonus
	Heals brute damage slowly over time.

//////////////////////////////////////
*/

/datum/symptom/heal/brute

	name = "Regeneration"
	stealth = 1
	resistance = -4
	stage_speed = -4
	transmittable = -4
	level = 6

/datum/symptom/heal/brute/Heal(mob/living/carbon/M, datum/disease/advance/A)
	var/heal_amt = 2 * power

	var/list/parts = M.get_damaged_bodyparts(1,1) //1,1 because it needs inputs.

	if(!parts.len)
		return

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt/parts.len, 0))
			M.update_damage_overlays()

	if(prob(base_message_chance) && !hide_healing)
		new /obj/effect/temp_visual/heal(get_turf(M), "#FF3333")

	return 1


/*
//////////////////////////////////////

Flesh Mending

	No resistance change.
	Decreases stage speed.
	Decreases transmittablity.
	Fatal Level.

Bonus
	Heals brute damage over time. Turns cloneloss into burn damage.

//////////////////////////////////////
*/

/datum/symptom/heal/brute/plus

	name = "Flesh Mending"
	stealth = 0
	resistance = 0
	stage_speed = -2
	transmittable = -2
	level = 8

/datum/symptom/heal/brute/plus/Heal(mob/living/carbon/M, datum/disease/advance/A)
	var/heal_amt = 4 * power

	var/list/parts = M.get_damaged_bodyparts(1,1) //1,1 because it needs inputs.

	if(M.getCloneLoss() > 0)
		M.adjustCloneLoss(-1)
		M.take_bodypart_damage(0, 1) //Deals BURN damage, which is not cured by this symptom
		if(!hide_healing)
			new /obj/effect/temp_visual/heal(get_turf(M), "#33FFCC")

	if(!parts.len)
		return

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt/parts.len, 0))
			M.update_damage_overlays()

	if(prob(base_message_chance) && !hide_healing)
		new /obj/effect/temp_visual/heal(get_turf(M), "#CC1100")

	return 1

/*
//////////////////////////////////////

Tissue Regrowth

	Little bit hidden.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity temrendously.
	Fatal Level.

Bonus
	Heals burn damage slowly over time.

//////////////////////////////////////
*/

/datum/symptom/heal/burn

	name = "Tissue Regrowth"
	stealth = 1
	resistance = -4
	stage_speed = -4
	transmittable = -4
	level = 6

/datum/symptom/heal/burn/Heal(mob/living/carbon/M, datum/disease/advance/A)
	var/heal_amt = 2 * power

	var/list/parts = M.get_damaged_bodyparts(1,1) //1,1 because it needs inputs.

	if(!parts.len)
		return

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(0, heal_amt/parts.len))
			M.update_damage_overlays()

	if(prob(base_message_chance) && !hide_healing)
		new /obj/effect/temp_visual/heal(get_turf(M), "#FF9933")
	return 1


/*
//////////////////////////////////////

Heat Resistance //Needs a better name

	No resistance change.
	Decreases stage speed.
	Decreases transmittablity.
	Fatal Level.

Bonus
	Heals burn damage over time, and helps stabilize body temperature.

//////////////////////////////////////
*/

/datum/symptom/heal/burn/plus

	name = "Heat Resistance"
	stealth = 0
	resistance = 0
	stage_speed = -2
	transmittable = -2
	level = 8

/datum/symptom/heal/burn/plus/Heal(mob/living/carbon/M, datum/disease/advance/A)
	var/heal_amt = 4 * power

	var/list/parts = M.get_damaged_bodyparts(1,1) //1,1 because it needs inputs.

	if(M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (10 * heal_amt * TEMPERATURE_DAMAGE_COEFFICIENT))
	else if(M.bodytemperature < 311)
		M.bodytemperature = min(310, M.bodytemperature + (10 * heal_amt * TEMPERATURE_DAMAGE_COEFFICIENT))

	if(!parts.len)
		return

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(0, heal_amt/parts.len))
			M.update_damage_overlays()

	if(prob(base_message_chance) && !hide_healing)
		new /obj/effect/temp_visual/heal(get_turf(M), "#CC6600")
	return 1


/*
//////////////////////////////////////

	DNA Restoration

	Not well hidden.
	Lowers resistance minorly.
	Does not affect stage speed.
	Decreases transmittablity greatly.
	Very high level.

Bonus
	Heals brain damage, treats radiation, cleans SE of non-power mutations.

//////////////////////////////////////
*/

/datum/symptom/heal/dna

	name = "Deoxyribonucleic Acid Restoration"
	stealth = -1
	resistance = -1
	stage_speed = 0
	transmittable = -3
	level = 5
	symptom_delay_min = 3
	symptom_delay_max = 8

/datum/symptom/heal/dna/Heal(mob/living/carbon/M, datum/disease/advance/A)
	var/amt_healed = 2 * power
	M.adjustBrainLoss(-amt_healed)
	//Non-power mutations, excluding race, so the virus does not force monkey -> human transformations.
	var/list/unclean_mutations = (GLOB.not_good_mutations|GLOB.bad_mutations) - GLOB.mutations_list[RACEMUT]
	M.dna.remove_mutation_group(unclean_mutations)
	M.radiation = max(M.radiation - (2 * amt_healed), 0)
	return 1

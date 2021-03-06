var/list/station_areas

/proc/get_station_areas()
	if(!station_areas)
		station_areas = list()
		for(var/area/A in all_areas)
			if(istype(A, /area/europa/ocean) || istype(A, /area/space) || istype(A, /area/shuttle))
				continue
			for(var/turf/T in A.contents)
				if(T.z in using_map.station_levels)
					station_areas[A] = 1
					continue
	return station_areas

/datum/objective/hunter_flood
	explanation_text = "Vent at least half of the human settlement. Choke them in their den."

/datum/objective/hunter_flood/check_completion()
	var/list/station_zones = list()
	var/vent_count = 0
	for(var/thing in get_station_areas())
		var/area/A = thing
		for(var/turf/simulated/T in A.contents)
			if(T.zone && !station_zones[T.zone])
				station_zones[T.zone] = 1
				if(T.zone.air.total_moles <= 50 || T.zone.air.gas["oxygen"] < 10)
					vent_count++
	return vent_count >= round(station_zones.len/2)

/datum/objective/hunter_depower
	explanation_text = "Destroy any power infrastructure in the human settlement and leave it in darkness."

/datum/objective/hunter_depower/check_completion()
	var/total_area_count = 0
	var/depower_count = 0
	for(var/thing in get_station_areas())
		var/area/A = thing
		if(A.requires_power)
			total_area_count++
			if(!A.get_apc() || (!A.power_light && !A.power_equip && !A.power_environ))
				depower_count++
	return (depower_count >= round(total_area_count/2))

/datum/objective/hunter_purge
	explanation_text = "Purge the human settlement of life. Kill or displace at least half of the primitives living there."

/datum/objective/hunter_purge/check_completion()
	var/human_count = 0
	var/dead_human_count = 0
	for(var/mob/living/carbon/human/H in mob_list)
		if(H.species.get_bodytype() == "Mantid Alate" || H.species.get_bodytype() == "Mantid Gyne")
			continue
		human_count++
		if(H.stat == DEAD)
			dead_human_count++
		else
			var/turf/T = get_turf(H)
			if(T && (T.loc.type in get_escape_areas()))
				dead_human_count++
	return (dead_human_count >= round(human_count/2))

/datum/objective/hunter_preserve_gyne
	explanation_text = "Preserve the lives of any gynes present."

/datum/objective/hunter_preserve_gyne/check_completion()
	var/gyne_count = 0
	for(var/mob/living/carbon/human/H in mob_list)
		if(H.species.get_bodytype(H) == "Mantid Gyne" && H.stat != DEAD)
			gyne_count++
	return (gyne_count >= hunters.gyne_count)

/datum/objective/hunter_preserve_alates
	explanation_text = "Preserve the lives of at least half of the alates present."

/datum/objective/hunter_preserve_alates/check_completion()
	var/alate_count = 0
	for(var/mob/living/carbon/human/H in mob_list)
		if(H.species.get_bodytype(H) == "Mantid Alate" && H.stat != DEAD)
			alate_count++
	return (alate_count >= round(hunters.alate_count/2))
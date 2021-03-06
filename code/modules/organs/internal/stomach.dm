/obj/item/organ/internal/stomach
	name = "stomach"
	desc = "Gross. This is hard to stomach."
	icon_state = "stomach"
	dead_icon = "stomach"
	organ_tag = BP_STOMACH
	parent_organ = BP_GROIN
	var/datum/reagents/metabolism/ingested
	var/next_cramp = 0

/obj/item/organ/internal/stomach/Destroy()
	qdel(ingested)
	. = ..()

/obj/item/organ/internal/stomach/New()
	..()
	ingested = new(1000, src)
	ingested.metabolism_class = CHEM_INGEST

/obj/item/organ/internal/stomach/process()

	..()

	if(owner)
		if(damage >= min_broken_damage || (damage >= min_bruised_damage && prob(damage)))
			if(world.time >= next_cramp)
				next_cramp = world.time + rand(200,800)
				owner.custom_pain("Your stomach cramps agonizingly!",1)
		else
			ingested.my_atom = owner
			ingested.parent = owner
			ingested.metabolize()

		if((owner.get_fullness() > 550 && prob(5)) || (ingested.get_reagent_amount_by_type(/datum/reagent/ethanol) > 60 && prob(15)))
			owner.vomit()
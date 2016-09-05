/mob/living/proc/ventcrawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Abilities"
	if(incapacitated() || restrained())
		return
	var/pipe = start_ventcrawl()
	if(pipe)
		handle_ventcrawl()

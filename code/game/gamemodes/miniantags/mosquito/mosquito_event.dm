/datum/event/spawn_mosquito
	var/SuccesAnnouncement = FALSE
	var/successSpawn = FALSE
	var/spawncount = 5
	var/datum/disease/ChosenDisease

/datum/event/spawn_mosquito/setup()
	spawncount = rand(3, 6)

/datum/event/spawn_mosquito/start()
	INVOKE_ASYNC(src, .proc/spawn_mosquitos)

/datum/event/spawn_mosquito/proc/spawn_mosquitos()
	var/list/possible_diseases = list(
	/datum/disease/cold,
	/datum/disease/flu,
	/datum/disease/magnitis,
	/datum/disease/appendicitis,
	/datum/disease/cold9)
	ChosenDisease = pick(possible_diseases)

	var/list/vents = get_valid_vent_spawns(exclude_mobs_nearby = TRUE, exclude_visible_by_mobs = TRUE)
	var/list/picked_candidates = new()
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a mosquito?", ROLE_MOSQUITO, TRUE, source = /mob/living/simple_animal/mosquito)

	if(!length(candidates))
		kill()
		message_admins("No candidates for mosquito event")
		return

	while(spawncount && length(candidates)) // todo: should be for forloop
		picked_candidates.Add(pick_n_take(candidates))
		spawncount--

	if(!length(picked_candidates))
		kill()
		message_admins("No candidates picked for mosquito event")
		return

	while(length(picked_candidates) && length(vents))
		var/mob/currentselected = pick_n_take(picked_candidates)
		var/key_of_mosquito = currentselected.key

		var/datum/mind/player_mind = new /datum/mind(key_of_mosquito)
		player_mind.active = TRUE

		var/obj/vent = pick_n_take(vents)
		var/mob/living/simple_animal/mosquito/S = new /mob/living/simple_animal/mosquito(vent.loc, ChosenDisease)
		player_mind.transfer_to(S)
		player_mind.assigned_role = ROLE_MOSQUITO
		player_mind.special_role = ROLE_MOSQUITO
		SSticker.mode.traitors |= player_mind
		to_chat(S, S.playstyle_string)
		successSpawn = TRUE

		message_admins("[key_of_mosquito] has been made into mosquito by an event.")
		log_game("[key_of_mosquito] was spawned as a mosquito by an event.")


/datum/event/spawn_mosquito/announce()
	if(prob(25))
		var/mosquito_report = "<font size=3><b>[command_name()] High-Priority Update</b></span>"
		mosquito_report += "<br><br>Suspected biohazard aboard the station. We recommend immediate investigation."
		print_command_report(mosquito_report, "Classified [command_name()] Update", FALSE)
		GLOB.event_announcement.Announce("A report has been downloaded and printed out at all communications consoles.", "Incoming Classified Message", 'sound/AI/commandreport.ogg')
		SuccesAnnouncement = TRUE
		kill()
	else
		addtimer(CALLBACK(src, .proc/announce), 3 MINUTES)

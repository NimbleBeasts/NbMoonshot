extends Control


const funFacts = [
	"The Sun weighs about 330,000 times more than Earth.",
	"Footprints left on the Moon wont disappear as there is no wind.",
	"There are 79 known moons orbiting Jupiter.",
	"The Martian day is 24 hours 39 minutes and 35 seconds long.",
	"The Sun makes a full rotation once every 25 – 35 days.",
	"Earth is the only planet that is not named after a God.",
	"There are more volcanoes on Venus than any other planet in our solar system.",
	"Uranus blue glow is due to the gases in its atmosphere.",
	"In our solar system that are four planets known as gas giants: Jupiter, Saturn, Uranus & Neptune.",
	"The Black Arrow is the only British satellite to be launched using a British rocket.",
	"The International Space Station circles Earth every 92 minutes.",
	"Stars twinkle because of the way light is disrupted as it passes through Earth’s atmosphere.",
	"The closest galaxy to us is the Andromeda Galaxy – it’s estimated at 2.5 million light-years away.",
	"The first Supernovae observed outside of our own galaxy was in 1885.",
	"The Kuiper Belt is a region of the Solar System beyond the orbit of Neptune.",
	"The first woman in space was a Russian called Valentina Tereshkova.",
	"The Hubble Space Telescope is one of the most productive scientific instruments ever built.",
	"The first artificial satellite in space was called Sputnik.",
	"Astronauts can't burp in space.",
	"Uranus was originally called Georges Star.",
	"A sunset on Mars is blue.",
	"The first living mammal to go into space was a dog named Laika from Russia."
]

const text = [
#1
"A few days ago (May 28, 1961), U.S. President John F. Kennedy called for a moon race. Our great leader wants for our nation to secure its rightful place in the world. Our intelligence concluded that Soviet space technology is the most advanced.\n\nYuri Gagarin was the first man in space and the first man to fly into orbit. Your mission is to search for and steal plans of the Vostok-K 8K72K rocket. We got the location of soviet central archive from a confirmed source. Look for the plans. And do not disappoint us!",
#2
"In August 1961, cosmonaut Titov (code name: Orjol) went on an orbital flight with the Vostok 2. Apparently there were medical problems and he has been under observation in a Soviet military hospital since.\nYour mission is to find out what physical impairments he had from the space flight and to get his medical records. Search all cabinets and bring us this file.\n\nHis name is: German Stepanovich Titov",
#3
"November 1961. We have information that a first American manned orbit of the Earth is to take place. The mission is called: Mercury-Atlas 5.\n\nThe guy in the training for this is called Mr. Enzo. You need to infiltrate the NASA training site and take some photos of Mr. Enzo's training program.\n\nWe want to know how the Americans prepare for something like this.",
#4
"Agent, this mission is a bit delicate and therefore TOP-TOP-Secret.\nI am afraid that my wife is having an affair. The new camera is very impressive so sneak into my house tonight and provide me with evidence! I've left you a note about the security system near the garage.",
#5
"The man is known by the name Platov. According to the lobby boy, he speaks with a Russian accent.\n\nBreak into his hotel room, tase him and bring him to me.\n\nI will have to interrogate him.\n\nHe lives in hotel room 6 on the third floor.",
#6
"Our great researchers have made significant progress with our own rocket. However, there are now rumors that the Soviets are already working on improved boosters.\n\nWe have located a factory near Baikonur that is suitable for construction.\n\nEnter the factory near Baikonur and get us plans or photos of the prototypes.",
#7
"My wife comes from a very wealthy family. So her father insisted on a marriage contract. This one really has it in it. I would be virtually bankrupt and she would still be rich.\n\nWe deposited the marriage contract with the largest law firm in Ustria. Search the archives. My last name is Jankovic.\n\nDestroy the contract at all costs!",
#8
"We are virtually ready for our first space flight. In the final tests, however, the control unit showed some anomalies and we were asked by the space agency to find a replacement.\nIn fact, the Soviet model seems to be identical to ours. That's why we have memorized the development department of the Soviets.\nBreak into the building and steal the unit.\nBy the way, while you are wearing an item you are not so agile and a bit sluggish. Plan your escape route carefully.",
#9
"Ustria is not a very rich country. The space program costs a lot and the great leader also needs a dignified lifestyle.\nTherefore, the only way I see to increase our funds is a classic bank robbery. And which country has a lot of banks and a lot of money?\n\nSwitzerland, of course! We want to steal a little bit of the Nazi gold from them to increase our own financial resources a little bit, our agents allready started the work on this one so it should be easy.",
#10
"Late in 1959, the Soviets made another lunar flyby with Luna 3. The special thing is that this time they took photos. We hope to find suitable landing sites for a moon landing from these photos.\n\nYour mission is to get these photos for us.",
#11
"In the Ides of May 1963, the Americans launched the crewed space mission Mercury-Atlas 9 to orbit the Earth 22 times before landing in the Pacific Ocean as part of the Mercury program. The astronaut Gordon Cooper could have been located by our intelligence. Kidnap him so we can get more information about the planned NASA program.",
#12
"NASA Administrator James E. Webb is known for taking home classified files. Enter his mansion and look for the Apollo files. Roadmap, plans, everything you can find. Make photocopies of the files and leave the house without getting caught. Destroy all traces.",
#13
"The Soviets put the first satellite into orbit around the moon in April 1966. We assume that, in addition to a gamma-ray spectrometer and a magnetometer, they are also actively searching for a possible landing site. Penetrate the radio telescope TNA-1500 and get us all the data. Avoid at all costs your exposure by the KGB.",
#14
"We are increasingly concerned about the Apollo program. Rumor has it that the first Apollo mission will launch soon. To buy more time, they sabotage the command module. The Americans will have to spend a lot of time troubleshooting.\nEnter the test lab and sabotage the command module.",
#15
"March 1967. After the Apollo-1 accident, the Moon Race nations increased their security measures because sabotage could not be ruled out - even though there was no evidence of it.\nDue to the increased security measures, one of our agents was caught in Moscow after he was too talkative after several vodkas.\nHe is currently in a military police cell and will be interrogated soon. Wire the interrogation room so that we have a head start in knowledge.",
#16
"April 1967. The Soviets are planning a first manned flight with the new Soyuz rocket. This could become the foundation for a moon landing.\nWe must, of course, prevent this until we are ready ourselves.\nThe Soviets are still waiting for a solar panel to be brought by train. Find the explosives on board the train, blow up the panels and escape by detaching the train from the locomotive.",
#17
"December 1968. The Apollo 8 mission orbited the moon, laying another foundation stone for the lunar mission.\nThe landing capsule will hit the Pacific Ocean tonight and be recovered by a salvage vessel.\nYou will be there, of course. Enter the ship and get us the records from the black box.",
#18
"May 1969. We are about to launch our moon mission. Only a few months separate us from our goal. But the Americans seem to be one step ahead of us again.\nOur intelligence was able to identify a new location where the planning for the moon landing is taking place.\nInfiltrate the building and get us the mission briefing. We must stop them at all costs.",
#19
"May 1969. It looks like we have now found the right main mission building.\nThe first location is probably the backup plan of the Americans to land on the moon before us. Or to make it look like one. Actually a very good idea. Why didn't we think of that?\nAnyway, get into the building and get us the mission plans. ",
#20
"Empty"
]

func setLevel(id):
	# subtract 1 because of hq level 
	if id - 1 < text.size():
		$BriefingLabel.bbcode_text = text[id - 1]
	else:
		print("Briefing Text out of Range")
	
	#enum LevelTypes {USA, USSR, Ustria}
	if id == Types.LevelTypes.USSR:
		$MapSprite.frame = 0
		$CountryLabel.set_text("USSR")
	elif id == Types.LevelTypes.Ustria:
		$MapSprite.frame = 2
		$CountryLabel.set_text("Ustria")
	elif id == Types.LevelTypes.Switzerland:
		$MapSprite.frame = 3
		$CountryLabel.set_text("Switzerland")
	else: 
		$MapSprite.frame = 1
		$CountryLabel.set_text("United States")
	
	showMissionBriefing()


func showMissionBriefing():
	randomize()
	$FunFactLabel.bbcode_text = "                " + funFacts[randi() % funFacts.size()]



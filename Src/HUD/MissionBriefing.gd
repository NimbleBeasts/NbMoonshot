extends Control


const funFacts = [
	"The Sun weighs about 330,000 times more than Earth.",
	"Footprints left on the Moon wont disappear as there is no wind.",
	"There are 79 known moons orbiting Jupiter.",
	"The Martian day is 24 hours 39 minutes and 35 seconds long.",
	"The Sun makes a full rotation once every 25 – 35 days.",
	"Earth is the only planet not named after a God.",
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
	"Astronauts can’t burp in space.",
	"Uranus was originally called Georges Star.",
	"A sunset on Mars is blue.",
	"The first living mammal to go into space was a dog named Laika from Russia."
]

const text = [
"Welcome Agent!\n\nYour first mission is to infiltrate the central archive of the Soviet Space Program and obtain plans of the Soyuz rocket. We will take some inspiration from their design and of course build a more magnificent rocket.\n\nThe plans are apparently in a safe on the 2nd floor. The code should also be hidden somewhere.",
"Agent, your last mission was a great success. Unfortunately some details are missing in the plans. Therefore, we are now sending them directly to the research facility where a Soyuz is currently being prepared. Take a picture of the boosters with the latest Ustrian invention of the instant camera, we call it Polyroid.\nTo access the factory floor, look for an employee ID card. Perhaps one is stored in the safe of the director.",
"Agent, this mission is a bit delicate and therefore TOP-TOP-Secret.\nI am afraid my wife is having an affair. The new Polyroid camera is very impressive. Sneak into my house tonight and provide me with evidence!",
"Comrade, I hope you did not let English slide. You will have to go to the USA today. We have heard that the states are planning a moon landing. We absolutely need these plans!\nIt would be an embarrassment to the great Republic of Ustria if the USA were to beat us to it.",
"I'm pretty sure that the Americans were just fooling us and that we were only on a film set. We have another source that confirms that they are planning a moon landing and new coordinates. There the moon landing module is supposed to be built. Infiltrate the building and get us the plans."
]

func setLevel(id):
	# subtract 1 because of hq level 
	$BriefingLabel.bbcode_text = text[id - 1]
	
	if id < 3:
		$MapSprite.frame = 0
	elif id == 3:
		$MapSprite.frame = 2
	else: 
		$MapSprite.frame = 1
	
	showMissionBriefing()


func showMissionBriefing():
	randomize()
	$FunFactLabel.bbcode_text = "                " + funFacts[randi() % funFacts.size()]



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


func setLevel(id):
	if id < 20: #Level amount
		print("setlevel: " + str(id))
		$BriefingLabel.bbcode_text = tr("MISSION_BRIEFING_LEVEL"+str(id))
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



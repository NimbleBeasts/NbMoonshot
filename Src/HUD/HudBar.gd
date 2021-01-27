extends NinePatchRect





func updateAlarm(count):
	$vbox/LLives.set_text(str(count))


func updateMoney(total, change):
	$vbox/LMoney.set_text(str(total))


func updateAmount(weapon, amount):
	$vbox/LAmount.set_text(str(amount))

	



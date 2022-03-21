extends CanvasLayer
# This is GUI.gd

signal press_build
signal cancel_conv

func _on_Button_pressed() -> void:
	emit_signal("press_build")


func updateMoney(money) -> void:
	$Label.text = "Money: " + str(money)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("RMB"):
		emit_signal("cancel_conv")

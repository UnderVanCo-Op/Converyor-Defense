extends CanvasLayer
# This is GUI.gd

signal press_build

func _on_Button_pressed() -> void:
	emit_signal("press_build")


func updateMoney(money) -> void:
	$Label.text = "Money: " + str(money)

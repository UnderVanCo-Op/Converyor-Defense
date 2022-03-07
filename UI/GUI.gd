extends CanvasLayer

signal press_build


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_Button_pressed() -> void:
	emit_signal("press_build")


func updateMoney(money) -> void:
	$Label.text = "Money: " + str(money)

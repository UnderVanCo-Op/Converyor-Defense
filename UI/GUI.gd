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

func _ready() -> void:
	var toggleDebug := false
	if(toggleDebug):
		OS.window_size = Vector2(1075,640)
		OS.window_position = Vector2(0,1200)
		OS.current_screen = 1
	var debugNout := false
	if(debugNout):
		OS.window_size = Vector2(800, 500)
		OS.window_position = Vector2(0,540)
	


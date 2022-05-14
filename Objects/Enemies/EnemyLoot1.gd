extends Node2D
var lootTimer:=10

func _on_TextureButton_pressed()->void:
	$"../../../GameManager".call("_change_resources",15)
	queue_free()
	
func _ready():
	$LootTimer.wait_time=lootTimer

func _on_Timer_timeout():
	queue_free()

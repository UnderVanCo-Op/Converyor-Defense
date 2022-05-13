extends Node2D



func _on_TextureButton_pressed():
	$"../../../GameManager".call("_change_resources",15)
	queue_free()

func _ready() -> void:
	pass



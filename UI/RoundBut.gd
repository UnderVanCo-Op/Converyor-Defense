extends TextureButton
# This is RoundBut.gd

signal FactoryButPressed(SpriteName)
var SSpriteName = null


func set_sprite(sprite_name) -> void:
	SSpriteName = sprite_name
	self.texture_normal = load("res://UI/" + sprite_name + ".png")


func _on_RoundBut_pressed() -> void:
	#print("Round button pressed")
	emit_signal("FactoryButPressed", SSpriteName)
	pass # Replace with function body.

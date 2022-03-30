extends TextureButton
# This is RoundBut.gd

signal FactoryButPressed(SpriteName)
var SpriteNum = null


func set_sprite(sprite_num : int = -1) -> void:
	SpriteNum = sprite_num
	#self.texture_normal = load("res://UI/but" + sprite_name + ".png")


func _on_RoundBut_pressed() -> void:
	#print("Round button pressed")
	emit_signal("FactoryButPressed", SpriteNum)
	pass # Replace with function body.

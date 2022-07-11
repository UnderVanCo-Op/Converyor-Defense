extends StaticBody2D

signal ConvBuilding(reftoNode, isUsed)
var isUsed := false		# for speed of checking
var inc_convs := []			# list-arrays for inc conveyors. All the conv inside these 2 lists must
var out_convs := []			# be (and are) ready to use
var OutConvMain = null		# point to the current out conv






# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func _on_TextureButton_pressed() -> void:
	emit_signal("ConvBuilding", self, isUsed)
	pass
	

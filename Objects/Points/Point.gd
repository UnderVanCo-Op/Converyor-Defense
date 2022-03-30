extends StaticBody2D
# This is Point.gd

signal ConvBuilding(Pntposition)


func _on_TextureButton_pressed() -> void:
	#emit_signal("ConvBuilding", get_node("TextureButton").rect_global_position)
	emit_signal("ConvBuilding", get_node("Position2D").global_position)

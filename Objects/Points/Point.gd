extends TextureButton
# This is Point.gd

signal ConvBuilding(Pntposition)

func _on_Point_pressed() -> void:
	emit_signal("ConvBuilding", rect_global_position)

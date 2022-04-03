extends StaticBody2D
# This is Point.gd

signal ConvBuilding(PathtoNode, isUsed, Pntposition)
var isUsed := false			# for speed of checking
var incConv := 0			# number of incoming conveyors
var outConv := 0			# number of outgoing conveyours

func _on_TextureButton_pressed() -> void:
	#emit_signal("ConvBuilding", get_node("TextureButton").rect_global_position)
	emit_signal("ConvBuilding", get_path(), isUsed, get_node("Position2D").global_position)

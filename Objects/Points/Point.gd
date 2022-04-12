extends StaticBody2D
# This is Point.gd

signal ConvBuilding(PathtoNode, isUsed, Pntposition)
var isUsed := false			# for speed of checking
var incConv := 0			# number of incoming conveyors (to be depricated)
var outConv := 0			# number of outgoing conveyors (to be depricated)
var inc_convs := []			# list-array for inc conveyors
var out_convs := []			# list-array for inc conveyors

func _on_TextureButton_pressed() -> void:
	#emit_signal("ConvBuilding", get_node("TextureButton").rect_global_position)
	emit_signal("ConvBuilding", get_path(), isUsed, get_node("Position2D").global_position)

# 
func AddIncConv(conv) -> void:
	incConv += 1
	inc_convs.append(conv)		# new ref to list
	pass

func AddOutConv(conv) -> void:
	outConv += 1
	out_convs.append(conv)		# new ref to list
	pass

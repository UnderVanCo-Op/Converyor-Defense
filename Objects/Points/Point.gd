extends StaticBody2D
# This is Point.gd

signal ConvBuilding(reftoNode, isUsed, Pntposition)
var isUsed := false			# for speed of checking
var isSpawnPoint := true	# shows if this is the start point of a chain
var incConv := 0			# number of incoming conveyors (to be depricated)
var outConv := 0			# number of outgoing conveyors (to be depricated)
var inc_convs := []			# list-array for inc conveyors
var out_convs := []			# list-array for inc conveyors

func _on_TextureButton_pressed() -> void:
	#emit_signal("ConvBuilding", get_node("TextureButton").rect_global_position)
	emit_signal("ConvBuilding", self, isUsed, get_node("Position2D").global_position)


func AddIncConv(conv) -> void:
	isSpawnPoint = false
	incConv += 1
	inc_convs.append(conv)		# new ref to list
	pass

func AddOutConv(conv) -> void:
	outConv += 1
	out_convs.append(conv)		# new ref to list
	pass


#
func ReceiveSpawnRequest(conv, count : int = -1) -> void:
	# Checks
	if(!isSpawnPoint and inc_convs.size() == 0):
		push_error("Point_ERROR: ReceiveReq can not be executed since no incoming conv are connected and not spawnpoint!")
		return
	if(count < 1):
		push_error("Point_ERROR: Can not spawn less than 1 cell!")
		return
	# General
	if(isSpawnPoint):
		conv.SpawnCells(count)
	else:
		inc_convs[0].Point.ReceiveSpawnRequest(count, conv)	# move on to the prev conv and Point


## 
#func SpawnCells(conv) -> void:
#	# Check
#	if(!isSpawnPoint):
#		push_error("Point_ERROR: Can not spawn cells in not SpawnPoint!")
#		return
#	# 

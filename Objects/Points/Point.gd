extends StaticBody2D
# This is Point.gd

signal ConvBuilding(reftoNode, isUsed, Pntposition)
var isUsed := false			# for speed of checking
var isSpawnPoint := true	# shows if this is the start point of a chain
var inc_convs := []			# list-arrays for inc conveyors. All the conv inside these 2 lists must
var out_convs := []			# be (and are) ready to use
#var first_cells := []		# list-array for keeping track of a every first cell in all inc conv


func _on_TextureButton_pressed() -> void:
	#emit_signal("ConvBuilding", get_node("TextureButton").rect_global_position)
	emit_signal("ConvBuilding", self, isUsed, get_node("Position2D").global_position)


#func _physics_process(delta: float) -> void:
#
##	TryMoveCell()
#	pass

#func CheckSpawn() -> void:
#	if(inc_convs.size() != 0):
#		isSpawnPoint = false			# this breaks a circle spawn
#	pass


func AddIncConv(conv) -> void:
	isSpawnPoint = false				# this breaks a circle spawn
	inc_convs.append(conv)				# new ref to list
#	connect("UpdateFirstCell", ref, "s_StartCell")
	pass

func AddOutConv(conv) -> void:
	out_convs.append(conv)		# new ref to list
	pass


# Methods tries to move cell to the next conv, update ref to first cell, and start inc conv
func TryMoveCell() -> bool:
	print("Try to move cell method reached")
	if(!isUsed or !out_convs or !inc_convs):
		push_warning("Point_ConnC_WARNING: first check triggered returning")
		return false
	if(out_convs[0].isBuilding or out_convs[0].CheckIfCapacityIsOver()):	# to be heavied in the future
		push_warning("Point_ConnC_WARNING: Out conv is full or is building, returning")
		return false
	if(inc_convs[0].isBuilding or !inc_convs[0].CheckIfCapacityIsOver()):
		push_warning("Point_ConnC_WARNING: Inc conv is not full, returning")
		return false
	
	print("Point is moving cell...")
	var cell = inc_convs[0].get_child(0)
	
	inc_convs[0].remove_child(cell)
	inc_convs[0].disconnect("StartCells", cell, "s_StartCell")
	inc_convs[0].disconnect("StopCells", cell, "s_StopCell")
	inc_convs[0].UpdateFirstCell()		# update first cell in the inc conv
	
	out_convs[0].add_child(cell)
	out_convs[0].ReceiveCell(cell)		# set up cell in new conv +updatefirstcell

	inc_convs[0].ActivatePhysics()		# activate check in phys_proc
	inc_convs[0].StartCells()			# start cells (emit signal) in inc conv bcs it is now freed
	return true


# 
func ReceiveSpawnRequest(count : int, conv = out_convs[0]) -> void:
	# Checks
	if(!isSpawnPoint and inc_convs.size() == 0):		# mb add another, antonymus check
		push_error("Point_ERROR: ReceiveReq can not be executed since no incoming conv are connected and not spawnpoint!")
		return
	if(count < 1):		# mb redundant since GM has it's own check
		push_error("Point_ERROR: Can not spawn less than 1 cell!")
		return
	# General
	if(isSpawnPoint):
		# add check for cycle works, mb TryMoveCell()
		conv.StartCells()
		conv.ActivatePhysics()
		conv.SpawnCells(count)
	else:
		print("Point: Moving request to the prev Point!")
#		print(inc_convs[0].Point.global_position)
		inc_convs[0].Point.ReceiveSpawnRequest(count)	# move on to the prev conv and Point


## Send cell to the out conv
#func SendCell(targetConv = out_convs[0]) -> void:
#	if(!cells[0]):
#		print("Point_Nothing to send, first add smth")
#		return
#	if(!targetConv):
#		push_error("Point_SendC_ERROR: No out conveyor for target!")
#		return
#	if(!targetConv.ReceiveCell(cells[0])):		# cell was not added for some reason in conv (mb full)
#
#		pass

## 
#func SpawnCells(conv) -> void:
#	# Check
#	if(!isSpawnPoint):
#		push_error("Point_ERROR: Can not spawn cells in not SpawnPoint!")
#		return
#	# 

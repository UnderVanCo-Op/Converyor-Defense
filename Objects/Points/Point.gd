extends StaticBody2D
# This is Point.gd

signal ConvBuilding(reftoNode, isUsed, Pntposition)
var isUsed := false			# for speed of checking
var isSpawnPoint := true	# shows if this is the start point of a chain
var inc_convs := []			# list-arrays for inc conveyors. All the conv inside these 2 lists must
var out_convs := []			# be (and are) ready to use

func _on_TextureButton_pressed() -> void:
	emit_signal("ConvBuilding", self, isUsed, get_node("Position2D").global_position)

func AddIncConv(conv) -> void:
	isSpawnPoint = false				# this breaks a circle spawn
	inc_convs.append(conv)				# new ref to list
	pass

func AddOutConv(conv) -> void:
	out_convs.append(conv)		# new ref to list
	pass

# warning-ignore:unused_argument
func _physics_process(delta: float) -> void:
	if(inc_convs and inc_convs[0].isReady and out_convs and !out_convs[0].isReady):
		TryMoveCell()
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
	if(inc_convs[0].isBuilding):
		push_warning("Point_ConnC_WARNING: Inc conv is not full or is building, returning")
		return false
	if(!out_convs[0].CheckIfSpawnIsFree()):
		push_warning("Point_ConnC_WARNING: Out conv spawn is not free, returning")
		return false
	
	print("Point is moving cell...")
	var cell = inc_convs[0].get_child(0)
	
	inc_convs[0].remove_child(cell)
	inc_convs[0].disconnect("StartCells", cell, "s_StartCell")
	inc_convs[0].disconnect("StopCells", cell, "s_StopCell")
	inc_convs[0].UpdateFirstCell()			# update first cell in the inc conv
	inc_convs[0].CheckIfCapacityIsOver()	# set isFull properly
	
	out_convs[0].add_child(cell)
	out_convs[0].call_deferred("ReceiveCell",cell)		# set up cell in new conv +updatefirstcell

	inc_convs[0].StartCells()
	inc_convs[0].isReady = false			# start cells (emit signal) in inc conv bcs it is now freed
	inc_convs[0].ActivatePhysics()
	return true


# Recursive function for moving request to the start of a chain
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
		inc_convs[0].Point.ReceiveSpawnRequest(count)	# move on to the prev conv and Point

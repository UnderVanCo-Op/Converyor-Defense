extends StaticBody2D
# This is Point.gd

signal ConvBuilding(reftoNode, isUsed, Pntposition)
var isUsed := false			# for speed of checking
var isSpawnPoint := true setget setter_isSpP	# shows if this is the start point of a chain
var inc_convs := []			# list-arrays for inc conveyors. All the conv inside these 2 lists must
var out_convs := []			# be (and are) ready to use
var inc_count := 0			# 
var out_count := 0			# 
var isShadingCell := false	#

func _ready() -> void:
	set_physics_process(false)

func setter_isSpP(new_val : bool) -> void:
	print("WOROAWROAWROARWOAORW", new_val)
	isSpawnPoint = new_val

func _on_TextureButton_pressed() -> void:
	emit_signal("ConvBuilding", self, isUsed, get_node("Position2D").global_position)

func AddIncConv(conv) -> void:
	call_deferred("set", "isSpawnPoint", false)
	inc_count += 1
#	isSpawnPoint = false				# this breaks a circle spawn
	inc_convs.append(conv)				# new ref to list

func AddOutConv(conv) -> void:
	out_count += 1
	out_convs.append(conv)		# new ref to list


# For now system chooses outc conv (if multiply are free) by who-is-first-entry in the out_convs (time approach)
# warning-ignore:unused_argument
func _physics_process(delta: float) -> void:
	if(isUsed and inc_convs and (inc_convs[0].isReady or inc_convs[0].isShaded) and out_convs):
		for outc in out_convs:
			if(!outc.isReady and !outc.isSpawning):		# finding free conv
				if(!isShadingCell):
					TryShadeCell(outc)
					break		# this ensures point only moves one cell from all inc convs to only one out conv
				elif(inc_convs[0].isCellOnQuit):
					TryMoveCell(outc)
					break		# this ensures point only moves one cell from all inc convs to only one out conv
#	if(isUsed and inc_convs and inc_convs[0].isReady and out_convs and !out_convs[0].isReady):
#		TryMoveCell()


#
func TryShadeCell(outconv):
	print("TryShadeCell reached")
	# Checks
	if(outconv.isBuilding or outconv.CheckIfCapacityIsOver()):	# to be heavied in the future
		push_warning("Point_ConnC_WARNING: Out conv is full or is building, returning")
		return false
	if(inc_convs[0].isBuilding):
		push_warning("Point_ConnC_WARNING: Inc conv is building, returning")
		return false
#	if(!outconv.CheckIfSpawnIsFree()):
#		push_warning("Point_ConnC_WARNING: Out conv spawn is not free, returning")
#		return false
	
	if(!isShadingCell):
		print("\nPoint is offsetting cell now")
		inc_convs[0].StartCells()
		inc_convs[0].ActivatePhysics()
		inc_convs[0].isShaded = true
		isShadingCell = true
	else:
		push_error("Point_TryShade_ERROR: Tried to shade cell when some other cell is already shading")
		

#
func TryMoveCell(outconv):
#	MoveCounter += 1	# seems like Point has only 1 unnessarily call of this func
#	print("Movecounter becomes ", MoveCounter, " on some Point...")
#	print("TryMoveCell reached")
	# Checks are commented, bcs we have done them in TryShade method
#	if(outconv.isBuilding or outconv.CheckIfCapacityIsOver()):	# to be heavied in the future
#		push_warning("Point_ConnC_WARNING: Out conv is full or is building, returning")
#		return false
#	if(inc_convs[0].isBuilding):
#		push_warning("Point_ConnC_WARNING: Inc conv is building, returning")
#		return false
#	if(!outconv.CheckIfSpawnIsFree()):
#		push_warning("Point_ConnC_WARNING: Out conv spawn is not free, returning")
#		return false
	
	# General
	print("\nPoint is moving cell now")
	var cell = inc_convs[0].get_child(0)
	
	inc_convs[0].remove_child(cell)
	inc_convs[0].disconnect("StartCells", cell, "s_StartCell")
	inc_convs[0].disconnect("StopCells", cell, "s_StopCell")
	inc_convs[0].UpdateFirstCell()			# update first cell in the inc conv
	inc_convs[0].CheckIfCapacityIsOver()	# set isFull properly
	
	outconv.add_child(cell)
	outconv.call_deferred("ReceiveCell", cell)		# set up cell in new conv +updatefirstcell
	
	# start cells (emit signal) in inc conv bcs it is now freed
	inc_convs[0].isShaded = false
	inc_convs[0].isCellOnQuit = false
#	inc_convs[0].StartCells()
	inc_convs[0].StopCells()
	inc_convs[0].ActivatePhysics()
	
	isShadingCell = false
	return true


# Methods tries to move cell to the next conv, update ref to first cell, and start inc conv
func OldTryMoveCell() -> bool:
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
func ReceiveSpawnRequest(count : int, conv) -> void:
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
#		conv.StartCells()
		conv.ActivatePhysics()
		conv.SpawnCells(count)
	else:
		print("Point: Moving request to the prev Point!")
		inc_convs[0].Point.ReceiveSpawnRequest(count, inc_convs[0])	# move on to the prev conv and Point
		# inc convs[0] should be replaced with smart choice of a path-system

extends StaticBody2D
# This is Point.gd

signal ConvBuilding(reftoNode, isUsed, Pntposition)
var isUsed := false			# for speed of checking
var isSpawnPoint := true setget setter_isSpP	# shows if this is the start point of a chain
var inc_convs := []			# list-arrays for inc conveyors. All the conv inside these 2 lists must
var out_convs := []			# be (and are) ready to use
var inc_count := 0			# not used currently
var out_count := 0			# not used currently
var isShadingCell := false	# shading
var WasUsed := false		# recursive system works
var WasCellMoved := false	# recursive system works
#var EndOfChain = null		# cycle system

func _ready() -> void:
	set_physics_process(false)

func setter_isSpP(new_val : bool) -> void:
#	print("WOROAWROAWROARWOAORW", new_val)
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
	if(!WasUsed):
		CellWork()

#
func ResetMarks() -> void:
	WasUsed = false
	WasCellMoved = false


# downlying if: mb isspawnpoint or smth
#
func CellWork(Point = null):
	if(isUsed and inc_convs and (inc_convs[0].isSending or inc_convs[0].isShaded) and out_convs and !WasUsed):
		for outc in out_convs:
			if((!outc.isReady and !outc.isSpawning) or outc.isSending):		# finding free conv
				if(!isShadingCell):
					TryShadeCell(outc)
					call_deferred("ResetMarks")
					break		# this ensures point only moves one cell from all inc convs to only one out conv
				elif(inc_convs[0].isCellOnQuit):
#					WasUsed = true
					TryMoveCell(outc)
					call_deferred("ResetMarks")
					break		# this ensures point only moves one cell from all inc convs to only one out conv


#
func TryShadeCell(outconv):
	print("TryShadeCell reached")
	# Checks
	if(outconv.isBuilding or outconv.CheckIfCapacityIsOver() or (outconv.CheckIfCapacityIsEqual() and !outconv.isSending)):	# to be heavied in the future
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
		inc_convs[0].isShaded = true
		isShadingCell = true
		inc_convs[0].StartCells()
		inc_convs[0].ActivatePhysics()
		# mb WasUsed = true
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
	if(!outconv.endPoint.WasUsed):
		outconv.endPoint.CellWork()		# recursive to the end
	
	print("\nPoint is moving cell now")
	var cell = inc_convs[0].get_child(0)
	
	inc_convs[0].remove_child(cell)
	inc_convs[0].disconnect("StartCells", cell, "s_StartCell")
	inc_convs[0].disconnect("StopCells", cell, "s_StopCell")
	inc_convs[0].UpdateFirstCell()			# update first cell in the inc conv
	inc_convs[0].CheckIfCapacityIsOver()	# set isFull properly
	
	outconv.add_child(cell)
	outconv.call_deferred("ReceiveCell", cell)		# set up cell in new conv +updatefirstcell, mb not deferred
	
	# start cells (emit signal) in inc conv bcs it is now freed
	inc_convs[0].isShaded = false
	inc_convs[0].isCellOnQuit = false
#	inc_convs[0].StartCells()
#	inc_convs[0].StopCells()
#	inc_convs[0].ActivatePhysics()
	if(!outconv.isSending and outconv.CheckIfCapacityIsEqual()):
		inc_convs[0].StopCells()
		inc_convs[0].DeactivatePhysics()
		inc_convs[0].isSending = false
	
	WasUsed = true
	WasCellMoved = true
	isShadingCell = false
	return true


# Recursive function for moving request to the start of a chain, conv is outc from P
func ReceiveSpawnRequest(count : int, conv, isContinuation := false, EndOfChainP = null) -> void:
	# Checks
	if(!isSpawnPoint and inc_convs.size() == 0):		# mb add another, antonymus check
		push_error("Point_ERROR: ReceiveReq can not be executed since no incoming conv are connected and not spawnpoint!")
		return
	if(count < 1):			# mb redundant since GM has it's own check
		push_error("Point_ERROR: Can not spawn less than 1 cell!")
		return
	# General
	var PToSend = null
	if(isContinuation):		# возможно лишняя переменная
		conv.isSending = true
		conv.StartCells()
		conv.ActivatePhysics()
		
		if(self == EndOfChainP):
			print("\nFOUND A CYCLE!!")
			call_deferred("set", "isSpawnPoint", true)
			inc_convs[0].isSending = true				# for now, to run the circle
		else:
			PToSend = EndOfChainP
	else:
		PToSend = conv.endPoint
	if(isSpawnPoint):
		# add check for cycle works, mb TryMoveCell()
		conv.StartCells()
		conv.ActivatePhysics()
		conv.SpawnCells(count)
	else:
		print("Point: Moving request to the prev Point!")
		inc_convs[0].Point.ReceiveSpawnRequest(count, inc_convs[0], true, PToSend)	# move on to the prev conv and Point
		# inc convs[0] should be replaced with smart choice of a path-system

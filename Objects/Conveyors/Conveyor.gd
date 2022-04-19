extends Path2D
# This is Conveyor.gd

var ConvCell := preload("res://Objects/Conveyors/ConvCell.tscn")
var Point : StaticBody2D = null			# stores ref to point-parent (not used currently)
var endPoint : StaticBody2D = null		# stores ref to point-next (used in phys_proc)
var capacity := -1						# stores number of cells, that conv can have
var isFull := false						# shows if the conveyor is fulled with cells
#var isMoving := false					#
var isBuilding := true					# shows if the conv is in building stage
var FirstCell : PathFollow2D = null		# ref to first cell in conv
var CellOnSpawn : PathFollow2D = null 	#
var isSpawning := false					#
var cellInQ := 0						#
#var isSending := false					# shows if conv is sending cells somewhere to next conv
const SPAWN_FREE_DST := 90				# wanted distance btw cells
var SpawnFreeOffset : float = -1		# gets calc in CountCap method
const POINT_OFFSET := 200				# basic offset to not overlap Point (around 230)
export var WantedOffset : float = 0	# adds to Points offset
var StartOffset : float = -1			# gets calc in CountCap method
var QuitOffset : float = -1				# gets calc in CountCap method

signal StopCells()			# signal is emitted when cells are need to be stopped
signal StartCells()			# signal is emitted when cells are need to be started
#signal SpawnFreed()			#
#signal UpdateFirstCell()	# emit when ref to  1 cell is changed

func ActivatePhysics() -> void:
	set_physics_process(true)

func DeactivatePhysics() -> void:
	set_physics_process(false)

func _physics_process(_delta: float) -> void:
	pass
	if(FirstCell and FirstCell.offset >= QuitOffset):
		print("offset worked")
		if(!endPoint.TryMoveCell()):				# if cell was not moved, than stop checking (until some point, connected with out conv says we need to start again
			StopCells()
			DeactivatePhysics()
	if(isSpawning and CellOnSpawn and CellOnSpawn.offset == SpawnFreeOffset):
		SpawnQ()
		
	
#func CheckLength(checkL : float) -> void:
#	if(checkL >= curve.get_baked_length()):
#		push_error("Conv_CheckL_ERROR: checking val is greater than curve length!")
#		return
#	pass

func StopCells() -> void:
	emit_signal("StopCells")
	
func StartCells() -> void:
	emit_signal("StartCells")


# Calculates and sets capacity, without gap and separation, to be redone in future
func CountCapacity() -> int:
	if(curve.get_point_count() < 2):
		push_error("Conveyor_CountC_ERROR: 1 or 0 points in curve is not enough!")
		return -1
	var c = ConvCell.instance()
	var sprite = c.get_node("Sprite")
	var _rect : Vector2 = sprite.region_rect.size
	var _scale : Vector2 = sprite.scale
	c.queue_free()
	
	var Cleng := curve.get_baked_length()
	
	StartOffset = POINT_OFFSET + WantedOffset
#	if(StartOffset >= Cleng):
#		push_error("Conv_CountCap_ERROR: Start offset is greater that curve length! Removing wanted offset...")
#		StartOffset = POINT_OFFSET
#		if(StartOffset >= Cleng):
#			push_error("Conv_CountCap_ERROR: Start offset is greater that curve length even after fix! Returning...")
#			StartOffset = -1
#			return
	SpawnFreeOffset = StartOffset + SPAWN_FREE_DST * 2
	if(SpawnFreeOffset >= Cleng):
		push_error("Conv_CountCap_ERROR: SpawnFree offset is greater that curve length! Removing wanted offset from both SpawnFree and Start offsets...")
		SpawnFreeOffset -= WantedOffset
		StartOffset -= WantedOffset
		if(SpawnFreeOffset >= Cleng):	# StartOffset is smaller than spawn one, so we dont need to check
			push_error("Conv_CountCap_ERROR: SpawnFree offset is greater that curve length even after fix! Returning...")
			SpawnFreeOffset = -1
			StartOffset = -1
			return -1
	QuitOffset = Cleng - StartOffset		# simmetry
	
	var _capacity : int =  int((Cleng - StartOffset - StartOffset) / (SPAWN_FREE_DST))	# for now, it is Cleng - 2 * StartOffset, actually
#	print(str(Cleng))
	print("\nCleng: ", Cleng, " Chislitel: ", Cleng - StartOffset - StartOffset, " capacity: ", _capacity, " x: ", _rect.x * _scale.x, " StartOffset: ", StartOffset, " SpawnFreeOffset: ", SpawnFreeOffset, " QuitOffset: ", QuitOffset, " SPAWN_FREE_DST: ", SPAWN_FREE_DST)
	capacity = _capacity
	return _capacity


# Checks if the number of cells exceed capacity + 1, should be done everytime op with moving/spawning cell is done
func CheckIfCapacityIsOver() -> bool:
	if(get_child_count() > capacity + 1):	# +1 bcs there are border-conditions when moving cells
		push_error("Conv_CRITICAL_ERROR: there are more than max cells on" + str(self) + "conveyor !!!")
		isFull = true
		return true
	elif(get_child_count() < capacity):
		isFull = false
		return false
	else:					# ==capacity + 1 and ==capacity
		isFull = true
		return true


# Method for setting starting valus for incoming cell, unit_offset doesn't seem to work outside the conv
func ReceiveCell(newcell : PathFollow2D) -> bool:
	if(isFull):
		push_error("Conv_ReceiveC_ERROR: Can not receive cell, since conv is full")
		return false
# warning-ignore:return_value_discarded
	connect("StartCells", newcell, "s_StartCell")		# connecting signal from conv
# warning-ignore:return_value_discarded
	connect("StopCells", newcell, "s_StopCell")			# connecting signal from conv
#	newcell.unit_offset = 0				# start parameters
	newcell.offset = StartOffset
	newcell.isMoving = true				# start parameters
	CheckIfCapacityIsOver()
	UpdateFirstCell()			# everytime cell move on to this conv
	return true


# Must be called everytime the action with adding/deleting cell is in place
func UpdateFirstCell() -> void:
	if(get_child_count() == 0):	# check
		push_warning("Conv_UpdateFirstC_WARNING: Can not update first cell bcs conv is empty")
		return
	FirstCell = get_child(0)	# update ref to first cell


# Helper-Function of SpawnCells
func SpawnQ() -> void:
	# Checks
	if(!isSpawning):
		push_error("Conv_SpawnQ_ERROR: tried to SpawnQ without isSpawning flag, returning...")
		return
	if(cellInQ <= 0):		# change to == in the future
		push_error("Conv_SpawnQ_ERROR: tried to SpawnQ without cells in q, returning...")
		if(CellOnSpawn.offset >= SpawnFreeOffset):
			CellOnSpawn = null
		isSpawning = false
		return
	
	# General
	print("SpawnQ is working now...")
	var newcell = AddCell()		# spawn
	CellOnSpawn = newcell		# update ref
	
	cellInQ -= 1
	if(cellInQ <= 0):		# change to == in the future
		isSpawning = false


# Method waits until timer, for now. Will be waiting for free for some time until error, in the future
func WaitUntilFree() -> void:
#	yield(get_tree().create_timer(0.3333), "timeout")		# only for the test
#	yield(_physics_process(1), "SpawnFreed")
#	yield(isFull, false)
	pass


# Method checks for some errors, then waits until conv is free and finally spawn cell with count specified in param
func SpawnCells(count : int) -> void:
	# Check
	if(curve.get_point_count() < 2):
		push_error("Conv_SpawnC_ERROR: 1 or 0 points in curve is not enough!")
		return
	print("Conv: spawning " + str(count) + " cells...")
	
	# General
	isSpawning = true
	if(get_child_count() == 0):		# mb if not firstcell
		CellOnSpawn = AddCell()		# update cellonspawn
		cellInQ -= 1
#		CellOnSpawn = FirstCell		# update cellonspawn
	
	cellInQ += count
	if(cellInQ == 0):
		isSpawning = false
#	SpawnQ()
	#	for c in count:
#		yield(WaitUntilFree(), "completed")
#		AddCell()
	
	
#		if(CheckIfCapacityIsOver()):				# first cell is worked separately
#		push_warning("Conv_SpawnC_WARNING: Conv is full! Trying to fix...")
#		yield(WaitUntilFree(), "completed")
#		if(CheckIfCapacityIsOver()):
#			push_error("Conv_SpawnC_ERROR: Conv is full after timer! Returning")
#			return
#		else:
#			AddCell()
#	else:
#		AddCell()
#	yield(WaitUntilFree(), "completed")
	
#	for c in count:							# other cells
#		if(CheckIfCapacityIsOver()):			# 
#			push_warning("Conv_SpawnC_WARNING: Conv is full! Trying to fix...")
#			yield(WaitUntilFree(), "completed")
#			if(CheckIfCapacityIsOver()):
#				push_error("Conv_SpawnC_ERROR: Conv is full after timer! Returning")
#				return
#			else:
#				AddCell()
#		else:
#			pass
##			
#		yield(WaitUntilFree(), "completed")
#		AddCell()
	
#	yield(WaitUntilFree(), "completed")	
	
#	if(CheckIfCapacityIsOver()):
#		StopCells()
#		print("Conv: Spawned and stopped!")


# Method adds one cell immediately to the start of conveyor without checks
func AddCell() -> PathFollow2D:
	var ref = ConvCell.instance()
	add_child(ref)
	ref.offset = StartOffset
	# disconnect first, if necessary
# warning-ignore:return_value_discarded
	connect("StartCells", ref, "s_StartCell")		# connecting signal from conv
# warning-ignore:return_value_discarded
	connect("StopCells", ref, "s_StopCell")			# connecting signal from conv
	UpdateFirstCell()		# everytime cell adds
	return ref

# Must be called after child added. Method updates ref to firstcell
#func CheckFirstCell(cell : PathFollow2D) -> void:
#	if(get_child_count() == 1):
#		FirstCell = cell
#		emit_signal("UpdateFirstCell", FirstCell)
#	pass


# Method does all the starting preparations and sets sending on
#func StartSendingCellsTo(convPath : NodePath) -> void:
#	var conv = get_node_or_null(convPath)
#	#print("Conv got path:" + convPath)
#	if(conv):
#		pass
##		conv.isContinue = true
##		refToNextConv = conv
##		isSending = true
##		refToNextConv.refToPrevConv = self			# 2-linked list
#	else:
#		push_error("Conv_StartS_ERROR: can not get next conv in the chain")

#
## Method fulls Conveyor with cells while first cell is not in the end
#func FullWithCells() -> void:		# mb add some bool to ensure spawning or getting an error
#	if(curve.get_point_count() == 0):
#		push_error("Conveyor_ERROR: 0 points in curve for conveyor!")
#		return
#	#print(curve.get_baked_length())
#	print("isFull: " + str(isFull))
#	while(!isFull):
#		AddCell()											# 7 cells if addcell is pre yield, otherwise 8
#		yield(get_tree().create_timer(0.333), "timeout")	# 


#func SendCell() -> void:
##	if(isSending and isFull):		# if conv is sending to the next one and full
#	if(isFull):
#		remove_child(refToFirstCell)						# changing parents
#		disconnect("StartCells", refToFirstCell, "s_StartCell")
#		disconnect("StopCells", refToFirstCell, "s_StopCell")
##		refToNextConv.add_child(refToFirstCell)				# changing parents
##		refToNextConv.call("ReceiveCell", refToFirstCell)
#		isFull = false
##		if(!isContinue):
#			#yield(get_tree().create_timer(0.3333333333), "timeout")
##			AddCell()
#		if(get_child_count() != 0):
#			refToFirstCell = get_child(0)				# new first cell
#			emit_signal("StartCells")
#		else:
#			refToFirstCell = null

extends Path2D
# This is Conveyor.gd

var ConvCell := preload("res://Objects/Conveyors/ConvCell.tscn")
var Point : StaticBody2D = null			# stores ref to point-parent (not used currently)
var endPoint : StaticBody2D = null		# stores ref to point-next (used in phys_proc)
var capacity := -1						# stores number of cells, that conv can have
var isFull := false						# shows if the conveyor is fulled with cells (+1)
var isMoving := false					#
var isReady := false					# fulled and stopped
var isBuilding := true					# shows if the conv is in building stage
var FirstCell : PathFollow2D = null		# ref to first cell in conv
var CellOnSpawn : PathFollow2D = null 	# Practically, this is the last cell in conv
var isSpawning := false					# shows if the conv is spawning cells
var cellInQ := 0						# cells, that are enqueued in this conv
var isSending := false				# shows if conv is sending cells somewhere to next conv
const FREE_DST := 110					# wanted distance btw pivot of near cells
var SpawnFreeOffset : int = -1			# gets calc in CountCap method
const POINT_OFFSET := 200				# basic offset to not overlap Point (around 230)
export var WantedOffset : int = 0		# adds to Points offset (can be set from Editor mb)
var StartOffset : int = -1				# gets calc in CountCap method
var ShadeOffset : int = -1				#
var QuitOffset : int = -1				# gets calc in CountCap method
var isShaded := false					# sets only from Point, no changing inside Conv.gd must be done
var isCellOnQuit := false				#

signal StopCells()			# signal is emitted when cells are need to be stopped
signal StartCells()			# signal is emitted when cells are need to be started

func ActivatePhysics() -> void:
#	isReady = false
	set_physics_process(true)

func DeactivatePhysics() -> void:
	set_physics_process(false)

func _physics_process(_delta: float) -> void:
	if(isSpawning and CellOnSpawn and CellOnSpawn.offset >= SpawnFreeOffset - 10):
		call("SpawnQ")
	if(!isReady and !isShaded):
#		CheckQuitOffset()
		CheckShadeOffset()
	if(isShaded):
		CheckQuitOffset()
	pass


func CheckShadeOffset() -> void:
	if(FirstCell and FirstCell.offset >= ShadeOffset - 10 and !isSending):
		print("Conv ", self, " firstcell is in 10p from the ShadeOffset!")
		call_deferred("StopCells")
		if(!isSpawning):
			call_deferred("DeactivatePhysics")


func CheckQuitOffset() -> void:
	if(FirstCell and FirstCell.offset >= QuitOffset - 10):
		print("Conv ", self,  " firstcell is in 10p from the QuitOffset!")
#		call_deferred("StopCells")
#		if(!isSpawning):
#			call_deferred("DeactivatePhysics")
		isCellOnQuit = true


func StopCells() -> void:
	print("Stopping cells on a conv ", self)
	isMoving = false
	emit_signal("StopCells")
	if(get_child_count() == capacity):
		isReady = true
	
func StartCells() -> void:
	print("Starting cells on a conv ", self)
	isReady = false
	isMoving = true
	emit_signal("StartCells")


# Calculates and sets all ofssets
func CountCapacity() -> int:
	if(curve.get_point_count() < 2):
		push_error("Conveyor_CountC_ERROR: 1 or 0 points in curve is not enough!")
		return -1
	var c = ConvCell.instance()		# adding instance for getting sizes
	var sprite = c.get_node("Sprite")
	var _rect : Vector2 = sprite.region_rect.size
	var _scale : Vector2 = sprite.scale
	c.queue_free()
	
	var Cleng := curve.get_baked_length()		# get length of the curve
	
	StartOffset = POINT_OFFSET + WantedOffset	# WantedOffset = 0 for default
	SpawnFreeOffset = StartOffset + FREE_DST
	if(SpawnFreeOffset >= Cleng):		# Check
		push_error("Conv_CountCap_ERROR: SpawnFree offset is greater that curve length! Removing wanted offset from both SpawnFree and Start offsets...")
		SpawnFreeOffset -= WantedOffset
		StartOffset -= WantedOffset
		if(SpawnFreeOffset >= Cleng):	# StartOffset is smaller than spawn one, so we dont need to check
			push_error("Conv_CountCap_ERROR: SpawnFree offset is greater that curve length even after fix! Returning...")
			SpawnFreeOffset = -1
			StartOffset = -1
			return -1
	
	var _capacity : int =  int((Cleng - StartOffset - StartOffset) / (FREE_DST))	# for now
	_capacity += 1		# bcs FREE_DST is only distance btw cells
	ShadeOffset = StartOffset + (_capacity - 1 ) * (FREE_DST)
	print("ShadeOffset before ceiling: ", ShadeOffset)
	var temp := ShadeOffset % 10
	if(temp != 0):
		ShadeOffset += (10 - ShadeOffset % 10)						# ceil to 10
	SpawnFreeOffset -= (SpawnFreeOffset % 10)
	if(ShadeOffset >= Cleng):		# Check
		push_error("Conv_CountCap_ERROR: ShadeOffset is greater that curve length! Setting default value...")
		print("ShadeOffset: ", ShadeOffset)
		ShadeOffset = Cleng - StartOffset
	if(StartOffset == ShadeOffset):
		push_warning("Conv_CountCap_WARNING: StartOffset = ShadeOffset, so there will be no movement on conveyor!")
	QuitOffset = ShadeOffset + FREE_DST
		
	print("\nCleng: ", Cleng, " Chislitel: ", Cleng - StartOffset - StartOffset, " capacity: ", _capacity, " x: ", _rect.x * _scale.x, " StartOffset: ", StartOffset, " SpawnFreeOffset: ", SpawnFreeOffset, " ShadeOffset: ", ShadeOffset, " QuitOffset: ", QuitOffset,  " FREE_DST: ", FREE_DST)
	
	capacity = _capacity
	return _capacity


func CheckIfCapacityIsEqual() -> bool:
	if(get_child_count() == capacity):	# +1 bcs there are border-conditions when moving cells
#		isFull = true
		return true
	else:
#		isFull = false
		return false

# Checks if the number of cells exceed capacity + 1, should be done everytime operation with moving/spawning cell is done
func CheckIfCapacityIsOver() -> bool:
	if(get_child_count() > capacity + 1):	# +1 bcs there are border-conditions when moving cells
		push_error("Conv_CRITICAL_ERROR: there are more than max cells on" + str(self) + "conveyor !!!")
		isFull = true
		return true
	else:
		isFull = false
		return false
#	else:					# ==capacity + 1 and ==capacity
#		isFull = true
#		return true

func CheckIfSpawnIsFree() -> bool:
	if(get_child_count() == 0):
		return true
	if(CellOnSpawn.offset < SpawnFreeOffset - 10):		# CellOnSpawn always exists if child count != 0
		return false
	else:
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
	newcell.offset = StartOffset
	if(isMoving):				# start parameters
		newcell.isMoving = true
	else:
		newcell.isMoving = false
		isReady = true
	CellOnSpawn = newcell
	if(get_child_count() == 1):		# if more, they should be moving already
		StartCells()
	CheckIfCapacityIsOver()
	UpdateFirstCell()			# everytime cell move on to this conv
	return true


# Must be called everytime the action with adding/deleting cell is in place
func UpdateFirstCell() -> void:
	if(get_child_count() == 0):	# check
		push_warning("Conv_UpdateFirstC_WARNING: Can not update first cell bcs conv is empty")
		return
	FirstCell = get_child(0)	# update ref to first cell


# Main function of spawn
func SpawnQ() -> void:
	# Checks
	if(!isSpawning):
		push_error("Conv_SpawnQ_ERROR: tried to SpawnQ without isSpawning flag, returning...")
		return
	if(cellInQ <= 0):		# change to == in the future
		push_error("Conv_SpawnQ_ERROR: tried to SpawnQ without cells in q, returning...")
		isSpawning = false
		return
	
	# General
	print("SpawnQ is working now...")
	var newcell = AddCell()		# spawn
	CellOnSpawn = newcell		# update ref
	
	cellInQ -= 1
	if(get_child_count() >= capacity):
		isFull = true
	if(cellInQ == 0):
		isSpawning = false


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
		print("First cell spawned")
		cellInQ -= 1
	
	cellInQ += count
	if(cellInQ == 0):
		isSpawning = false


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

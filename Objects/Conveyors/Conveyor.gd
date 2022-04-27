extends Path2D
# This is Conveyor.gd

var ConvCell := preload("res://Objects/Conveyors/ConvCell.tscn")
var Point : StaticBody2D = null			# stores ref to point-parent (not used currently)
var endPoint : StaticBody2D = null		# stores ref to point-next (used in phys_proc)
var capacity := -1						# stores number of cells, that conv can have
var isFull := false						# shows if the conveyor is fulled with cells
var isMoving := false					#
var isBuilding := true					# shows if the conv is in building stage
var FirstCell : PathFollow2D = null		# ref to first cell in conv
var CellOnSpawn : PathFollow2D = null 	# Practically, this is the last cell in conv
var isSpawning := false					# shows if the conv is spawning cells
var cellInQ := 0						# cells, that are enqueued in this conv
#var isSending := false					# shows if conv is sending cells somewhere to next conv
const FREE_DST := 110					# wanted distance btw pivot of near cells
var SpawnFreeOffset : int = -1			# gets calc in CountCap method
const POINT_OFFSET := 200				# basic offset to not overlap Point (around 230)
export var WantedOffset : float = 0		# adds to Points offset (can be set from Editor mb)
var StartOffset : float = -1			# gets calc in CountCap method
var QuitOffset : int = -1				# gets calc in CountCap method

signal StopCells()			# signal is emitted when cells are need to be stopped
signal StartCells()			# signal is emitted when cells are need to be started
#signal SpawnFreed()			#
#signal UpdateFirstCell()	# emit when ref to  1 cell is changed

func ActivatePhysics() -> void:
	set_physics_process(true)

func DeactivatePhysics() -> void:
	set_physics_process(false)

func _physics_process(_delta: float) -> void:
	if(isSpawning and CellOnSpawn and CellOnSpawn.offset >= SpawnFreeOffset - 10):
		SpawnQ()
	if(FirstCell and FirstCell.offset >= QuitOffset ):
		print("offset worked")
		if(!endPoint.call("TryMoveCell")):				# if cell was not moved, than stop checking (until some point, connected with out conv says we need to start again
			StopCells()
			DeactivatePhysics()	 #commented bcs the request to move cell is soming late if we deactivate physics process, at least for now
	pass
		
func _ready() -> void:
	get_tree().connect("physics_frame", self, "PrePhysProc")
	pass


# Method is only needed for fixing dst btw cells, which turns out to be inaccurate bcs of cells doing += speed 1 more phys tick more, than needed
func PrePhysProc() -> void:
#	print("prephys")
	
	pass


func StopCells() -> void:
	print("Stopping cells on a conv ", self)
	isMoving = false
	emit_signal("StopCells")
	
func StartCells() -> void:
	print("Starting cells on a conv ", self)
	isMoving = true
	emit_signal("StartCells")


# Calculates and sets capacity, without gap and separation, to be redone in future
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
#	if(_capacity == 0):
#		push_error("Conv_CountCap_ERROR: Capacity is 0!!! Returning")
#		capacity = _capacity
#		return _capacity
#	if(_capacity == 1):
#		QuitOffset = StartOffset + FREE_DST 
#	else:
	QuitOffset = StartOffset + (_capacity - 1 ) * (FREE_DST)
	print("QuitOffset before ceiling: ", QuitOffset)
	var temp := QuitOffset % 10
	if(temp != 0):
		QuitOffset += (10 - QuitOffset % 10)						# ceil to 10
	SpawnFreeOffset -= (SpawnFreeOffset % 10)
#	QuitOffset = stepify(QuitOffset, 10)
	if(QuitOffset >= Cleng):		# Check
		push_error("Conv_CountCap_ERROR: QuitOffset is greater that curve length! Setting default value...")
		print("QuitOffset: ", QuitOffset)
		QuitOffset = Cleng - StartOffset
	if(StartOffset == QuitOffset):
		push_warning("Conv_CountCap_WARNING: StartOffset = QuitOffset, so there will be no movement on conveyor!")
#	QuitOffset = 560
	print("\nCleng: ", Cleng, " Chislitel: ", Cleng - StartOffset - StartOffset, " capacity: ", _capacity, " x: ", _rect.x * _scale.x, " StartOffset: ", StartOffset, " SpawnFreeOffset: ", SpawnFreeOffset, " QuitOffset: ", QuitOffset, " FREE_DST: ", FREE_DST)
	
	capacity = _capacity
	return _capacity


# Checks if the number of cells exceed capacity + 1, should be done everytime operation with moving/spawning cell is done
func CheckIfCapacityIsOver() -> bool:
	if(get_child_count() > capacity):	# +1 bcs there are border-conditions when moving cells
		push_error("Conv_CRITICAL_ERROR: there are more than max cells on" + str(self) + "conveyor !!!")
		isFull = true
		return true
	elif(get_child_count() < capacity):
		isFull = false
		return false
	else:					# ==capacity + 1 and ==capacity
		isFull = true
		return true


func CheckIfSpawnIsFree() -> bool:
	if(get_child_count() == 0):
		return true
	if(CellOnSpawn.offset < SpawnFreeOffset):		# CellOnSpawn always exists if child count != 0
		return false
	else:
		return true

# Method for setting starting valus for incoming cell, unit_offset doesn't seem to work outside the conv
func ReceiveCell(newcell : PathFollow2D, addtnlOffset := 0) -> bool:
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
	
	if(get_child_count() != 1 and get_child_count() != capacity):	# 1 bcs cell is already spawned from Point, capacity to exclude last cell bcs conv is going to be stopped and last cell is gonna overlap the next cell bcs of down (else) fix
		newcell.offset += 10
		if(addtnlOffset != 0):
			newcell.offset += addtnlOffset
	
	CellOnSpawn = newcell
#	newcell._physics_process(0)
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
#		if(CellOnSpawn.offset >= SpawnFreeOffset):
#			CellOnSpawn = null
		isSpawning = false
		return
	
	# General
	print("SpawnQ is working now...")
	var newcell = AddCell()		# spawn
	CellOnSpawn = newcell		# update ref
	
	cellInQ -= 1
# 	downlying code stop cells, but now we need wait for 1 more tick
#	if(cellInQ <= 0):		# change to == in the future
#		isSpawning = false
#		StopCells()
#		DeactivatePhysics()


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

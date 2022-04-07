extends Path2D
# This is Conveyor.gd

var ConvCell := preload("res://Objects/Conveyors/ConvCell.tscn")
var refToFirstCell = null		# stores reference to first cell in conv
var StartPpos := Vector2.ZERO	# stores Vector2 position of a start Point
var EndPpos := Vector2.ZERO		# stores Vector2 position of a end Point
var isFull := false				# shows if the conveyor is fulled with cells
var refToNextConv = null		# stores ref to the next conv in chains
var isSending := false			# shows if conv is sending cells somewhere to next conv
var isContinue := false			# shows if the conveyor has a start in the end of the other conv
var isStartOfChain := false	# shows if the conv is the start for the chain of conv

signal StopCells()				# signal is emitted when cells are need to be stopped
signal StartCells()				# signal is emitted when cells are need to be started

#func ActivatePhysics() -> void:
#	set_physics_process(true)
#
#func DeactivatePhysics() -> void:
#	set_physics_process(false)


# Method does all the starting preparations and sets sending on
func StartSendingCellsTo(convPath : NodePath) -> void:
	var conv = get_node_or_null(convPath)
	#print("Conv got path:" + convPath)
	if(conv):
		conv.isContinue = true
		refToNextConv = conv
		isSending = true
	else:
		push_error("Conveyor_ERROR: can not get next conv in the chain")


# Method for setting starting valus for cell, moving to _phys... doesn't seem to work
func ReceiveCell(newcell : PathFollow2D) -> void:
	if(get_child_count() == 1):
		refToFirstCell = newcell
	connect("StartCells", newcell, "s_StartCell")		# connecting signal from conv
	connect("StopCells", newcell, "s_StopCell")			# connecting signal from conv
	newcell.unit_offset = 0
	newcell.isMoving = true


func _physics_process(delta: float) -> void:
	if(isSending and isFull and !refToNextConv.isFull):
		remove_child(refToFirstCell)
		disconnect("StartCells", refToFirstCell, "s_StartCell")
		disconnect("StopCells", refToFirstCell, "s_StopCell")
		refToNextConv.add_child(refToFirstCell)
		refToNextConv.call("ReceiveCell", refToFirstCell)
		isFull = false
		if(!isContinue):
			#yield(get_tree().create_timer(0.3333333333), "timeout")
			AddCell()
		if(get_child_count() != 0):
			refToFirstCell = get_child(0)				# new first cell
			emit_signal("StartCells")
		else:
			refToFirstCell = null
		
	elif(!isFull and refToFirstCell and refToFirstCell.unit_offset >= 1):
		#print("First cell is in the end!")
		isFull = true
		emit_signal("StopCells")


# Method adds one cell to the start of conveyor
func AddCell() -> void:
	if(!isFull):
		var ref = ConvCell.instance()
		add_child(ref)
		# disconnect first, if necessary
		connect("StartCells", ref, "s_StartCell")		# connecting signal from conv
		connect("StopCells", ref, "s_StopCell")			# connecting signal from conv
		if(get_child_count() == 1):
			refToFirstCell = ref
			#print(refToFirstCell.unit_offset)
			#refToFirstCell.add_user_signal("FirstCellEnd")
		#ref.connect("ReachedEnd", self, "s_CellReachedEnd")
	else:
		push_error("Conveyor_ERROR: Can't add cell bcs Conv is full")


# Method fulls Conveyor with cells while first cell is not in the end
func FullWithCells() -> void:		# mb add some bool to ensure spawning or getting an error
	if(curve.get_point_count() == 0):
		push_error("Conveyor_ERROR: 0 points in curve for conveyor!")
		return
	#print(curve.get_baked_length())
	while(!isFull):
		AddCell()												# 7 cells if addcell is pre yield, otherwise 8
		yield(get_tree().create_timer(0.3333333333), "timeout")	# 0.3333... needs for fixing disctance btw

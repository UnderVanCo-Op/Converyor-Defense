extends Path2D
# This is Conveyor.gd

var ConvCell := preload("res://Objects/Conveyors/ConvCell.tscn")
var refToFirstCell = null		# stores reference to first cell in conv
var refToPoint = null			# stores ref to point-parent 
var isFull := false				# shows if the conveyor is fulled with cells
var isSending := false			# shows if conv is sending cells somewhere to next conv

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
#		conv.isContinue = true
#		refToNextConv = conv
		isSending = true
#		refToNextConv.refToPrevConv = self			# 2-linked list
	else:
		push_error("Conveyor_ERROR: can not get next conv in the chain")


# Unused for now
func StopSendingCells() -> void:
	isSending = false
	pass


# Method for setting starting valus for cell, moving to _phys... doesn't seem to work
func ReceiveCell(newcell : PathFollow2D) -> void:
	if(get_child_count() == 1):
		refToFirstCell = newcell
	connect("StartCells", newcell, "s_StartCell")		# connecting signal from conv
	connect("StopCells", newcell, "s_StopCell")			# connecting signal from conv
	newcell.unit_offset = 0		# start parameters
	newcell.isMoving = true		# start parameters


func _physics_process(delta: float) -> void:
	if(!isFull and refToFirstCell and refToFirstCell.unit_offset >= 1):
		#print("First cell is in the end!")
		isFull = true
		emit_signal("StopCells")

#
func SendCell() -> void:
	if(isSending and isFull):		# if conv is sending to the next one and full
		remove_child(refToFirstCell)						# changing parents
		disconnect("StartCells", refToFirstCell, "s_StartCell")
		disconnect("StopCells", refToFirstCell, "s_StopCell")
#		refToNextConv.add_child(refToFirstCell)				# changing parents
#		refToNextConv.call("ReceiveCell", refToFirstCell)
		isFull = false
#		if(!isContinue):
			#yield(get_tree().create_timer(0.3333333333), "timeout")
#			AddCell()
		if(get_child_count() != 0):
			refToFirstCell = get_child(0)				# new first cell
			emit_signal("StartCells")
		else:
			refToFirstCell = null
		


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
	print("isFull: " + str(isFull))
	while(!isFull):
		AddCell()											# 7 cells if addcell is pre yield, otherwise 8
		yield(get_tree().create_timer(0.333), "timeout")	# 

extends Path2D
# This is Conveyor.gd

var ConvCell := preload("res://Objects/Conveyors/ConvCell.tscn")
var refToFirstCell = null		# stores reference to first cell in conv
var StartPpos := Vector2.ZERO	# stores Vector2 position of a start Point
var EndPpos := Vector2.ZERO		# store Vector2 position of a end Point
var isFull := false				# shows if the conveyor is fulled with cells

signal StopCells()				# signal is emitted when cells are need to be stopped


# Method adds one cell to conveyor
func AddCell() -> void:
	if(!isFull):
		var ref = ConvCell.instance()
		add_child(ref)
		if(get_child_count() == 1):
			refToFirstCell = ref
			#print(refToFirstCell.unit_offset)
			#refToFirstCell.add_user_signal("FirstCellEnd")
		#ref.connect("ReachedEnd", self, "s_CellReachedEnd")
	else:
		print("Conveyor_ERROR: Can't add cell bcs Conv is full")


func _physics_process(delta: float) -> void:
	if(refToFirstCell and !isFull and refToFirstCell.unit_offset >= 1):
		#print("First cell is in the end!")
		isFull = true
		emit_signal("StopCells")


# Method fulls Conveyor with cells while first cell is not in the end
func FullWithCells() -> void:		# mb add some bool to ensure spawning or getting an error
	if(curve.get_point_count() == 0):
		print("Conveyor_ERROR: 0 points in curve for conveyor!")
		return
	#print(curve.get_baked_length())
	while(!isFull):
		AddCell()											# 7 cells if addcell is pre yield, otherwise 8
		yield(get_tree().create_timer(0.3333333), "timeout")	# 0.3333 needs for fixing disctance btw

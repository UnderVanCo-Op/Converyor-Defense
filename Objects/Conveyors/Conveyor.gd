extends Path2D
# This is Conveyor.gd

var ConvCell := preload("res://Objects/Conveyors/ConvCell.tscn")
var refToFirstCell = null
var isFull := false
# 


signal StopCells()

func _ready() -> void:
	#print(curve.get_baked_length())
	pass

func AddCell() -> void:
	var ref = ConvCell.instance()
	add_child(ref)
	if(get_child_count() == 1):
		refToFirstCell = ref
		#print(refToFirstCell.unit_offset)
		#refToFirstCell.add_user_signal("FirstCellEnd")
	#ref.connect("ReachedEnd", self, "s_CellReachedEnd")
	

func _physics_process(delta: float) -> void:
	if(refToFirstCell and refToFirstCell.unit_offset >= 1):
		#print("First cell is in the end!")
		isFull = true
		emit_signal("StopCells")
	pass

#func s_CellReachedEnd() -> void:
#	#print("cell reached end, stopping spawn...")
#	#isFull = true
#	pass

func FullWithCells() -> void:
	#print(curve.get_baked_length())
	while(!isFull):
		AddCell()											# 7 cells if addcell is pre yield, otherwise 8
		yield(get_tree().create_timer(0.3333), "timeout")	# 0.3333 needs for fixing disctance btw
		
		

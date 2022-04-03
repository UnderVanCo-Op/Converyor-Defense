extends PathFollow2D
# This is ConvCell.gd

var speed = 10			# speed of the cell (needs to be moved in conveyor)
var cannon := preload("res://Objects/Cannons/Cannon.tscn")
var isMoving := true	# if the cell is in movement
#var isOccupied := false

func _ready() -> void:
	var ref = cannon.instance()
	ref.building = false
	add_child(ref)
	get_parent().connect("StopCells", self, "s_StopCell")	# connecting signal from parent conv
	

func _physics_process(delta: float) -> void:
	if(isMoving):
		offset += speed
	#if(unit_offset >= 1):
		#emit_signal("ReachedEnd")
		#queue_free()

func s_StopCell() -> void:		# signal income from Conveyor.gd
	isMoving = false


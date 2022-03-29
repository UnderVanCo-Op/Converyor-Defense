extends PathFollow2D
# This is ConvCell.gd

var speed = 10
var isMoving := true
#var isOccupied := false

func _ready() -> void:
	get_parent().connect("StopCells", self, "s_StopCell")
	pass

func _physics_process(delta: float) -> void:
	if(isMoving):
		offset += speed
	#if(unit_offset >= 1):
		#emit_signal("ReachedEnd")
		#queue_free()

func s_StopCell() -> void:		# signal income from Conveyor.gd
	isMoving = false
	pass

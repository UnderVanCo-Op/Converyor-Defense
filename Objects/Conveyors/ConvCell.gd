extends PathFollow2D
# This is ConvCell.gd

var speed = 10
#var isOccupied := false

func _physics_process(delta: float) -> void:
	offset += speed
#	if unit_offset >= 1:
#		queue_free()

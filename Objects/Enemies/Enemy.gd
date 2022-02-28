extends PathFollow2D

var speed = 6
var hp = 10

func _physics_process(delta: float) -> void:
	offset += speed		# smeshenie
	
	if unit_offset >= 1:
		queue_free()
		


extends PathFollow2D

var speed = 5
var hp = 10

func _physics_process(delta: float) -> void:
	# offset += speed		# smeshenie
	var newOffset=get_offset()+speed
	set_offset(newOffset)
	
	
	


extends Area2D

var moveV = Vector2.ZERO
var speed = 3
var lookV = Vector2.ZERO
var target

func _ready() -> void:
	if target:
		$Bullet1.look_at(target.global_position)
		lookV = target.global_position - global_position
		
func _physics_process(delta: float) -> void:
	moveV = Vector2.ZERO
	
	moveV = moveV.move_toward(lookV, speed)
	#moveV = moveV.normalized() * speed
	global_position += moveV

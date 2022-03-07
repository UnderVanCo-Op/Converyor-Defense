extends Area2D

var speed = 3
var lookV = Vector2.ZERO
var target

func _ready() -> void:
	if target:
		$Bullet1.look_at(target.global_position)
		lookV = target.global_position - global_position
		
func _physics_process(delta: float) -> void:
	global_position += Vector2.ZERO.move_toward(lookV, speed)


func _on_VisibilityNotifier2D_screen_exited() -> void:
	queue_free() # АККУРАТНО, если карта будет большой надо будет переделать

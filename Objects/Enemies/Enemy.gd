extends PathFollow2D

var speed = 2
var hp = 10


func _physics_process(delta: float) -> void:
	offset += speed		# smeshenie
	
	if unit_offset >= 1:
		queue_free()
		

func _on_Area2D_area_entered(area: Area2D) -> void:
	if area.is_in_group("Projectile"):
		area.queue_free()
		hp -=5
		if hp <= 0:
			$"../../GameManager".call("change_money", 15)
			queue_free()

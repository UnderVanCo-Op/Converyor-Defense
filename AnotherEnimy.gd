extends PathFollow2D
# This is Enemy.gd

var speed = 4
var hp = 100


func _physics_process(delta: float) -> void:
	offset += speed
	if (unit_offset>=0.99):
		print("Pizdos")
		get_parent().get_parent().get_parent().get_node("GUI/ProgressBar").AnotherProgresBarHP()
		queue_free()

func _on_Area2D_area_entered(area: Area2D) -> void:
	if area.is_in_group("Projectile"):
		area.queue_free()
		hp -=5
		if hp <= 0:
		#print("enemy died")
			$"../../../GameManager".call("change_money", 15)
			queue_free()

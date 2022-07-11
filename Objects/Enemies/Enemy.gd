extends PathFollow2D
# This is Enemy.gd

var speed = 4
var hp = 40
var enemyDrop=preload("res://Objects/Enemies/EnemyLoot1.tscn")
var dropPosition

func _ready():
	$AnimatedSprite.play("default")
	
func _physics_process(delta: float) -> void:
	offset += speed
	#if unit_offset >= 1:
		#queue_free()	
	if (unit_offset >= 0.99):
		print("ENDMAP")
		get_parent().get_parent().get_parent().get_node("GUI/ProgressBar").ProgresBarHP()
		queue_free()
		
func _enemy_drop():
	var enemy_loot = enemyDrop.instance()
	get_parent().add_child(enemy_loot)
	enemy_loot.position = position
	

func _on_Area2D_area_entered(area: Area2D) -> void:
	if area.is_in_group("Projectile"):
		#$AnimatedSprite.play("hit")
		area.queue_free()
		hp -=5
		if hp <= 0:
			#print("enemy died")
			$"../../../GameManager".call("change_money", 15)
			_enemy_drop()
			queue_free()
			

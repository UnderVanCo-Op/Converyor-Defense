extends Node2D

var bullet = preload("res://Objects/Bullets/Bullet.tscn")

var building = true
var enemies = []
var cur_enemy
var is_drawing = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start_scan():
	pass

func _physics_process(delta: float) -> void:
	if not building:
		$Vision.monitoring = true
		is_drawing = false
		update()
		# рескан противников
		if enemies:
			#print("enemies not null")
			cur_enemy = enemies[0]
			#$DuloSprite.look_at(cur_enemy.global_position)
			#rotate(1.5708)
			$DuloSprite.rotation = (global_position - cur_enemy.global_position).angle() - 1.5708
	else:
		$Vision.monitoring = false
		global_position = get_global_mouse_position()
		if Input.is_action_just_pressed("LMB"):
			building = false
			get_parent().get_node("GameManager").call("tower_built")
			

func _on_Vision_area_entered(area: Area2D) -> void:
	print("smth IN")
	if not building:
		if(area.is_in_group("Enemies")):
			enemies.append(area)
			print(str(area) + " appended")

func _on_Vision_area_exited(area: Area2D) -> void:
	if not building:
		if(area.is_in_group("Enemies")):
			enemies.erase(area)
			print("enemy exited")

func _draw():
	if is_drawing:
		var col = Color(0, 0, 0, 0.5)
		draw_circle (Vector2.ZERO, 250, col)

func _on_ReloadTimer_timeout() -> void:
	if not building:
		if cur_enemy and enemies:
			#print("reloaded")
			var b = bullet.instance()
			b.global_position = $DuloSprite/Position2D.global_position
			b.target = cur_enemy
			get_parent().add_child(b)
			b.rotation = 1.5708
			

extends Node2D
# This is Cannon.gd

var bullet := preload("res://Objects/Bullets/Bullet.tscn")
var GM = null				# ref to GameManager.gd
var BBullets = null			# ref to spawn bullets parent node
export var building := true
var enemies = []		# list of all enemies in vision area
var cur_enemy = null

# Called when the node enters the scene tree for the first time.
func _ready():
	BBullets = get_tree().get_root().get_node("/root/Main/Bullets")		# connection
	#print("BBullets: " + str(BBullets))
	if(building):
		GM = get_parent().get_node("GameManager")	# connection between nodes
	else:											# added for pre-placing functionality
		GM = $"../../../../GameManager"
		$Vision.monitoring = true
		$Vision.monitorable = true
		building = false
		#GM.call("tower_built")		# probably we shouldn't call this in conveyor case
	
# Start Building function
func StartB() -> void:				# calling from GM
	$Vision.monitoring = false
	$Vision.monitorable = false
	building = true
	# set_physics_process(false)
	
# Finish Building function
func FinishB() -> void:
	$Vision.monitoring = true
	$Vision.monitorable = true
	building = false
	GM.call("tower_built")			# calling to GM
	

func _physics_process(_delta: float) -> void:
	if not building:
		if enemies:
			#print("enemies not null")
			cur_enemy = enemies[0]			# choose of an enemy
			$DuloSprite.rotation = (global_position - cur_enemy.global_position).angle() - 1.5708	# rotation of the dulo
			if(true):					# if is on conveyor
				$DuloSprite.rotation -= get_parent().rotation
				pass
	else:
		global_position = get_global_mouse_position()
		if Input.is_action_just_pressed("LMB"):
			for b in $Body.get_overlapping_bodies():
				if b == self:
					continue
				elif(b.is_in_group("Points")):
					return
			FinishB()
	

func _on_Vision_area_entered(area: Area2D) -> void:
	if(area.is_in_group("Enemies")):
		enemies.append(area)
		#print(str(area) + " appended")

func _on_Vision_area_exited(area: Area2D) -> void:
	if(area.is_in_group("Enemies")):
		enemies.erase(area)
		#print("enemy exited")

#func _draw():
#	if is_drawing:
#		var col = Color(0, 0, 0, 0.5)
#		draw_circle (Vector2.ZERO, 250, col)

# Cannon Reloaded
func _on_ReloadTimer_timeout() -> void:
	if cur_enemy and enemies:
		#print("reloaded")
		var b = bullet.instance()
		b.global_position = $DuloSprite/Position2D.global_position
		b.target = cur_enemy
		BBullets.add_child(b)
		b.rotation = 1.5708	

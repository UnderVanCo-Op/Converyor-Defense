extends Node2D

var startP := Vector2.ZERO
#var endP := Vector2.ZERO

var isBuilding := false
var isBuilt := false

func StartBuilding() -> void:	# _startP: Vector2k
	$End.rotation = $Sprite.rotation #- deg2rad(180)
	$Sprite.rotation = $Sprite.position.angle_to_point($End.position) + deg2rad(90)
	$Sprite.region_rect.size.y = to_local(get_global_mouse_position()).length()
	startP = get_global_mouse_position()
	isBuilding = true
	

func Built() -> void:
	isBuilding = false
	isBuilt = true

func _process(delta: float) -> void:
	self.visible = isBuilding or isBuilt	#Only visible if flying or attached to something
	if not self.visible:
		return	# Not visible -> nothing to draw
	if(isBuilding):		# просто пользовательская отрисовка
		$End.rotation = $Sprite.rotation
		$End.global_position = get_global_mouse_position()
		$Sprite.rotation = $Sprite.position.angle_to_point($End.position) + deg2rad(90)
		$Sprite.region_rect.size.y = to_local(get_global_mouse_position()).length() + 1
		

func _physics_process(delta: float) -> void:
	if(Input.is_action_just_pressed("TestAction")):
		if(!isBuilding and !isBuilt):
			StartBuilding()
			print("start b")
			return
	if(Input.is_action_just_pressed("TestAction2")):
		if(isBuilding):
			Built()
			print("end b")
		

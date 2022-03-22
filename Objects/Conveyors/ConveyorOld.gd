extends Node2D

var dir := Vector2.ZERO
var end := Vector2.ZERO		# упростить, тк у нас игрок не двигается
var startPoint := Vector2.ZERO

var isBuilding := false
var isBuilt := false

func StartBuilding() -> void:	# direction: Vector2k
	startPoint = get_global_mouse_position()
	dir = Vector2.RIGHT		# give vector of direction from parameter
	isBuilding = true
	#$Tile.position = startPoint
	position = startPoint
	end = startPoint	#reset the tip position to the player's position
	$Tile.rotation = deg2rad(-90)

func Built() -> void:
	isBuilding = false
	isBuilt = false

func _process(delta: float) -> void:
	self.visible = isBuilding or isBuilt	#Only visible if flying or attached to something
	if not self.visible:
		return	# Not visible -> nothing to draw
	var end_loc = to_local(end)	# Easier to work in local coordinates
	# We rotate the links (= chain) and the tip to fit on the line between self.position (= origin = player.position) and the tip
	#$Tile.rotation = self.position.angle_to_point(end_loc) - deg2rad(90)
	#$End.rotation = self.position.angle_to_point(end_loc) - deg2rad(90)
	#$Tile.position = end_loc	# The links are moved to start at the tip
	$Tile.region_rect.size.y = end_loc.length()	# and get extended for the distance between (0,0) and the tip
	
func _physics_process(delta: float) -> void:
	if(Input.is_action_pressed("TestAction")):
		if(!isBuilding and !isBuilt):
			StartBuilding()
			print("start b")
	$End.global_position = end	 #The player might have moved and thus updated the position of the tip -> reset it
	if isBuilding:	# `if move_and_collide()` always moves, but returns true if we did collide
		if($End.move_and_collide(dir*5)):
			isBuilding = false
			isBuilt = true
	end = $End.global_position # set `tip` as starting position for next frame

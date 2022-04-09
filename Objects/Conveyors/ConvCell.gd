extends PathFollow2D
# This is ConvCell.gd

var speed = 10			# speed of the cell (needs to be moved in conveyor)
var cannon := preload("res://Objects/Cannons/Cannon.tscn")
var isMoving := true	# if the cell is in movement
#var isOccupied := false

func _ready() -> void:
	var ref = cannon.instance()
	ref.building = false
	add_child(ref)
	$Sprite.scale = Vector2(1,1)						# for highlighting spawn
	yield(get_tree().create_timer(0.333), "timeout")	# 
	$Sprite.scale = Vector2(0.5,0.5)					# 
	#get_parent().connect("StopCells", self, "s_StopCell")	# connecting signal from parent conv
	#get_parent().connect("StartCells", self, "s_StartCell")	# connecting signal from parent conv
	

func _physics_process(delta: float) -> void:
	if(isMoving):
		offset += speed
	#if(unit_offset >= 1):
		#emit_signal("ReachedEnd")
		#queue_free()

#func ChangeSignals(newParent : NodePath):
#	disconnect("StopCells")
#	pass

func s_StopCell() -> void:		# signal income from Conveyor.gd
	isMoving = false

func s_StartCell() -> void:		# signal income from Conveyor.gd
	isMoving = true

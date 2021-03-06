extends PathFollow2D
# This is ConvCell.gd

var speed = 10			# speed of the cell (needs to be moved in conveyor)
#var cannon := preload("res://Objects/Cannons/Cannon.tscn")
var isMoving := true	# if the cell is in movement
var isOccupied := false
var package = null

func _ready() -> void:
	# Cannon
#	var ref = cannon.instance()
#	ref.building = false
#	add_child(ref)

	# Highlighting on spawn
	$Sprite.scale *= 2						# for highlighting spawn
	yield(get_tree().create_timer(0.5), "timeout")	# 
	$Sprite.scale = Vector2(0.3,0.3)					# 
	#get_parent().connect("StopCells", self, "s_StopCell")	# connecting signal from parent conv
	#get_parent().connect("StartCells", self, "s_StartCell")	# connecting signal from parent conv
	

func _physics_process(_delta: float) -> void:
	if(isMoving):
		offset += speed

func s_StopCell() -> void:		# signal income from Conveyor.gd
	isMoving = false

func s_StartCell() -> void:		# signal income from Conveyor.gd
	isMoving = true


# Deletes pack from childs and returns it
func RemovePackage() -> Node2D:
	if(isOccupied):
		var pack = get_node("Package")
		remove_child(pack)
		return pack
	else:
		push_error("ConvCell: tried to removePackage from empty cell!")
		return null

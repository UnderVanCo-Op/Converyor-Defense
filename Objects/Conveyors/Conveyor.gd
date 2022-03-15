extends Node2D

var dir := Vector2.ZERO
#var end := Vector2.ZERO

var isBuilding := false
var isBuilt := false

func StartBuilding() -> void:	# direction: Vector2k
	dir = Vector2.RIGHT		# give vector of direction from parameter
	isBuilding = true
	#end = self.global_position()

func Built() -> void:
	isBuilding = false
	isBuilt = true

func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if isBuilding:
		pass
	pass

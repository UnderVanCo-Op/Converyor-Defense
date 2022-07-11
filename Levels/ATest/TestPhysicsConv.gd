extends Node2D
# This is TestPhysicsConv.gd (основы конвеера с нуля через физ движок)

var start := Vector2(500,500)
var end := Vector2(800,800)
var convV := Vector2.ZERO
var StartConv := true



class Con:
	
	var Start := Vector2.ZERO	# centered
	var End := Vector2.ZERO		# centered
	
	func _init(_startP : Vector2, _endP : Vector2) -> void:
		Start = _startP
		End = _endP
	pass


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	get_node("V2PointUL").connect("ConvBuilding", self, "s_ConvBuild")	# signal connection
	get_node("V2Point2DR").connect("ConvBuilding", self, "s_ConvBuild")	# signal connection
	
	
	pass # Replace with function body.


func s_ConvBuild(refToPoint : StaticBody2D, isUsed : bool) -> void:	# singal income from Point.gd
	
	print("\nsignal received, pos: " + str(refToPoint.position) + ", isUsed: " + str(isUsed) + ", Pointpath: " + str(refToPoint))
	
	if(StartConv):
		start = refToPoint.position + refToPoint.get_node("Position2D").position
		print("start = ", start)
		StartConv = false
	else:
		end = refToPoint.position + refToPoint.get_node("Position2D").position
		
		convV = start + (end - start) / 2 	# середина с учетом половины поинтов
		print("convV: " + str(convV))
		var dlina = convV.length()
		print("dlina: ", dlina)
		
		$Conv.position = convV
		
		var shape = RectangleShape2D.new()
		shape.set_extents(Vector2(500,50))

		var collisionS = CollisionShape2D.new()
		collisionS.set_shape(shape)
		collisionS.rotate(start.angle_to_point(end))

		var n = get_node("Conv/Area2D")
		n.add_child(collisionS)
		
		var area = $Conv/Area2D
		area.space_override = 3
		area.gravity_vec = end
		area.gravity = 0.1
		
		print("Conv has been built")
		
		
		
		
		StartConv = true
		
		
		
	
	pass


func _on_Area2D_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	print("input event")
	pass # Replace with function body.

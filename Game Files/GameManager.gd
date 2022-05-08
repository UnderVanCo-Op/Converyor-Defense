extends Node2D
#This is GameManager.gd

var cannon = preload("res://Objects/Cannons/Cannon.tscn")
var conv = preload("res://Objects/Conveyors/Conveyor.tscn")

var convBuildRef  = null 			# ref to new v of conveyour building	(conv)
var cannonBuildRef = null			# ref to cannon in b-ing stage, mb unj-ly	(cannon)
var gui = null						# gui reference	(GUI)
var Point = null					#  (point, for cancelling)
var isStartConv := true				# if there was a start of a conveyor (conv switcher btw start/end)
var isFocusedOnSmth := false		# if we are already interacting with smth	(focus)

var money := 250


func _ready() -> void:
	signalConnector()
	gui.call("updateMoney", money)				# calling to GUI.gd

# Method is responsible for finding and connecting signals to THIS script
func signalConnector() -> void:
	var t = get_node_or_null("../Points")					# привязка к Точкам
	if(t):
		for ch in t.get_children():
			ch.connect("ConvBuilding", self, "s_ConvBuild")	# signal connection
	else:
		push_error("GM_ERROR: failed to get Points Nodes in Points!")
	
	t = get_node_or_null("../Factories")					# привязка к Точкам 2 в факторках
	if(t):
		for ch in t.get_children():
			ch.get_node("Point").connect("ConvBuilding", self, "s_ConvBuild")	# signal connection
	else:
		push_error("GM_ERROR: failed to get Points Nodes in Factories!")
	
	
	gui = $"../GUI"											# привязка к GUI
	gui.connect("press_build", self, "s_Towerbuild()")		# signal connection
	gui.connect("cancel_conv", self, "s_Cancel")			# signal connection


# Method for dealing with signal from gui to cancel building (RMB)
func s_Cancel() -> void:				# signal from GUI.gd (RMB)
	if(isFocusedOnSmth):
		if(!isStartConv):
			print("\nCanceling conveyor")
			isStartConv = true
			isFocusedOnSmth = false
			convBuildRef.queue_free()
		elif(cannonBuildRef):
			print("\nCanceling cannon")
			isFocusedOnSmth = false
			cannonBuildRef.queue_free()
		else:
			push_error("GM_ERROR: Cannon find focused thing to cancel")
	else:
		push_warning("WARNING: Nothing to cancel")


# Demarks Point (inside), also sets Used to 0 if no other conv are connected and delete ref to conv
func DeArmPoint() -> void:
	print("DeArm starting...")
	if(!Point.isUsed):				# first use of this point
		push_error("GM_DeArmPoint_ERROR: Can't demark point bcs it's unused")
	else:
		if(!isStartConv):
			Point.out_convs.erase(convBuildRef)		# delete new ref in the list
			print("disarmed Point")
			if(Point.inc_convs.size() == 0 and Point.inc_convs.size() == 0):
				Point.isUsed = false
		else:
			push_error("GM_DeArmPoint_ERROR: isStartConv is true, wtf?")


# Marks point as Used and turns physics on, and also adds ref to conv, must be called after convBuildRef is set properly.
func ArmPoint(_point : StaticBody2D, _isStartConv : bool) -> void:
	_point.set_physics_process(true)	# turn on the physics
	if(!_point.isUsed):					# first use of this point
		_point.isUsed = true
	
	if(_isStartConv):
		_point.AddOutConv(convBuildRef)
		#print("Point out has been increased to 1")
	else:
		_point.AddIncConv(convBuildRef)
		#print("Point inc has been increased to 1")
	print("armed point")


# Method for dealing with signal from Point (click on Point)
func s_ConvBuild(refToPoint : StaticBody2D, isUsed : bool, _Pntposition : Vector2) -> void:	# singal income from Point.gd
	
	print("\nsignal received, pos: " + str(_Pntposition) + ", isUsed: " + str(isUsed) + ", Pointpath: " + str(refToPoint))
	
	if(refToPoint):
		pass
	else:
		push_error("GM_ERROR: Point is NULL!")		# Game Manager Error
		return
		
	if(isStartConv and !isFocusedOnSmth):					# START POINT
		
		print("Start of new conveyor")
		# Conveyor
		convBuildRef = conv.instance()
		get_parent().get_node("Conveyors").add_child(convBuildRef)
		convBuildRef.position = Vector2.ZERO				# clearing pos
		convBuildRef.curve.clear_points()					# clearing points just in case
		convBuildRef.curve.add_point(_Pntposition)			# add start point
		convBuildRef.Point = refToPoint						# ref to start point
		
		# Points
		Point = refToPoint					# upd the point		
		
		# General
		isFocusedOnSmth = true
		isStartConv = false					# carefull
		
	elif(!isStartConv and isFocusedOnSmth):					# END POINT
		
		if(Point == refToPoint):					# checking for conv to itself
			push_warning("GM_ERROR: Can not stretch conv to itself (for now)")
			s_Cancel()
			return
		
		print("End of new conveyor")
		# Conveyor
		convBuildRef.curve.add_point(_Pntposition)	#
		convBuildRef.endPoint = refToPoint			# ref to end point
		convBuildRef.isBuilding = false				#
		convBuildRef.CountCapacity()				#
		
		# Points
		ArmPoint(Point, true)				# Set up start point
#		Point = refToPoint					# upd the point	(not necessarily now)	
		ArmPoint(refToPoint, false)			# marking end point, must be before isStartConv setting
#		Point.TryMoveCell()					# Set up connections in start point
		RequestSpawn(convBuildRef.capacity)	# requesting spawn from start point
		
		isFocusedOnSmth = false
		isStartConv = true
		convBuildRef = null					# deleting reference as a precaution
		Point = null						# also


# convBuildRef dependent
func RequestSpawn(_count : int) -> void:
	print("GM: req for spawning ", _count, " cells")
	if(_count < 1):
		push_error("GM_RequestS_ERROR: Can not send req with less than 1 cells to spawn!")
		return
	convBuildRef.Point.ReceiveSpawnRequest(_count, convBuildRef)	# get the ref to start point by conv


# Method for dealing with signal from Build Cannon button
func s_Towerbuild() -> void:				# signal income from GUI.gd
	if !isFocusedOnSmth and money >= 25:
		cannonBuildRef = cannon.instance()
		get_parent().add_child(cannonBuildRef)
		cannonBuildRef.position = get_global_mouse_position()
		cannonBuildRef.call("StartB")		# calling to Cannon.gd
		isFocusedOnSmth = true


# Method for finishing building cannon
func tower_built() -> void:					# calling from Cannon.gd
	isFocusedOnSmth = false
	change_money(-25)


# Method for changing money in GUI
func change_money(_money) -> void:			# calling from THIS script and Enemy.gd
	money += _money
	gui.call("updateMoney", money)			# calling to GUI.gd

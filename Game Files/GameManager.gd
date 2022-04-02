extends Node2D
#This is GameManager.gd

var cannon = preload("res://Objects/Cannons/Cannon.tscn")
var conv = preload("res://Objects/Conveyors/Conveyor.tscn")		# new version

#var instance = null
var convBuildRef = null 			# ref to new v of conveyour building
var cannonBuildRef = null			# ref to cannon in b-ing stage, mb unj-ly
var lastPointPath : NodePath = ""	# Path to the last Point used (for cancelling)
var isStartPoint := false			# additional parametr for Point (for cancelling)
var gui = null						# gui reference
var isStartConv := true				# if there was a start of a conveyor (switcher btw start/end)
var isFocusedOnSmth := false		# if we are already interacting with smth

var money := 250


func _ready() -> void:
	signalConnector()
	gui.call("updateMoney", money)							# calling to GUI.gd


# Method is responsible for finding and connecting signals to THIS script
func signalConnector() -> void:
	var t = get_node_or_null("../Points")					# привязка к Точкам
	if(t):
		for ch in t.get_children():
			ch.connect("ConvBuilding", self, "s_ConvBuild")	# signal connection
	else:
		print("GM_ERROR: failed to get Points Nodes in Points!")
	
	t = get_node_or_null("../Factories")					# привязка к Точкам 2 в факторках
	if(t):
		for ch in t.get_children():
			ch.get_node("Point").connect("ConvBuilding", self, "s_ConvBuild")	# signal connection
	else:
		print("GM_ERROR: failed to get Points Nodes in Factories!")
	
	
	gui = $"../GUI"											# привязка к GUI
	gui.connect("press_build", self, "s_Towerbuild()")		# signal connection
	gui.connect("cancel_conv", self, "s_Cancel")			# signal connection


# Method for dealing with signal from gui to cancel building (RMB)
func s_Cancel() -> void:				# signal from GUI.gd (RMB)
	if(isFocusedOnSmth):
		if(!isStartConv):
			DeMarkPoint()
			isStartConv = true
			isFocusedOnSmth = false
			convBuildRef.queue_free()
			print("Canceled conveyor")
			
		elif(cannonBuildRef):
			isFocusedOnSmth = false
			cannonBuildRef.queue_free()
			print("Canceled cannon")
		else:
			print("GM_ERROR: Cannon find focused thing to cancel")
	else:
		print("WARNING: Nothing to cancel")


# Gets Point by NodePath and demarks it (inside), also set Used to 0 if no other conv are connected
func DeMarkPoint() -> void:
	var point = get_node_or_null(lastPointPath)
	if(point):
		if(!point.isUsed):				# first use of this point
			print("GM_ERROR: Can't demark point bcs it's unused")
		else:
			if(isStartPoint):
				point.outConv -= 1
				print("Point out has been decreased to 1")
				if(point.outConv == 0 and point.incConv == 0):
					point.isUsed = false
					print("Point has been marked as not used")
			else:
				#point.incConv -= 1
				print("GM_ERROR: Trying to decrease end point, wtf?")
	else:
		print("GM_ERROR: can not get point to mark")		# Game Manager Error


# Gets Point by NodePath and marks it (inside) as Used, and Start or End of some Conveyor
func MarkPoint() -> void:
	var point = get_node_or_null(lastPointPath)
	if(point):
		if(!point.isUsed):				# first use of this point
			point.isUsed = true
		
		if(isStartPoint):
			point.outConv += 1
			print("Point out has been increased to 1")
		else:
			point.incConv += 1
			print("Point inc has been increased to 1")
	else:
		print("GM_ERROR: can not get point to mark")		# Game Manager Error


# Method for dealing with signal from Point (click on Point)
func s_ConvBuild(PathToPoint, _Pntposition := Vector2.ZERO, isUsed := false) -> void:	# singal income from Point.gd
	
	print("\nsignal received, pos: " + str(_Pntposition) + ", isUsed: " + str(isUsed) + ", Pointpath: " + str(PathToPoint)) 
	if(isStartConv and !isFocusedOnSmth):			# START POINT
		print("Start of new conveyor")
		
		lastPointPath = PathToPoint		# 
		isStartPoint = true				# 
		MarkPoint()						# marking point
		
		convBuildRef = conv.instance()
		get_parent().get_node("Conveyors").add_child(convBuildRef)
		convBuildRef.position = Vector2.ZERO				# clearing pos
		convBuildRef.curve.clear_points()					# clearing points just in case
		convBuildRef.curve.add_point(_Pntposition)			# add start point
		convBuildRef.StartPpos = _Pntposition				# setting start point in conv
		
		#convBuildingRef.call("StartBuilding")
		isFocusedOnSmth = true
		isStartConv = false							# carefull
		
	elif(!isStartConv and isFocusedOnSmth):			# END POINT
		if(lastPointPath == PathToPoint):
			print("GM_ERROR: Can not stretch conv to itself (for now)")
			s_Cancel()
			return
		print("End of new conveyor")
		lastPointPath = PathToPoint
		isStartPoint = false
		MarkPoint()
		
		convBuildRef.curve.add_point(_Pntposition)
		convBuildRef.FullWithCells()				# start filling of conveyor
		convBuildRef = null						# deleting reference as a precaution
		isStartConv = true
		isFocusedOnSmth = false


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

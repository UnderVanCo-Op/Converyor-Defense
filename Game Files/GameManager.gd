extends Node2D
#This is GameManager.gd

var cannon = preload("res://Objects/Cannons/Cannon.tscn")
var conv = preload("res://Objects/Conveyors/Conveyor.tscn")		# new version

#var instance = null
var convBuildRef = null 			# ref to new v of conveyour building
var cannonBuildRef = null			# ref to cannon in b-ing stage, mb unj-ly
var gui = null						# gui reference
var lastPointPath : NodePath = ""	# Path to the last Point used (for cancelling)
var isStartPoint := false			# additional parametr for Point (for cancelling)
var isStartConv := true				# if there was a start of a conveyor (switcher btw start/end)
var isFocusedOnSmth := false		# if we are already interacting with smth

var conv_list := []					# list of all conv objects
var money := 250


func _ready() -> void:
	conv_list.clear()
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


# Print all conveyors in conv_list
func PrintConvList() -> void:
	print("Conv list:")
	for c in conv_list:
		print(c)


# Method for dealing with signal from gui to cancel building (RMB)
func s_Cancel() -> void:				# signal from GUI.gd (RMB)
	if(isFocusedOnSmth):
		if(!isStartConv):
			print("\nCanceling conveyor")
			conv_list.erase(convBuildRef)	# delete conv from list
			PrintConvList()					# print active conv-s
			DeMarkPoint() 
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


# Gets Point by NodePath and demarks it (inside), also set Used to 0 if no other conv are connected
func DeMarkPoint() -> void:
	var point = get_node_or_null(lastPointPath)
	if(point):
		if(!point.isUsed):				# first use of this point
			push_error("GM_DeMarkPoint_ERROR: Can't demark point bcs it's unused")
		else:
			if(isStartPoint):
				point.outConv -= 1
				#print("Point out has been decreased to 1")
				if(point.outConv == 0 and point.incConv == 0):
					point.isUsed = false
					#print("Point also has been marked as not used")
			else:
				push_error("GM_DeMarkPoint_ERROR: Trying to decrease end point, wtf?")
	else:
		push_error("GM_DeMarkPoint_ERROR: can not get point to mark")		# Game Manager Error


# Gets Point by NodePath and marks it (inside) as Used, and Start or End of some Conveyor
func MarkPoint() -> void:
	var point = get_node_or_null(lastPointPath)
	if(point):
		if(!point.isUsed):				# first use of this point
			point.isUsed = true
		
		if(isStartPoint):
			point.outConv += 1
			#print("Point out has been increased to 1")
		else:
			point.incConv += 1
			#print("Point inc has been increased to 1")
	else:
		push_error("GM_ERROR: can not get point to mark")		# Game Manager Error


# Method for dealing with signal from Point (click on Point)
func s_ConvBuild(PathToPoint, isUsed, _Pntposition := Vector2.ZERO) -> void:	# singal income from Point.gd
	
	print("\nsignal received, pos: " + str(_Pntposition) + ", isUsed: " + str(isUsed) + ", Pointpath: " + str(PathToPoint))
	if(isStartConv and !isFocusedOnSmth):					# START POINT
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
		conv_list.append(convBuildRef)						# adding to the list
		PrintConvList()										# print list of conv-s
		
		isFocusedOnSmth = true
		isStartConv = false									# carefull

	elif(!isStartConv and isFocusedOnSmth):					# END POINT
		if(lastPointPath == PathToPoint):					# checking for conv to itself
			push_warning("GM_ERROR: Can not stretch conv to itself (for now)")
			s_Cancel()
			return
		
		if(isUsed):											# Point has been used
			for c in conv_list:
				# if conv are identical
				if(convBuildRef.StartPpos == c.StartPpos and _Pntposition == c.EndPpos):
					push_warning("GM_WARNING: can not stretch identical conveyor!")
					s_Cancel()
					return
				# if conv are inverted identical
				if(convBuildRef.StartPpos == c.EndPpos and _Pntposition == c.StartPpos):
					push_warning("GM_WARNING: can not stretch identical reversed conveyor!")
					s_Cancel()
					return
		
		print("End of new conveyor")
		lastPointPath = PathToPoint
		isStartPoint = false
		MarkPoint()
		
		convBuildRef.EndPpos = _Pntposition			# setting end point in conv
		convBuildRef.curve.add_point(_Pntposition)
		CheckForNearByConv()
		
		convBuildRef = null							# deleting reference as a precaution
		isStartConv = true
		isFocusedOnSmth = false


# 
func CheckForNearByConv() -> void:
	var switcher := false
	if(convBuildRef):
		for c in conv_list:
			if(convBuildRef.StartPpos == c.EndPpos):		# if our conv is a continuation for other
				print("inc conv has been identified, info:", c)
				c.StartSendingCellsTo(convBuildRef.get_path())
				switcher = true
				continue
			if(convBuildRef.EndPpos == c.StartPpos):		# if our conv is a start for other conv
				print("out conv has been identified, info:", c)
				convBuildRef.StartSendingCellsTo(c.get_path())
		if(!switcher):
			convBuildRef.FullWithCells()
	
	else:
		push_error("GM_CheckForNearByConv_ERROR: can not find convBuildRef")


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

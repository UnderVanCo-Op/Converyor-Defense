extends Node2D
#This is GameManager.gd

var cannon = preload("res://Objects/Cannons/Cannon.tscn")
var conv = preload("res://Objects/Conveyors/ConveyorNew.tscn")
var convnew = preload("res://Objects/Conveyors/Conveyor.tscn")

#var instance = null
var convBuildingRef = null		# ref to conveyor in building stage, mb unjustifiably
var cannonBuildRef = null		# ref to cannon in b-ing stage, mb unj-ly
var convBuildRef2 = null 		# ref to new v of conveyour building
var gui = null

var isStartConv := true
var isFocusedOnSmth := false
var NewVersionSwitcher := true

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
		print("ERROR: failed to get Points Nodes in Points!")
	
	t = get_node_or_null("../Factories")					# привязка к Точкам 2 в факторках
	if(t):
		for ch in t.get_children():
			ch.get_node("Point").connect("ConvBuilding", self, "s_ConvBuild")	# signal connection
	else:
		print("ERROR: failed to get Points Nodes in Factories!")
	
	
	gui = $"../GUI"											# привязка к GUI
	gui.connect("press_build", self, "s_Towerbuild()")		# signal connection
	gui.connect("cancel_conv", self, "s_Cancel")			# signal connection


# Method for dealing with signal from gui to cancel building (RMB)
func s_Cancel() -> void:							# signal from GUI.gd (RMB)
	if(isFocusedOnSmth):
		if(!isStartConv):
			print("Canceled conveyor")
			isStartConv = true
			isFocusedOnSmth = false
			convBuildingRef.queue_free()
		elif(cannonBuildRef):
			print("Canceled cannon")
			isFocusedOnSmth = false
			cannonBuildRef.queue_free()
		else:
			print("ERROR: Cannon find focused thing to cancel")
	else:
		print("WARNING: Nothing to cancel")


# Method for dealing with signal from Point (click on Point)
func s_ConvBuild(_Pntposition) -> void:				# singal income from Point.gd
	if(NewVersionSwitcher):
		#print("NewVSwitcher")
		
		
		if(isStartConv and !isFocusedOnSmth):
			print("Start of new conveyor")
			convBuildRef2 = convnew.instance()
			get_parent().get_node("Conveyors").add_child(convBuildRef2)
			
			convBuildRef2.position = Vector2.ZERO
			convBuildRef2.curve.clear_points()
			convBuildRef2.curve.add_point(_Pntposition)
			convBuildRef2.StartPpos = _Pntposition
			
			#convBuildRef2.curve.add_point(Vector2(400,400),Vector2(700,0),Vector2(-500,-100))
			#convBuildRef2.FullWithCells()
			#print(convBuildRef2.curve.get_point_count())
			
			#convBuildingRef.call("StartBuilding")
			isFocusedOnSmth = true
			isStartConv = false							# carefull
		elif(!isStartConv and isFocusedOnSmth and _Pntposition != convBuildRef2.position):
			#convBuildingRef.call("Built")
			convBuildRef2.curve.add_point(_Pntposition)
			print("End of new conveyor")
			convBuildRef2.FullWithCells()
			convBuildRef2 = null
			isStartConv = true
			isFocusedOnSmth = false
		
		#NewVersionSwitcher = false
	else:
		#print("signal achieved" + str(_Pntposition))
		if(isStartConv and !isFocusedOnSmth):
			convBuildingRef = conv.instance()
			get_parent().get_node("Conveyors").add_child(convBuildingRef)
			convBuildingRef.position = _Pntposition
			convBuildingRef.call("StartBuilding")
			isFocusedOnSmth = true
			isStartConv = false							# carefull
		elif(!isStartConv and isFocusedOnSmth and _Pntposition != convBuildingRef.position):
			convBuildingRef.call("Built")
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

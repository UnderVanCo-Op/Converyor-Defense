extends Node2D
#This is GameManager.gd

var cannon = preload("res://Objects/Cannons/Cannon.tscn")
var conv = preload("res://Objects/Conveyors/ConveyorNew.tscn")
var instance = null
var convBuildingRef = null		# mb unjustifiably
var gui = null

var isStartConv := true
var twrBuilding := false
var isFocusedOnSmth := false

var money := 250



func _ready() -> void:
	signalConnector()

func signalConnector() -> void:
	var t = get_node_or_null("../Points")				# привязка к Точкам
	if(t):
		for ch in t.get_children():
			ch.connect("ConvBuilding", self, "s_ConvBuild")
	else:
		print("ERROR: failed to get Points Node!")
	
	gui = $"../GUI"										# привязка к GUI
	gui.connect("press_build", self, "s_Towerbuild")	# 1 method
	gui.call("updateMoney", money)						# 2 method


func s_ConvBuild(_Pntposition) -> void:					# 
	#print("signal achieved" + str(_Pntposition))
	if(isStartConv):
		instance = conv.instance()
		get_parent().get_node("Conveyors").add_child(instance)
		instance.position = _Pntposition
		instance.call("StartBuilding")
		convBuildingRef = instance
		isStartConv = false								# carefull
	else:
		convBuildingRef.call("Built")
		isStartConv = true


func s_Towerbuild() -> void:				# signal connected
	if (not twrBuilding) and money >= 25:
		instance = cannon.instance()
		get_parent().add_child(instance)
		instance.position = get_global_mouse_position()
		instance.call("StartB")


func tower_built() -> void:					#
	twrBuilding = false 
	change_money(-25)


func change_money(_money) -> void:			# Вызывается из других скриптов
	money += _money
	gui.call("updateMoney", money)

extends Node2D
#This is GameManager.gd

var cannon = preload("res://Objects/Cannons/Cannon.tscn")
var conv = preload("res://Objects/Conveyors/ConveyourNew.tscn")
var gui = null
var building := false
var instance = null
var money := 250

func _ready() -> void:
	gui = $"../GUI"		# привязка к GUI здесь
	var smth = get_node_or_null("../Point")				# can be perfomance-lowering
	if(smth):
		smth.connect("ConvBuilding", self, "s_ConvBuild")
	gui.connect("press_build", self, "s_Towerbuild")	# 1 method
	gui.call("updateMoney", money)						# 2 method

func s_ConvBuild(_Pntposition) -> void:
	print("signal achieved" + str(_Pntposition))
	instance = conv.instance()
	get_parent().add_child(instance)
	instance.position = _Pntposition
	instance.call("StartBuilding")
	
func s_Towerbuild() -> void:	# signal connected
	if (not building) and money >= 25:
		instance = cannon.instance()
		get_parent().add_child(instance)
		instance.position = get_global_mouse_position()

func tower_built() -> void:
	building = false 
	change_money(-25)
	
func change_money(_money) -> void:
	money += _money
	gui.call("updateMoney", money)

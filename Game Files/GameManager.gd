extends Node2D
#This is GameManager.gd

var cannon = preload("res://Objects/Cannons/Cannon.tscn")
var building = false
var instance
var money = 250

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"../GUI".connect("press_build", self, "_press_build")	# 1 method
	$"../GUI".call("updateMoney", money)	# 2 method
	
func _press_build() -> void:	# signal connected
	#print("WORKDE WDUD")
	if (not building) and money >= 25:
		instance = cannon.instance()
		get_parent().add_child(instance)
		instance.position = get_global_mouse_position()

func tower_built() -> void:
	building = false 
	change_money(-25)
	
func change_money(_money) -> void:
	money += _money
	$"../GUI".call("updateMoney", money)

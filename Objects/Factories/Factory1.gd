extends Node2D

onready var objMenu := $ObjectMenu
var cannon = preload("res://Objects/Cannons/Cannon.tscn")
var point = null
var isShowed := false
var hasCannon := false
#var sprNamesList := ["but1", "but2", "but3"]
#enum s {but1, but2, but3}


func _ready() -> void:
#	$Point.isFactoryP = true
	point = get_node("Point")
	point.isFactoryP = true					# set Point ot factory point
	point.set_physics_process(true)			# turn on physics
	objMenu.hide()		# ensuring menu is hidden
	isShowed = false
	var menu = get_node_or_null("ObjectMenu")		# привязка к Кнопкам внутри менюхи
	var counter = 0									# for sprite name
	if(menu):
		for rndbut in menu.get_children():			# dynamically setting the sprites for buttons
			counter += 1
			rndbut.connect("FactoryButPressed", self, "s_FactoryButPressed")		# signal connection
			rndbut.texture_normal = load("res://UI/but" + str(counter) + ".png")
			rndbut.set_sprite(counter)
			#rndbut.call("set_sprite", str(counter))
	else:
		print("ERROR: failed to get ObjectMenu in Factory!")


# incoming signal from RoundBut.gd
func s_FactoryButPressed(spriteNumber) -> void:		
	#print("signal received")
	#print("button " + _spriteName + " was pressed")
	if int(spriteNumber) == 1:
		# build tower
#		print("Number 1 button was pressed!")
		var newCannon = cannon.instance()
		
		print("Factory: Cannon added to the Delivery")
		if(point):
			newCannon.DeliveryStatus = 2
			if(point.TrySendCannon(newCannon)):	# if point succeeds in adding cannon to the q in the conv
				hasCannon = false
			else:
				newCannon.DeliveryStatus = 1
				add_child(newCannon)
				hasCannon = true
		else:
			push_error("Factory: Tried to call get cannon in point, but no point is set!")
		


# Pressing on a Factory area
func _on_TextureButton_pressed() -> void:
	#print("click on tb")
	if(isShowed):
		objMenu.hide()
		isShowed = false
	else:
		objMenu.show()
		isShowed = true

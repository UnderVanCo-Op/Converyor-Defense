extends Node2D

onready var objMenu := $ObjectMenu
var cannon = preload("res://Objects/Cannons/Cannon.tscn")
var CannonsInDelivery = null
var isShowed := false
#var sprNamesList := ["but1", "but2", "but3"]
#enum s {but1, but2, but3}


func _ready() -> void:
#	$Point.isFactoryP = true
	CannonsInDelivery = get_node("../../CannonsInDelivery")
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
#		CannonsInDelivery.add_child(newCannon)
		add_child(newCannon)
		print("Factory: Cannon added to the Delivery")


# Pressing on a Factory area
func _on_TextureButton_pressed() -> void:
	#print("click on tb")
	if(isShowed):
		objMenu.hide()
		isShowed = false
	else:
		objMenu.show()
		isShowed = true

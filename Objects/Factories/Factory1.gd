extends Node2D

onready var objMenu := $ObjectMenu
var cannon = preload("res://Objects/Cannons/Cannon.tscn")
var package = preload("res://Objects/Package/Package.tscn")
var point = null
var isShowed := false


func _ready() -> void:
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
	else:
		print("ERROR: failed to get ObjectMenu in Factory!")


# incoming signal from RoundBut.gd
func s_FactoryButPressed(spriteNumber) -> void:		
	#print("signal received")
	#print("button " + _spriteName + " was pressed")
	match spriteNumber:
		1:			# build tower
	#		print("Number 1 button was pressed!")
			var newPackage = package.instance()
			var newCannon = cannon.instance()
			newCannon.hide()
			newPackage.add_child(newCannon)
			print("Factory: Cannon added to the Package, Package added to the Point")
			newPackage.DeliveryStatus = 1		# on factory
			if(!point.TryReceivePackage(newPackage)):
				push_error("Factory: Tried to call receivePack in point, but get false. Adding as a child to factory")
				add_child(newPackage)
		2:
			print("Factory: Button2 was pressed")
		3:
			print("Factory: Button2 was pressed")


# Pressing on a Factory area
func _on_TextureButton_pressed() -> void:
	#print("click on tb")
	if(isShowed):
		objMenu.hide()
		isShowed = false
	else:
		objMenu.show()
		isShowed = true

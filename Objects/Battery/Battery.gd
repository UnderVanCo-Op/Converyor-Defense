extends Node2D
# This is Battery.gd

var listOfLafets := []		#


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for laf in $Lafets.get_children():
		listOfLafets.append(laf)
	$"Point".isBatteryP = true


# Simple method that checks for a free place in a lafets
func CheckForPlace() -> bool:
	var laf = Request()
	if(laf):
		return true
	else:
		return false


# Gets called from point
func ReceivePackage(package) -> void:
	var laf = Request()
	if(laf):
		laf.add_child(package)
		laf.isOccupied = true
	else:
		push_error("Battery: Can not add cannon, since no free place is available")


# Request
func Request() -> Node2D:
	for laf in listOfLafets:
		if(!laf.isOccupied):
			return laf
	return null

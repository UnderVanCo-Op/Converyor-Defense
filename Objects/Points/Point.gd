extends StaticBody2D
# This is Point.gd

signal ConvBuilding(reftoNode, isUsed, Pntposition)
var isUsed := false			# for speed of checking
var isSpawnPoint := true	# shows if this is the start point of a chain
var inc_convs := []			# list-array for inc conveyors
var out_convs := []			# list-array for inc conveyors
#var cells := []				# list-array for cells inside

func _on_TextureButton_pressed() -> void:
	#emit_signal("ConvBuilding", get_node("TextureButton").rect_global_position)
	emit_signal("ConvBuilding", self, isUsed, get_node("Position2D").global_position)


func _physics_process(delta: float) -> void:
#	TryMoveCell()
	pass

func CheckSpawn() -> void:
	if(inc_convs.size() != 0):
		isSpawnPoint = false			# this breaks a circle spawn
	pass


func AddIncConv(conv) -> void:
	isSpawnPoint = false				# this breaks a circle spawn
	inc_convs.append(conv)		# new ref to list
	pass

func AddOutConv(conv) -> void:
	out_convs.append(conv)		# new ref to list
	pass


# 
func TryMoveCell() -> void:
	# Checks
	if(!isUsed or !out_convs or !inc_convs):
		return
	if(out_convs[0].isFull or out_convs[0].isBuilding):			# to be heavied in the future
		for c in inc_convs:				# stop all inc conv, need to add stop in their prev too
			c.call("StopCells")
	else:								# General
		if(inc_convs[0].isFull):
			print("Point is moving cell...")
			var cell = inc_convs[0].get_child(0)
			
			inc_convs[0].remove_child(cell)
			inc_convs[0].disconnect("StartCells", cell, "s_StartCell")
			inc_convs[0].disconnect("StopCells", cell, "s_StopCell")
			
			out_convs[0].add_child(cell)
			out_convs[0].ReceiveCell(cell)
#			out_convs[0].add_child(cell)
#			out_convs[0].connect("StartCells", cell, "s_StartCell")
#			out_convs[0].connect("StopCells", cell, "s_StopCell")	
		else:
			print("Point_MoveC_WANRING: inc conv 0 is not full, returning...")
			return


## Send cell to the out conv
#func SendCell(targetConv = out_convs[0]) -> void:
#	if(!cells[0]):
#		print("Point_Nothing to send, first add smth")
#		return
#	if(!targetConv):
#		push_error("Point_SendC_ERROR: No out conveyor for target!")
#		return
#	if(!targetConv.ReceiveCell(cells[0])):		# cell was not added for some reason in conv (mb full)
#
#		pass

# 
func ReceiveSpawnRequest(count : int, conv = out_convs[0]) -> void:
	# Checks
	if(!isSpawnPoint and inc_convs.size() == 0):		# mb add another, antonymus check
		push_error("Point_ERROR: ReceiveReq can not be executed since no incoming conv are connected and not spawnpoint!")
		return
	if(count < 1):		# mb redundant since GM has it's own check
		push_error("Point_ERROR: Can not spawn less than 1 cell!")
		return
	# General
	if(isSpawnPoint):
		conv.SpawnCells(count)
	else:
		print("reached else!")
#		print(inc_convs[0].Point.global_position)
		inc_convs[0].Point.ReceiveSpawnRequest(count)	# move on to the prev conv and Point


## 
#func SpawnCells(conv) -> void:
#	# Check
#	if(!isSpawnPoint):
#		push_error("Point_ERROR: Can not spawn cells in not SpawnPoint!")
#		return
#	# 

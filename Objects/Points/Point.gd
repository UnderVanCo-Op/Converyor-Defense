extends StaticBody2D
# This is Point.gd

signal ConvBuilding(reftoNode, isUsed, Pntposition)
var isUsed := false			# for speed of checking
var isSpawnPoint := true setget setter_isSpP	# shows if this is the start point of a chain
var inc_convs := []			# list-arrays for inc conveyors. All the conv inside these 2 lists must
var out_convs := []			# be (and are) ready to use
var OutConvMain = null		# point to the current out conv
var isFactoryP := false		# shows if point is a Factory point
var packages := []			# list of packages inside
var capacity := 9 			# amount of available space for packages
var isFulled := false		# shows if the amount of packages reached capacity
var isBatteryP := false		# shows if point is a Battery point
var isShadingCell := false	# shading
var WasUsed := false		# recursive system works
var WasCellMoved := false	# recursive system works
var isPaused := false		# new system
var WasOutJustStopped := false	# very spec variable for looking at the next point movements (slight imitation of a bidirectional chain)


func _ready() -> void:
	# Arrow work
	if(out_convs.size() < 1):
		$Arrow.hide()
	elif(out_convs.size() == 1):
		print("Point_ready: There was a pre-build conv, so setting arrow dir now...")
		setArrowDirAndShow(out_convs[0])
	else:
		push_warning("Point_ready: Cant set arrow dir bcs there are already more than 1 convs")
	
	set_physics_process(false)	    # turn off ph process


func setter_isSpP(new_val : bool) -> void:
#	print("WOROAWROAWROARWOAORW", new_val)
	isSpawnPoint = new_val


func _on_TextureButton_pressed() -> void:		# need to get rid of position
	emit_signal("ConvBuilding", self, isUsed, get_node("Position2D").global_position)


func AddIncConv(conv) -> void:		# adds inc conv
	call_deferred("set", "isSpawnPoint", false)
#	inc_count += 1
#	isSpawnPoint = false				# this breaks a circle spawn
	inc_convs.append(conv)				# new ref to list


func AddOutConv(conv) -> void:		# adds out conv with some additional work of setting arrow dir
#	out_count += 1
	out_convs.append(conv)			# new ref to list
	if(out_convs.size() == 1):		# if this is first out conv
		OutConvMain = conv
		setArrowDirAndShow(conv)
		

func SetPackageWaitingRecursive() -> void:
	if(OutConvMain):
		OutConvMain.endPoint.SetPackageWaitingRecursive()
		OutConvMain.isPackageWaiting = true
	pass


func SetSendingRecursive() -> void:
	if(OutConvMain.endPoint.OutConvMain):
		OutConvMain.endPoint.SetSendingRecursive()
		OutConvMain.isSending = true
	elif(OutConvMain.endPoint.isBatteryP):
		OutConvMain.isSending = true


func IncRequestPackage() -> Node2D:
	if(packages):
		var new_text = $Counter.text as int
		new_text -= 1
		$Counter.text = new_text as String

#		SetPackageWaitingRecursive()
		SetSendingRecursive()
#		OutConvMain.isPackageWaiting = false	# BROKEN fix for the first outconvmain (our)

		var _pack = packages[0]
		$Packages.remove_child(packages[0])
		packages.remove(0)
		return _pack
	return null


# Just receives package by appending it to the list and adding its as a child
func TryReceivePackage(package) -> bool:
	if(packages.size() >= capacity):
		isFulled = true
		push_warning("Point: There are no space in the Point!")
		return false
	
#	package.DeliveryStatus = 2		# set status = in delivery
#	if(OutConvMain):				# if we have our target conv
#		if(!TrySendPackage(package, OutConvMain)):		# if package was not sent to conv
#			package.visible = false
#
#			var new_text = $Counter.text as int
#			new_text += 1
#			$Counter.text = new_text as String
#
#			packages.append(package)					# then add to point
#			$Packages.add_child(package)				#
#
#		else:
#			SetPackageWaitingRecursive()
#	else:
	package.visible = false
	
	var new_text = $Counter.text as int
	new_text += 1
	$Counter.text = new_text as String
	
	packages.append(package)					# then add to point
	$Packages.add_child(package)				#
	
	if(packages.size() == capacity):	# check for trigger
		isFulled = true					# set trigger
	
	return true


# Sets direction of the sprite to the current output conv
func setArrowDirAndShow(conv) -> void:
	$Arrow.look_at(conv.endPoint.get_node("Position2D").global_position)
	$Arrow.show()


# Tries to send package on a last cell in the out[0] conv
#func TrySendPackage(package, conv) -> bool:
#		# Checks
##		if(conv.endPoint.isFulled):	# add and !enpoint.outconv.ismoving
##			push_warning("Point_TrySendPack: outconvs endpoint is fulled, returning")
##			return false
#		if(conv.isBuilding):
#			push_warning("Point_TryGetPack: Out conv is building, returning")
#			return false
#		if(conv.CheckIfSpawnIsFree()):
#			push_warning("Point_TrySendPack: I dont know how, but Spawn is free, lol. Resuming anyway")
#
#		# General
#		print("\nPoint ", self, " is trying to put package on cell now")
#		conv.PreReceivePackage(package)	# send package to conv
#		StartOutConv()
##		out_convs.ActivatePhysics()
#		if(packages.size() < capacity):		# trigger checks
#			isFulled = false				# trigger set
#		return true


# Recursive method to start all convs to the end of a chain (MAY NEED REWORK)
#func StartOutConv() -> void:
#	if(!OutConvMain):# may work unproperly, needs checking
#		return
#	OutConvMain.endPoint.StartOutConv()		# recursive to the end of a chain
#	OutConvMain.StartCells()
#	OutConvMain.ActivatePhysics()
#	OutConvMain.isSending = true		# turn trigger for physics on 
#	if(!inc_convs):
#		OutConvMain.isFulling = true		# set continious spawning of a new cells on
##		out_convs.ActivatePhysics()
#	pass


# Gets called deferred in order to clear all flags dedicated to recursive call of TryMove
func ResetMarks() -> void:
	WasUsed = false
	WasCellMoved = false


# Method checks if we can stop conv on a shade level. Also gets called in a Conv2.gd
func TryStopConvOnShade(outc):
	if(outc.isCellOnShade and !outc.isShaded and outc.isMoving):
		if((!outc.hasPackage and !outc.isSending) or (outc.hasPackage and !outc.isSending and !outc.endPoint.isBatteryP) or (outc.endPoint.WasOutJustStopped)):
			outc.endPoint.WasOutJustStopped = false
			outc.StopCells()
			if(!outc.isSpawning):
				outc.DeactivatePhysics()
			WasOutJustStopped = true


# warning-ignore:unused_argument
func _physics_process(delta: float) -> void:
	if(!WasUsed and !isPaused):
		CellWork()
	pass


# All general stuff related to cells
func CellWork() -> void:
	if(!isUsed):
		return
	if(OutConvMain and !OutConvMain.endPoint.WasUsed):	# recursive call to the end of a chain
		OutConvMain.endPoint.CellWork()		# recursive to the end
	if(out_convs):
		for outc in out_convs:
			TryStopConvOnShade(outc)
	if(!isBatteryP and inc_convs and (inc_convs[0].isSending or inc_convs[0].isShaded) and out_convs and !WasUsed):
		for outc in out_convs:
			if((!outc.isReady and !outc.isSpawning) or outc.isSending):		# finding free conv
				if(!isShadingCell):
					TryShadeCell(outc)
					call_deferred("ResetMarks")
					break	# this ensures point only moves one cell from all inc convs to only one out conv
				elif(inc_convs[0].isCellOnQuit):
#					WasUsed = true
					if(!isSpawnPoint):
						TryMoveCell(outc)
					else:
						TryMoveCell(outc)	#false
					call_deferred("ResetMarks")
					break	# this ensures point only moves one cell from all inc convs to only one outconv
	elif(isBatteryP and isUsed and inc_convs and (inc_convs[0].isSending or inc_convs[0].isShaded) and !WasUsed):	# same, but for battery point, including additional checks
		if(!isShadingCell):
			TryShadeCell()
			call_deferred("ResetMarks")
		elif(inc_convs[0].isCellOnQuit):
			if(inc_convs[0].FirstCell.isOccupied):
				TryToGiveOutPackage()
			else:
				RemoveCell()
			call_deferred("ResetMarks")
#		(inc_convs[0].isPackageWaiting or inc_convs[0].hasPackage)


# Method removes FirstCell on inc[0] 
func RemoveCell() -> void:
	inc_convs[0].remove_child(inc_convs[0].FirstCell)
	inc_convs[0].FirstCell.queue_free()
	inc_convs[0].isCellOnQuit = false
	inc_convs[0].isShaded = false			# CAREFULL (will lead to unexpected beh-r if we ever try to delete some custom cell in the middle of the conv (which should not ever happen, according to the current design-doc(in our heads lol))) 
	
	inc_convs[0].call_deferred("UpdateFirstCell")	# update first cell in the inc conv
	inc_convs[0].call_deferred("CheckIfCapacityIsOver")		# set isFull properly
	
	# Final
	WasUsed = true
	WasCellMoved = true		# careful
	isShadingCell = false


# Method checks if there is space in Battery, if so, send cannon to it, if not stopsConv
func TryToGiveOutPackage() -> void:
	print("\nPoint ", self, " is moving cell to the Battery now")
	if(get_parent().CheckForPlace()):		# if there is space inside a battery
		
		var pack = inc_convs[0].FirstCell.RemovePackage()
		inc_convs[0].RemovePackageWork()
		get_parent().ReceivePackage(pack)	# get battery and send it pack (there is free place, bcs we checked in if earlier)
		RemoveCell()
		
		if(!inc_convs[0].hasPackage and !inc_convs[0].isPackageWaiting):
			print("Stopped by trygiveoutIF!")
			inc_convs[0].isFulling = false
			inc_convs[0].isSending = false
			inc_convs[0].StopCells()
			inc_convs[0].DeactivatePhysics()
		
		isShadingCell = false
		
	else:		# there is now place in battery, so we stop conv and turn pause on
		var pack = inc_convs[0].FirstCell.RemovePackage()
		inc_convs[0].RemovePackageWork()
		pack.visible = false
		
		var new_text = $Counter.text as int
		new_text += 1
		$Counter.text = new_text as String
		$Packages.add_child(pack)
		RemoveCell()
		
		if(!inc_convs[0].hasPackage and !inc_convs[0].isPackageWaiting):
			print("Stopped by trygiveoutELSE!")
			inc_convs[0].isFulling = false
			inc_convs[0].isSending = false
			inc_convs[0].StopCells()
			inc_convs[0].DeactivatePhysics()
#		isPaused = true
		
	WasUsed = true


# Method tries to shade cell
func TryShadeCell(outconv = null):
	print("TryShadeCell reached")
	# Checks
	if(outconv):
		if(outconv.isBuilding or outconv.CheckIfCapacityIsOver() or (outconv.CheckIfCapacityIsEqual() and !outconv.isSending)):	# to be heavied in the future
			push_warning("Point_TryShade_WARNING: Out conv is full or is building, returning")
			return false
	if(inc_convs[0].isBuilding):
		push_warning("Point_TryShade_WARNING: Inc conv is building, returning")
		return false
	if(isPaused):
		push_warning("Point_TryShade_WARNING: Point is paused")
		return
	
	if(!isShadingCell):
		print("\nPoint ", self, " is offsetting cell now")
		inc_convs[0].isShaded = true
#		inc_convs[0].isPackageWaiting = true		# set packageWaiting for outc
		if(OutConvMain and inc_convs[0].FirstCell.isOccupied):	# if cell that we are shading has pack
			OutConvMain.isPackageWaiting = true		# set packaga waiting for the next conv beforehead
		isShadingCell = true
		inc_convs[0].StartCells()
		inc_convs[0].ActivatePhysics()
		# mb WasUsed = true
	else:
		push_error("Point_TryShade_ERROR: Tried to shade cell when some other cell is already shading")


# Method tries to send cell to the next conv
func TryMoveCell(outconv):
	
	# Recursion (seems like we dont need this anymore bcs its now written in CellWork()
#	if(!outconv.endPoint.WasUsed and useRecursion):		#useRecur can be replaced with isspawnpoint
#		outconv.endPoint.CellWork()		# recursive to the end
	
	# General
	print("\nPoint ", self, " is moving cell now")
	var cell = inc_convs[0].get_child(0)
	if(cell.isOccupied):
		inc_convs[0].RemovePackageWork()
		if(!inc_convs[0].hasPackage):
			out_convs[0].isPackageWaiting = false
#		out_convs[0].ReceivePackage()
	
	inc_convs[0].remove_child(cell)
	inc_convs[0].disconnect("StartCells", cell, "s_StartCell")
	inc_convs[0].disconnect("StopCells", cell, "s_StopCell")
	inc_convs[0].UpdateFirstCell()			# update first cell in the inc conv
	inc_convs[0].CheckIfCapacityIsOver()	# set isFull properly
	
	outconv.add_child(cell)
	outconv.call_deferred("ReceiveCell", cell)		# set up cell in new conv +updatefirstcell, mb not deferred
	
	# start cells (emit signal) in inc conv bcs it is now freed
	
	# Final
	inc_convs[0].isShaded = false
	inc_convs[0].isCellOnQuit = false
	
#	if(!outconv.isSending and outconv.CheckIfCapacityIsEqual()):	# stop cells on inc conv if out conv has got no place to send them
#		print("Stopped by trymovecell!")
#		inc_convs[0].StopCells()
#		inc_convs[0].DeactivatePhysics()
#		inc_convs[0].isSending = false
#	CellWork()
	
	WasUsed = true
	WasCellMoved = true
	isShadingCell = false
	return true


# Recursive function for moving request to the start of a chain, conv is outc from P
func ReceiveSpawnRequest(count : int, conv, isContinuation := false, EndOfChainP = null) -> void:
	# Checks
	if(!isSpawnPoint and inc_convs.size() == 0):		# mb add another, antonymus check
		push_error("Point_ERROR: ReceiveReq can not be executed since no incoming conv are connected and not spawnpoint!")
		return
	if(count < 1):			# mb redundant since GM has it's own check
		push_error("Point_ERROR: Can not spawn less than 1 cell!")
		return
	# General
	var PToSend = null
	if(isContinuation):		# возможно лишняя переменная
		conv.isSending = true
		conv.StartCells()
		conv.ActivatePhysics()
		
		if(self == EndOfChainP):
			print("\nFOUND A CYCLE!!")
			call_deferred("set", "isSpawnPoint", true)
			inc_convs[0].isSending = true				# for now, to run the circle
		else:
			PToSend = EndOfChainP
	else:
		PToSend = conv.endPoint
	if(isSpawnPoint):
		# add check for cycle works, mb TryMoveCell()
#		if(packages):
#			get_node("Packages").remove_child(packages[0])
#			if(TrySendPackage(packages[0], conv)):
#				packages.pop_at(0)		# pop out of a list
#				count -= 1				# to be changed
#			else:
#		get_node("Packages").add_child(packages[0])	# add child back
		conv.StartCells()
		conv.ActivatePhysics()
		conv.SpawnCells(count)
	else:
		print("Point ", self, ": Moving request to the prev Point!")
		inc_convs[0].Point.ReceiveSpawnRequest(count, inc_convs[0], true, PToSend)	# move on to the prev conv and Point
		# inc convs[0] should be replaced with smart choice of a path-system

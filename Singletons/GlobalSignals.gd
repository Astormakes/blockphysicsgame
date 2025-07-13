extends Node



## Grid Request
signal newGridRequested(playerId1:int, gridId1:int, BlockId1:int, Pos1:Vector3)

func triggernewGridRequested(playerId1:int, Pos1:Vector3):
	rpc("signalNewGridRequested",playerId1,Pos1)

@rpc("any_peer","call_local")
func signalNewGridRequested(playerId1:int, Pos1:Vector3):
	emit_signal("newGridRequested",playerId1, Pos1)

signal GenereateNewRegion(pos:Vector3)

func signalGenereateNewRegion(pos:Vector3):
	emit_signal("GenereateNewRegion",pos)

## Block place Request
signal blockplacementRequested(playerId2:int, gridname2:String, BlockId2:int, localPos2:Transform3D,currentItemID2:int)

func triggerBlockplacementRequested(gridname2:String,playerId2:int, localPos2:Transform3D,currentItemID2:int):
	rpc("signalblockplacementRequested",gridname2,playerId2,localPos2,currentItemID2)


@rpc("any_peer","call_local")
func signalblockplacementRequested(gridname2:String,playerId2:int, localPos2:Transform3D,currentItemID2:int):
	emit_signal("blockplacementRequested",gridname2,playerId2, localPos2,currentItemID2)


## Block remove Request 
signal blockremoveRequested(playerId3:int, gridname3:String, localPos3:Transform3D)

func triggerBlockremoveRequested(gridname3:String,playerId3:int, localPos3:Transform3D):
	rpc("signalblockremoveRequested",gridname3,playerId3,localPos3)


@rpc("any_peer","call_local")
func signalblockremoveRequested(gridname3:String,playerId3:int, localPos3:Transform3D):
	emit_signal("blockremoveRequested",gridname3,playerId3, localPos3)

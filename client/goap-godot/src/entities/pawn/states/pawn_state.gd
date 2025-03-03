extends BaseState
class_name PawnBaseState

var _pawn: PawnEntity


func init(context):
	_pawn = context as PawnEntity


func get_pawn() -> PawnEntity:
	return _pawn

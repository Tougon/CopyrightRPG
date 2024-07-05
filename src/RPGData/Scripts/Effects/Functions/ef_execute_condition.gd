extends EffectFunction
class_name EFExecuteCondition

enum EffectCheckType { AND, OR }
@export var check_success_type : EffectCheckType;
@export var check_success : Array[EffectFunction]
@export var on_success : Array[EffectFunction]
@export var on_fail : Array[EffectFunction]

var success : bool = false;

func execute(instance : EffectInstance):
	_check_success(instance);
	
	if instance.cast_success:
		for function in on_success:
			if function == null : continue;
			function.execute(instance);
	else:
		for function in on_fail:
			if function == null : continue;
			function.execute(instance);


func _check_success(instance : EffectInstance):
	instance.cast_success = true;
	
	for function in check_success:
		if function == null : continue;
		function.execute(instance);
		
		if check_success_type == EffectCheckType.AND && instance.cast_success == false:
			return;
		elif check_success_type == EffectCheckType.OR && instance.cast_success == true:
			return;

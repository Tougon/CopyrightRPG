@tool
extends Resource

class_name TweenFrame

enum ValueType { INT, FLOAT, STRING, VECTOR2, VECTOR3, COLOR }

@export var target: String;
@export var property_name: String;
@export var material_property : bool = false;
@export var duration: float = 1;
@export var delay: float = 0;
@export var transition: Tween.TransitionType = Tween.TRANS_LINEAR;
@export var ease: Tween.EaseType = Tween.EASE_IN;
@export var relative: bool = false;
var value_type: ValueType;

var int_value: int = 0;
var float_value: float = 0;
var string_value: String = "";
var vector2_value: Vector2 = Vector2.ZERO;
var vector3_value: Vector3 = Vector3.ZERO;
var color_value: Color = Color.WHITE;

var use_from: bool = false;

var int_from: int = 0;
var float_from: float = 0;
var string_from: String = "";
var vector2_from: Vector2 = Vector2.ZERO;
var vector3_from: Vector3 = Vector3.ZERO;
var color_from: Color = Color.WHITE;


func _init(p_property_name = "", p_duration = 1):
	property_name = p_property_name;
	duration = p_duration;

# Returns the correct value according to the set property type
func get_value():
	
	var retval = null
	
	match value_type:
		ValueType.INT:
			return int_value;
		ValueType.FLOAT:
			return float_value;
		ValueType.STRING:
			return string_value;
		ValueType.VECTOR2:
			return vector2_value;
		ValueType.VECTOR3:
			return vector3_value;
		ValueType.COLOR:
			return color_value;
			
	return retval;

# Returns the correct from value according to the set property type
func get_value_from():
	
	var retval = null
	
	match value_type:
		ValueType.INT:
			return int_from;
		ValueType.FLOAT:
			return float_from;
		ValueType.STRING:
			return string_from;
		ValueType.VECTOR2:
			return vector2_from;
		ValueType.VECTOR3:
			return vector3_from;
		ValueType.COLOR:
			return color_from;
			
	return retval;

# Returns the target relative to the node's parent
func get_relative_target():
	return "../" + target;

# Used so we can do conditional variable displays in the inspector.
func _get_property_list() -> Array:
	var ret: Array = []
	
	ret.append({
		"name": "Use From",
		"type": TYPE_BOOL
	})
	
	ret.append({
		"name": "Value Type",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "Int,Float,String,Vector2,Vector3,Color"
	})
	
	match value_type:
		
		ValueType.INT:
			ret.append({
				"name": "Int Value",
				"type": TYPE_INT,
			})
			
			if use_from:
				ret.append(({
					"name": "From Int",
					"type": TYPE_INT,
				}))
			
		ValueType.FLOAT:
			ret.append({
				"name": "Float Value",
				"type": TYPE_FLOAT,
			})
			
			if use_from:
				ret.append(({
					"name": "From Float",
					"type": TYPE_FLOAT,
				}))
			
		ValueType.STRING:
			ret.append({
				"name": "String Value",
				"type": TYPE_STRING,
			})
			
			if use_from:
				ret.append(({
					"name": "From String",
					"type": TYPE_STRING,
				}))
			
		ValueType.VECTOR2:
			ret.append({
				"name": "Vector2 Value",
				"type": TYPE_VECTOR2,
			})
			
			if use_from:
				ret.append(({
					"name": "From Vector2",
					"type": TYPE_VECTOR2,
				}))
			
		ValueType.VECTOR3:
			ret.append({
				"name": "Vector3 Value",
				"type": TYPE_VECTOR3,
			})
			
			if use_from:
				ret.append(({
					"name": "From Vector3",
					"type": TYPE_VECTOR3,
				}))
			
		ValueType.COLOR:
			ret.append({
				"name": "Color Value",
				"type": TYPE_COLOR,
			})
			
			if use_from:
				ret.append(({
					"name": "From Color",
					"type": TYPE_COLOR,
				}))
	
	return ret;

# Sets a property's value. Required for conditional displays.
func _set(property, val) -> bool:
	var retval: bool = true;
	
	match property:
		"Value Type":
			value_type = val;
			notify_property_list_changed();
		"Use From":
			use_from = false if val == null else val;
			notify_property_list_changed();
		"Int Value":
			int_value = val;
			notify_property_list_changed();
		"Float Value":
			float_value = val;
			notify_property_list_changed();
		"String Value":
			string_value = val;
			notify_property_list_changed();
		"Vector2 Value":
			vector2_value = val;
			notify_property_list_changed();
		"Vector3 Value":
			vector3_value = val;
			notify_property_list_changed();
		"Color Value":
			color_value = val;
			notify_property_list_changed();
		"From Int":
			int_from = val;
			notify_property_list_changed();
		"From Float":
			float_from = val;
			notify_property_list_changed();
		"From String":
			string_from = val;
			notify_property_list_changed();
		"From Vector2":
			vector2_from = val;
			notify_property_list_changed();
		"From Vector3":
			vector3_from = val;
			notify_property_list_changed();
		"From Color":
			color_from = val;
			notify_property_list_changed();
		_:
			retval = false;
	
	return retval;
	
# Gets a property's value. Required for conditional displays.
func _get(property):
	var retval = null
	
	match property:
		"Value Type":
			return value_type;
		"Use From":
			return use_from;
		"Int Value":
			return int_value;
		"Float Value":
			return float_value;
		"String Value":
			return string_value;
		"Vector2 Value":
			return vector2_value;
		"Vector3 Value":
			return vector3_value;
		"Color Value":
			return color_value;
		"From Int":
			return int_from;
		"From Float":
			return float_from;
		"From String":
			return string_from;
		"From Vector2":
			return vector2_from;
		"From Vector3":
			return vector3_from;
		"From Color":
			return color_from;
			
	return retval;
	

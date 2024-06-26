extends Node3D

class_name wjAbilityBase

signal sens_ability_viable

@export var ability_name: String = "Ability"
@export var ability_description: String = "This is an ability."
@export var ability_icon: Texture = null
@export var ability_cooldown_sec: float = 1.0
@export var ability_callback_delay_sec: float = 1.0
@export var ability_cost: float = 0
@export var ability_damage: float = 0
@export var ability_range_meters: float = 0.0
@export var ability_resource: wjAbilityResource = null

var user: wjCharacterBase = null
var valid_target_factions: Array = []

var is_on_cooldown = false
var is_enabled = true

func restore_cooldown():
	await get_tree().create_timer(ability_cooldown_sec).timeout
	is_on_cooldown = false

func enqueue_callback(callback: Callable = Callable(), args: Array = []):
	await get_tree().create_timer(ability_callback_delay_sec).timeout
	if args.size() == 0:
		callback.call()
	else:
		callback.call(args)


func activate(callback: Callable = Callable(), args: Array = []) -> bool:
	if is_on_cooldown or !is_enabled:
		if ability_resource != null:
			if ability_resource.deplete_success(ability_cost) == false:
				return false
		return false
	
	is_on_cooldown = true
	restore_cooldown.call_deferred()
	if callback:
		enqueue_callback.call_deferred(callback, args)
	return true

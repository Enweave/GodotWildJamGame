extends Node

class_name wjAbilityResource

@export var resource_name: String = "Resource name"
@export var resource_description: String = "This is a resource."
@export var resource_icon: Texture = null
@export var resource_amount: float = 0
@export var resource_max: float = 100
var is_unlimited = false

func deplete_success(amount: float) -> bool:
    if is_unlimited:
        return true
    if resource_amount > amount:
        clamp(resource_amount - amount, 0, resource_max)
        return true
    return false

func replenish(amount: float):
    resource_amount = clamp(resource_amount + amount, 0, resource_max)
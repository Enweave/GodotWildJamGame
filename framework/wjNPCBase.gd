extends Node3D

class_name wjNPCBase

@export var active_dialogue: DialogueResource = null
@export var npc_name: String = 'Name'
@export var action_prefix: String = 'Talk to '
@onready var action_available = false
@onready var dialogue_in_process = false

func display_action(display: bool):
    if display:
        %actionDisplay.text = action_prefix + npc_name
    else:
        %actionDisplay.text = npc_name

func _ready():
    DialogueManager.dialogue_ended.connect(_on_dialogue_end)
    display_action(false)

func _on_dialogue_end(resource: DialogueResource):
    if resource == active_dialogue:
        dialogue_in_process = false
        action_available = true
        display_action(true)

func _process(delta):
    if action_available:
        if Input.is_action_just_pressed('interact'):
            action_available = false
            display_action(false)
            if active_dialogue != null:
                DialogueManager.show_dialogue_balloon(active_dialogue, 'start')
                dialogue_in_process = true
            else:
                push_error('No dialogue resource attached to ' + self.name)

func _on_action_sensor_body_entered(body:Node3D):
    if body is wjPlayer:
        action_available = true
        display_action(true)

func _on_action_sensor_body_exited(body:Node3D):
    if body is wjPlayer:
        if not dialogue_in_process:
            action_available = true
            display_action(false)


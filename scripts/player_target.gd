class_name PlayerTarget
extends Node2D

@export var start_move_threshold: float = 400.0 # Position where target starts moving
@export var initial_speed: float = 300.0 # Initial target movement speed
@export var speed_increase: float = 0.0 # Rate at which the target speed increases
@export var distance_buffer: float = 1000.0 # Distance buffer between player and right edge of screen

@onready var player: Player
var initial_player_position: Vector2

var target_speed: float = 0.0
var x_position: float = 0.0
var moving: bool = false


func _ready() -> void:
	x_position = position.x
	player = get_tree().get_first_node_in_group("Player") as Player
	assert(player != null, "PlayerTarget must be in the same scene as the player to target it.")
	initial_player_position = player.position


func _physics_process(delta: float) -> void:
	if player:
		if not moving and player.position.distance_to(initial_player_position) >= start_move_threshold:
			moving = true
			target_speed = initial_speed
		if moving:
			target_speed += speed_increase * delta
			move_target(delta)

		if moving and player.position.x < position.x:
			get_tree().reload_current_scene()


func move_target(delta: float) -> void:
	x_position += target_speed * delta

	if player.position.x - x_position > distance_buffer:
		x_position = player.position.x - distance_buffer

	position.x = x_position

@tool
class_name Player
extends RigidBody2D

@export var move_speed: float = 400.0
@export var max_speed: float = 1000
@export var min_jump_impulse := Vector2(350, -450)
@export var max_jump_impulse := Vector2(450, -850)
@export var max_charge_time: float = 0.5
@export var max_floor_airborne_time: float = 0.15

var request := PhysicsRequest.new()
var is_on_floor: bool = false
var airborne_time: float = 0.0
var current_gravity: Vector2
var default_gravity: Vector2 = (ProjectSettings.get_setting("physics/2d/default_gravity") *
	ProjectSettings.get_setting("physics/2d/default_gravity_vector") )
var camera: Camera2D

@onready var jump_preview: Line2D = $JumpPreview
@onready var jump_charge_bar: TextureProgressBar = $JumpCharge


func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 10
	lock_rotation = true
	custom_integrator = true
	is_on_floor = false
	airborne_time = max_floor_airborne_time
	current_gravity = default_gravity


func _integrate_forces(physics_state: PhysicsDirectBodyState2D) -> void:
	var velocity: Vector2 = physics_state.linear_velocity

	if request.desired_velocity != Vector2.ZERO:
		velocity = request.desired_velocity

	velocity += request.additive_force * physics_state.step

	if request.impulse != Vector2.ZERO:
		velocity += request.impulse / mass

	velocity += current_gravity * physics_state.step

	#velocity = preserve_slope_velocity(physics_state, velocity)
	var damp: float = linear_damp + physics_state.total_linear_damp
	velocity *= pow(1.0 - damp, physics_state.step)

	physics_state.linear_velocity = velocity
	request = PhysicsRequest.new()

	var found_floor: bool = false
	var floor_index: int = -1

	for contact_index: int in physics_state.get_contact_count():
		var collision_normal: Vector2 = physics_state.get_contact_local_normal(contact_index)

		if collision_normal.dot(Vector2(0, -1)) > 0.6:
			found_floor = true
			floor_index = contact_index

	if found_floor:
		airborne_time = 0.0
	else:
		airborne_time += physics_state.step

	is_on_floor = airborne_time < max_floor_airborne_time


class PhysicsRequest:
	var desired_velocity := Vector2.ZERO
	var impulse := Vector2.ZERO
	var additive_force := Vector2.ZERO

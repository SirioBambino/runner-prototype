class_name ChargePlayerState
extends PlayerState

@export var jump_state: State

var jump_charge_time: float
var jump_charge_ratio: float
var jump_charge_bar: TextureProgressBar


func enter(_previous_state_path: State, _data: Dictionary = { }) -> void:
	jump_charge_time = 0.0
	player.jump_charge_bar.value = 0


func exit() -> void:
	_leave_jump_preview()
	player.jump_preview.clear_points()
	player.jump_charge_bar.value = 0


func update(delta: float) -> void:
	if Input.is_action_just_released("Jump"):
		request_transition.emit(jump_state, { "jump_charge_ratio": jump_charge_ratio })
		return

	jump_charge_time = min(jump_charge_time + delta, player.max_charge_time)
	jump_charge_ratio = clamp(jump_charge_time / player.max_charge_time, 0, 1)
	_draw_jump_preview(jump_charge_ratio)
	player.linear_velocity = Vector2.ZERO

	player.jump_charge_bar.value = jump_charge_ratio * 100


func predict_jump_path(charge_ratio: float, delta: float = 0.017, steps: int = 300) -> PackedVector2Array:
	var path := PackedVector2Array()

	var jump_impulse: Vector2 = lerp(player.min_jump_impulse, player.max_jump_impulse, charge_ratio)
	var velocity: Vector2 = (jump_impulse / player.mass)
	var position: Vector2 = player.global_position
	var space_state: PhysicsDirectSpaceState2D = get_viewport().get_world_2d().direct_space_state
	var gravity: Vector2 = (
		ProjectSettings.get_setting("physics/2d/default_gravity") *
		ProjectSettings.get_setting("physics/2d/default_gravity_vector")
	)

	var collision_shape: CollisionShape2D = player.get_node("LowerCollision")
	var shape_rid: RID = collision_shape.shape.get_rid()

	for i: int in range(steps):
		if velocity.y > -400:
			gravity *= 1.007

		velocity += gravity * delta
		var motion: Vector2 = velocity * delta

		var query := PhysicsShapeQueryParameters2D.new()
		query.shape_rid = shape_rid
		query.transform = Transform2D(0, position)
		query.motion = motion
		query.collide_with_bodies = true
		query.collide_with_areas = true

		var result: PackedFloat32Array = space_state.cast_motion(query)
		var safe_proportion: float = result[0]

		position += motion * safe_proportion
		path.append(position)

		if safe_proportion < 1.0:
			break

	return path


func _draw_jump_preview(charge_ratio: float) -> void:
	var points_global: PackedVector2Array = predict_jump_path(charge_ratio)
	var points_local := PackedVector2Array()
	for point: Vector2 in points_global:
		points_local.append(player.to_local(point))
	player.jump_preview.clear_points()
	player.jump_preview.points = points_local


func _leave_jump_preview() -> void:
	var debug_preview: Line2D = player.jump_preview

	var debug_line := Line2D.new()
	debug_line.width = 2
	debug_line.default_color = Color(1, 0, 0)

	for point: Vector2 in debug_preview.points:
		var world_point: Vector2 = player.to_global(point)
		debug_line.add_point(world_point)

	get_owner().get_owner().add_child(debug_line)

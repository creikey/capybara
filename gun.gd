extends CharacterBody3D


enum State { FLOOR, THROWN, HELD }

@export var uses = 5
@onready var anim = $AnimationPlayer
@onready var col = $CollisionShape3D
var state = State.FLOOR
var picked_up_by: Node3D = null
var hovering = false
var time_thrown = 0.0
var thrown_by: PhysicsBody3D = null

func throw(new_thrown_by: PhysicsBody3D, target: Vector3, oomf: float):
	picked_up_by = null
	thrown_by = new_thrown_by
	add_collision_exception_with(new_thrown_by)
	state = State.THROWN
	time_thrown = 0.0
	velocity = (target - global_position).normalized() * oomf

func pick_up(new_owner: Node3D):
	state = State.HELD
	picked_up_by = new_owner

func fire(_target: Vector3):
	pass

func _physics_process(delta: float) -> void:
	$gun/MAK_381_M_Pistolet_Vis.set_layer_mask_value(2, hovering)
	
	if thrown_by != null:
		if (state == State.THROWN and time_thrown > 0.2) or state != State.THROWN:
			remove_collision_exception_with(thrown_by)
			thrown_by = null
	
	if state == State.FLOOR:
		$CollisionShape3D.disabled = false
		anim.play("floor")
		velocity += get_gravity() * delta
		velocity.x = lerp(velocity.x, 0.0, 6.0 * delta)
		velocity.z = lerp(velocity.z, 0.0, 6.0 * delta)
		transform.basis = Basis()
		move_and_slide()
	elif state == State.THROWN:
		$CollisionShape3D.disabled = false
		anim.play("thrown")
		velocity += get_gravity() * delta
		var previous_velocity = velocity
		move_and_slide()
		if is_on_wall():
			velocity = previous_velocity.bounce(get_wall_normal()) * 0.5
		if is_on_floor():
			state = State.FLOOR
		for c_idx in range(get_slide_collision_count()):
			var c = get_slide_collision(c_idx)
			var collider = c.get_collider()
			if collider is Node and collider.is_in_group("killable"):
				collider.kill(global_position, velocity.normalized())
		time_thrown += delta
	elif state == State.HELD:
		$CollisionShape3D.disabled = true
		anim.play("held")
		global_transform = picked_up_by.global_transform
		global_transform.basis.x = global_transform.basis.x.normalized()
		global_transform.basis.y = global_transform.basis.y.normalized()
		global_transform.basis.z = global_transform.basis.z.normalized()

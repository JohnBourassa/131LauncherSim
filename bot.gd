extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 0

const BALL = preload("res://ball.tscn")     
@onready var ball_spawn: MeshInstance3D = $BallSpawn
@onready var goal: StaticBody3D = $"../Goal"
const h1 = 10
const h2 = 1.7

func _shoot():
	var ballNode = BALL.instantiate()
	get_tree().current_scene.add_child(ballNode)
	ballNode.global_position = ball_spawn.global_position
	ballNode.linear_velocity.y = sqrt(19.62 * h1)
	ballNode.linear_velocity.x = -get_velocity_x() + velocity.x
	ballNode.linear_velocity.z = -get_velocity_z() + velocity.z
	
func get_displacement_x() -> float:
	var bot_pos = ball_spawn.global_transform.origin.x
	var goal_pos = goal.global_transform.origin.x
	var displacement = goal_pos - bot_pos
	return displacement

func get_displacement_z() -> float:
	var bot_pos = ball_spawn.global_transform.origin.z
	var goal_pos = goal.global_transform.origin.z
	var displacement = goal_pos - bot_pos
	return displacement

func get_flight_time() -> float:
	var numerator = sqrt(19.62 * h1) + sqrt(19.62 * (h1 - h2))
	return numerator / 19.62

func get_pitch() -> float:
	var numerator = h1 * (1 + sqrt(h1 - h2))
	var denominator = sqrt(pow(get_displacement_x(), 2) + pow(get_displacement_z(), 2))
	return atan(numerator / denominator)

func get_yaw() -> float:
	var numerator = (get_displacement_x() / get_flight_time()) - velocity.x
	var denominator = (get_displacement_z() / get_flight_time()) - velocity.z
	
	print(get_displacement_x() / get_flight_time())
	print(get_displacement_z() / get_flight_time())
	
	var yaw = atan(numerator / denominator)
	if yaw < 0:
		yaw = yaw + PI
	return yaw
	
func get_launch_velocity() -> float:
	var numerator = 19.62 * sqrt(pow(get_displacement_x(), 2) + pow(get_displacement_z(), 2))
	var denominator = sqrt(19.62 * h1) + sqrt(19.62 * (h1 - h2))
	var speedDif = pow(velocity.x, 2) + pow(velocity.z, 2)
	var b = pow(numerator / denominator, 2) - speedDif
	print(speedDif)
	var a = 19.62 * h1
	# return sqrt(a + b)
	return sqrt(a + b) 

func get_velocity_2D() -> float:
	return cos(get_pitch()) * get_launch_velocity()

func get_velocity_x() -> float:
	return get_velocity_2D() * sin(get_yaw())
	
func get_velocity_z() -> float:
	return get_velocity_2D() * cos(get_yaw())
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if Input.is_action_just_pressed("Shoot"):
		_shoot()
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.z * SPEED
		velocity.z = -direction.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()

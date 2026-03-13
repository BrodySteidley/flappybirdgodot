class_name Pipe extends Obstacle


const PIPE_HEIGHT : float = 216;
const PIPE_SCENE = preload("res://src/pipe.tscn");
const COLOR_COUNT = 8

@export_range(0, COLOR_COUNT - 1) var color : int = 0:
	set(val):
		if val >= COLOR_COUNT:
			return;
		color = val;
		$Top.region_rect.position.x = 32 * val;
		$Middle.region_rect.position.x = 32 * val;
		$Bottom.region_rect.position.x = 32 * val;


func get_color():
	return color;

static func create_pipe(parent : Node2D, col : int) -> Pipe:
	var pipe = PIPE_SCENE.instantiate();
	parent.add_child(pipe);
	pipe.color = col;
	return pipe;

static func create_pipe_set(parent : Node2D, col : int = 0, vel : Vector2 = Vector2.ZERO, height : float = 0, seperation : float = 48, stagger : float = 0) -> Array:
	var pipe1 = create_pipe(parent, col);
	pipe1.position.y = height - PIPE_HEIGHT/2.0 - seperation/2.0;
	pipe1.position.x = stagger;
	pipe1.velocity = vel;
	
	var pipe2 = create_pipe(parent, col);
	pipe2.position.y = height + PIPE_HEIGHT/2.0 + seperation/2.0;
	pipe2.position.x = -stagger;
	pipe2.velocity = vel;
	
	return [pipe1, pipe2];

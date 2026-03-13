extends Node2D

const THEME_COUNT = 9;
const WINTERY_THEMES = [2, 3, 4, 5, 6];

@export var playfield_size : Vector2i = Vector2i(288, 230);


# these variables change per point scored:
@export var initial_move_speed : float = 100;
@export var move_speed_change : float = 0.5;
var move_speed = 100;

@export var initial_pipe_time : float = 1;
@export var pipe_time_change : float = -0.005;
@export var pipe_time_min : float = 0.1;
var pipe_time : float = 1;

@export var initial_pipe_dist : float = 64;
@export var pipe_dist_change : float = 0.02;
@export var pipe_dist_min : float = 28;
var pipe_dist : float = 64;

var pipe_color_change_prob_denominator : int = 15;

var game_paused : bool = true:
	set(val):
		game_paused = val;
		if val:
			$GUI/AnimationPlayer.play("PauseScreenFadeIn")
		else:
			$GUI/AnimationPlayer.play("PauseScreenFadeOut")

var high_score : int = 0:
	set(val):
		high_score = val;
			
		$GUI/Pause/GameoverScreen/HighScoreCounter.text = str(val)

var score : int = 0:
	set(val):
		if (val > 9999):
			val = 9999;
		
		score = val;
		$GUI/ScoreCounter.text = str(val);
		$GUI/Pause/GameoverScreen/ScoreCounter.text = str(val);
		if score > high_score:
			high_score = score;


func start_game():
	game_paused = false;
	
	var themeId : int = randi() % THEME_COUNT + 1;
	if themeId in WINTERY_THEMES:
		$Ground.region_rect.position.y = 32;
	else:
		$Ground.region_rect.position.y = 0;
	$Background.texture = load("res://img/Background/Background" + str(themeId) + ".png");
	pipe_color_change_prob_denominator = THEME_COUNT - themeId + 1;
	
	score = 0;
	high_score = retrieve_high_score();
	
	move_speed = initial_move_speed;
	pipe_time = initial_pipe_time;
	pipe_dist = initial_pipe_dist;
	kill_obstacles();
	
	spawn_obstacle();   
	$"Obstacle Timer".wait_time = pipe_time;
	$"Obstacle Timer".start();
	
	$Player.reset();

func game_over():
	if !game_paused:
		stop_obstacles();
		$"Obstacle Timer".stop();
		game_paused = true;
		$Player.disable_danger_collider();
		
		$GameOverMusic.play();

		save_high_score(high_score);

func _process(delta: float) -> void:
	if not game_paused:
		if $Player.position.y < 0:
			$Player.position.y = 0;
			if $Player.velocity.y < 0:
				$Player.velocity.y = 0;
		if $Player.position.y > playfield_size.y or $Player.position.x > playfield_size.x:
			$Player.animate_death(Vector2(-1, 0));
			$Player.dead = true;
			game_over();
		elif $Player.exploded():
			game_over();
		
		$Ground.position.x -= move_speed * delta;
		$Background.position.x -= move_speed * delta * 0.5;
		if $Ground.position.x <= -playfield_size.x:
			$Ground.position.x += playfield_size.x;
			
		if $Background.position.x <= -256:
			$Background.position.x += 256;
	elif Input.is_action_just_pressed("Flap"):
		if $GUI/Pause/GameoverScreen.visible:
			$GUI/Pause/GameoverScreen.visible = false;
			$GameOverMusic.stop();
			$GameStartSound.play();
		else:
			start_game();

func spawn_obstacle():
	var height : int = -50 + randi() % 100
	
	var pipe_color = 0;
	for i in range(Pipe.COLOR_COUNT):
		if randi() % pipe_color_change_prob_denominator == 0:
			pipe_color += 1;
	
	var obstacles : Array = Pipe.create_pipe_set($ObstacleParent, pipe_color, Vector2(-move_speed, 0), height, pipe_dist);
	
	var new_scorezone : ScoreZone = ScoreZone.create_scorezone($ObstacleParent);
	new_scorezone.velocity.x = -move_speed
	new_scorezone.connect("scored", Callable(self, "_on_player_scored"));
	obstacles.append(new_scorezone);
	
	for obstacle in obstacles:
		obstacle.kill_type = Obstacle.KillType.LEFT;
		obstacle.kill_pos = Vector2(-playfield_size.x * 1.5, 0);

func stop_obstacles():
	for obstacle in $ObstacleParent.get_children():
		obstacle.stop();

func kill_obstacles():
	for obstacle in $ObstacleParent.get_children():
		if not obstacle.is_queued_for_deletion():
			obstacle.queue_free();

func _on_obstacle_timer_timeout() -> void:
	$"Obstacle Timer".wait_time = pipe_time;
	spawn_obstacle();
	
func _on_player_scored():
	if not $Player.dead:
		score += 1;
		
		if randi() % 2 == 0:
			$ScoreSound2.play();
		else:
			$ScoreSound.play();
		
		if pipe_time > pipe_time_min:
			pipe_time += pipe_time_change;
			
		if pipe_dist > pipe_dist_min:
			pipe_dist += pipe_dist_change;
			
		move_speed += move_speed_change;

func save_high_score(score_to_store : int):
	var save_file = FileAccess.open("user://flappyclone.save", FileAccess.WRITE);

	if FileAccess.get_open_error() == Error.OK:
		save_file.store_64(score_to_store);
		save_file.close();


func retrieve_high_score() -> int:
	var save_file = FileAccess.open("user://flappyclone.save", FileAccess.READ);
	
	if FileAccess.get_open_error() == Error.OK:
		var value = save_file.get_64();
		save_file.close();
		return value;

	return 0;

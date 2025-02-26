extends Area2D

@export var connectedScene: String
@export var hasAni: bool
@export var sprite: Texture
@export var hframes: int = 4
@export var pos: Vector2i = Vector2i(0,0)

var animatedSprite

func _ready():
	if hasAni:
		_create_animeted_sprite()

func _create_animeted_sprite():
	animatedSprite = AnimatedSprite2D.new()
	add_child(animatedSprite)
	
	animatedSprite.centered = false
	
	var frames = SpriteFrames.new()
	
	frames.add_animation("opening")
	
	var originalImage = sprite.get_image()
	
	for i in range(hframes):
		var frameImage = Image.create(16, 16, false, originalImage.get_format())
		frameImage.blit_rect(originalImage, Rect2(i * 16, 0, 16, 16), Vector2(0,0))
		var frameTexture = ImageTexture.create_from_image(frameImage)
		frames.add_frame("opening", frameTexture)
		
	frames.set_animation_loop("opening", false)
	
	
	frames.add_animation("closing")
		
	for i in range(hframes-1, -1, -1):
		var frameImage = Image.create(16, 16, false, originalImage.get_format())
		frameImage.blit_rect(originalImage, Rect2(i * 16, 0, 16, 16), Vector2(0,0))
		var frameTexture = ImageTexture.create_from_image(frameImage)
		frames.add_frame("closing", frameTexture)
		
	frames.set_animation_loop("closing", false)
	
	animatedSprite.frames = frames
	animatedSprite.animation = "opening"
	
	animatedSprite.frame = 0

func _on_body_entered(body):
	if animatedSprite:
		animatedSprite.play("opening")
	
	if body is Player:
		var connections = body.get_signal_connection_list("Player_entered_trigger")
		if connections.size() == 0:
			var callchange = Callable(self, "_change_scene")
			body.connect("Player_entered_trigger", callchange)

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		if animatedSprite:
			animatedSprite.play("closing")

func _change_scene():
	Global.changeScene(get_owner(), connectedScene, pos)
	position = Vector2i(0,0)
	Global.wait(5,51)

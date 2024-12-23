extends Area2D

@export var connectedScene: String
@export var hasAni: bool
@export var sprite: Texture
@export var hframes: int = 4


var animatedSprite

func _ready():
	if hasAni:
		_create_animeted_sprite()
	
func _create_animeted_sprite():
	animatedSprite = AnimatedSprite2D.new()
	add_child(animatedSprite)
	
	animatedSprite.position = Vector2(32,8)
	
	var frames = SpriteFrames.new()
	
	frames.add_animation("opening")
	
	var originalImage = sprite.get_image()
	var frameWidth = sprite.get_width()
	var frameHeight = sprite.get_height()
	
	for i in range(hframes):
		var frameImage = Image.create(frameWidth, frameHeight, false, originalImage.get_format())
		frameImage.blit_rect(originalImage, Rect2(i * 16, 0, 16, 16), Vector2(0,0))
		var frameTexture = ImageTexture.create_from_image(frameImage)
		frames.add_frame("opening", frameTexture)
		
	animatedSprite.frames = frames
	animatedSprite.animation = "opening"
		
		
func _on_body_entered(body):
	if body is Player:
		var callchange = Callable(self, "_change_scene")
		body.connect("Player_entered_trigger", callchange)
		if animatedSprite:
			animatedSprite.play("opening")


func _change_scene():
	manager_scene.changeScene(get_owner(), connectedScene)
	

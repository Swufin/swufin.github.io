extends CanvasLayer

@onready var details_label: Label = $Details/SubViewport/Label
@onready var character: TextureRect = $Bars/Character
@onready var dialogue: Control = $Intro/Dialogue

var amplitude: float = -0.05
var speed: float = 1.0
var time: float = 0.0

var birthday = {
	"year": 2007,
	"month": 1,
	"day": 11
}

func get_exact_years_since(past_unix_time: int) -> int:
	var current_dict = Time.get_date_dict_from_system()
	var past_dict = Time.get_date_dict_from_unix_time(past_unix_time)
	
	var year_difference = current_dict.year - past_dict.year
	
	if current_dict.month < past_dict.month or (current_dict.month == past_dict.month and current_dict.day < past_dict.day):
		year_difference -= 1
		
	return year_difference

func _ready() -> void:
	var birthday_unix = Time.get_unix_time_from_datetime_dict(birthday)
	var age = get_exact_years_since(birthday_unix)
	var newText = "they/them - " + str(age)
	
	details_label.text = newText
	
func _process(delta: float) -> void:
	time += delta

	var character_offset = sin(time * speed) * amplitude
	character.rotation = character_offset

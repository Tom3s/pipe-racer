extends Control
class_name RatingMenu

@onready var yourRating: Label = %YourRating
@onready var closeButton: Button = %CloseButton

var rateButtons: Array[Button] = []

@export
var trackId: String

signal ratingSubmitted(newRating: float)
signal closePressed()

func init(initTrackId: String):
	trackId = initTrackId

	if ratings.size() > 0:
		setYourRating()
	else:
		loadYourRating()

func _ready():
	for i in 6:
		var button = get_node("%Rate" + str(i) + "Button")
		rateButtons.append(button)

		button.pressed.connect(func(): onRatingPressed(i))
	closeButton.pressed.connect(func(): 
		hide()
		closePressed.emit()
	)
	visibility_changed.connect(func():
		if is_visible_in_tree():
			rateButtons.back().grab_focus()
	)
	loadYourRating()


func onRatingPressed(rating: int):
	# yourRating.text = str(rating)
	disableButtons()
	submitRating(rating)

func disableButtons():
	for button in rateButtons:
		button.disabled = true
		button.selected = true
	# closeButton.disabled = true

func enableButtons():
	for button in rateButtons:
		button.disabled = false
		button.selected = button.name == "Rate" + yourRating.text + "Button"
	# closeButton.disabled = false

var ratings = []
func loadYourRating():
	var request = HTTPRequest.new()
	add_child(request)
	request.timeout = 5
	request.request_completed.connect(onAllRatingsLoaded)

	var httpError = request.request(
		Backend.BACKEND_IP_ADRESS + "/api/ratings/", # + trackId, TODO: implement in backend
		[
			"Content-Type: application/json",
			"Session-Token: " + GlobalProperties.SESSION_TOKEN,
		],
		HTTPClient.METHOD_GET
	)
	if httpError != OK:
		print("Error sending get request: " + error_string(httpError))

func onAllRatingsLoaded(_result: int, _responseCode: int, _headers: PackedStringArray, _body: PackedByteArray):
	if _responseCode != 200:
		AlertManager.showAlert(
			self,
			"Error loading your rating",
			_body.get_string_from_utf8()
		)
		return
	
	var data = JSON.parse_string(_body.get_string_from_utf8())

	ratings.assign(data)

	setYourRating()

func setYourRating():
	for rating in ratings:
		if rating.userId == GlobalProperties.USER_ID && rating.trackId == trackId:
			yourRating.text = str(rating.rating)
			enableButtons()
			return
	yourRating.text = '-'
	enableButtons()

func submitRating(rating: int):
	var request = HTTPRequest.new()
	add_child(request)
	request.timeout = 5
	request.request_completed.connect(onRatingSubmitted)

	var httpError = request.request(
		Backend.BACKEND_IP_ADRESS + "/api/ratings/" + trackId,
		[
			"Content-Type: application/json",
			"Session-Token: " + GlobalProperties.SESSION_TOKEN,
		],
		HTTPClient.METHOD_POST,
		JSON.stringify({
			"rating": rating,
		})
	)
	if httpError != OK:
		print("Error submitting rating request: " + error_string(httpError))
		enableButtons()

func onRatingSubmitted(_result: int, _responseCode: int, _headers: PackedStringArray, _body: PackedByteArray):
	if _responseCode != 200:
		AlertManager.showAlert(
			self,
			"Error submitting your rating",
			_body.get_string_from_utf8()
		)
	else:
		AlertManager.showAlert(
			self,
			"Rating submitted successfully!",
			"Your rating has been submitted successfully."
		)
	# enableButtons()

	loadYourRating()

	var data = JSON.parse_string(_body.get_string_from_utf8())

	ratingSubmitted.emit(data.rating)
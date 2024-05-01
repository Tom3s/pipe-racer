extends HBoxContainer
class_name Comment

@onready var indent: Control = %Indent
@onready var profilePicture: TextureRect = %ProfilePicture
@onready var usernameLabel: Label = %Username
@onready var deleteButton: Button = %DeleteButton
@onready var commentLabel: Label = %Comment
@onready var upvoteButton: Button = %UpvoteButton
@onready var rating: Label = %Rating
@onready var downvoteButton: Button = %DownvoteButton
@onready var replyButton: Button = %ReplyButton
@onready var replyContainer: CommentTextField = %ReplyContainer

var username: String
var userId: String
var commentText: String
var trackId: String
var indentLevel: int
var ratingValue: int
var commentId: String

signal replySubmitted()
signal commentDeleted()

func init(
	initialUsername: String,
	initialUserId: String,
	initialCommentText: String,
	initialTrackId: String,
	initialIndentLevel: int,
	initialRatingValue: int,
	initialCommentId: String
):
	username = initialUsername
	userId = initialUserId
	commentText = initialCommentText
	trackId = initialTrackId
	indentLevel = initialIndentLevel
	ratingValue = initialRatingValue
	commentId = initialCommentId

	# loadProfilePicture()
	TextureLoader.loadOnlineTexture(
		Backend.BACKEND_IP_ADRESS + "/api/users/picture/" + userId,
		func(image):
			profilePicture.texture = image
	)
	usernameLabel.text = username
	commentLabel.text = commentText
	rating.text = str(ratingValue)
	setIndent()
	deleteButton.visible = userId == GlobalProperties.USER_ID

	replyContainer.init(
		commentId,
		username,
		trackId
	)

	replyContainer.commentSubmitted.connect(func(): replySubmitted.emit())

func _ready():
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	connectSignals()

func connectSignals() -> void:
	deleteButton.pressed.connect(onDeleteButtonPressed)
	upvoteButton.pressed.connect(onUpvoteButtonPressed)
	downvoteButton.pressed.connect(onDownvoteButtonPressed)
	replyButton.toggled.connect(onReplyButtonToggled)

const INDENT_SIZE: int = 20

func setIndent():
	indent.custom_minimum_size = Vector2(indentLevel * INDENT_SIZE, 0)

func onDeleteButtonPressed():
	AlertManager.showDeleteAlert(
		self,
		"Are you sure you want to delete this comment?",
		deleteComment
	)

func onUpvoteButtonPressed():
	submitRating(1)

func onDownvoteButtonPressed():
	submitRating(-1)

func onReplyButtonToggled(toggled: bool):
	replyContainer.visible = toggled

func deleteComment():
	var request = HTTPRequest.new()
	add_child(request)
	request.timeout = 5
	request.request_completed.connect(onCommentDeletedResponse)

	var httpError = request.request(
		Backend.BACKEND_IP_ADRESS + "/api/comments/" + commentId,
		[
			"Content-Type: application/json",
			"Session-Token: " + GlobalProperties.SESSION_TOKEN,
		],
		HTTPClient.METHOD_DELETE
	)
	if httpError != OK:
		print("Error sending delete request: " + error_string(httpError))

func onCommentDeletedResponse(_result: int, _responseCode: int, _headers: PackedStringArray, _body: PackedByteArray):
	# var title = "Comment deleted"
	# if _responseCode != 200:
	# 	title = "Error deleting comment"
	# AlertManager.showAlert(
	# 	self,
	# 	title,
	# 	_body.get_string_from_utf8()
	# )
	if _responseCode != 200:
		AlertManager.showAlert(
			self,
			"Error deleting comment",
			_body.get_string_from_utf8()
		)
	else:
		AlertManager.showAlert(
			get_parent(),
			"Comment deleted",
			"Comment deleted successfully"
		)
		commentDeleted.emit()
	return

func submitRating(newRating: int):
	var request = HTTPRequest.new()
	add_child(request)
	request.timeout = 5
	request.request_completed.connect(onCommentRatingSubmittedResponse)

	var data = {
		"rating": newRating
	}

	var httpError = request.request(
		Backend.BACKEND_IP_ADRESS + "/api/comments/rate/" + commentId,
		[
			"Content-Type: application/json",
			"Session-Token: " + GlobalProperties.SESSION_TOKEN,
		],
		HTTPClient.METHOD_POST,
		JSON.stringify(data)
	)
	if httpError != OK:
		print("Error submitting rating: " + error_string(httpError))

func onCommentRatingSubmittedResponse(_result: int, _responseCode: int, _headers: PackedStringArray, _body: PackedByteArray):
	# var title = "Rating submitted"
	if _responseCode != 200:
		AlertManager.showAlert(
			self,
			"Error submitting rating",
			_body.get_string_from_utf8()
		)
	else:
		var json = JSON.parse_string(_body.get_string_from_utf8())
		ratingValue = int(json["rating"])
		rating.text = str(ratingValue)


	
	return
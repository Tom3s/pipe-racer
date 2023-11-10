extends PanelContainer
class_name TrackPanel

@onready var trackName: Label = %TrackName
@onready var author: Label = %Author
@onready var viewButton: Button = %ViewButton
@onready var downloadCount: Label = %DownloadCount
@onready var rating: Label = %Rating
@onready var uploadDate: Label = %UploadDate

var trackId: String

signal viewButtonPressed(trackId: String)

func init(
	initTrackId: String,
	initTrackName: String,
	initAuthor: String,
	initDownloadCount: int,
	initRating: float,
	initUploadDate: String,
):
	trackId = initTrackId
	trackName.text = initTrackName
	author.text = "By: " + initAuthor
	downloadCount.text = str(initDownloadCount)
	rating.text = str(initRating).pad_decimals(2) + "/5"
	uploadDate.text = initUploadDate

func _ready():
	viewButton.pressed.connect(onViewButtonPressed)
	scale = Vector2(.75, .75)
	size = Vector2(1536, 209)

func onViewButtonPressed():
	viewButtonPressed.emit(trackId)
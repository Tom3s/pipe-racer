extends Node
class_name UsernameGenerator

const ADJECTIVES = [
	# A
	"adorable",
	"alive",
	"amused",
	"angry",
	"annoyed",
	"anxious",
	"attractive",
	# B
	"beautiful",
	"better",
	"big",
	"bitter",
	"black",
	"blue",
	"bored",
	"boring",
	"brave",
	"bright",
	"busy",
	# C
	"calm",
	"careful",
	"cautious",
	"charming",
	"cheerful",
	"clean",
	"clever",
	"clumsy",
	"colorful",
	"comfortable",
	"confident",
	"confused",
	"cute",
	# D
	"delightful",
	"determined",
	"disgusted",
	"doubtful",
	"dull",
	# E
	"eager",
	"easy",
	"elegant",
	"energetic",
	"enthusiastic",
	# F
	"fabulous",
	"faithful",
	"fancy",
	"fantastic",
	"friendly",
	# G
	"generous",
	"gentle",
	"genuine",
	"grateful",
	"great",
	# H
	"happy",
	"helpful",
	"honest",
	"hopeful",
	"humble",
	# I
	"imaginative",
	"impartial",
	"impressive",
	"intelligent",
	"interesting",
	# J
	"joyful",
	"jovial",
	"jubilant",
	# K
	"kind",
	"knowledgeable",
	# L
	"lovely",
	"lucky",
	# M
	"magnificent",
	"marvelous",
	"merry",
	"modest",
	# N
	"nice",
	"noble",
	"nutty",
	# O
	"optimistic",
	"outgoing",
	# P
	"passionate",
	"patient",
	"peaceful",
	"perfect",
	"playful",
	# Q
	"quick",
	"quiet",
	# R
	"radiant",
	"reliable",
	"respectful",
	"responsible",
	# S
	"sincere",
	"smart",
	"sociable",
	"strong",
	"successful",
	# T
	"talented",
	"thoughtful",
	"thrilled",
	"trustworthy",
	# U
	"unique",
	"upbeat",
	# V
	"vibrant",
	"victorious",
	# W
	"warm",
	"wonderful",
	# X
	"exciting",
	"excellent",
	# Y
	"youthful",
	# Z
	"zealous"
]


const NOUNS = [
	# Animals
	"alligator",
	"ant",
	"bear",
	"bee",
	"bird",
	"cat",
	"cheetah",
	"chicken",
	"cow",
	"crocodile",
	"deer",
	"dog",
	"dolphin",
	"duck",
	"eagle",
	"elephant",
	"fish",
	"fox",
	"frog",
	"giraffe",
	"goat",
	"gorilla",
	"hamster",
	"hippo",
	"horse",
	"jaguar",
	"kangaroo",
	"koala",
	"lion",
	"monkey",
	"octopus",
	"owl",
	"panda",
	"parrot",
	"penguin",
	"pig",
	"rabbit",
	"raccoon",
	"shark",
	"sheep",
	"snake",
	"tiger",
	"turtle",
	"whale",
	"wolf",
	"zebra",

	# Fruits - Veggies - Snacks
	"apple",
	"banana",
	"carrot",
	"cherry",
	"grape",
	"kiwi",
	"lemon",
	"orange",
	"peach",
	"pear",
	"pineapple",
	"potato",
	"strawberry",
	"watermelon",
	"avocado",
	"broccoli",
	"corn",
	"cucumber",
	"eggplant",
	"garlic",
	"lettuce",
	"mushroom",
	"onion",
	"pepper",
	"pumpkin",
	"tomato",
	"bread",
	"butter",
	"cake",
	"candy",
	"cheese",
	"chocolate",
	"cookie",
	"cracker",
	"cupcake",
	"donut",
	"egg",
	"jam",
	"jelly",
	"milk",
	"muffin",
	"pie",
	"pizza",
	"popcorn",
	"pretzel",
	"pudding",

	# Objects
	"plane",
	"car",
	"train",
	"boat",
	"bike",
	"computer",
	"phone",
	"book",
	"pen",
	"pencil",
	"chair",
	"table",
	"lamp",
	"bed",
	"door",
	"window",
	"clock",
	"shirt",
	"pants",
	"shoes",
	"hat",
	"coat",
	"jacket",
	"tie",
	"socks",
	"shorts",
	"skirt",
	"purse",
	"wallet",
	"backpack",
	"umbrella",
	"camera",
	"watch",
	"ring",
	"necklace",
	"earrings",
	"bracelet",
]

static func l33tize(string: String) -> String:
	var mappings = {
		'o': 0,
		'i': 1,
		'z': 2,
		'e': 3,
		'a': 4,
		's': 5,
		't': 7,
	}

	for mapping in mappings:
		if randf() < 0.85:
			string = string.replace(mapping, str(mappings[mapping]))	
	
	return string

static func ruinLettering(string: String) -> String:
	var ruined = ""
	for letter in string:
		if randf() < 0.8:
			ruined += letter
		else:
			ruined += letter + letter

	return ruined

static func alternatingCase(string: String) -> String:
	var alternating = ""
	for i in range(string.length()):
		if i % 2 == 0:
			alternating += string[i].to_lower()
		else:
			alternating += string[i].to_upper()

	return alternating

static func getUsername() -> String:
	var adjective = ADJECTIVES.pick_random()
	var noun = NOUNS.pick_random()

	if randf() < 0.5:
		adjective = adjective.capitalize()

	if randf() < 0.5:
		noun = noun.capitalize()

	var username = ""

	if randf() < 0.9:
		username += adjective
	
	if randf() < 0.4:
		username += "_"
	
	if randf() < 0.9:
		username += noun
	
	if randf() < 0.1:
		username += str(randi() % 1000)

	if randf() < 0.01:
		username = "xX" + username + "Xx"
	elif randf() < 0.03:
		username = 'The' + ('_' if username.contains('_') else '')  + username
	
	if randf() < 0.04:
		username = l33tize(username)
	elif randf() < 0.04:
		username = ruinLettering(username)
	elif randf() < 0.04:
		username = alternatingCase(username)

	if username == '':
		username = 'ILostTheGame'

	return username
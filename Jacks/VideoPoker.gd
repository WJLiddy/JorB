extends Node2D

var holds = [false,false,false,false,false]
var deck = null
var dealt = false

var credits = 100
var paytable = {1:250,2:50,3:25,4:9,5:6,6:4,7:3,8:2,9:1,0:0}

# Called when the node enters the scene tree for the first time.
func _ready():
	redeal()

func mkdeck():
	var ndeck = []
	for suit in ["S","C","D","H"]:
		for rank in [14,13,12,11,10,9,8,7,6,5,4,3,2]:
			ndeck.append([suit,rank])
	ndeck.shuffle()
	return ndeck

func check_score():
	get_node("Misc/Credit").text = "CREDITS\n" + str(credits)
	if(dealt):
		get_node("Misc/Instr").text = "SPACE: DEAL"
	else:
		get_node("Misc/Instr").text = "SPACE: DRAW"

	for i in [1,2,3,4,5,6,7,8,9]:
		get_node("PayIcons/"+str(i)).modulate = Color(1,1,1,1)
		get_node("PayValues/"+str(i)).modulate = Color(1,1,1,1)
	var s = score()
	if(s != 0):
		get_node("PayIcons/"+str(s)).modulate = Color(1,1,0,1)
		get_node("PayValues/"+str(s)).modulate = Color(1,1,0,1)

func deal():
	dealt = true
	if(!holds[0]):
		get_node("Card1").setVal(deck.pop_front())
	if(!holds[1]):
		get_node("Card2").setVal(deck.pop_front())
	if(!holds[2]):
		get_node("Card3").setVal(deck.pop_front())
	if(!holds[3]):
		get_node("Card4").setVal(deck.pop_front())
	if(!holds[4]):
		get_node("Card5").setVal(deck.pop_front())
	var s = score()
	credits += paytable[s]
	check_score()

func redeal():
	credits -= 1
	dealt = false
	for i in [0,1,2,3,4]:
		set_hold(i,false)
	deck = mkdeck()
	get_node("Card1").setVal(deck.pop_front())
	get_node("Card2").setVal(deck.pop_front())
	get_node("Card3").setVal(deck.pop_front())
	get_node("Card4").setVal(deck.pop_front())
	get_node("Card5").setVal(deck.pop_front())
	check_score()

func set_hold(i, v):
	get_node("Controls/"+str(i+1)).visible = !v
	get_node("Controls/"+str(i+1)+"Hold").visible = v
	holds[i] = v
			
func _input(ev):
	if ev is InputEventKey and ev.pressed:
		if(ev.keycode == KEY_Q):
			set_hold(0,!holds[0])
		if(ev.keycode == KEY_W):
			set_hold(1,!holds[1])
		if(ev.keycode == KEY_E):
			set_hold(2,!holds[2])
		if(ev.keycode == KEY_R):
			set_hold(3,!holds[3])
		if(ev.keycode == KEY_T):
			set_hold(4,!holds[4])
		if(ev.keycode == KEY_SPACE):
			if(dealt):
				redeal()
			else:
				deal()

func card_sort(a, b):
	return a[1] > b[1]
			

func get_sets(cards, jacks_only):
	var sets = {}
	for c in cards:
		if(jacks_only and c[1] < 11):
			continue
		if(!sets.has(c[1])):
			sets[c[1]] = 0
		sets[c[1]] += 1 
	var ret = sets.values()
	ret.sort()
	ret.reverse()
	return ret

func score():
	var cards = [get_node("Card1").val,get_node("Card2").val,get_node("Card3").val,get_node("Card4").val,get_node("Card5").val]
	cards.sort_custom(card_sort)
	
	# run checks for winning hands on the cards.
	var flush = cards[0][0] == cards[1][0] && cards[1][0] == cards[2][0] && cards[2][0] == cards[3][0] && cards[3][0] == cards[4][0]
	var straight = cards[0][1] == cards[1][1] + 1 && cards[1][1] == cards[2][1] + 1 && cards[2][1] == cards[3][1] + 1 && cards[3][1] == cards[4][1] + 1
	
	# ace low straight
	var ace_low = cards[0][1] == 14 && cards[1][1] == 5 && cards[2][1] == 4 && cards[3][1] == 3 && cards[4][1] == 2
	straight = straight or ace_low
	
	var sets = get_sets(cards, false)
	var jsets = get_sets(cards, true)
	print("flush? " + str(flush))
	print("straight? " + str(straight))
	print("sets? " + str(sets))
	if(straight && flush):
		# ace high straight flush is a royal
		if(cards[0][1] == 14 and cards[0][1] == 13):
			return 1
		else:
			return 2
	if(sets[0] == 4):
		return 3
	if(sets[0] == 3 and sets[1] == 2):
		return 4
	if(flush):
		return 5
	if(straight):
		return 6
	if(sets[0] == 3):
		return 7
	if(sets[0] == 2 and sets[1] == 2):
		return 8
	if(jsets.size() > 0 and jsets[0] == 2):
		return 9
	return 0

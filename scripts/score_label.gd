extends Label

enum AnimationState{
	Static,
	TweenScoreJustEarned,
	MultiplyScoreJustEarned,
	TweenTotalScore
}

var Current_Animation_State: AnimationState
var tweening_total_score: float
var tweening_score_just_earned: float
var multiplied_score_earned: int
const animation_freeze_time: float = 0.5
var animation_time_frozen_timer: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Current_Animation_State = AnimationState.Static
	tweening_total_score = 0
	tweening_score_just_earned = 0
	
	ScoreManager.multiply_score_just_earned.connect(multiply_score_just_earned)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	match Current_Animation_State:
		
		AnimationState.Static: 

			if (ScoreManager.score_just_earned == 0):
				text = """%s pts""" %[ScoreManager.total_score]
				return
			text = """%s pts
			%s x %s""" %[ScoreManager.total_score, ScoreManager.score_just_earned, ScoreManager.mult]
			
			#if (ScoreManager.score_just_earned > tweening_score_just_earned):
				#Current_Animation_State = AnimationState.TweenScoreJustEarned
		
		AnimationState.TweenScoreJustEarned: # NOT USED RN if you want the score earned to tween uncomment code
			#tweening_score_just_earned += max(10*_delta,2* (ScoreManager.score_just_earned - tweening_score_just_earned) *_delta)
			#tweening_score_just_earned = min(tweening_score_just_earned, ScoreManager.score_just_earned)
			#text = """%s pts
			#%s x %s""" %[ScoreManager.total_score, int(tweening_score_just_earned), ScoreManager.mult]
			
			#if (ScoreManager.score_just_earned == tweening_score_just_earned):
				#Current_Animation_State = AnimationState.Static
			pass
			
		AnimationState.MultiplyScoreJustEarned: 
			if (multiplied_score_earned == 0):
				text = """%s pts """%[ScoreManager.total_score]
				Current_Animation_State = AnimationState.Static
				return
				
			if (floor(tweening_score_just_earned) == multiplied_score_earned):
				animation_time_frozen_timer += _delta
				if (animation_time_frozen_timer >= animation_freeze_time):
					Current_Animation_State = AnimationState.TweenTotalScore
					return
			
			tweening_score_just_earned += max(25*_delta,5* (multiplied_score_earned - tweening_score_just_earned) *_delta)
			tweening_score_just_earned = min(tweening_score_just_earned, multiplied_score_earned)
			text = """%s pts
			+%s pts""" %[int(tweening_total_score), int(tweening_score_just_earned)]
			
			
			
		AnimationState.TweenTotalScore:
			tweening_total_score += max(25*_delta,5* (ScoreManager.total_score - tweening_total_score) * _delta)
			tweening_total_score = min(tweening_total_score, ScoreManager.total_score)
			
			if (ScoreManager.score_just_earned == 0):
				text = """%s pts""" %[int(tweening_total_score)]
			else:
				text = """%s pts
				%s x %s""" %[int(tweening_total_score), ScoreManager.score_just_earned, ScoreManager.mult]
			
			if (floor(tweening_total_score) == ScoreManager.total_score):
				Current_Animation_State = AnimationState.Static
				
func multiply_score_just_earned(mult_score_earned: int):
	Current_Animation_State = AnimationState.MultiplyScoreJustEarned
	multiplied_score_earned = mult_score_earned
	animation_time_frozen_timer = 0

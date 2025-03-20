extends Node

var is_android: bool

# Use Android Studio Logcat for debugging!
func _ready() -> void:

    is_android = OS.has_feature("android")
        
    if(!is_android): return

    # Make variables for Java classes
    var Rect = JavaClassWrapper.wrap("android.graphics.Rect")
    var ArrayList = JavaClassWrapper.wrap("java.util.ArrayList")

    # Get the android view
    var android_runtime = Engine.get_singleton("AndroidRuntime")
    var view = android_runtime.getActivity().getWindow().getDecorView()

    # Set the entire screen to an exclusion rect
    var exclusion_rects = ArrayList.ArrayList()
    exclusion_rects.add(Rect.Rect(view.getLeft(), view.getTop(), view.getRight(), view.getBottom()))
    view.setSystemGestureExclusionRects(exclusion_rects)
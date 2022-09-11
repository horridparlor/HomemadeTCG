extends TouchScreenButton

const x_scale : int = 9

func reduce_touch_area(amount : int):
	scale.x = x_scale + amount / 10

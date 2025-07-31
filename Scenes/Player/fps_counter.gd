extends Label

var viewport_rid

func _ready() -> void:
	viewport_rid = get_viewport().get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(viewport_rid, true)

func _process(_delta: float) -> void:
	
	var frametime_cpu = snapped(RenderingServer.viewport_get_measured_render_time_cpu(viewport_rid) + RenderingServer.get_frame_setup_time_cpu(),0.01)
	var frametime_gpu = snapped(RenderingServer.viewport_get_measured_render_time_gpu(viewport_rid),0.01)
	text = "Render tCPU: " + str(frametime_cpu) + " ns, Render tGPU" + str(frametime_gpu) + " ns \n"
	text += "FPS:" + str(Performance.get_monitor(Performance.TIME_FPS)) + "\n"
	text += "tPhysics:" + str(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)) + "\n"

	

extends Node3D
class_name EngineMain

# Util
static func ratio(value: float, local_min: float, local_max: float) -> float:
	return clamp((value - local_min) / (local_max - local_min), 0, 1)



class Drivetrain extends Node:
	var gear: float = 0
	var clutch: float = 1.0
	var downShift: bool = false

	var gears: PackedFloat32Array = [3.4, 2.36, 1.85, 1.47, 1.24, 1.07]
	var final_drive: float = 3.44

	var theta: float = 0
	var omega: float = 0
	var prevTheta: float = 0
	var prevOmega: float = 0

	var theta_wheel: float = 0
	var omega_wheel: float = 0

	# Inertia of geartrain + drive shaft [kg m2] 
	var inertia: float = 0.1 + 0.05 # 0.5 * MR^2 
	var damping: float = 12
	var compliance: float = 0.01

	var shiftTime: float = 50

	var backfire_delay: float = 0.1

	signal shiftedUp()

	# TODO: lod config
	# func load_config(..)
	func _init() -> void:
		# procar config
		self.shiftTime = 100
		self.damping = 12

		self.theta = 0
		self.omega = 0
		self.prevTheta = 0
		self.prevOmega = 0
		self.theta_wheel = 0
		self.omega_wheel = 0

		self.gear = 0

	func integrate(delta: float) -> void:
		clutch = clamp(clutch, 0, 1)		
		prevTheta = theta

		theta += omega * delta

	func update(delta: float) -> void:
		prevOmega = omega

		var dTheta: float = (theta - prevTheta) / delta

		omega = dTheta

	func solvePos(engine: SimulatedEngine, h: float) -> void:
		# var compliance = 0.01
		var c = engine.theta - theta
		var corr1 = getCorrection(c, h, compliance)
		theta += corr1 * sign(c)
	
	func solveVel(engine: SimulatedEngine, h: float) -> void:
		var local_damping: float = damping

		if gear > 3:
			local_damping = damping * 0.75

		omega += (engine.omega - omega) * local_damping * h
	
	func getCorrection(corr: float, h: float, local_compliance: float = 0) -> float:
		var w: float = corr * corr * 1 / inertia # idk? - originl author

		var dlambda: float = -corr / (w + local_compliance / h / h)
		
		return corr * -dlambda
	
	func getFinalDriveRatio() -> float:
		return final_drive
	
	func getGearRatio(local_gear: float = -1) -> float:
		if local_gear == -1:
			local_gear = gear

		local_gear = clamp(local_gear, 0, gears.size())

		var ratio: float = gears[local_gear - 1] if local_gear > 0 else 0.0

		return ratio
	
	func getTotalGearRatio() -> float:
		return getGearRatio() * getFinalDriveRatio()
	
	func changeGear(local_gear: float) -> void:

		var prevRatio: float = getGearRatio(self.gear)
		var nextRatio: float = getGearRatio(local_gear)
		var ratioRatio: float = nextRatio / prevRatio if prevRatio > 0 else 0.0

		if ratioRatio == 1: return

		# Neutral
		gear = 0 

		if ratioRatio > 1:
			downShift = true

		# Engage next gear
		# setTimeout(() => {
		# 	omega = omega * ratioRatio

		# 	gear = gear
		# 	gear = clamp(gear, 0, gears.length)
		# 	downShift = false

		# 	console.log('Changed', gear)

		# , shiftTime)
		get_tree().create_timer(shiftTime / 1000.0).timeout.connect(func() -> void:
			self.omega = self.omega * ratioRatio

			self.gear = local_gear
			self.gear = clamp(local_gear, 0, self.gears.size())
			self.downShift = false
		)
		if local_gear > self.gear:
			get_tree().create_timer(backfire_delay).timeout.connect(shiftedUp.emit)

	
	func nextGear() -> void:
		changeGear(gear + 1)

	func prevGear() -> void:
		changeGear(gear - 1)


class SimulatedEngine extends Node:

	# Base settings
	var idle: float = 1000
	var limiter: float = 0
	var soft_limiter: float = 0
	var rpm: float = idle

	# Inertia of engine + clutch and flywheel [kg/m2]
	var inertia: float = 0.2 + 0.8 # 0.5 * MR^2

	# Limiter
	var limiter_ms: float = 0 # Hard cutoff time
	var limiter_delay: float = 100 # Time while feeding throttle back in
	var last_limiter: float = 0

	# Torque curves
	var torque: float = 400 # Nm
	var engine_braking: float = 200
	var throttle: float = 0

	# Integration state
	var theta: float = 0
	var alpha: float = 0
	var omega: float = 0

	var prevTheta: float = 0
	var prevOmega: float = 0
	var dTheta: float = 0

	# Precalculated values
	var omega_max: float = 0

	var _DEBUG_TEXT: String

	var output_torque: float = 0.0

	# TODO:
	# init()
	func _init() -> void:
		self.omega_max = (2 * PI * self.limiter) / 60.0

		limiter = 9000
		soft_limiter = 9000
		limiter_ms = 150

		# this is set in procar
		# self.soft_limiter = config?.soft_limiter ?? self.limiter * 0.99

		self.theta = 0
		self.alpha = 0
		self.omega = 0
		
		self.prevTheta = 0
		self.prevOmega = 0
		self.dTheta = 0
		self.rpm = 0
	
	func integrate(load_inertia: float, time: float, delta: float) -> void:
		# Limiter
		if self.rpm >= self.soft_limiter:
			var ratio2: float = EngineMain.ratio(self.rpm, self.soft_limiter, self.limiter)
			self.throttle *= pow(1 - ratio2, 0.05)
		
		if self.rpm >= self.limiter:
			self.last_limiter = time
		
		if time - self.last_limiter >= self.limiter_ms:
			var t: float = time - self.last_limiter
			var r: float = EngineMain.ratio(t, 0, self.limiter_delay)
			self.throttle *= r
		else:
			self.throttle = 0.0
		

		# Idle adjustment
		var idleTorque: float = 0
		if self.throttle < 0.1 && self.rpm < self.idle * 1.5:
			var rIdle: float = EngineMain.ratio(self.rpm, self.idle * 0.9, self.idle)
			idleTorque = (1-rIdle) * self.engine_braking * 10
		
		
		# Torque
		var t1 = pow(self.throttle, 1.2) * self.torque
		var t2 = pow(1-self.throttle, 1.2) * self.engine_braking
		var local_torque = t1 - t2 + idleTorque

		output_torque = local_torque
		# print("Output torque: ", output_torque)

		# Integrate
		var inertia_i = load_inertia + self.inertia
		var dAlpha = local_torque / inertia_i
		
		self.prevTheta = self.theta
		self.omega += dAlpha * delta
		self.theta += self.omega * delta
		self.dTheta = self.omega * delta

		# self.omega = clamp(self.omega, 0, self.omega_max)
		self.rpm = (60 * self.omega) / 2 * PI

	func update(h: float) -> void:
		self.prevOmega = self.omega

		var local_dTheta: float = (self.theta - self.prevTheta) / h

		self.omega = local_dTheta
	
	func solvePos(drivetrain: Drivetrain, h: float) -> void:
		if is_equal_approx(drivetrain.gear, 0):
			return
		var compliance: float = max(0.0006 - 0.00015 * drivetrain.gear, 0.00007)
		var c: float = drivetrain.theta - self.theta
		var corr1: float = self.getCorrection(c, h, compliance)
		self.theta += corr1 * sign(c)
	
	func solveVel(drivetrain: Drivetrain, h: float) -> void:
		var damping: float = 12
		if drivetrain.gear > 3:
			damping = 9

		self.omega += (drivetrain.omega - self.omega) * damping * h
	
	func getCorrection(corr: float, h: float, local_compliance: float = 0) -> float:
		var w: float = corr * corr * 1/self.inertia # idk?
		var dlambda: float = -corr / (w + local_compliance / h / h)
		return corr * -dlambda
	
	# TODO:
	# func applySounds(..)

		# sounds: {

		# on_high: {
		#	 source: 'audio/procar/on_midhigh {eed64b99-c102-43cf-834e-4e4cafa68fdc}.wav',
		#	 rpm: 8000,
		# },
		# on_low: {
		#	 source: 'audio/procar/on_low {0477930f-2954-45ee-8ac4-db4867fe1749}.wav',
		#	 rpm: 3200,
		# },
		# off_high: {
		#	 source: 'audio/procar/off_midhigh {092a60f7-c729-4d2c-979e-2e766ba42c6c}.wav',
		#	 rpm: 8430,
		#	 volume: 1.3
		# },
		# off_low: {
		#	 source: 'audio/procar/off_lower {05f28dcf-8251-4e6a-bc40-8099139ef81e}.wav',
		#	 rpm: 3400,
		#	 volume: 1.3
		# },
		# limiter: {
		#	 source: 'audio/limiter.wav',
		#	 volume: 0.5,
		#	 rpm: 8000,
		# },

	func getFactorFromDetune(detuneValue: float) -> float:
		return pow(2, detuneValue / 1200)

	func applySounds(audio: EngineAudioManager, gearRatio: float = 0, rpmPitchFactor: float = 0.2) -> void:
		
		# const { gain1: high, gain2: low } = AudioManager.crossFade(this.rpm, 3000, 6500);
		var high_low = EngineAudioManager.crossFade(self.rpm, 3000, 6500)
		# const { gain1: on, gain2: off } = AudioManager.crossFade(this.throttle, 0, 1);
		var on_off = EngineAudioManager.crossFade(self.throttle, 0, 1)

		var on: float = on_off.gain1
		var off: float = on_off.gain2
		var high: float = high_low.gain1
		var low: float = high_low.gain2

		# const limiterGain = ratio(this.rpm, this.soft_limiter * 0.93, this.limiter);
		var limiterGain = EngineMain.ratio(self.rpm, self.soft_limiter * 0.93, self.limiter)

		# const applySample = (key: string, gain: number, applyPitch: boolean = true) => {
		#	 if (!samples[key]) {
		#		 return;
		#	 }

		#	 if (applyPitch) {
		#		 samples[key].audio.detune.value = this.getRPMPitch(samples[key].rpm, rpmPitchFactor);
		#	 }

		#	 samples[key].gain.gain.value = gain * samples[key].volume;
		# };
		var applySample: Callable = func(sample: EngineSampler, gain: float, applyPitch: bool = true) -> void:
			if sample == null:
				return
			
			if applyPitch:
				sample.pitch_scale = getFactorFromDetune(self.getRPMPitch(sample.rpm, rpmPitchFactor))
			
			_DEBUG_TEXT += "%s: %.2f, %.2fdb\n" % [sample.name, gain * sample.volume, linear_to_db(gain * sample.volume)]
			sample.volume_db = linear_to_db(gain * sample.volume)

		_DEBUG_TEXT = ""
		applySample.call(audio.on_low, on * low)
		applySample.call(audio.off_low, off * low)
		applySample.call(audio.on_high, on * high)
		applySample.call(audio.off_high, off * high)
		applySample.call(audio.limiter, limiterGain, false)

		# TRANSMISSION 
		# if (samples['tranny_on'] && samples['tranny_off']) {
		# 	samples['tranny_on'].audio.detune.value = this.rpm * gearRatio * 0.05 - 100;
		# 	samples['tranny_on'].gain.gain.value = gearRatio > 0 ? on * samples['tranny_on'].volume : 0;
			
		# 	samples['tranny_off'].audio.detune.value = this.rpm * gearRatio * 0.035 - 800;
		# 	samples['tranny_off'].gain.gain.value = gearRatio > 0 ? off * samples['tranny_off'].volume : 0;
		# }

	func getRPMPitch(sampleRPM: float, rpmPitchFactor: float) -> float:
		return (self.rpm - sampleRPM) * rpmPitchFactor


class SimulatedVehicle extends Node:

	# TODO: audio
	var audio: EngineAudioManager

	var engine: SimulatedEngine = SimulatedEngine.new()
	var drivetrain: Drivetrain = Drivetrain.new()

	var mass: float = 700

	var velocity: float = 0
	var wheel_rpm: float = 0
	var wheel_omega: float = 0
	var wheel_radius: float = 0.375

	func _init() -> void: # configuration: EngineConfiguration
		# if self.audio:
		# 	self.audio.dispose()

		# self.engine.init(configuration.engine)
		# self.drivetrain.init(configuration.drivetrain)

		# self.audio = AudioManager.new()
		
		# await self.audio.init(configuration.sounds)
		pass

	func update(time: float, dt: float) -> void:

		# Simulation loop
		var subSteps: float = 20
		var h: float = dt / subSteps

		var inertia_i = self.getLoadInertia() * 0.00

		for i in subSteps:
			self.engine.integrate(inertia_i, time + dt * i, h)
			self.drivetrain.integrate(h)

			self.engine.solvePos(self.drivetrain, h)
			self.drivetrain.solvePos(self.engine, h)
			
			self.engine.update(h)
			self.drivetrain.update(h)

			self.engine.solveVel(self.drivetrain, h)
			self.drivetrain.solveVel(self.engine, h)

		# if self.audio.ctx:
		# 	self.engine.applySounds(self.audio.samples, self.drivetrain.gear)
		if audio != null:
			engine.applySounds(audio, drivetrain.gear)
	
	func getLoadInertia() -> float:
		if is_equal_approx(self.drivetrain.gear, 0):
			return 0
			
		var gearRatio: float = self.drivetrain.getGearRatio()
		var totalGearRatio: float = self.drivetrain.getTotalGearRatio()

		# Moment of inertia - I = mr^2
		var I_veh: float = self.mass * pow(self.wheel_radius, 2)
		var I_wheels: float = 4 * 12.0 * pow(self.wheel_radius, 2)

		# Adjust inertia for gear ratio
		var I1: float = I_veh / pow(totalGearRatio, 2) 
		var I2: float = I_wheels / pow(totalGearRatio, 2) 
		var I3: float = self.drivetrain.inertia / pow(gearRatio, 2) 
		var I: float = I1 + I2 + I3

		return I


class EngineConfiguration:
	var engine: SimulatedEngine
	var drivetrain: Drivetrain
	# sounds

@onready var engine_audio_manager: EngineAudioManager = %EngineAudioManager

# var guis: Array[EngineGUI] ->

var drivetrain: Drivetrain
var engine: SimulatedEngine
var vehicle: SimulatedVehicle

# @export
# var gear_speed: PackedFloat32Array = [
# 	5.0, # idle
# ]
# func set_gear(speed: float) -> void:
# 	for i in gear_speed.size():
# 		if speed <= gear_speed[i]:
# 			drivetrain.changeGear(i)
# 			return

func _ready() -> void:
	engine = SimulatedEngine.new()
	drivetrain = Drivetrain.new()
	add_child(drivetrain)
	vehicle = SimulatedVehicle.new()
	vehicle.engine = engine
	vehicle.drivetrain = drivetrain
	vehicle.audio = engine_audio_manager

	drivetrain.shiftedUp.connect(engine_audio_manager.play_backfire)

	engine_audio_manager.start_all_sounds()

	set_physics_process(true)

var accelerate_pressed: bool = false
var brake_pressed: bool = false
var gear_up_pressed: bool = false
var gear_down_pressed: bool = false

func _physics_process(delta: float) -> void:
	# accelerate_pressed = Input.is_action_pressed("accel")
	# brake_pressed = Input.is_action_pressed("brake")
	# gear_up_pressed = Input.is_action_just_pressed("gear_up")
	# gear_down_pressed = Input.is_action_just_pressed("gear_down")


	if gear_up_pressed:
		drivetrain.nextGear()
		print("shifting up")
	if gear_down_pressed:
		drivetrain.prevGear()
		print("shifting down")

	if drivetrain.downShift:
		engine.throttle = 0.8 # Rev matching
	else:
		if accelerate_pressed:
			engine.throttle = clamp(engine.throttle + 10. * delta, 0, 1)
		else:
			engine.throttle = clamp(engine.throttle - 10. * delta, 0, 1)
		
		

	if brake_pressed:
		# drivetrain.omega -= 0.3 # Brakes original
		drivetrain.omega -= 30 * delta # Brakes
		

	vehicle.update(Time.get_ticks_msec(), delta)
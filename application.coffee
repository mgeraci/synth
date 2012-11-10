$(->
  init()
  $('button').click ->
    adsr()
)

init = ()->
  try
    @context = new webkitAudioContext()
  catch error
    alert('Web Audio API is not supported in this browser')

  oscillator() if @context

oscillator = ->
  osc = @context.createOscillator()
  @gainnode = @context.createGainNode()
  osc.connect(@gainnode)

  @gainnode.gain.value = 0

  #Sine wave = 0
  #Square wave = 1
  #Sawtooth wave = 2
  #Triangle wave = 3
  #osc.type = 0

  @gainnode.connect(context.destination) # Connect to speakers
  osc.noteOn(0) # Start generating sound immediately

  osc.frequency.value = 500

  setTimeout(->
    osc.frequency.value = 900
  , 500)

adsr = (a = 80, d = 100, s = 500, sl = 0.5, r = 100)->
  grain = 10
  output = 0

  # you should get from start to end in a ms, with steps of @grain
  aNumberOfSteps = a / grain
  aSizeOfSteps = 1 / aNumberOfSteps

  dNumberOfSteps = d / grain
  dSizeOfSteps = (1 - sl) / dNumberOfSteps

  rNumberOfSteps = r / grain
  rSizeOfSteps = sl / rNumberOfSteps

  # attack
  for i in [0...aNumberOfSteps]
    setTimeout(=>
      output += aSizeOfSteps
      @gainnode.gain.value = output
    , i * grain)

  # decay
  setTimeout(=>
    for i in [0...dNumberOfSteps]
      setTimeout(=>
        output -= dSizeOfSteps
        @gainnode.gain.value = output
      , i * grain)
  , a)

  # sustain doesn't change the volume level, so nothing happens here

  # release
  setTimeout(=>
    for i in [0...rNumberOfSteps]
      setTimeout(=>
        output -= rSizeOfSteps
        @gainnode.gain.value = output
      , i * grain)
  , a + d + s)

  # and set to 0 at the end
  setTimeout(=>
    output = 0
    @gainnode.gain.value = output
  , a + d + s + r)

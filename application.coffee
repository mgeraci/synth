$(->
  init()

  $('body').click ->
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

adsr = (a = 80, d = 30, s = 100, sl = 0.7, r = 20)->
  @grain = 10

  # you should get from 0 to 1 in a ms, with steps of @grain
  numberOfSteps = a / @grain
  sizeOfSteps = 1 / numberOfSteps
  output = 0

  # attack
  for i in [0...numberOfSteps]
    setTimeout(=>
      output += sizeOfSteps
      console.log output
    , i * @grain)

  # decay
  setTimeout(=>
    console.log 'start d'
  , a)

  # sustain
  setTimeout(=>
    console.log 'start d'
  , a + d)

  # release
  setTimeout(=>
    console.log 'start r'
  , a + d + s)

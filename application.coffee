$(->
  init()
  $('button').click ->
    adsr()
)

init = ()->
  try
    @context = new webkitAudioContext()
  catch error
    alert('Web Audio API is not supported in your browser')

  if @context
    oscillator()
    controlWatchers()
    setDefaults()

controlWatchers = ->
  $('#attack').on 'change', (e)=>
    @a = (500 * $(e.target).val()) / 100

  $('#decay').on 'change', (e)=>
    @d = (500 * $(e.target).val()) / 100

  $('#sustain').on 'change', (e)=>
    @s = (500 * $(e.target).val()) / 100

  $('#release').on 'change', (e)=>
    @r = (500 * $(e.target).val()) / 100

  $('#sustain-level').on 'change', (e)=>
    @sl = $(e.target).val() / 100

setDefaults = ->
  $('#attack').val(10).trigger('change')
  $('#decay').val(20).trigger('change')
  $('#sustain').val(100).trigger('change')
  $('#release').val(60).trigger('change')
  $('#sustain-level').val(50).trigger('change')

# create an oscillator, connect it, and turn it on
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

# adsr stands for attack, decay, sustain, release
adsr = ->
  grain = 1 # frequency of steps
  output = 0 # let's start at 0

  # clear any timeouts that exist from other notes
  clearTimeout(@aInnerTimeout) if @aInnerTimeout?
  clearTimeout(@dTimeout) if @dTimeout?
  clearTimeout(@dInnerTimeout) if @dInnerTimeout?
  clearTimeout(@rTimeout) if @rTimeout?
  clearTimeout(@rInnerTimeout) if @rInnerTimeout?
  clearTimeout(@endTimeout) if @endTimeout?

  # you should get from start to end in a ms, with steps of @grain
  aNumberOfSteps = @a / grain
  aSizeOfSteps = 1 / aNumberOfSteps

  dNumberOfSteps = @d / grain
  dSizeOfSteps = (1 - @sl) / dNumberOfSteps

  rNumberOfSteps = @r / grain
  rSizeOfSteps = @sl / rNumberOfSteps

  # attack
  for i in [0...aNumberOfSteps]
    @aInnerTimeout = setTimeout(=>
      output += aSizeOfSteps
      @gainnode.gain.value = output
    , i * grain)

  # decay
  @dTimeout = setTimeout(=>
    for i in [0...dNumberOfSteps]
      @dInnerTimeout = setTimeout(=>
        output -= dSizeOfSteps
        @gainnode.gain.value = output
      , i * grain)
  , @a)

  # sustain doesn't change the volume level, so nothing happens here

  # release
  @rTimeout = setTimeout(=>
    for i in [0...rNumberOfSteps]
      @rInnerTimeout = setTimeout(=>
        output -= rSizeOfSteps
        @gainnode.gain.value = output
      , i * grain)
  , @a + @d + @s)

  # and set to 0 at the end
  @endTimeout = setTimeout(=>
    output = 0
    @gainnode.gain.value = output
  , @a + @d + @s + @r + grain * 2)

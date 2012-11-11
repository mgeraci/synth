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
    keyboard()

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

  #Sine wave = 0
  #Square wave = 1
  #Sawtooth wave = 2
  #Triangle wave = 3
  $('#wave').on 'change', (e)=>
    span = $(e.target).siblings('span')
    switch parseInt $(e.target).val()
      when 0
        wave = 0
        span.text('sine')
      when 25
        wave = 1
        span.text('square')
      when 50
        wave = 2
        span.text('saw')
      when 75
        wave = 3
        span.text('triangle')

    @osc.type = wave

setDefaults = ->
  $('#attack').val(10).trigger('change')
  $('#decay').val(20).trigger('change')
  $('#sustain').val(100).trigger('change')
  $('#release').val(60).trigger('change')
  $('#sustain-level').val(50).trigger('change')

# create an oscillator, connect it, and turn it on
oscillator = ->
  @osc = @context.createOscillator()
  @gainnode = @context.createGainNode()
  @osc.connect(@gainnode)
  @gainnode.gain.value = 0

  @gainnode.connect(context.destination) # Connect to speakers
  @osc.noteOn(0) # Start generating sound immediately

  @osc.frequency.value = 500

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

note = (freq)->
  @osc.frequency.value = freq
  adsr()

# bind keys to frequencies using mousetrap
keyboard = ->
  notes = [
    ['z',523.25],
    ['s',554.37],
    ['x',587.33],
    ['d',622.25],
    ['c',659.26],
    ['v',698.46],
    ['g',739.99],
    ['b',783.99],
    ['h',830.61],
    ['n',880],
    ['j',932.33],
    ['m',987.77],

    [',',1046.5],
    ['l',1108.73],
    ['.',1174.66],
    [';',1244.51],
    ['/',1318.51],

    ['q',1046.5],
    ['2',1108.73],
    ['w',1174.66],
    ['3',1244.51],
    ['e',1318.51],
    ['r',1396.91],
    ['5',1479.98],
    ['t',1567.98],
    ['6',1661.22],
    ['y',1760],
    ['7',1864.66],
    ['u',1975.53],

    ['i',2093.00],
    ['9',2217.46],
    ['o',2349.32],
    ['0',2489.02],
    ['p',2637.02],
    ['[',2793.83],
    ['=',2959.96],
    [']',3135.96]
  ]

  # bind a keyevent for each note
  $.each notes, (k,v)->
    # change numbers and chars to text
    key = v[0]
    switch key
      when ',' then key = 'comma'
      when '.' then key = 'period'
      when ';' then key = 'semicolon'
      when '/' then key = 'slash'
      when '2' then key = 'two'
      when '3' then key = 'three'
      when '5' then key = 'five'
      when '6' then key = 'six'
      when '7' then key = 'seven'
      when '0' then key = 'zero'
      when '[' then key = 'leftbracket'
      when '=' then key = 'equals'
      when ']' then key = 'rightbracket'

    # attach click events to the keyboard to trigger notes
    $("##{key}").click (e)->
      e.preventDefault()
      note v[1]

    # keydown
    Mousetrap.bind v[0], ->
      # play the note
      note v[1]

      # highlight the note
      $("##{key}").addClass('active')

    # keyup
    Mousetrap.bind(v[0], ->
      # unhighlight the note
      $("##{key}").removeClass('active')
    , 'keyup')

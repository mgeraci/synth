// Generated by CoffeeScript 1.3.3
(function() {
  var adsr, controlWatchers, init, keyboard, note, oscillator, setDefaults;

  $(function() {
    init();
    return $('button').click(function() {
      return adsr();
    });
  });

  init = function() {
    try {
      this.context = new webkitAudioContext();
    } catch (error) {
      alert('Web Audio API is not supported in your browser');
    }
    if (this.context) {
      oscillator();
      controlWatchers();
      setDefaults();
      return keyboard();
    }
  };

  controlWatchers = function() {
    var _this = this;
    $('#attack').on('change', function(e) {
      return _this.a = (500 * $(e.target).val()) / 100;
    });
    $('#decay').on('change', function(e) {
      return _this.d = (500 * $(e.target).val()) / 100;
    });
    $('#sustain').on('change', function(e) {
      return _this.s = (500 * $(e.target).val()) / 100;
    });
    $('#release').on('change', function(e) {
      return _this.r = (500 * $(e.target).val()) / 100;
    });
    $('#sustain-level').on('change', function(e) {
      return _this.sl = $(e.target).val() / 100;
    });
    return $('#wave').on('change', function(e) {
      var span, wave;
      span = $(e.target).siblings('span');
      switch (parseInt($(e.target).val())) {
        case 0:
          wave = 0;
          span.text('sine');
          break;
        case 25:
          wave = 1;
          span.text('square');
          break;
        case 50:
          wave = 2;
          span.text('saw');
          break;
        case 75:
          wave = 3;
          span.text('triangle');
      }
      return _this.osc.type = wave;
    });
  };

  setDefaults = function() {
    $('#attack').val(10).trigger('change');
    $('#decay').val(20).trigger('change');
    $('#sustain').val(100).trigger('change');
    $('#release').val(60).trigger('change');
    return $('#sustain-level').val(50).trigger('change');
  };

  oscillator = function() {
    this.osc = this.context.createOscillator();
    this.gainnode = this.context.createGainNode();
    this.osc.connect(this.gainnode);
    this.gainnode.gain.value = 0;
    this.gainnode.connect(context.destination);
    this.osc.noteOn(0);
    return this.osc.frequency.value = 500;
  };

  adsr = function() {
    var aNumberOfSteps, aSizeOfSteps, dNumberOfSteps, dSizeOfSteps, grain, i, output, rNumberOfSteps, rSizeOfSteps, _i,
      _this = this;
    grain = 1;
    output = 0;
    if (this.aInnerTimeout != null) {
      clearTimeout(this.aInnerTimeout);
    }
    if (this.dTimeout != null) {
      clearTimeout(this.dTimeout);
    }
    if (this.dInnerTimeout != null) {
      clearTimeout(this.dInnerTimeout);
    }
    if (this.rTimeout != null) {
      clearTimeout(this.rTimeout);
    }
    if (this.rInnerTimeout != null) {
      clearTimeout(this.rInnerTimeout);
    }
    if (this.endTimeout != null) {
      clearTimeout(this.endTimeout);
    }
    aNumberOfSteps = this.a / grain;
    aSizeOfSteps = 1 / aNumberOfSteps;
    dNumberOfSteps = this.d / grain;
    dSizeOfSteps = (1 - this.sl) / dNumberOfSteps;
    rNumberOfSteps = this.r / grain;
    rSizeOfSteps = this.sl / rNumberOfSteps;
    for (i = _i = 0; 0 <= aNumberOfSteps ? _i < aNumberOfSteps : _i > aNumberOfSteps; i = 0 <= aNumberOfSteps ? ++_i : --_i) {
      this.aInnerTimeout = setTimeout(function() {
        output += aSizeOfSteps;
        return _this.gainnode.gain.value = output;
      }, i * grain);
    }
    this.dTimeout = setTimeout(function() {
      var _j, _results;
      _results = [];
      for (i = _j = 0; 0 <= dNumberOfSteps ? _j < dNumberOfSteps : _j > dNumberOfSteps; i = 0 <= dNumberOfSteps ? ++_j : --_j) {
        _results.push(_this.dInnerTimeout = setTimeout(function() {
          output -= dSizeOfSteps;
          return _this.gainnode.gain.value = output;
        }, i * grain));
      }
      return _results;
    }, this.a);
    this.rTimeout = setTimeout(function() {
      var _j, _results;
      _results = [];
      for (i = _j = 0; 0 <= rNumberOfSteps ? _j < rNumberOfSteps : _j > rNumberOfSteps; i = 0 <= rNumberOfSteps ? ++_j : --_j) {
        _results.push(_this.rInnerTimeout = setTimeout(function() {
          output -= rSizeOfSteps;
          return _this.gainnode.gain.value = output;
        }, i * grain));
      }
      return _results;
    }, this.a + this.d + this.s);
    return this.endTimeout = setTimeout(function() {
      output = 0;
      return _this.gainnode.gain.value = output;
    }, this.a + this.d + this.s + this.r + grain * 2);
  };

  note = function(freq) {
    this.osc.frequency.value = freq;
    return adsr();
  };

  keyboard = function() {
    var notes;
    notes = [['z', 523.25], ['s', 554.37], ['x', 587.33], ['d', 622.25], ['c', 659.26], ['v', 698.46], ['g', 739.99], ['b', 783.99], ['h', 830.61], ['n', 880], ['j', 932.33], ['m', 987.77], [',', 1046.5], ['l', 1108.73], ['.', 1174.66], [';', 1244.51], ['/', 1318.51], ['q', 1046.5], ['2', 1108.73], ['w', 1174.66], ['3', 1244.51], ['e', 1318.51], ['r', 1396.91], ['5', 1479.98], ['t', 1567.98], ['6', 1661.22], ['y', 1760], ['7', 1864.66], ['u', 1975.53], ['i', 2093.00], ['9', 2217.46], ['o', 2349.32], ['0', 2489.02], ['p', 2637.02], ['[', 2793.83], ['=', 2959.96], [']', 3135.96]];
    return $.each(notes, function(k, v) {
      return Mousetrap.bind(v[0], function() {
        var key;
        note(v[1]);
        key = v[0];
        switch (key) {
          case ',':
            key = 'comma';
            break;
          case '.':
            key = 'period';
            break;
          case ';':
            key = 'semicolon';
            break;
          case '/':
            key = 'slash';
            break;
          case '2':
            key = 'two';
            break;
          case '3':
            key = 'three';
            break;
          case '5':
            key = 'five';
            break;
          case '6':
            key = 'six';
            break;
          case '7':
            key = 'seven';
            break;
          case '0':
            key = 'zero';
            break;
          case '[':
            key = 'leftbracket';
            break;
          case '=':
            key = 'equals';
            break;
          case ']':
            key = 'rightbracket';
        }
        $("#" + key).addClass('active');
        return setTimeout(function() {
          return $("#" + key).removeClass('active');
        }, 100);
      });
    });
  };

}).call(this);

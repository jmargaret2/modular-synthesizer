s.boot;
MIDIClient.init(1, 1); // 1 input 1 output
MIDIIn.connectAll;
// MIDIClient.disposeClient; // cleans up MIDIClient


MIDIdef.noteOn(\print, {arg val, num, chan, src; [src,chan, num, val].postln}); // print associated info when a note is pressed
//
// // https://github.com/sensestage/interface2instrument
MIDIFunc.noteOn( { arg ...args; "noteon\t".post; args.postln; } );
MIDIFunc.noteOff( { arg ...args; "noteoff\t".post; args.postln; } );
MIDIFunc.touch( { arg ...args; "touch\t".post; args.postln; } );
MIDIFunc.bend( { arg ...args; "bend\t".post; args.postln; } );
MIDIFunc.program( { arg ...args; "program\t".post; args.postln; } );

// MIDIFunc.allFuncProxies.do{ |it| it.do{ |jt| if ( jt.isKindOf( MIDIFunc ) ){ jt.free } } }; -> remove all MIDI functions

/*MIDIFunc.trace;
// to turn tracing off:
MIDIFunc.trace( false );*/
/*
[8454144, 0, 60, 127 ] -> example [source as INT, channel notes were sent on (indexed zero), note itself, velocity of note]
*/

// create a MIDI out connection:
m = MIDIOut(0, MIDIClient.destinations.at(0).uid);
// connect SC first port with device's
m.connect(1);

(
SynthDef("sinewave", {arg freq=440, vol=0.5;
  Out.ar(0, SinOsc.ar(freq,0,vol))
  }).send(s);
)
(
var onNote, offNote, quitNotes;

var notes = Array.newClear(128);

onNote = MIDIFunc.noteOn({ |src, chan, num, veloc|
	notes[num] = Synth("noteOn", [\freq, num.midicps,
        \amp, veloc * 0.00315]);
});

offNote = MIDIFunc.noteOff({ |src, chan, num, veloc|
    notes[num].release;
});
)


(
var awindow, volumeSlider, pitchKnob, statusButton, bpmSlider, bpm, legatoButton, onNote;
var notes = Array.newClear(128);


onNote = MIDIFunc.noteOn({ |src, chan, num, veloc|
	notes[num] = Synth("noteOn", [\freq, num.midicps,
        \amp, veloc * 0.00315]);
});

/*var tempo = TempoClock.value(1); // init value = 60 BPM
tempo.value;
tempo.tempo_.value;*/

// BPM for different types of music: https://www.gemtracks.com/guides/view.php?title=music-genres-and-their-typical-bpms&id=823
// need to cite this site in the paper
// 24 BPM: Largissimo
// 162-200 BPM: Presto
// 201+: Prestissimo

/*
Must have modules in synth:
- [x] pitch bender
- [x] volume control
- [] bpm slider BPM here is meausred BPS
- [] legato switch - sustain button
- [] arpeggiator
- [] delay effect
*/

/*
Nice to have modules in synth:
- [] aftertouch
- [] generator
- [] step sequencer
- [] distortion effect
- [] reverb effect
- [] stutter effect
*/

awindow = FlowView.new(windowTitle:"A Modular Synthesizer");
volumeSlider = EZSlider(awindow, label:"Volume",controlSpec:[0,100], action:{|mv| x.set("vol",mv.value)}, initVal:50);
pitchKnob = EZKnob(awindow, label:"Pitch",controlSpec:\freq, action:{|noteOn| x.set("freq",noteOn.value)}, initVal:440);
bpmSlider = EZPopUpMenu(awindow, label:"BPM", controlSpec:[0.4, 4.16666667], action:{|mbpm| x.set("bpm", bpm.value)}, initVal:0.4); // 24-250 range of BPM OR 0.4, 4,16666667 BPS/HZ

statusButton = Button(awindow, Rect(20,20, 50, 25))
  .states_([["Off", Color.black, Color.grey],
    ["On",Color.black,Color.yellow]])
  .action_({ arg vbutton;
     if(vbutton.value==1,
      {(
		x=SynthDef("sinewave");
        volumeSlider.value = 50;
        pitchKnob.value = 440;
		bpmSlider.value = 0.4;
         )}
     ,
    {x.free});
    });

statusButton.value=0;
// quitNotes = { onNote.free; offNote.free; }
// when done
)

MIDIdef.freeAll;
s.quit();
/*MIDIClient.init(1, 1); // 1 input 1 output
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
)*/

// BPM for different types of music: https://www.gemtracks.com/guides/view.php?title=music-genres-and-their-typical-bpms&id=823
// need to cite this site in the paper

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

(
/*s.boot;
MIDIClient.init(1, 1); // 1 input 1 output
MIDIIn.connectAll;*/
var allNotes = Array.newClear(128);
var onNote;
var awindow, volumeSlider, pitchKnob, statusButton, bpmDropDown, legatoButton, applyButton, arpeggiator, bpmViewer, bpmDictionaryValues, currentBpmValue;


onNote = MIDIFunc.noteOn({ |src, chan, num, veloc|
	allNotes[num] = Synth("noteOn", [\freq, num.midicps,
        \amp, veloc * 0.00315]);
});

awindow = FlowView.new(windowTitle:"A Modular Synthesizer");
volumeSlider = EZSlider(awindow, label:"Volume",controlSpec:[0,100], action:{|mv| x.set("vol",mv.value)}, initVal:50);
pitchKnob = EZKnob(awindow, label:"Pitch",controlSpec:\freq, action:{|mn| x.set("freq",mn.value)}, initVal:440);
bpmDropDown = PopUpMenu(awindow, Rect(20, 20, 120, 20));

bpmDropDown.items = [
	"Select a Genre", "Cha Cha", "Charleston", "Foxtrot", "Hip-Hop", "House", "Jazz/Funk", "Jive", "Metal", "Paso Doble", "Pop", "Quickstep", "Rock", "Rumba", "R&B", "Salsa", "Samba", "Tango", "Waltz", "Viennese Waltz"
];
bpmViewer = TextView.new(awindow, Rect(45, 70, 100, 20));

bpmDictionaryValues = Dictionary.new(20);
bpmDictionaryValues.put(0, 0);
bpmDictionaryValues.put(1, 128);
bpmDictionaryValues.put(2, 290);
bpmDictionaryValues.put(3, 120);
bpmDictionaryValues.put(4, 115);
bpmDictionaryValues.put(5, 135);
bpmDictionaryValues.put(6, 125);
bpmDictionaryValues.put(7, 184);
bpmDictionaryValues.put(8, 160);
bpmDictionaryValues.put(9, 124);
bpmDictionaryValues.put(10, 130);
bpmDictionaryValues.put(11, 208);
bpmDictionaryValues.put(12, 140);
bpmDictionaryValues.put(13, 108);
bpmDictionaryValues.put(14, 80);
bpmDictionaryValues.put(15, 300);
bpmDictionaryValues.put(16, 105);
bpmDictionaryValues.put(17, 66);
bpmDictionaryValues.put(18, 90);
bpmDictionaryValues.put(19, 180);


/*bpmSlider = EZPopUpMenu(awindow, label:"BPM", controlSpec:[0.4, 4.16666667], action:{|mbpm| x.set("bpm", bpm.value)}, initVal:0.4); // 24-250 range of BPM OR 0.4, 4,16666667 BPS/HZ*/
legatoButton = Button(awindow, Rect(20, 20, 100, 25)).states_([["Sustain Off", Color.black, Color.gray],
	["Sustain On", Color.black, Color.yellow]]).action_({arg vbutton;
	if(vbutton.value==1,
		{(
			// make sure MIDI note is sustained until turned off
		)}
	);
});

applyButton = Button(awindow, Rect(20, 20, 100, 25)).states_([["Update BPM", Color.black, Color.clear]]).action_({arg vbutton;
	// apply changes from BPM drop down
	currentBpmValue = bpmDropDown.value;
	currentBpmValue = bpmDictionaryValues.at(currentBpmValue);
	bpmViewer.string = currentBpmValue;
});

statusButton = Button(awindow, Rect(20,20, 50, 25))
  .states_([["Off", Color.black, Color.grey],
    ["On",Color.black,Color.yellow]])
  .action_({ arg vbutton;
     if(vbutton.value==1,
      {(
		x=SynthDef("sinewave");
        volumeSlider.value = 50;
        pitchKnob.value = 440;
		/*bpmSlider.value = 0.4;*/
         )}
     ,
    {x.free});
    });

statusButton.value=0;
// applyButton.value=0;
// quitNotes = { onNote.free; offNote.free; }
// when done
)
//
// MIDIdef.freeAll;
// s.quit();
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
var snd, functions, b, waveformMenu, awindow, volumeSlider, pitchKnob, statusButton, bpmDropDown, legatoButton, applyButton, arpeggiator, bpmViewer, bpmDictionaryValues, currentBpmValue;
var w = Window.new.front;
waveformMenu = PopUpMenu(w, Rect(10, 10, 90, 20)).items_([
	"Sine wave", "Square wave", "Sawtooth wave", "Triangle wave", "Pulse wave"
]);

functions = [
	{ SinOsc.ar(440, 0) },
	{ Pulse.ar(440, 0.5) }, // square wave
	{ Saw.ar(440) },
	{ LFTri.ar(freq: 440.0) }, // triangle wave
	// TODO: find way to not hardcode pulse
	{ Pulse.ar(440, 0.1) } // pulse wave, typically cycles between 0 and 1, right now this is hardcoded
];

b = Button(w, Rect(110, 10, 180, 20)).states_([["Play off", Color.black, Color.grey],
    ["Play On",Color.black,Color.yellow]]).action_({ arg vbutton;
	if(vbutton.value==1,
		{(
			snd = functions.at(waveformMenu.value).play;
		)}
	)
});

w.front;

awindow = FlowView.new(windowTitle:"A Modular Synthesizer");
volumeSlider = EZSlider(awindow, label:"Volume", controlSpec:[0,100], action:{|mv| x.set("vol", mv.value)}, initVal:50);
pitchKnob = EZKnob(awindow, label:"Pitch", controlSpec:\freq, action:{|mn| x.set("freq", mn.value)}, initVal:440);
bpmDropDown = PopUpMenu(awindow, Rect(20, 20, 120, 20));

bpmDropDown.items = [
	"Select a Genre", "Cha Cha", "Charleston", "Foxtrot", "Hip-Hop", "House", "Jazz/Funk", "Jive", "Metal", "Paso Doble", "Pop", "Quickstep", "Rock", "Rumba", "R&B", "Salsa", "Samba", "Tango", "Waltz", "Viennese Waltz"
];
bpmViewer = StaticText.new(awindow, Rect(45, 70, 100, 20));

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

/*legatoButton = Button(awindow, Rect(20, 20, 100, 25)).states_([["Sustain Off", Color.black, Color.gray],
["Sustain On", Color.black, Color.yellow]]).action_({arg vbutton;
if(vbutton.value==1,
{(
// make sure MIDI note is sustained until turned off
)}
);.
});*/

applyButton = Button(awindow, Rect(20, 20, 100, 25)).states_([["Update BPM", Color.black, Color.clear]]).action_({arg vbutton;
	// apply changes to BPM values from BPM drop down
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
			x=Synth("sinewave");
			volumeSlider.value = 50;
			pitchKnob.value = 440;
			/*bpmSlider.value = 0.4;*/
		)},
		{x.free});
});

statusButton.value = 0;
// quitNotes = { onNote.free; offNote.free; }
// when done
)
//
// MIDIdef.freeAll;
// s.quit();
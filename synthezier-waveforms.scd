/*
Must have modules in synth:
- [x] pitch bender
- [x] volume control
- [] bpm slider BPM here is meausred BPS
- [] legato switch - sustain button
- [x] arpeggiator
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
var waveformMenu, awindow, volumeSlider, pitchKnob, statusButton, bpmDropDown, legatoButton, applyButton, arpeggiator, arpeggio, bpmViewer, currentBpmValue, bpmDictionaryValues, thirdFreq, fifthFreq;

var baseFrequency = 440; // A4

awindow = FlowView.new(windowTitle:"A Modular Synthesizer with Waveforms");

waveformMenu = PopUpMenu(awindow, Rect(10, 10, 130, 20));
waveformMenu.items = [
	"Sine wave", "Square wave", "Sawtooth wave", "Triangle wave", "Pulse wave"
];

switch(waveformMenu.value,
	0, {SynthDef("sinewave", {arg freq=440, vol=50; Out.ar(0, SinOsc.ar(freq, 0, vol))}).add;}, // sine wave
	1, {SynthDef("squarewave", {arg freq=440, vol=50; Out.ar(0, Pulse.ar(freq, 0, vol))}).add;}, // square wave
	2, {SynthDef("sawtoothwave", {arg freq=440, vol=50; Out.ar(0, Saw.ar(freq, 0, vol))}).add;}, // sawtooth wave
	3, {SynthDef("trianglewave", {arg freq=440, vol=50; Out.ar(0, LFTri.ar(freq, 0, vol))}).add;}, // triangle wave
	4, {SynthDef("pulsewave", {arg freq=440, vol=50; Out.ar(0, Pulse.ar(freq, 0.1, vol))}).add;} // pulse wave
);

/*waveformButton = Button(awindow, Rect(20,20, 130, 25))
.states_([["Update Waveform", Color.black, Color.clear]])
.action_({arg vbutton;
// apply changes to wave form type from dropdown

waveformMenu.item.postln;
});*/

/*functions = [
{ SinOsc.ar(440, 0) }, // sine wave
{ Pulse.ar(440, 0.5) }, // square wave
{ Saw.ar(440) }, // sawtooth wave
{ LFTri.ar(freq: 440.0) }, // triangle wave
// TODO: find way to not hardcode pulse
{ Pulse.ar(440, 0.1) } // pulse wave, typically cycles between 0 and 1, right now this is hardcoded
];*/

volumeSlider = EZSlider(awindow, label:"Volume", controlSpec:[0,100], action:{|mv| x.set("vol", mv.value)}, initVal:50);
pitchKnob = EZKnob(awindow, label:"Pitch", controlSpec:\freq, action:{|mn| x.set("freq", mn.value)}, initVal:440);

thirdFreq = (baseFrequency * 5) / 4;
Post << thirdFreq << " the third interval" << Char.nl;
fifthFreq = baseFrequency * 1.5;
Post << fifthFreq << " the fifth interval" << Char.nl;

Post << baseFrequency << " current note pitch" << Char.nl;

bpmDropDown = PopUpMenu(awindow, Rect(20, 20, 120, 20));

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

bpmDropDown.items = [
	"Select a Genre", "Cha Cha", "Charleston", "Foxtrot", "Hip-Hop", "House", "Jazz/Funk", "Jive", "Metal", "Paso Doble", "Pop", "Quickstep", "Rock", "Rumba", "R&B", "Salsa", "Samba", "Tango", "Waltz", "Viennese Waltz"
];

/*switch(bpmDropDown.value,
0, {currentBpmValue = 0;}, // select a genre
1, {currentBpmValue = 128;}, // Cha Cha
2, {currentBpmValue = 290;}, // Charleston
3, {currentBpmValue = 120;}, // Foxtrot
4, {currentBpmValue = 115;}, // Hip-Hop
5, {currentBpmValue = 135;}, // House
6, {currentBpmValue = 125;}, // Jazz/Funk
7, {currentBpmValue = 184;}, // Jive
8, {currentBpmValue = 160;}, // Metal
9, {currentBpmValue = 124;}, // Paso Doble
10, {currentBpmValue = 130;}, // Pop
11, {currentBpmValue = 208;}, // Quickstep
12, {currentBpmValue = 140;}, // Rock
13, {currentBpmValue = 108;}, // Rumba
14, {currentBpmValue = 80;}, // R&B
15, {currentBpmValue = 300;}, // Salsa
16, {currentBpmValue = 105;}, // Samba
17, {currentBpmValue = 66;}, // Tango
18, {currentBpmValue = 90;}, // Waltz
19, {currentBpmValue = 180;}, // Viennese Waltz
);*/

bpmViewer = StaticText.new(awindow, Rect(45, 70, 100, 20));

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

arpeggiator = Button(awindow, Rect(20, 20, 150, 25)).states_([["Turn Arpeggiator Off", Color.black, Color.gray], ["Turn Arpeggiator On", Color.black, Color.yellow]]).action_({arg vbutton;
	if(vbutton.value==1){(
		SynthDef("sinewave_third", {arg vol=50; Out.ar(0, SinOsc.ar(thirdFreq, 0, vol))}).add;
		SynthDef("sinewave_fifth", {arg vol=50; Out.ar(0, SinOsc.ar(fifthFreq, 0, vol))}).add;
		y = Synth("sinewave_third");
		z = Synth("sinewave_fifth");
		arpeggio = ["sinewave", "sinewave_third", "sinewave_fifth"];
	)}
	{
		y.free;
		z.free;
	}
});

statusButton = Button(awindow, Rect(20,20, 50, 25))
.states_([["Off", Color.black, Color.grey],
	["On",Color.black,Color.yellow]])
.action_({ arg vbutton;
	if(vbutton.value==1,
		{(
			volumeSlider.value = 50;
			pitchKnob.value = 440;
			switch(waveformMenu.value,
				0, {x = Synth("sinewave")}, // sine wave
				1, {x = Synth("squarewave")}, // square wave
				2, {x = Synth("sawtoothwave")}, // sawtooth wave
				3, {x = Synth("trianglewave")}, // triangle wave
				4, {x = Synth("pulsewave")} // pulse wave
			);
		)},
		{x.free;}
	);
});

statusButton.value = 0;
)
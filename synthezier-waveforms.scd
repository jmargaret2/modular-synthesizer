/*
Must have modules in synth:
- [x] pitch bender
- [x] volume control
- [] bpm slider BPM here is meausred BPS
- [-] legato switch - sustain button -> writing added
- [x] majorChord
- [x] delay effect
- [x] distortion effect
*/
/*
Nice to have modules in synth:
- [] aftertouch
- [] generator
- [] step sequencer
- [] reverb effect
- [] stutter effect
*/
(
// Environment variables
var awindow;

// Module variables
var volumeSlider, pitchKnob, applyButton, majorChord, delaySlider, distortionButton;
// var legatoButton

// GUI variables
var statusButton, resetButton, waveformButton;

// Other variables
var waveformMenu, bpmDictionaryValues, majChord, currentWaveform, waveformSelection, waveformDictionary;

// const variables
var baseFrequency = 440; // A4 -> synthesizer is based on A = 440 is standard tuning
var thirdFreq = baseFrequency * (2**(4/12));
var fifthFreq = baseFrequency * (2**(7/12));
var piOverSix = pi/6;
var negativePiOverSix = (-pi)/6;
var dist;

awindow = FlowView.new(windowTitle:"A Modular Synthesizer with Waveforms");

waveformMenu = PopUpMenu(awindow, Rect(10, 10, 130, 20));
waveformMenu.items = [
	"Sine wave", "Square wave", "Sawtooth wave", "Triangle wave", "Pulse wave"
];

waveformDictionary = Dictionary.new(4);
waveformDictionary.put(0, {SynthDef("sinewave", {arg freq=baseFrequency, phase=0, vol=50; Out.ar(0, SinOsc.ar(freq, phase, vol))}).add});
waveformDictionary.put(1, {SynthDef("squarewave", {arg freq=440, vol=50; Out.ar(0, Pulse.ar(freq, 0, vol))}).add;});
waveformDictionary.put(2, {SynthDef("sawtoothwave", {arg freq=440, vol=50; Out.ar(0, Saw.ar(freq, 0, vol))}).add;});
waveformDictionary.put(3, {SynthDef("trianglewave", {arg freq=440, vol=50; Out.ar(0, LFTri.ar(freq, 0, vol))}).add;});

waveformButton = Button(awindow, Rect(20,20, 130, 25))
.states_([["Update Waveform", Color.black, Color.gray]])
.action_({arg vbutton;
	// apply changes to wave form type from dropdown
	currentWaveform = waveformMenu.value;
	currentWaveform.postln;
	waveformSelection = waveformDictionary.at(currentWaveform);
});

volumeSlider = EZSlider(awindow, label:"Volume", controlSpec:[0,100], action:{|mv| x.set("vol", mv.value)}, initVal:50);
pitchKnob = EZKnob(awindow, label:"Pitch", controlSpec:\freq, action:{|mn| x.set("freq", mn.value)}, initVal:440);

// bpmDropDown = PopUpMenu(awindow, Rect(20, 20, 120, 20));
//
// bpmDictionaryValues = Dictionary.new(20);
// bpmDictionaryValues.put(0, 0);
// bpmDictionaryValues.put(1, 128);
// bpmDictionaryValues.put(2, 290);
// bpmDictionaryValues.put(3, 120);
// bpmDictionaryValues.put(4, 115);
// bpmDictionaryValues.put(5, 135);
// bpmDictionaryValues.put(6, 125);
// bpmDictionaryValues.put(7, 184);
// bpmDictionaryValues.put(8, 160);
// bpmDictionaryValues.put(9, 124);
// bpmDictionaryValues.put(10, 130);
// bpmDictionaryValues.put(11, 208);
// bpmDictionaryValues.put(12, 140);
// bpmDictionaryValues.put(13, 108);
// bpmDictionaryValues.put(14, 80);
// bpmDictionaryValues.put(15, 300);
// bpmDictionaryValues.put(16, 105);
// bpmDictionaryValues.put(17, 66);
// bpmDictionaryValues.put(18, 90);
// bpmDictionaryValues.put(19, 180);
//
// bpmDropDown.items = [
// 	"Select a Genre", "Cha Cha", "Charleston", "Foxtrot", "Hip-Hop", "House", "Jazz/Funk", "Jive", "Metal", "Paso Doble", "Pop", "Quickstep", "Rock", "Rumba", "R&B", "Salsa", "Samba", "Tango", "Waltz", "Viennese Waltz"
// ];
//
// bpmViewer = StaticText.new(awindow, Rect(45, 70, 100, 20));

applyButton = Button(awindow, Rect(20, 20, 100, 25)).states_([["Update BPM", Color.black, Color.grey]]).action_({arg vbutton;
	// apply changes to BPM values from BPM drop down
	currentBpmValue = bpmDropDown.value;
	currentBpmValue = bpmDictionaryValues.at(currentBpmValue);
	bpmViewer.string = currentBpmValue;
});

// Does not apply to sinewave/waveform SynthDef, they are automatically sustained, and more effort would be needed to create the opposite module
// legatoButton

majorChord = Button(awindow, Rect(20, 20, 150, 25)).states_([["Turn Major Chord Off", Color.black, Color.gray], ["Turn Major Chord On", Color.black, Color.yellow]]).action_({arg vbutton;
	if(vbutton.value==1){(
		thirdFreq.postln;
		fifthFreq.postln;
		SynthDef("sinewave_third", {Out.ar(0, SinOsc.ar(thirdFreq, 0, 50))}).add;
		SynthDef("sinewave_fifth", {Out.ar(0, SinOsc.ar(fifthFreq, 0, 50))}).add;
		y = Synth("sinewave_third");
		z = Synth("sinewave_fifth");
		majChord = ["sinewave", "sinewave_third", "sinewave_fifth"];
	)}
	{
		y.free;
		z.free;
		majChord.free;
	}
});

// Create additional Synths and SynthDefs
// SynthDef("sinewave2", {arg freq=440, vol=50, phase=0; Out.ar(0, SinOsc.ar(freq, 0, vol))}).add;

delaySlider = EZSlider(awindow, label:"Delay Time", labelHeight:50, labelWidth:100, controlSpec:[(-pi)/6, pi/6], action: {|md| x.set("phase", md.value)}, initVal:0); // maxes out at negative pi/6 (on a unit circle, 11pi/6) through to pi/6

distortionButton = Button(awindow, Rect(20, 20, 130, 25)).states_([["Turn Distortion Off", Color.black, Color.grey], ["Turn Distortion On", Color.black, Color.yellow]]).action_({arg vbutton, freq, phase, vol;
	if(vbutton.value==1,
		{(
			// add distortion by using the PinkNoise function, with a new sine wave, with the same frequency from pitchKnob
			dist = {InsideOut.ar(SinOsc.ar(baseFrequency) + PinkNoise.ar(0.9, 0), 30, 50)}.scope;
		)},
		{
			dist.free;
		}
	);
});

resetButton = Button(awindow, Rect(20,20,125,25)).states_([["Reset Everything",Color.black,Color.grey]]).action_({arg vbutton;
	volumeSlider.value = 50;
	pitchKnob.value = 440;
	bpmViewer.string = "";
	bpmDropDown.value = 0;
	delaySlider.value = 0;
	statusButton.value = 0;
	x.free;
});

statusButton = Button(awindow, Rect(20,20, 50, 25))
.states_([["Off", Color.black, Color.grey],
	["On",Color.black,Color.yellow]])
.action_({ arg vbutton;
	if(vbutton.value==1,
		{(
			volumeSlider.value = 50;
			pitchKnob.value = 440;
			x = Synth("sinewave");
			/*switch(waveformSelection);
			switch(waveformMenu.value,
			0, {x = Synth("sinewave")}, // sine wave
			1, {x = Synth("squarewave")}, // square wave
			2, {x = Synth("sawtoothwave")}, // sawtooth wave
			3, {x = Synth("trianglewave")} // triangle wave
			);*/
			delaySlider.value = 0;
		)},
		{
			x.free;
		}
	);
});

statusButton.value = 0;
resetButton.value = 0;
distortionButton.value = 0;
majorChord.value = 0;
)
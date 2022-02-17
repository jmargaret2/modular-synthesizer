/*
Must have modules in synth:
- [x] pitch bender
- [x] volume control
- [-] legato switch - sustain button -> writing added, this module does not work with pure waveforms
- [x] majorChord
- [x] delay effect
- [x] distortion effect
- [] high-pass filter
*/
(
// Environment variables
var awindow;

// Module variables
var volumeSlider, pitchKnob, majorChord, delaySlider, distortionButton;
// var legatoButton

// Module support variables
var currentFrequency;

// GUI variables
var statusButton, resetButton, waveformButton;

// Other variables
var waveformMenu, majChord, waveName;

// const variables
var baseFrequency = 440; // A4 -> synthesizer is based on A = 440 is standard tuning
var thirdFreq = baseFrequency * (2**(4/12));
var fifthFreq = baseFrequency * (2**(7/12));
var currentFreq;
var dist;

awindow = FlowView.new(windowTitle:"A Modular Synthesizer with Waveforms");

waveformMenu = PopUpMenu(awindow, Rect(10, 10, 130, 20));
waveformMenu.items = [
	"Sine wave", "Square wave", "Sawtooth wave", "Triangle wave"
];

waveformButton = Button(awindow, Rect(20,20, 130, 25))
.states_([["Update Waveform", Color.black, Color.gray]])
.action_({arg vbutton;
	switch(waveformMenu.value,
		0, {SynthDef("sinewave", {arg freq=440, phase=0, vol=50; Out.ar(0, SinOsc.ar(freq, phase, vol))}).add},
		1, {SynthDef("squarewave", {arg freq=440, vol=50; Out.ar(0, Pulse.ar(freq, 0, vol))}).add;},
		2, {SynthDef("sawtoothwave", {arg freq=440, vol=50; Out.ar(0, Saw.ar(freq, 0, vol))}).add;},
		3, {SynthDef("trianglewave", {arg freq=440, vol=50; Out.ar(0, LFTri.ar(freq, 0, vol))}).add;},
	);
});

volumeSlider = EZSlider(awindow, label:"Volume", controlSpec:[0,100], action:{|volumeSliderValue| x.set("vol", volumeSliderValue.value)}, initVal:50);
pitchKnob = EZKnob(awindow, label:"Pitch", controlSpec:\freq, action:{|pitchKnobValue| x.set("freq", pitchKnobValue.value, currentFreq)}, initVal:440);

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
	delaySlider.value = 0;
	statusButton.value = 0;
	waveformMenu.value = 0;
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
			delaySlider.value = 0;
			switch(waveformMenu.value,
				0, {x = Synth("sinewave");},
				1, {x = Synth("squarewave");},
				2, {x = Synth("sawtoothwave");},
				3, {x = Synth("trianglewave");},
			);
			x.postln;
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
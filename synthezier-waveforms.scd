/* This file contains the logic for the modules based around the pure sound tones. In this file, the following modules exist:
- a volume slider
- a pitch knob
- a harmonics generator (for this, a major chord)
- a delay slider
- distortion
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

// This window will hold all the modules within this version of the synthesizer
awindow = FlowView.new(windowTitle:"A Modular Synthesizer with Waveforms");

// This menu is in charge of managing the four waveform options
waveformMenu = PopUpMenu(awindow, Rect(10, 10, 130, 20));
waveformMenu.items = [
	"Sine wave", "Square wave", "Sawtooth wave", "Triangle wave"
];

// This button will actively select the desired waveform type
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

// Volume will be adjusted with this slider, with values between 0 and 100 being the difference between soft and loud
volumeSlider = EZSlider(awindow, label:"Volume", controlSpec:[0,100], action:{|volumeSliderValue| x.set("vol", volumeSliderValue.value)}, initVal:50);

// The frequency of the chosen waveform will be adjusted with this knob
pitchKnob = EZKnob(awindow, label:"Pitch", controlSpec:\freq, action:{|pitchKnobValue| x.set("freq", pitchKnobValue.value, currentFreq)}, initVal:440);

// For the purposes of a periodic, sinusoidal waveform, there is no need to add a legato module. This is due to the waveform's innate ability to continue to sound and move until stopped by an external force. More effort would be needed to create a module that stops a periodic sinusoidal waveform at discrete points in time, so no development on such a module would take place.
// legatoButton

// This module is a harmonics generator. For this, a major chord is generated, creating two sine waves on top of the
// user-defined starting waveform.
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

// Delay is added to the user-defined waveform
delaySlider = EZSlider(awindow, label:"Delay Time", labelHeight:50, labelWidth:100, controlSpec:[(-pi)/6, pi/6], action: {|md| x.set("phase", md.value)}, initVal:0); // maxes out at negative pi/6 (on a unit circle, 11pi/6) through to pi/6

// Distortion is added to the starting waveform. Pink Noise and an additional waveform are added noise.
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

// This module will reset all the values within this version of the synthesizer, essentially starting over from 0 from any changes made.
resetButton = Button(awindow, Rect(20,20,125,25)).states_([["Reset Everything",Color.black,Color.grey]]).action_({arg vbutton;
	volumeSlider.value = 50;
	pitchKnob.value = 440;
	delaySlider.value = 0;
	statusButton.value = 0;
	waveformMenu.value = 0;
	x.free;
});

// This button will determine the on/off status of the synthesizer
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

// These values will be set to 0, or "off" when the synthesizer is first run
statusButton.value = 0;
resetButton.value = 0;
distortionButton.value = 0;
majorChord.value = 0;
)
(
/* This is a virtual synthesizer, for demo purposes. For greater explanation into each module, please refer to the appropriate files.
For modules related to the pure sound waveforms, please refer to file ``synthesizer-waveforms.scd``. For modules related to MIDI, please refer to file ``synthesizer-MIDI.scd``.

Modules on the left side of the virtual modular synthesizer are built specifically for use with pure sound waves, while modules on the far right side of the synthesizer are built for MIDI. Modules which are in the middle of the synthesizer are built for both pure sound waves and MIDI.

To run, either uncomment line 12 ``s.boot``, or go to Server > Boot Server, then Language > Evaluate File.
*/

// The variable ``s'' hold a special role in SuperCollider. It is in charge of actions regarding the server.
// This will allow the server to start up, and let sound output be heard.
// s.boot;

// These variables will contain the necessary GUI elements, as well as any relevant modules
var oscillatorTitle, envelopeTitle, waveformLabel, bothModules;
var w, waveformMenu, waveformButton, waveformChoose, synth, statusButton, resetButton, pitchKnob, volumeSlider, majorChordButton; var delaySlider, distortionButton, attackSlider, decaySlider, releaseSlider, sustainSlider, staccatoButton, legatoButton;
var midiButton, ampSlider, dist;

// These variables will contain the necessary values for MIDI to function properly within this module synthesizer
var aLevel, dLevel, sLevel, rTime;
var on, off, notesArray, noteOnVel;

// These are other helper variables, that allow certain modules within this synthesizer to function
var y, z, majChord, tritone;
var currentFreq = 440;
var thirdFreq = currentFreq * (2**(4/12));
var fifthFreq = currentFreq * (2**(7/12));

// We create the background window, on which the remainder of this virtual modular synthesizer will be
w = Window.new("Demo: A Virtual Modular Synthesizer", Rect(50, 50, 800, 500));

// This will add text describing that the left side of the synthesizer is dedicated to modules specifically built for the pure
// sound waveforms
oscillatorTitle = StaticText(w, Rect(30, 325, 100, 200));
oscillatorTitle.font = Font("OCR A Std", 18);
oscillatorTitle.string = "Waveform Modules";

// This will add text describing that these modules in the center of the synthesizer is dedicated to modules built for both pure tones and MIDI
bothModules = StaticText(w, Rect(275, 325, 130, 200));
bothModules.font = Font("OCR A Std", 18);
bothModules.string = "Modules for Both";

// This menu allows the user to choose the type of pure sound wave they would like to use with this synthesizer
// Currently, the user must also be sure to press the "Update Waveforms" button for the change in sound wave to apply.
waveformMenu = PopUpMenu(w, Rect(20, 10, 130, 20));
waveformMenu.items = [
	"Sine wave", "Square wave", "Sawtooth wave", "Triangle wave"
];

/* waveformChoose - a button which confirms the previously made choice on the user-desired sound tone to be used
There are four possibilities: sine wave, square wave, sawtooth wave, triangle wave
*/
waveformChoose = Button(w, Rect(20, 50, 130, 25))
.states_([["Update Waveform", Color.black, Color.gray]])
.action_({arg vbutton, freq=440, phase=0, vol=50;
	switch(waveformMenu.value,
		0, {SynthDef(\wave, {Out.ar(0, SinOsc.ar(freq, phase, vol))}).add}, // sine wave
		1, {SynthDef(\wave, {Out.kr(0, Pulse.ar(freq, phase, vol))}).add;}, // square wave
		2, {SynthDef(\wave, {Out.kr(0, Saw.ar(freq, phase, vol))}).add;}, // sawtooth wave
		3, {SynthDef(\wave, {Out.kr(0, LFTri.ar(freq, phase, vol))}).add;}, // triangle wave
	);
});

// This will add text describing that the right side of the synthesizer is dedicated to modules specifically built for
// MIDI
envelopeTitle = StaticText(w, Rect(550,370, 200, 100));
envelopeTitle.font = Font("OCR A Std", 18);
envelopeTitle.string = "ADSR ENVELOPE";

/* Status Button - to start sound modifications on the pure sound waves
There are 2 states to this button, on and off, to start and stop the playing of the sound wave
*/
waveformButton = Button(w, Rect(20, 100, 150, 50));
waveformButton.states = [["START WAVEFORMS", Color.white, Color.black], ["STOP WAVEFORMS",Color.white,Color.black]];
waveformButton.action = {|vbutton|
	if(vbutton.value==1,{
		synth = Synth(\wave);
	},
	{
		synth.free;
	}
	);
};

/* Reset Button - resets all values in synthesizer
There is only one state to the button: to reset all existing values in the synthesizer
*/
resetButton = Button(w, Rect(290, 345, 70, 15));
resetButton.states = [["RESET ALL",Color.white,Color.black]];
resetButton.action = {|vbutton|
	waveformButton.value=0;
	synth.free;
	pitchKnob.value=440;
	volumeSlider.value=50;
	majorChordButton.value=0;
	midiButton.value=0;
	delaySlider.value=0;
	distortionButton.value=0;
	attackSlider.value=0.01;
	decaySlider.value=0.1;
	releaseSlider.value=2;
	sustainSlider.value=0.3;
	staccatoButton.value=0;
	legatoButton.value=0;
};

// This volume slider will control the output volume of the pure sound tones
volumeSlider = EZSlider(w, Rect(0, 175, 230, 25), label:"VOLUME", controlSpec:[0,100], action:{|volumeSliderValue| x.set("vol", volumeSliderValue.value)}, initVal:50);

// This pitch knob will adjust the perceived frequency of the pure sound wave
pitchKnob = EZKnob(w, Rect(75, 275, 50, 100), label:"PITCH", controlSpec:\freq, action:{|pitchKnobValue| x.set("freq", pitchKnobValue.value, currentFreq)}, initVal:440);

// This is a harmonics generator which will create a major chord on top of either the pure sound waves or MIDI
majorChordButton = Button(w, Rect(275, 180, 100, 25));
majorChordButton.states = [["Start Chord", Color.white, Color.black], ["Stop Chord", Color.white, Color.black]];
majorChordButton.action = {|vbutton|
	if(vbutton.value==1){(
		if(waveformButton.value==1,
			{(
				SynthDef(\thirdInterval, {Out.ar(0, SinOsc.ar(thirdFreq, 0, 50))}).add;
				SynthDef(\fifthInterval, {Out.ar(0, SinOsc.ar(fifthFreq, 0, 50))}).add;
				y = Synth(\thirdInterval);
				z = Synth(\fifthInterval);
				majChord = [\wave, "sinewave_third", "sinewave_fifth"];
			)},
			{(
				y.free;
				z.free;
				majChord.free;
			)}
		);
		if(midiButton.value==1,
			{(
				// stuff
			)}
		);
	)};
};

// This slider will add delay to the pure sound waveforms
delaySlider = EZSlider(w, Rect(-50, 235, 230, 25), label:"DELAY", labelHeight:50, labelWidth:100, controlSpec:[(-pi)/6, pi/6], action: {|md| x.set("phase", md.value)}, initVal:0); // maxes out at negative pi/6 (on a unit circle, 11pi/6) through to pi/6


// Distortion will be added to either the pure sound waves or MIDI
distortionButton = Button(w, Rect(275, 275, 100, 20));
distortionButton.states = ([["Start Distortion", Color.white, Color.black], ["Stop Distortion", Color.white, Color.black]]);
distortionButton.action = {|vbutton|
	if(waveformButton.value==1,
		{(
			// add distortion by using the PinkNoise function, with a new sine wave, with the same frequency from pitchKnob
			dist = {InsideOut.ar(SinOsc.ar(currentFreq) + PinkNoise.ar(0.9, 0), 30, 50)};
		)},
		{
			dist.free;
		}
	);
	if(midiButton.value==1,
		{(
			// Calculate the tritone interval
			// For the purposes of MIDI, this type of interval will produce a dissonant sound,
			// similar to how distortion will make an unpleasant sound
			tritone = currentFreq * (2**(6/12));
			// Create Distortion Effect, but not playing
			SynthDef("distortionSynthDef", {arg out = 0;
				Out.ar(out, SinOsc.ar(tritone, 0, 50), Saw.ar(tritone, 0, 50))
			}).add;
			dist = Synth("distortionSynthDef");
		)},
		{
			dist.free;
		}
	);
};

/* The four following sliders are in charge of the exact values within an ADSR envelope. Attack, Decay, Sustain, and Release values can be manually adjusted here if the preset modules do not produce a desired sound output.
*/

attackSlider = EZSlider(w, Rect(460, 30, 260, 25), "ATTACK", [0, 2],
	{|attackSlider| synth.set(aLevel, attackSlider.value); }, 0.01);

decaySlider = EZSlider(w, Rect(460, 60, 260, 25), "DECAY", [0, 2],
	{|decaySlider| synth.set(dLevel, decaySlider.value); }, 0.1);

sustainSlider = EZSlider(w, Rect(460, 90, 260, 25), "SUSTAIN", [0, 2],
	{|sustainSlider| synth.set(sLevel, sustainSlider.value); }, 0.3);

releaseSlider = EZSlider(w, Rect(460, 120, 260, 25), "RELEASE", [0, 5],
	{|releaseSlider| synth.set(rTime, releaseSlider.value); }, 2);

// This slider will adjust the amp level of the MIDI modules, essentially adjusting the perceived loudness of sounds
ampSlider = EZSlider(w, Rect(400, 150, 320, 25), label:"ADSR amp value", labelHeight: 100, labelWidth: 150, controlSpec: ControlSpec(0.1, 1, \lin), initVal:0.3);

/* staccatoButton - adds staccato to the MIDI note
This button has 2 states, on and off, to control how short a note may sound
*/
staccatoButton = Button(w, Rect(550, 200, 100, 20));
staccatoButton.states = [["Start Staccato", Color.white, Color.black], ["Stop Staccato", Color.white, Color.black]];
staccatoButton.action = {|vbutton|
	if(vbutton.value==1,
		{(
			// shorten attack time, shorten decay time to create sudden drop in sustained volume
			aLevel = 0;
			dLevel = 0;
		)},
		{
			aLevel = 0.01;
			dLevel = 0.1;
	})
};

/* legatoButton - adds legato to the MIDI note
This button has 2 states, on and off, to control how connected a note may sound to another
*/
legatoButton = Button(w, Rect(550, 250, 100, 20));
legatoButton.states = [["Start Legato", Color.white, Color.black], ["Stop Legato", Color.white, Color.black]];
legatoButton.action = {|vbutton|
	// stuff
};

/* MIDI Button - to start allowing MIDI as input, to hear MIDI being played, and to start sound modifications on MIDI
There are 2 states to this button, on and off, to start and stop interacting with MIDI
*/
midiButton = Button(w, Rect(550, 300, 100, 50));
midiButton.states = [["Start MIDI", Color.white, Color.black], ["Stop MIDI", Color.white, Color.black]];
midiButton.action = {|vbutton|
	if(vbutton.value==1,
		{(
			MIDIClient.init;
			MIDIIn.connect;

			on = MIDIdef.noteOn(\keyDown, {arg vel, note, vol;
				currentFreq = note.midicps;
				note.postln;
				// notesArray[note] = Synth("piano", [\freq, baseFrequency, \amp, vel.linlin(0, 127, 0, 1)]);
				notesArray[note] = Synth("piano", [\freq, currentFreq, \amp, vel.linlin(aLevel, dLevel, sLevel, rTime)]);
				noteOnVel = vel;
				["NOTE ON STATUS BUTTON", note].postln;
			});

			off = MIDIdef.noteOff(\keyUp, {arg vel, note;
				notesArray[note].set(\gate, 0);
				["NOTE OFF STATUS BUTTON", note].postln;
			});
		)},
		{
			on.free;
			off.free;
			MIDIClient.disposeClient;
	});
};

// This will allow us to see everything that is overlaid on top of this window, that is, we can see the final virtual modular
// synthesizer
w.front;

// When we start the synthesizer, the two buttons in charge of starting wave forms and MIDI compatibility will be off
waveformButton.value=0;
midiButton.value=0;
)
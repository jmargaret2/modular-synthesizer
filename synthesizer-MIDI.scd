/*
Must have modules in synth:
- [] pitch bender
- [] volume control
- [x] legato switch - sustain button
- [x] staccato button
- [x] distortion effect
- [x] major chord generator -> needs work to be better than turning off/on again
*/
(
// Environment variables
var awindow, resetButton;

// Module variables
var volumeSlider, pitchKnob, majorChord, legatoButton, staccatoButton, distortionButton;

// ASDR variables
var aLevel = 0.01;
var dLevel = 0.1;
var sLevel = 0.3;
var rTime = 2;

// MIDI variables
var notesArray = Array.newClear(128); // the notes array, to hold the MIDI notes, one note slot per possible MIDI note
var note, noteOnVel, on, off;

// GUI variables
var statusButton;

// Other variables
var baseFrequency, dist;
var thirdInterval, fifthInterval;
var thirdIntervalSynth, fifthIntervalSynth;

// A SynthDef with ADSR envelope
SynthDef("piano", {arg freq = 440, amp = 0.1, gate = 1;
	var snd, env;
	env = Env.adsr(aLevel, dLevel, sLevel, rTime, amp).kr(2, gate);
	snd = Saw.ar(freq: [freq, freq*1.5], mul: env);
	Out.ar(0, snd)
}).add;

awindow = FlowView.new(windowTitle:"A Modular Synthesizer with MIDI");
volumeSlider = EZSlider(awindow, label:"Volume", controlSpec:[0,127], action:{|volumeSliderValue| }, initVal:64);
pitchKnob = EZKnob(awindow, label:"Pitch", controlSpec:[0, 127], action:{|pitchKnobValue| pitchKnobValue}, initVal:0);

majorChord = Button(awindow, Rect(20, 20, 150, 25)).states_([["Turn Major Chord Off", Color.black, Color.gray], ["Turn Major Chord On", Color.black, Color.yellow]]).action_({arg vbutton;
	if(vbutton.value==1){(
		thirdInterval = baseFrequency * (2**(4/12));
		fifthInterval = baseFrequency * (2**(7/12));
		thirdIntervalSynth = Synth("piano", [\freq, thirdInterval, \amp, noteOnVel.linlin(0, 127, 0, 1)]);
		fifthIntervalSynth = Synth("piano", [\freq, fifthInterval, \amp, noteOnVel.linlin(0, 127, 0, 1)]);
	)}
	{
		thirdInterval = 0;
		fifthInterval = 0;
		thirdIntervalSynth.free;
		fifthIntervalSynth.free;
	}
});

staccatoButton = Button(awindow, Rect(20, 20, 150, 25)).states_([["Turn Staccato Off", Color.black, Color.gray], ["Turn Staccato On", Color.black, Color.yellow]]).action_({arg vbutton;
	if(vbutton.value==1){
		// shorten attack time, shorten decay time to create sudden drop in sustained volume
		aLevel = 0;
		dLevel = 0;
	}
	{
		aLevel = 0.01;
		dLevel = 0.1;
	}
});

legatoButton = Button(awindow, Rect(20, 20, 100, 25))
.states_([["Turn Legato Off", Color.black, Color.gray], ["Turn Legato On", Color.black, Color.yellow]])
.action_({arg vbutton;
	if(vbutton.value==1){
		// increase attack and release levels
		aLevel = 3;
		rTime = 5;
	}
	{
		// reset attack and release levels to default
		aLevel = 0.01;
		rTime = 2;
	}
});

distortionButton = Button(awindow, Rect(20, 20, 130, 25)).states_([["Turn Distortion Off", Color.black, Color.grey], ["Turn Distortion On", Color.black, Color.yellow]]).action_({arg vbutton;
	if(vbutton.value==1,
		{(
			// Create Distortion Effect, but not playing
			SynthDef("distortionSynthDef", {arg freq = baseFrequency, out = 0;
				Out.ar(out, SinOsc.ar(baseFrequency, 0, 50), Saw.ar(baseFrequency, 0, 50))
			}).add;
		)},
		{
		}
	);
});

resetButton = Button(awindow, Rect(20,20,130,25)).states_([["Reset Everything",Color.black,Color.gray]]).action_({arg vbutton;
	volumeSlider.value = 64;
	pitchKnob.value = 0;
	majorChord.value = 0;
	legatoButton.value = 0;
	staccatoButton.value = 0;
	distortionButton.value = 0;
	MIDIClient.disposeClient;
	thirdInterval = 0;
	fifthInterval = 0;
	statusButton.value = 0;
	aLevel = 0.01;
	rTime = 2;
	on.free;
	off.free;
});

statusButton = Button(awindow, Rect(20,20, 50, 25))
.states_([["Off", Color.black, Color.grey],
	["On",Color.black,Color.yellow]])
.action_({ arg vbutton;
	if(vbutton.value==1,
		{(
			MIDIClient.init;
			MIDIIn.connect;
			volumeSlider.value = 64;
			pitchKnob.value = 0;

			on = MIDIdef.noteOn(\keyDown, {arg vel, note, vol;
				baseFrequency = note.midicps;
				note.postln;
				// notesArray[note] = Synth("piano", [\freq, baseFrequency, \amp, vel.linlin(0, 127, 0, 1)]);
				notesArray[note] = Synth("piano", [\freq, baseFrequency, \amp, vel.linlin(aLevel, dLevel, sLevel, rTime)]);
				noteOnVel = vel;
				["NOTE ON STATUS BUTTON", note].postln;
			});

			off = MIDIdef.noteOff(\keyUp, {arg vel, note;
				notesArray[note].set(\gate, 0);
				["NOTE OFF STATUS BUTTON", note].postln;
				dist.free;
			});

		)},
		{
			on.free;
			off.free;
			MIDIClient.disposeClient;
	});
});

statusButton.value = 0;
)
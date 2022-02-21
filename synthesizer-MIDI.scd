/*
Must have modules in synth:
- [x] volume control/amp slider
- [x] legato switch - sustain button
- [x] staccato button
- [x] distortion effect
- [x] major chord generator -> needs work to be better than turning off/on again
- [] reverb dial
*/
(
// Environment variables
var awindow, resetButton;

// Module variables
var ampSlider, pitchKnob, majorChord, legatoButton, staccatoButton, distortionButton, attackKnob, decayKnob, sustainKnob, releaseKnob;

// ASDR variables
var aLevel = 0.01;
var dLevel = 0.1;
var sLevel = 0.3;
var rTime = 2;
var amp = 0.1;

// MIDI variables
var notesArray = Array.newClear(128); // the notes array, to hold the MIDI notes, one note slot per possible MIDI note
var note, noteOnVel, on, off;

// GUI variables
var statusButton;

// Other variables
var baseFrequency, dist;
var thirdInterval, fifthInterval;
var thirdIntervalSynth, fifthIntervalSynth;
var tritone;

// A SynthDef with ADSR envelope
SynthDef("piano", {arg freq = 440, amp = 0.1, gate = 1;
	var snd, env;
	env = Env.adsr(aLevel, dLevel, sLevel, rTime, amp).kr(2, gate);
	snd = Saw.ar(freq: [freq, freq*1.5], mul: env);
	Out.ar(0, snd)
}).add;

awindow = FlowView.new(windowTitle:"A Modular Synthesizer with MIDI");
ampSlider = EZSlider(awindow, label:"Amp Volume", labelHeight: 100, labelWidth: 150, controlSpec: ControlSpec(0.1, 1, \lin), action:{|ampSliderValue| note.set(\amp, ampSliderValue.value)}, initVal:0.3);

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
		aLevel = 1;
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
			tritone = baseFrequency * (2**(6/12));
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
});

attackKnob = EZKnob(awindow, label: "Attack", controlSpec: [0, 1], action:{|attackKnobValue| aLevel = attackKnobValue.value}, initVal: 0.01);

decayKnob = EZKnob(awindow, label: "Decay", controlSpec: [0, 1], action:{|decayKnobValue| dLevel = decayKnobValue.value}, initVal: 0.1);

sustainKnob = EZKnob(awindow, label: "Sustain", controlSpec: [0, 1], action:{|sustainKnobValue| sLevel = sustainKnobValue.value}, initVal: 0.3);

releaseKnob = EZKnob(awindow, label: "Release", controlSpec: [0, 5], action:{|releaseKnobValue| rTime = releaseKnobValue.value}, initVal: 2);

resetButton = Button(awindow, Rect(20,20,130,25)).states_([["Reset Everything",Color.black,Color.gray]]).action_({arg vbutton;
	ampSlider.value = 0.3;
	pitchKnob.value = 440;
	majorChord.value = 0;
	legatoButton.value = 0;
	staccatoButton.value = 0;
	distortionButton.value = 0;
	thirdInterval = 0;
	fifthInterval = 0;
	statusButton.value = 0;
	aLevel = 0.01;
	dLevel = 0.1;
	sLevel = 0.3;
	rTime = 2;
	amp = 0.1;
	attackKnob.value = 0.01;
	decayKnob.value = 0.1;
	sustainKnob.value = 0.3;
	releaseKnob.value = 2;
	on.free;
	off.free;
	MIDIClient.disposeClient;

});

statusButton = Button(awindow, Rect(20,20, 50, 25))
.states_([["Off", Color.black, Color.grey],
	["On",Color.black,Color.yellow]])
.action_({ arg vbutton;
	if(vbutton.value==1,
		{(
			MIDIClient.init;
			MIDIIn.connect;

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
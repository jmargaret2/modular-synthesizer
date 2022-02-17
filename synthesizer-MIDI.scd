/*
Must have modules in synth:
- [] pitch bender
- [] volume control
- [] legato switch - sustain button
- [x] distortion effect
- [x] major chord generator -> needs work to be better than turning off/on again
- [] delay effect
*/
(
// Environment variables
var awindow, resetButton;

// Module variables
var volumeSlider, pitchKnob, majorChord, delaySlider, legatoButton, distortionButton;

// MIDI variables
var notesArray = Array.newClear(128); // the notes array, to hold the MIDI notes, one note slot per possible MIDI note
var note, noteOnVel, on, off;

// GUI variables
var statusButton;

// Other variables
var arpeggio, currentBpmValue, baseNote, baseFrequency, dist;
var thirdInterval, fifthInterval;
var thirdIntervalSynth, fifthIntervalSynth;
var isNoteOn;

// A SynthDef with ADSR envelope
SynthDef("piano", {arg freq = 440, amp = 0.1, gate = 1;
	var snd, env;
	env = Env.adsr(0.01, 0.1, 0.3, 2, amp).kr(2, gate);
	snd = Saw.ar(freq: [freq, freq*1.5], mul: env);
	Out.ar(0, snd)
}).add;

awindow = FlowView.new(windowTitle:"A Modular Synthesizer with MIDI");
volumeSlider = EZSlider(awindow, label:"Volume", controlSpec:[0,127], action:{|volumeSliderValue|}, initVal:64);
pitchKnob = EZKnob(awindow, label:"Pitch", controlSpec:[0, 127], action:{|pitchKnobValue| baseFrequency = \freq + pitchKnobValue.value}, initVal:0);

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

legatoButton = Button(awindow, Rect(20, 20, 100, 25))
.states_([["Sustain Off", Color.black, Color.gray], ["Sustain On", Color.black, Color.yellow]])
.action_({arg vbutton;
	if(vbutton.value==1){
		// MIDI is sustained through the status button
		/*on = MIDIdef.noteOn(\myKeyDown, {arg vel, note;
		baseNote = note;
		noteOnVel = vel;
		notesArray[note] = Synth("piano", [\freq, note, \amp, vel.linlin(0, 127, 0, 1)]);
		["NOTE ON STATUS BUTTON", note].postln;
		baseNote.postln;
		});*/
	}
	{
		// MIDI is off - turned off in this button
	}
});

delaySlider = EZSlider(awindow, label:"Delay Time", labelHeight:50, labelWidth:100, controlSpec:[(-pi)/6, pi/6], action: {|md| x.set("phase", md.value)}, initVal:0); // maxes out at negative pi/6 (on a unit circle, 11pi/6) through to pi/6

distortionButton = Button(awindow, Rect(20, 20, 130, 25)).states_([["Turn Distortion Off", Color.black, Color.grey], ["Turn Distortion On", Color.black, Color.yellow]]).action_({arg vbutton, freq, phase, vol;
	if(vbutton.value==1,
		{(
			SynthDef("distortionSynthDef", {arg freq = baseFrequency, out = 0;
				Out.ar(out, PinkNoise.ar(0.8), Saw.ar(baseFrequency, 0, 64))
			}).add;
			dist = Synth("distortionSynthDef");
		)},
		{
			dist.free;
		}
	);
});

resetButton = Button(awindow, Rect(20,20,130,25)).states_([["Reset Everything",Color.black,Color.gray]]).action_({arg vbutton;
	volumeSlider.value = 64;
	pitchKnob.value = 0;
	delaySlider.value = 0;
	majorChord.value = 0;
	MIDIClient.disposeClient;
	thirdInterval = 0;
	fifthInterval = 0;
	statusButton.value = 0;
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
				isNoteOn = True;
				baseNote = note;
				baseFrequency = note.midicps;
				noteOnVel = vel;
				notesArray[note] = Synth("piano", [\freq, baseFrequency, \amp, vel.linlin(0, 127, 0, 1)]);
				["NOTE ON STATUS BUTTON", note].postln;
			});

			off = MIDIdef.noteOff(\keyUp, {arg vel, note;
				isNoteOn = False;
				notesArray[note].set(\gate, 0);
				["NOTE OFF STATUS BUTTON", note].postln;
			});
		)},
		{
			on.free;
			off.free;
			thirdIntervalSynth.free;
			fifthIntervalSynth.free;
			MIDIClient.disposeClient;
	});
});

statusButton.value = 0;
)
(
// Environment variables
var awindow;

// Module variables
var volumeSlider, pitchKnob, bpmButton, arpeggiator, delayButton, legatoButton;

// MIDI variables
var notesArray = Array.new(128); // the notes array, to hold the MIDI notes, one note slot per possible MIDI note
var mOut;

// GUI variables
var bpmViewer, statusButton, bpmDropDown;

// Other variables
var bpmDictionaryValues, arpeggio, currentBpmValue;
var baseFrequency = 440; // A4 -> synthesizer is based on the key of A Major, since that's standard tuning
var thirdFreq = baseFrequency * (5/4);
var fifthFreq = baseFrequency * (3/2);

MIDIClient.init(1,1);
MIDIIn.connectAll;
mOut = MIDIOut.newByName("LPK25", "LPK25").latency_(Server.default.latency);

awindow = FlowView.new(windowTitle:"A Modular Synthesizer with MIDI");
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

bpmButton = Button(awindow, Rect(20, 20, 100, 25)).states_([["Update BPM", Color.black, Color.clear]]).action_({arg vbutton;
	// apply changes to BPM values from BPM drop down
	currentBpmValue = bpmDropDown.value;
	currentBpmValue = bpmDictionaryValues.at(currentBpmValue);
	bpmViewer.string = currentBpmValue;
});

arpeggiator = Button(awindow, Rect(20, 20, 150, 25)).states_([["Turn Arpeggiator Off", Color.black, Color.gray], ["Turn Arpeggiator On", Color.black, Color.yellow]]).action_({arg vbutton;
	if(vbutton.value == 1){(
		// insert things
	)}
});



arpeggiator = Button(awindow, Rect(20, 20, 150, 25)).states_([["Turn Arpeggiator Off", Color.black, Color.gray], ["Turn Arpeggiator On", Color.black, Color.yellow]]).action_({arg vbutton;
	if(vbutton.value==1){(
		SynthDef("sinewave_third", {arg third_freq = 329.63, vol=50; Out.ar(0, SinOsc.ar(third_freq, 0, vol))}).add;
		SynthDef("sinewave_fifth", {arg fifth_freq = 392, vol=50; Out.ar(0, SinOsc.ar(fifth_freq, 0, vol))}).add;
		y = Synth("sinewave_third");
		z = Synth("sinewave_fifth");
		arpeggio = ["sinewave", "sinewave_third", "sinewave_fifth"];
	)}
	{
		y.free;
		z.free;
	}
});

legatoButton = Button(awindow, Rect(20, 20, 100, 25))
.states_([["Sustain Off", Color.black, Color.gray], ["Sustain On", Color.black, Color.yellow]])
.action_({arg vbutton;
	if(vbutton.value==1){
		// MIDI is sustained
	}
	// MIDI is off
});

statusButton = Button(awindow, Rect(20,20, 50, 25))
.states_([["Off", Color.black, Color.grey],
	["On",Color.black,Color.yellow]])
.action_({ arg vbutton;
	if(vbutton.value==1,
		{(
			// x=Synth("sinewave");
			volumeSlider.value = 50;
			pitchKnob.value = 440;
			MIDIdef.noteOn(\print, {arg val, num, chan, src; [src,chan, num, val].postln});
		)},
		{x.free});
});

statusButton.value = 0;
MIDIClient.disposeClient;
)
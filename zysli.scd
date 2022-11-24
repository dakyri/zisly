(
s.waitForBoot(
	Buffer.freeAll;
//	s.sync;

/*
 * create global buses and groups
 */
//	s.sync;
	s.newBusAllocators;
	~padOutBus = Bus.audio(s, 2); // collective output for supports and pads
	~voiceOutBus = Bus.audio(s, 2); // collective output for processed sound
	~mainOut = 0; // audio out, 2 channel

	~inputGrp = Group.new; // group for line inputs
	~trigGrp = Group.after(~inputGrp); // group for any trigger traffic
	~playGrp = Group.after(~trigGrp); // group for direct and strand players
	~recGrp = Group.after(~playGrp); // group for recording line in
	~masterFXGrp = Group.after(~recGrp); // group for any master fx
	~masterOutGrp = Group.after(~masterFXGrp); // group for main hardware io

	~cleanup = {
		ServerBoot.removeAll;
		ServerQuit.removeAll;
		ServerTree.removeAll;
		CmdPeriod.removeAll;
	};
	ServerQuit.add(~cleanup);
//	~cleanup();

/*
 * setup sample buffers
 */
	// thisProcess.nowExecutingPath
	~root = "D:/sounds/supercollider/zisly";

	~sampleroot = ~root +/+ "samples/";

	~buf = (
		for_the_80pc: 	Buffer.read(s, ~sampleroot +/+ "noam/for_the_80pc.wav"),
		group_cohesion: Buffer.read(s, ~sampleroot +/+ "noam/group_cohesion.wav"),
		indoctrination: Buffer.read(s, ~sampleroot +/+ "noam/indoctrination.wav"),
		reduce_think: 	Buffer.read(s, ~sampleroot +/+ "noam/reduce_think.wav"),
		skepticism: 	Buffer.read(s, ~sampleroot +/+ "noam/skepticism.wav"),
		take_sports: 	Buffer.read(s, ~sampleroot +/+ "noam/take_sports.wav"),
		tries_entertain: Buffer.read(s, ~sampleroot +/+ "noam/tries_entertain.wav"),
		unbelief: 		Buffer.read(s, ~sampleroot +/+ "noam/unbelief.wav"),
		why_cheering: 	Buffer.read(s, ~sampleroot +/+ "noam/why_cheering.wav"),
		sub_to_power: 	Buffer.read(s, ~sampleroot +/+ "noam/sub_to_power.wav")
	);

	~onsetTrigId = 1;

	// input synth, mono->mono
	// we'd like to be flexible with this, and take input from a ball loop or aud in
	//  \inBus - source buss
	//  \outBus - audio destination bus
	//  \amp - input gain
	//  \onsetTrigId - trigger id used for an onset event
	SynthDef(\input, {
		var sig;
		sig = SoundIn.ar(\inBus.ir(0)) * \amp.kr(1);
		SendTrig.kr(
			Coyote.kr(sig, fastMul: 0.6, thresh: 0.001),
			\onsetTrigId.ir(~onsetTrigId), sig);
		Out.ar(\outBus.ir(0), sig);
	}).add;

	// responder for our onset trig
	OSCdef(\onsetResponder, {
		| msg, time, adr, rxport |
		[time, msg].postln;
	}, '/tr', s.addr, argTemplate: [nil, ~onsetTrigId, nil]);

	// reverb synth, stereo->stereo
	//  \inBus - source
	//  \outBus - destination
	//  \mix
	//  \room
	//  \damp
	SynthDef(\rev, {
		var sig, wet;
		sig = In.ar(\inBus.ir(0), 2);
		wet = FreeVerb2.ar(sig[0], sig[1],
			mix: \wetAmp.kr(0.3), room: \room.kr(1.0), damp: \damp.kr(0.85));
		Out.ar(\outBus.ir(0), wet);
	}).add;
)


)


(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar(10),
		0.09, //0.06, 0.02
		~buf.group_cohesion.bufnum,
		1,
		0.2,
		2,
		0,
		-1,
		512
	); //delete scaling
}.play
)

(
{
	SinOsc.ar(440, [0.4, 0.4])
}.play
)
(
	~root = "D:/sounds/supercollider/zisly";
	~sampleroot = ~root +/+ "samples/";
	~buf = (
		for_the_80pc: 	Buffer.read(s, ~sampleroot +/+ "noam/for_the_80pc.wav"),
		group_cohesion: Buffer.read(s, ~sampleroot +/+ "noam/group_cohesion.wav"),
		indoctrination: Buffer.read(s, ~sampleroot +/+ "noam/indoctrination.wav"),
		reduce_think: 	Buffer.read(s, ~sampleroot +/+ "noam/reduce_think.wav"),
		skepticism: 	Buffer.read(s, ~sampleroot +/+ "noam/skepticism.wav"),
		take_sports: 	Buffer.read(s, ~sampleroot +/+ "noam/take_sports.wav"),
		tries_entertain: Buffer.read(s, ~sampleroot +/+ "noam/tries_entertain.wav"),
		unbelief: 		Buffer.read(s, ~sampleroot +/+ "noam/unbelief.wav"),
		why_cheering: 	Buffer.read(s, ~sampleroot +/+ "noam/why_cheering.wav"),
		sub_to_power: 	Buffer.read(s, ~sampleroot +/+ "noam/sub_to_power.wav")
	);
)
(
SynthDef(\g1, {
	var sig = GrainBuf.ar(
			2, // channels
			Impulse.ar(MouseX.kr(1,200,1)), //Dust.ar(10), back to Impulse // trigger
			0.09, // grain duration
			~buf.group_cohesion.bufnum,  //.bufnum then delete // bufnum of the source
			1, //2, 0.5, 1, // rate
			MouseX.kr(1,200,1), //0.2, // pos
			2, // interpolation
			0, // pan position
			-1,
			512
	);

	Out.ar(0, sig)}).add;
)
Synth(\g1)


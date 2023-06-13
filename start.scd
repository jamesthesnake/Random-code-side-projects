This is an example startup file.
If you want to modify it, best copy it elsewhere to keep the git repository clean.

You can then load it by calling
"path/to/my/superdirt_startup.scd".load
from the supercollider startup file

The supercollider startup file is to be found in
Platform.userAppSupportDir +/+ "startup.scd",
or via the menu File > Open startup file
*/


(
s.reboot { // server options are only updated on reboot
	// configure the sound server: here you could add hardware specific options
	// see http://doc.sccode.org/Classes/ServerOptions.html
	s.options.numBuffers = 1024 * 256; // increase this if you need to load more samples
	s.options.memSize = 8192 * 32; // increase this if you get "alloc failed" messages
	s.options.numWireBufs = 64; // increase this if you get "exceeded number of interconnect buffers" messages
	s.options.maxNodes = 1024 * 32; // increase this if you are getting drop outs and the message "too many nodes"
	s.options.numOutputBusChannels = 2; // set this to your hardware output channel size, if necessary
	s.options.numInputBusChannels = 2; // set this to your hardware output channel size, if necessary
	// boot the server and start SuperDirt
	s.waitForBoot {
		~dirt.stop; // stop any old ones, avoid duplicate dirt (if it is nil, this won't do anything)
		~dirt = SuperDirt(2, s); // two output channels, increase if you want to pan across more channels
		~dirt.loadSoundFiles;   // load samples (path containing a wildcard can be passed in)
		// for example: ~dirt.loadSoundFiles("/Users/myUserName/Dirt/samples/*");
		// s.sync; // optionally: wait for samples to be read
		~dirt.loadSoundFiles("/Users/jakehennessy/Downloads/samples-extra/*");

		~dirt.start(57120, 0 ! 12);   // start listening on port 57120, create two busses each sending audio to channel 0

		// optional, needed for convenient access from sclang:
		(
			~d1 = ~dirt.orbits[0]; ~d2 = ~dirt.orbits[1]; ~d3 = ~dirt.orbits[2];
			~d4 = ~dirt.orbits[3]; ~d5 = ~dirt.orbits[4]; ~d6 = ~dirt.orbits[5];
			~d7 = ~dirt.orbits[6]; ~d8 = ~dirt.orbits[7]; ~d9 = ~dirt.orbits[8];
			~d10 = ~dirt.orbits[9]; ~d11 = ~dirt.orbits[10]; ~d12 = ~dirt.orbits[11];
		);

		// directly below here, in your own copy of this file, you could add further code that you want to call on startup
		// this makes sure the server and ~dirt are running
		// you can keep this separate and make it easier to switch between setups
		// by using "path/to/my/file.scd".load and if necessary commenting out different load statements
		// ...
SynthDef(\test, {
 |out,sustain=1,freq=440,speed=1,begin=0,end=1,pan,accelerate,offset,clamp=1|
 var line, env, volume, tone, outAudio;
 freq=freq*speed;
 line = Line.ar(begin,end,sustain/speed,doneAction: Done.freeSelf);
 env = Env.new(levels: [0, 1, 0.9, 0], times: [0.1, 0.5, 1], curve: [-5, 0, -5]);
 volume = IEnvGen.ar(env, line);
 tone = (Pulse.ar(freq,line)+Pulse.ar(freq*1.01,line)+Pulse.ar(freq*0.99,line))/3;
 outAudio = RLPF.ar(tone*volume, 20000*clamp*volume,0.3);
 OffsetOut.ar(out,DirtPan.ar(outAudio, ~dirt.numChannels, pan, volume));
}).add;

	};

	s.latency = 0.3; // increase this if you get "late" messages

};
);



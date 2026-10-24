// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// ignore_for_file: avoid_print

import 'package:aud_midi_core/aud_midi_core.dart';
import 'package:aud_midi_standard/aud_midi_standard.dart';

Future<void> main() async {
  // A fake backend with an output that loops back into an input
  final backend = FakeMidiBackend();
  final output = backend.addPort(
    backend.portInfo('out', direction: MidiDirection.output),
  );
  final input = backend.addPort(
    backend.portInfo('in', direction: MidiDirection.input),
  );
  backend.connectLoopback(output.id, input.id);

  // The engine hosts the backend and lists its ports
  final engine = MidiEngine(backend: backend);
  await engine.open();
  for (final port in engine.ports) {
    print('${port.direction.name}: ${port.id}');
  }

  // Listen to the input and play a note on the output
  final inputSession = await engine.openInput(input.id);
  final received = inputSession.events.take(2).toList();
  final outputSession = await engine.openOutput(output.id);
  await outputSession.send(
    const MidiNoteOn(channel: 0, note: 60, velocity: 100),
  );
  await outputSession.send(const MidiNoteOff(channel: 0, note: 60));
  for (final event in await received) {
    print('received ${event.message}');
  }

  // Close the sessions before the engine
  await inputSession.close();
  await outputSession.close();
  await engine.close();
}

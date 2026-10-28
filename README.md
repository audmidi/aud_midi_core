# aud_midi_core

English | [Deutsch](README.de.md)

Runtime contracts for aud_midi: backend interfaces, fake backend, scheduler,
port registry, diagnostics. It also holds the MIDI engine that hosts one
backend with its input and output pipelines.

Part of the aud_midi family, see [aud_midi](https://github.com/audmidi/aud_midi).

## Motivation

Every platform backend of the aud_midi family should behave the same, so
that apps reach their MIDI devices through one API whatever the transport,
and the contracts have to be testable without native code. Musicians must
hear notes when they are due: input events keep the time the operating
system stamped and output is scheduled by the operating system wherever it
can be, by a software scheduler everywhere else. The package aims for:

- MidiBackend, advertiser and BLE transport interfaces
- FakeMidiBackend for tests
- Software scheduler with the send contract
- Port registry and diagnostics bus
- No dart:io, dart:ffi or dart:isolate

## Installation

```bash
dart pub add aud_midi_core
```

## Usage

Host a fake backend in the engine, loop an output back into an input and
play a note:

```dart
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
```

It prints:

```text
output: fake:out
input: fake:in
received MidiNoteOn(channel: 0, note: 60, velocity: 100)
received MidiNoteOff(channel: 0, note: 60, velocity: 64)
```

## Limitations

- The package uses no dart:io, dart:ffi or dart:isolate: it contains no
  platform backend and opens no real port. The backends of the family
  implement its contracts, the umbrella package hosts the engine in the
  MIDI isolate.
- The contract tests run against `FakeMidiBackend`: they prove the Dart
  abstraction, not a native binding.

## Documentation

- [Plan of the aud_midi family](https://github.com/audmidi/aud_midi_pm/blob/main/doc/2026-Q4/tickets/2026-10-06-aud_midi_01-initial-midi-implementation.md)
- [Guides](doc/guides/)

## How it works

- Contracts: `MidiBackend` with virtual port, Bluetooth and network sub-APIs, `MidiBackendHost`, `MidiServiceAdvertiser`, `MidiBleTransport`, `MidiBluetoothSystemPicker` (the Bluetooth device picker of the operating system), `MidiException` with `MidiTimeout`.
- Native taps: `MidiNativeTapBackend` next to `MidiBackend`, found with `is`, attaches a `MidiNativeTap` (the addresses of a C function and its user pointer) to an input port; the backend calls it on its own receive thread with UMP words or MIDI 1.0 bytes and a host timestamp in nanoseconds, and with `gone` when the port disappears. A detach completes after the last call. `MidiCompositeBackend` routes taps to the backend of the port.
- Clock: `MidiSystemClock` (`Timeline.now` on the VM, `performance.now()` in the browser), `MidiClockMapper`, and `MidiFakeClock` with `MidiFakeTimers` for tests.
- `MidiEngine` hosts one backend in the current isolate: per input a MIDI 1.0 parser or UMP decoder, JR timestamps as sender time, optional translation, bounded queues with overflow diagnostics; per output translation to the port's protocol, encoding, scheduling by the operating system or the software scheduler (with a lookahead for ports that cannot discard), `cancelPending` and panic; port registry with re-plug candidates and devices; diagnostics bus; a fixed shutdown order.
- `MidiCompositeBackend` combines backends, `MidiBleBluetoothBackend` runs BLE-MIDI over a GATT client.
- `FakeMidiBackend` with loopback, hotplug, failures, recorded native taps and in-memory virtual ports, BLE and network sessions.

## Status

Before 1.0 — the API may change between minor versions.

Implemented; every file is covered 100 % by its own tests on the Dart VM, and the pure-Dart tests also pass in Chrome (`dart test -p chrome test/clock test/engine test/fake test/backend test/ble test/error`).

## Contributing

See [doc/guides/develop-guide.md](doc/guides/develop-guide.md).

## License

MIT — see [LICENSE](LICENSE).

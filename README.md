# aud_midi_core

Runtime contracts of the aud_midi family: backend interfaces, a fake backend, the software scheduler, the port registry and diagnostics.

Part of the aud_midi family, see [aud_midi](https://github.com/audmidi/aud_midi).

## Goals

- MidiBackend, advertiser and BLE transport interfaces
- FakeMidiBackend for tests
- Software scheduler with the send contract
- Port registry and diagnostics bus
- No dart:io, dart:ffi or dart:isolate

## State

Implemented; every file is covered 100 % by its own tests on the Dart VM, and the pure-Dart tests also pass in Chrome (`dart test -p chrome test/clock test/engine test/fake test/backend test/ble test/error`).

- Contracts: `MidiBackend` with virtual port, Bluetooth and network sub-APIs, `MidiBackendHost`, `MidiServiceAdvertiser`, `MidiBleTransport`, `MidiBluetoothSystemPicker` (the Bluetooth device picker of the operating system), `MidiException` with `MidiTimeout`.
- Native taps: `MidiNativeTapBackend` next to `MidiBackend`, found with `is`, attaches a `MidiNativeTap` (the addresses of a C function and its user pointer) to an input port; the backend calls it on its own receive thread with UMP words or MIDI 1.0 bytes and a host timestamp in nanoseconds, and with `gone` when the port disappears. A detach completes after the last call. `MidiCompositeBackend` routes taps to the backend of the port.
- Clock: `MidiSystemClock` (`Timeline.now` on the VM, `performance.now()` in the browser), `MidiClockMapper`, and `MidiFakeClock` with `MidiFakeTimers` for tests.
- `MidiEngine` hosts one backend in the current isolate: per input a MIDI 1.0 parser or UMP decoder, JR timestamps as sender time, optional translation, bounded queues with overflow diagnostics; per output translation to the port's protocol, encoding, scheduling by the operating system or the software scheduler (with a lookahead for ports that cannot discard), `cancelPending` and panic; port registry with re-plug candidates and devices; diagnostics bus; a fixed shutdown order.
- `MidiCompositeBackend` combines backends, `MidiBleBluetoothBackend` runs BLE-MIDI over a GATT client.
- `FakeMidiBackend` with loopback, hotplug, failures, recorded native taps and in-memory virtual ports, BLE and network sessions. The contract tests run against it: they prove the Dart abstraction, not a native binding.

See the plan in [aud_midi_pm](https://github.com/audmidi/aud_midi_pm/blob/main/doc/2026-Q4/tickets/2026-10-06-aud_midi_01-initial-midi-implementation.md).

## Installation

```bash
dart pub add aud_midi_core
```

## Contributing

See [doc/guides/develop-guide.md](doc/guides/develop-guide.md).

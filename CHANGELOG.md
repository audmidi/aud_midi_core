# Changelog

## Unreleased

### Added

- Add the native tap contract and its fake

- MidiNativeTap and MidiNativeTapBackend: a backend calls a native function for an input port on its receive thread (native-001)

- FakeMidiBackend records taps; the composite backend routes them to the port's backend

- Add the Bluetooth system picker interface and MidiTimeout

- MidiBluetoothSystemPicker, an optional interface for backends with a system device picker
- MidiTimeout for operations that do not complete in time

## 0.1.0 - 2026-10-07

### Added

- Add boilerplate
- Add package dependencies

### Changed

- Upgrade dependencies
- Move the plan to aud_midi_pm
- Rename the PM repo to aud_midi_pm and move the plan there
- Use git dependencies and set publish_to none
- Implement the MIDI engine and backend contracts
- Reference the aud_midi packages on pub.dev and the audmidi organization

## 0.0.0 - 2026-10-06

- Initial boilerplate

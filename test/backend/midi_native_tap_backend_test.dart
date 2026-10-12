// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_core/aud_midi_core.dart';
import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

/// A backend without native taps.
final class _PlainBackend implements MidiBackend {
  @override
  Future<void> start(MidiBackendHost host) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> openPort(MidiPortId port) async {}

  @override
  Future<void> closePort(MidiPortId port) async {}

  @override
  Future<void> send(MidiPortId port, MidiPacket packet) async {}

  @override
  Future<void> cancelPending(MidiPortId port) async {}

  @override
  String get name => 'plain';

  @override
  MidiCapabilities get capabilities => const MidiCapabilities.none();

  @override
  List<MidiPortInfo> get ports => const [];

  @override
  MidiVirtualPortsBackend? get virtualPorts => null;

  @override
  MidiBluetoothBackend? get bluetooth => null;

  @override
  MidiNetworkBackend? get network => null;
}

void main() {
  group('MidiNativeTapBackend', () {
    test('is found next to MidiBackend with is', () {
      final MidiBackend fake = FakeMidiBackend();
      final MidiBackend plain = _PlainBackend();
      expect(fake, isA<MidiNativeTapBackend>());
      expect(plain, isNot(isA<MidiNativeTapBackend>()));
    });

    test('is implemented by the fake with the contract', () async {
      final fake = FakeMidiBackend();
      final input = fake.addPort(
        fake.portInfo('in', direction: MidiDirection.input),
      );
      final MidiNativeTapBackend taps = fake;
      const tap = MidiNativeTap(function: 1, user: 2);
      expect(taps.supportsNativeTap(input.id), isTrue);
      await taps.attachNativeTap(input.id, tap);
      expect(fake.taps, {input.id: tap});
      await taps.detachNativeTap(input.id);
      expect(fake.taps, isEmpty);
    });
  });
}

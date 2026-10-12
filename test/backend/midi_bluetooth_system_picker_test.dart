// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_core/aud_midi_core.dart';
import 'package:test/test.dart';

/// A picker that counts how often it was shown.
final class _Picker implements MidiBluetoothSystemPicker {
  int shown = 0;

  @override
  Future<void> showSystemDevicePicker() async => shown++;
}

void main() {
  group('MidiBluetoothSystemPicker', () {
    test('can be implemented and shown', () async {
      final picker = _Picker();
      await picker.showSystemDevicePicker();
      expect(picker.shown, 1);
    });

    test('is not implemented by the fake Bluetooth backend', () {
      expect(
        FakeMidiBackend().bluetooth,
        isNot(isA<MidiBluetoothSystemPicker>()),
      );
    });
  });
}

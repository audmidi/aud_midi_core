// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_core/aud_midi_core.dart';
import 'package:test/test.dart';

void main() {
  group('MidiNativeTap', () {
    group('MidiNativeTap(function, user)', () {
      test('keeps the addresses', () {
        const tap = MidiNativeTap(function: 0x1000, user: 0x2000);
        expect(tap.function, 0x1000);
        expect(tap.user, 0x2000);
      });
    });

    group('==, hashCode, toString()', () {
      test('compare both addresses', () {
        const tap = MidiNativeTap(function: 0x1000, user: 0x2000);
        expect(tap, const MidiNativeTap(function: 0x1000, user: 0x2000));
        expect(
          tap.hashCode,
          const MidiNativeTap(function: 0x1000, user: 0x2000).hashCode,
        );
        expect(tap, isNot(const MidiNativeTap(function: 0x1000, user: 1)));
        expect(tap, isNot(const MidiNativeTap(function: 1, user: 0x2000)));
        expect(tap.toString(), 'MidiNativeTap(function: 0x1000, user: 0x2000)');
      });
    });
  });

  group('MidiNativeTapKind', () {
    test('matches the C contract', () {
      expect(MidiNativeTapKind.ump, 1);
      expect(MidiNativeTapKind.bytes, 2);
      expect(MidiNativeTapKind.gone, 3);
    });
  });
}

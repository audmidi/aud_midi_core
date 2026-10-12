// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';

import 'midi_native_tap.dart';

// #############################################################################
/// Native taps on input ports: a backend that implements this interface
/// next to `MidiBackend` calls a [MidiNativeTap] on its own receive thread
/// with the raw data of a port, so that a native consumer gets the data
/// without the Dart isolate in between.
///
/// A backend is checked for the interface with `is`; backends without
/// native receive threads do not implement it.
///
/// - One tap per input port. The data calls of a tap come from one thread
///   at a time; a [MidiNativeTapKind.gone] call may come from another
///   thread, e.g. the hotplug callback, and is never dropped.
/// - A tap stays attached while its port goes offline and comes back under
///   the same id; `gone` marks the gap.
/// - The source of a port stays connected while a tap exists, also when no
///   Dart listener has the port open.
/// - [detachNativeTap] completes only after the last call of the tap
///   returned, and no call starts afterwards; the backend never frees
///   memory the tap may still touch.
abstract interface class MidiNativeTapBackend {
  // ...........................................................................
  /// Returns whether [port] is an input of this backend that takes a native
  /// tap.
  bool supportsNativeTap(MidiPortId port);

  /// Attaches [tap] to the input [port].
  ///
  /// Throws a `MidiPortGone` for an unknown port, an [ArgumentError] for an
  /// output port, a `MidiUnsupported` when the port takes no tap and a
  /// [StateError] when a tap is attached already.
  Future<void> attachNativeTap(MidiPortId port, MidiNativeTap tap);

  /// Detaches the tap of [port] and completes after the last call of the
  /// tap returned; does nothing when no tap is attached.
  ///
  /// Throws a `MidiPortGone` for an unknown port.
  Future<void> detachNativeTap(MidiPortId port);
}

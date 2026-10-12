// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// A native consumer of the raw data of an input port: a C function that a
/// backend calls on its receive thread, without Dart in between.
///
/// [function] is the address of a C function of the signature
///
/// ```c
/// void tap(void* user, uint32_t kind, const void* data, uint32_t count,
///          int64_t host_time_ns);
/// ```
///
/// and [user] the address passed as its first argument. `kind` is
/// [MidiNativeTapKind.ump] (`data` are `uint32_t` words in host byte
/// order, `count` words, one or more complete packets),
/// [MidiNativeTapKind.bytes] (`data` are `count` bytes of a MIDI 1.0 byte
/// stream; a message may span calls) or [MidiNativeTapKind.gone] (the port
/// disappeared or went offline; `data` is null and `count` 0).
/// `host_time_ns` is the time of the operating system's monotonic clock:
/// `mach_absolute_time` in nanoseconds on Apple, `System.nanoTime` on
/// Android; never 0 — the arrival time when the OS gives none.
///
/// Both addresses are plain integers, so a tap travels between isolates.
final class MidiNativeTap {
  /// Creates the tap of the C function at [function] called with [user].
  const MidiNativeTap({required this.function, required this.user});

  // ...........................................................................
  /// The address of the C function.
  final int function;

  /// The address passed to the function as `user`.
  final int user;

  // ...........................................................................
  @override
  bool operator ==(Object other) =>
      other is MidiNativeTap &&
      other.function == function &&
      other.user == user;

  @override
  int get hashCode => Object.hash(function, user);

  @override
  String toString() =>
      'MidiNativeTap(function: 0x${function.toRadixString(16)}, '
      'user: 0x${user.toRadixString(16)})';
}

// #############################################################################
/// The kinds of calls a [MidiNativeTap] receives, the `kind` argument of
/// its function. The values are ABI, never renumber them.
abstract final class MidiNativeTapKind {
  /// UMP words in host byte order, complete packets.
  static const int ump = 1;

  /// Bytes of a MIDI 1.0 byte stream.
  static const int bytes = 2;

  /// The port disappeared or went offline.
  static const int gone = 3;
}

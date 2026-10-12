// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// A Bluetooth backend that can show the device picker of the operating
/// system, e.g. Apple's `CABTMIDICentralViewController` on iOS.
///
/// Optional: a `MidiBluetoothBackend` implements it only where the
/// operating system offers such a picker.
abstract interface class MidiBluetoothSystemPicker {
  /// Shows the picker and completes once the user dismissed it; the
  /// peripherals the user connected there appear as ports.
  ///
  /// Throws a `MidiUnsupported` when the picker cannot be shown.
  Future<void> showSystemDevicePicker();
}

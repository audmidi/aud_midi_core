# aud_midi_core

[English](README.md) | Deutsch

Laufzeit-Verträge für aud_midi: Backend-Interfaces, Fake-Backend, Scheduler,
Port-Registry, Diagnose. Dazu die MIDI-Engine, die ein Backend mit seinen
Eingangs- und Ausgangs-Pipelines betreibt.

Teil der aud_midi-Familie, siehe [aud_midi](https://github.com/audmidi/aud_midi).

## Motivation

Jedes Plattform-Backend der aud_midi-Familie soll sich gleich verhalten,
damit Apps ihre MIDI-Geräte über eine API erreichen, welcher Transport auch
immer dahintersteht — und die Verträge müssen ohne nativen Code testbar
sein. Musiker müssen Noten hören, wenn sie fällig sind: Eingangsereignisse
behalten die Zeit, die das Betriebssystem gestempelt hat, und Ausgaben plant
das Betriebssystem, wo es kann, sonst ein Software-Scheduler. Das Paket zielt
auf:

- MidiBackend-, Advertiser- und BLE-Transport-Interfaces
- FakeMidiBackend für Tests
- Software-Scheduler mit dem Send-Vertrag
- Port-Registry und Diagnose-Bus
- Kein dart:io, dart:ffi oder dart:isolate

## Installation

```bash
dart pub add aud_midi_core
```

## Verwendung

Ein Fake-Backend in der Engine betreiben, einen Ausgang auf einen Eingang
zurückschleifen und eine Note spielen:

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

Es gibt aus:

```text
output: fake:out
input: fake:in
received MidiNoteOn(channel: 0, note: 60, velocity: 100)
received MidiNoteOff(channel: 0, note: 60, velocity: 64)
```

## Einschränkungen

- Das Paket verwendet kein dart:io, dart:ffi oder dart:isolate: Es enthält
  kein Plattform-Backend und öffnet keinen echten Port. Die Backends der
  Familie implementieren seine Verträge, das Dachpaket betreibt die Engine
  im MIDI-Isolate.
- Die Vertragstests laufen gegen `FakeMidiBackend`: Sie belegen die
  Dart-Abstraktion, keine native Anbindung.

## Dokumentation

- [Plan der aud_midi-Familie](https://github.com/audmidi/aud_midi_pm/blob/main/doc/2026-Q4/tickets/2026-10-06-aud_midi_01-initial-midi-implementation.md)
- [Guides](doc/guides/)

## Funktionsweise

- Verträge: `MidiBackend` mit den Unter-APIs für virtuelle Ports, Bluetooth und Netzwerk, `MidiBackendHost`, `MidiServiceAdvertiser`, `MidiBleTransport`, `MidiBluetoothSystemPicker` (die Bluetooth-Geräteauswahl des Betriebssystems), `MidiException` mit `MidiTimeout`.
- Native Taps: `MidiNativeTapBackend` neben `MidiBackend`, per `is` gefunden, hängt einen `MidiNativeTap` (die Adressen einer C-Funktion und ihres User-Pointers) an einen Eingangsport; das Backend ruft ihn auf seinem eigenen Empfangs-Thread mit UMP-Wörtern oder MIDI-1.0-Bytes und einem Host-Zeitstempel in Nanosekunden auf, und mit `gone`, wenn der Port verschwindet. Ein Detach ist erst nach dem letzten Aufruf abgeschlossen. `MidiCompositeBackend` leitet Taps an das Backend des Ports weiter.
- Uhr: `MidiSystemClock` (`Timeline.now` auf der VM, `performance.now()` im Browser), `MidiClockMapper` sowie `MidiFakeClock` mit `MidiFakeTimers` für Tests.
- `MidiEngine` betreibt ein Backend im aktuellen Isolate: je Eingang ein MIDI-1.0-Parser oder UMP-Decoder, JR-Timestamps als Senderzeit, optionale Übersetzung, begrenzte Warteschlangen mit Überlauf-Diagnosen; je Ausgang Übersetzung ins Protokoll des Ports, Kodierung, Planung durch das Betriebssystem oder den Software-Scheduler (mit Vorlauf für Ports, die nicht verwerfen können), `cancelPending` und Panic; Port-Registry mit Re-Plug-Kandidaten und Geräten; Diagnose-Bus; eine feste Reihenfolge beim Herunterfahren.
- `MidiCompositeBackend` kombiniert Backends, `MidiBleBluetoothBackend` betreibt BLE-MIDI über einen GATT-Client.
- `FakeMidiBackend` mit Loopback, Hotplug, Fehlern, aufgezeichneten nativen Taps sowie virtuellen Ports, BLE- und Netzwerk-Sessions im Speicher.

## Status

Vor 1.0 — die API kann sich zwischen Minor-Versionen ändern.

Implementiert; jede Datei ist auf der Dart VM zu 100 % durch ihre eigenen Tests abgedeckt, die reinen Dart-Tests laufen auch in Chrome (`dart test -p chrome test/clock test/engine test/fake test/backend test/ble test/error`).

## Mitwirken

Siehe [doc/guides/develop-guide.md](doc/guides/develop-guide.md).

## Lizenz

MIT — siehe [LICENSE](LICENSE).

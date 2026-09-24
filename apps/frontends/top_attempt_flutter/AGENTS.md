# AGENTS.md — top_attempt_flutter (Kopiervorlage)

Rohes Serverpod-Flutter-Grundgerüst im Monorepo `top_attempt` — **kein
eigener Zweck**, dient als Kopiervorlage, wenn ein weiteres Frontend
benötigt wird. Kontext: [`apps/AGENTS.md`](../../AGENTS.md), Monorepo:
[Root-AGENTS.md](../../../AGENTS.md).

## Status / Rolle

- Praktisch unverändertes Serverpod-Startprojekt (SignIn/Greeting-
  Beispiele), bindet den globalen Client ein.
- 2026-09-23 entstanden die echten Apps `top_attempt_global_flutter`
  (Plattform-Admin) und `top_attempt_local_flutter` (Site-Admin) als
  Kopien dieses Gerüsts.
- **Achtung:** Die `flutter_build`-Skripte beider Backends
  (`serverpod.scripts.flutter_build` in den jeweiligen pubspecs) bauen
  noch **diese** App als Web-App für den Backend-Webserver (Ports 8082/
  8182). Das ist vermutlich ein Überbleibsel — Ziel-App festlegen und
  die Skripte umstellen (To-do, siehe apps/AGENTS.md).
- Paket ist noch in der Workspace-Liste (`apps/pubspec.yaml`) und
  funktioniert daher im Workspace-Kontext — beim Entfernen/Ersetzen
  auf die Skripte achten.

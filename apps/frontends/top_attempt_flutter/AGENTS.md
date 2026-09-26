# AGENTS.md — top_attempt_flutter (copy template)

Raw Serverpod Flutter scaffold in the `top_attempt` monorepo — **no
purpose of its own**; serves as a copy template when another frontend is
needed. Context: [`apps/AGENTS.md`](../../AGENTS.md), monorepo:
[Root AGENTS.md](../../../AGENTS.md).

## State / role

- Practically unchanged Serverpod starter project (SignIn/Greeting
  examples), includes the global client.
- On 2026-09-23 the real apps `top_attempt_global_flutter` (platform
  admin) and `top_attempt_local_flutter` (site admin) were created as
  copies of this scaffold.
- **Attention:** the `flutter_build` scripts of both backends
  (`serverpod.scripts.flutter_build` in the respective pubspecs) still
  build **this** app as web app for the backend web server (ports 8082/
  8182). Probably a leftover — decide the target app and retarget the
  scripts (TODO, see apps/AGENTS.md).
- The package is (still) in the workspace list (`apps/pubspec.yaml`)
  and therefore works in the workspace context — pay attention to the
  scripts when removing/replacing it.

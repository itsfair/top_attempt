# AGENTS.md — top_attempt_global_flutter (platform admin app)

Flutter app for **managing the global instance** (platform level of the
`top_attempt` monorepo): view/manage end-user accounts/profiles, later
more global administration (e.g. course catalog once the global-vs-local
question is settled). Context: [`apps/AGENTS.md`](../../AGENTS.md),
monorepo: [Root AGENTS.md](../../../AGENTS.md).

## Purpose / audience

- Audience: platform operators (super-admins of the central instance),
  **not** end users and **not** site admins (for those there is
  `top_attempt_local_flutter`).
- Future content: user management (accounts, profiles, verification
  status), later global entity administration and possibly an insight
  into the instance landscape (open).

## Current state

Created 2026-09-23 as a copy of the Serverpod scaffold (together with
`top_attempt_local_flutter`); since then heavily expanded (2026-09-24/25):

- GoRouter (`lib/main.dart`) with auth guard: not signed in → `/sign-in`,
  signed-in non-admin (no `global-admin` scope in
  `client.auth.authInfo.scopeNames`) → `/forbidden`.
- Drawer layout (`lib/layout.dart`) for Home, Members, Sites and an
  **account dropdown in the AppBar** (avatar with profile image or
  initials; menu: Profil / Einstellungen / Logout). The dropdown, the
  `ProfileState` and the Profile screen live in the
  **`frontends/shared` package** (`top_attempt_shared`) and are consumed
  identically by the end-user app — changes there apply to both apps.
  The admin app deliberately does not force profile completion (the
  `isComplete` guard is ignored for admins). Wiring contract of the
  shared widget: `onLogin`/`onLogout`/`onProfile` are host-injected —
  `onLogout` MUST perform the real device sign-out
  (`client.auth.signOutDevice()`); navigation after actions goes via
  the host callbacks.
- **Members** (`screens/members.dart` + `screens/member_detail.dart`):
  list of all users (backend paging, 50/page with "load more" button,
  email/name search), detail route `/members/:authUserId` with toggles
  (Global Admin / Blocked; self-protection snack bars mirroring the
  backend).
- **Sites** (expanded 2026-09-25, `screens/sites.dart`,
  `screens/create_site_dialog.dart`, `screens/site_detail.dart`):
  sites list (backend paging 50/page + search by name/email/city,
  **connection chip per site** derived from `lastSeenAt` — setup
  pending / connected (fresh, <90 s) / offline since …), FAB bottom
  right opens the create dialog (address + company email + first site
  admin via search dropdown over `usersAdmin.listUsers`). After
  creation NO onboarding-secrets modal — a hint snack bar (setup happens
  on site with global credentials) and the detail route `/sites/:siteId`
  with status chip, `lastSeenAt` display and the action "revoke
  connection" (`sitesAdmin.revokeSiteConnection`).
- Registration in the admin frontend is **intentionally visible and
  usable** (state: suppressing it failed due to Serverpod auth widget
  internals — TODO below). No security risk: every non-admin lands in
  the `/forbidden` screen (scope guard, enforced server-side).
- Serverpod Flutter packages on 4.0.2. **Attention:** package is still
  missing from the workspace list (`apps/pubspec.yaml`) — TODO, see
  apps/AGENTS.md.

## Backend / client

- Uses the **global client** (`top_attempt_global_client`) — correct for
  this app.
- Server URL: `--dart-define=SERVER_URL=…` or `assets/config.json`
  (default `http://localhost:8080/`); for physical devices the LAN IP of
  the dev machine.

## Next steps (suggestion)

1. Add to the workspace (`apps/pubspec.yaml`).
2. Clean up scaffold leftovers (replace/remove the greeting example).
3. More admin features against `usersAdmin`/`sitesAdmin` extensions:
   confirm on block (confirmation dialog), profile details in the
   editor, memberships display per site in the detail (stage 3).
4. **Stage 3 (sites)**: live status push (Serverpod message central)
   instead of polling; site edit/delete.
5. **Disable registration in the admin frontend** (TODO, not urgent):
   The admin app should not offer self sign-up — but registration must
   stay on the global server for the end-user app (server-side disabling
   would be wrong; admin access is enforced server-side by scopes
   anyway). Attempts on 2026-09-25 that failed:
   a) blanking the "Sign-up" texts via
      `SignInLocalizationProvider`/`EmailSignInTexts.copyWith(
      dontHaveAnAccount: '', signUp: '')` — the button remains
      clickable as an invisible hotspot; navigation to the registration
      screen remains possible.
   b) own `EmailAuthController` subclass blocking `navigateTo` to the
      registration screens (`startRegistration`, `verifyRegistration`,
      `completeRegistration`) — also had no effect (exact cause unclear;
      state: `screens/sign_in.dart` was reset to the working state with
      registration).
   Possible approaches later: own login screen (build the login form
   without the sign-up row, backend calls directly via
   `client.emailIdp`/auth controller) or request an upstream feature of
   the `serverpod_auth_idp_flutter` widgets.

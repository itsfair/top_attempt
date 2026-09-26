import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
// Imported with a prefix to keep the auth extension on the client
// unambiguous in the host apps.
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as auth_core;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:top_attempt_global_client/top_attempt_client.dart';

import '../profile_state.dart';

/// Lets the user edit their own profile: first name, last name, birthday,
/// an optional profile image, plus read-only email, user id and its QR
/// code.
///
/// Lives in `apps/frontends/shared` and is consumed by the end-user app
/// and the global admin app identically — changes here apply to both.
/// After saving, the host app is navigated to `/` (both routers define
/// home there).
class ProfileScreen extends StatefulWidget {
  final Client client;
  final ProfileState profileState;

  const ProfileScreen({
    required this.client,
    required this.profileState,
    super.key,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Client get client => widget.client;

  ProfileState get profileState => widget.profileState;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _imagePicker = ImagePicker();

  DateTime? _birthday;
  Uint8List? _pickedImage;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    profileState.addListener(_onProfileChanged);
    _seedFormFields(profileState.details);
  }

  @override
  void dispose() {
    profileState.removeListener(_onProfileChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  /// Fill the form fields once the profile has been loaded from the server.
  void _onProfileChanged() {
    _seedFormFields(profileState.details);
    if (mounted) setState(() {});
  }

  void _seedFormFields(ProfileDetails? details) {
    if (_firstNameController.text.isEmpty) {
      _firstNameController.text = details?.firstName ?? '';
      _lastNameController.text = details?.lastName ?? '';
      _birthday = details?.birthday;
    }
  }

  Future<void> _pickImage() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;

    final bytes = await file.readAsBytes();
    setState(() => _pickedImage = bytes);
  }

  Future<void> _removeImage() async {
    if (_pickedImage != null) {
      setState(() => _pickedImage = null);
      return;
    }

    try {
      final updated = await client.userProfileEdit.removeUserImage();
      profileState.update(profile: updated);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Entfernen des Bildes: $error')),
        );
      }
    }
  }

  Future<void> _save() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final birthday = _birthday;

    if (firstName.isEmpty || lastName.isEmpty || birthday == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte Vorname, Nachname und Geburtstag angeben.'),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      // Send the UTC-midnight sentinel: the client serialization is
      // toUtc(), so a local-midnight value would drift one day back.
      final normalizedBirthday = _birthday == null
          ? null
          : DateTime.utc(_birthday!.year, _birthday!.month, _birthday!.day);

      final details = await client.profileDetails.save(
        firstName: firstName,
        lastName: lastName,
        birthday: normalizedBirthday ?? DateTime.utc(2000),
      );

      var profile = profileState.profile!;
      if (_pickedImage != null) {
        profile = await client.userProfileEdit.setUserImage(
          ByteData.sublistView(_pickedImage!),
        );
      }

      profileState.update(details: details, profile: profile);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profil gespeichert.')));
      context.go('/');
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Speichern fehlgeschlagen: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _selectBirthday() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final selected = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: today.subtract(const Duration(days: 1)),
    );

    if (selected != null) {
      // Keep the date as a UTC-midnight sentinel so the client-side
      // DateTime serialization (toUtc()) cannot shift the calendar day
      // (local midnight in UT+1 would become the previous day in UTC).
      setState(
        () => _birthday = DateTime.utc(
          selected.year,
          selected.month,
          selected.day,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = profileState.profile;

    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImageSection(),
          _buildDetailsSection(),
          _buildAccountSection(profile),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: const Text('Speichern'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    final imageUrl = profileState.profile?.imageUrl;

    final ImageProvider? preview = switch ((_pickedImage, imageUrl)) {
      (final bytes, _) when bytes != null => MemoryImage(bytes),
      (_, final url?) => NetworkImage(url.toString()),
      _ => null,
    };

    final hasRemovableImage =
        _pickedImage != null || profileState.profile?.imageUrl != null;

    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundImage: preview,
          child: preview == null
              ? const Icon(Icons.person_outline, size: 44)
              : null,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Profilbild wählen'),
            ),
            if (hasRemovableImage) ...[
              IconButton(
                tooltip: 'Bild entfernen',
                icon: const Icon(Icons.delete_outline),
                onPressed: _removeImage,
              ),
            ],
          ],
        ),
        const Text('(optional)', style: TextStyle(fontSize: 12)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDetailsSection() {
    final birthdayText = _birthday == null
        ? ''
        : '${_birthday!.day.toStringAsFixed(0).padLeft(2, '0')}.'
              '${_birthday!.month.toStringAsFixed(0).padLeft(2, '0')}.'
              '${_birthday!.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Meine Daten',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _firstNameController,
          decoration: const InputDecoration(
            labelText: 'Vorname',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.badge_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _lastNameController,
          decoration: const InputDecoration(
            labelText: 'Nachname',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.cake_outlined),
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _selectBirthday,
          borderRadius: BorderRadius.circular(4),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Geburtstag',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.cake_outlined),
            ),
            child: Text(birthdayText),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAccountSection(auth_core.UserProfileModel profile) {
    final userIdString = profile.authUserId.uuid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mein Konto',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (profile.email case final email?)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.alternate_email),
            title: Text(email),
            subtitle: const Text('E-Mail'),
          ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.fingerprint),
          title: SelectableText(userIdString),
          subtitle: const Text('Meine ID'),
        ),
        const SizedBox(height: 8),
        Center(
          child: QrImageView(
            data: userIdString,
            version: QrVersions.auto,
            size: 160,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

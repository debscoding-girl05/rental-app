import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:landlord_os/core/extensions/l10n_ext.dart';
import 'package:landlord_os/core/extensions/datetime_ext.dart';
import 'package:landlord_os/core/utils/error_utils.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final TextEditingController _nameCtrl;
  bool _saving = false;

  User? get _user => Supabase.instance.client.auth.currentUser;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(
      text: _user?.userMetadata?['full_name'] as String? ?? '',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'full_name': name}),
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.saved)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(
          content: Text(ErrorUtils.getUserFriendlyMessage(e)),
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (image == null) return;

    setState(() => _saving = true);
    try {
      final userId = _user!.id;
      final bytes = await image.readAsBytes();
      final path = 'avatars/$userId.jpg';

      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(path);

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'avatar_url': publicUrl}),
      );

      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(
          content: Text(ErrorUtils.getUserFriendlyMessage(e)),
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _user;
    final avatarUrl = user?.userMetadata?['avatar_url'] as String?;
    final email = user?.email ?? '';
    final createdAt = user?.createdAt != null
        ? DateTime.tryParse(user!.createdAt)
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.profile)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Avatar
          Center(
            child: GestureDetector(
              onTap: _pickAvatar,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundImage: avatarUrl != null
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: avatarUrl == null
                        ? const Icon(Icons.person, size: 56)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Name
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: context.l10n.fullName,
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                onPressed: _saving ? null : _saveName,
              ),
            ),
            onSubmitted: (_) => _saveName(),
          ),
          const SizedBox(height: 16),

          // Email (read-only)
          TextField(
            controller: TextEditingController(text: email),
            readOnly: true,
            decoration: InputDecoration(
              labelText: context.l10n.email,
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 24),

          // Member since
          if (createdAt != null)
            ListTile(
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(context.l10n.memberSince),
              subtitle: Text(createdAt.formatted),
            ),
        ],
      ),
    );
  }
}

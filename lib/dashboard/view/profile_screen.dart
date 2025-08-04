import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = Supabase.instance.client.auth.currentUser;
  final _nameController = TextEditingController();
  bool isLoading = false;
  String? avatarUrl;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user!.id)
          .single();

      _nameController.text = response['name'] ?? '';
      avatarUrl = response['avatar_url'];
      setState(() {});
    } catch (e) {
      print('Fetch profile error: $e');
    }
  }

  Future<void> _updateProfile() async {
    setState(() => isLoading = true);

    try {
      await Supabase.instance.client.from('profiles').upsert({
        'id': user!.id,
        'name': _nameController.text,
        'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
    } catch (e) {
      print('Update profile error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final bytes = await image.readAsBytes();
    final fileExt = image.path.split('.').last;
    final filePath = '${user!.id}/avatar.$fileExt';

    try {
      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(filePath, bytes, fileOptions: FileOptions(upsert: true));

      final publicUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(filePath);

      avatarUrl = publicUrl;

      await Supabase.instance.client.from('profiles').upsert({
        'id': user!.id,
        'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });

      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Avatar updated")),
      );
    } catch (e) {
      print('Upload image error: $e');
    }
  }

  Future<void> _changePassword() async {
    final TextEditingController passCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Change Password"),
        content: TextField(
          controller: passCtrl,
          obscureText: true,
          decoration: const InputDecoration(labelText: "New Password"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final newPassword = passCtrl.text;
              if (newPassword.isNotEmpty) {
                try {
                  await Supabase.instance.client.auth
                      .updateUser(UserAttributes(password: newPassword));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password updated")),
                  );
                } catch (e) {
                  print('Password update error: $e');
                }
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget _glassTextField({required TextEditingController controller, required String hint}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white30),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white70),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickAndUploadImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                child: avatarUrl == null
                    ? const Icon(Icons.person, size: 50, color: Colors.white70)
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            _glassTextField(controller: _nameController, hint: "Enter your name"),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _updateProfile,
              icon: const Icon(Icons.save),
              label: const Text("Save Profile"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.1),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _changePassword,
              icon: const Icon(Icons.lock),
              label: const Text("Change Password"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.8),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

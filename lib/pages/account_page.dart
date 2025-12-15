import 'package:flutter/material.dart';
import 'change_email_page.dart';
import 'change_password_page.dart';
import 'auth_verification_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Akun"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            // Kartu Profil
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundImage: AssetImage('assets/profile.png'),
                    backgroundColor: Colors.transparent,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Nissan Abdul Agung",
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                      Text("nisaan@gmail.com",
                          style:
                              TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Seksi Akun
            _buildMenuItem(
              context,
              icon: Icons.email,
              title: 'Ganti Email',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ChangeEmailPage())),
            ),
            _buildMenuItem(
              context,
              icon: Icons.lock,
              title: 'Ganti Password',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ChangePasswordPage())),
            ),
            _buildMenuItem(
              context,
              icon: Icons.verified_user,
              title: 'Autentikasi Akun',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => AuthVerificationPage())),
            ),

            const SizedBox(height: 24),

            // Tombol Logout (dengan ikon merah)
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text('Keluar Akun',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  // TODO: Logout logic
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.indigo.shade700,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
        onTap: onTap,
      ),
    );
  }
}

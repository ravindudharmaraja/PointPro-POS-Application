import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';

class MenuScreen extends StatelessWidget {
  final void Function(String route)? onSelect;
  final VoidCallback? onHome;

  const MenuScreen({
    super.key,
    this.onSelect,
    this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    // Get the auth provider to access user data
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    return Material(
      color: Colors.blueGrey.shade900,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blueGrey.shade900,
              Colors.blueGrey.shade800,
              Colors.blueGrey.shade700,
            ],
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(5, 0),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 60, left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/logo.png', height: 50),
              const SizedBox(height: 40),
              _buildMenuItem(icon: Icons.dashboard, title: 'POS Screen', onTap: () => onSelect?.call('pos')),
              _buildMenuItem(icon: Icons.shopping_bag, title: 'Refund', onTap: () => onSelect?.call('refund')),
              _buildMenuItem(icon: Icons.receipt_long, title: 'Hold Bill', onTap: () => onSelect?.call('hold_bill')),
              _buildMenuItem(icon: Icons.people, title: 'Customers', onTap: () => onSelect?.call('customers')),
              const Spacer(),
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.home, color: Colors.greenAccent.shade700),
                  ),
                  title: Text(
                    'Home',
                    style: TextStyle(
                      color: Colors.greenAccent.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    if (onHome != null) {
                      onHome!();
                    } else {
                      // Navigate to home/dashboard
                      Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false);
                    }
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  tileColor: Colors.transparent,
                  hoverColor: Colors.greenAccent.withOpacity(0.1),
                ),
              ),
            //  Container(
            //     margin: const EdgeInsets.only(bottom: 30),
            //     child: ListTile(
            //       leading: Container(
            //         width: 40,
            //         height: 40,
            //         decoration: BoxDecoration(
            //           shape: BoxShape.circle,
            //           border: Border.all(color: Colors.tealAccent.shade400, width: 2),
            //         ),
            //         child: const Icon(Icons.person, color: Colors.white),
            //       ),
            //       title: Text(
            //         currentUser?.name ?? 'Guest',
            //         style: const TextStyle(
            //           color: Colors.white,
            //           fontWeight: FontWeight.w600,
            //         ),
            //       ),
            //        subtitle: currentUser?.email != null
            //           ? Text(
            //               currentUser!.email!,
            //               style: const TextStyle(color: Colors.white70),
            //             )
            //           : null,
            //     ),
            //   ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade800.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.tealAccent.shade400),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: Colors.transparent,
        hoverColor: Colors.blueGrey.shade700.withOpacity(0.5),
      ),
    );
  }
}
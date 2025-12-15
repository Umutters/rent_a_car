import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_a_cart/core/theme/app_colors.dart';
import 'package:rent_a_cart/core/services/database_service.dart';
import 'package:rent_a_cart/core/widgets/common_states.dart';
import 'package:rent_a_cart/pages/bookings_page.dart';
import 'package:rent_a_cart/pages/login_page.dart';
import 'package:rent_a_cart/pages/profile/widgets/profile_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final DatabaseService _dbService = DatabaseService();

  String _fullName = '';
  String _email = '';
  String _avatarUrl = '';
  bool _isLoading = true;

  // Kullanıcı istatistikleri
  Map<String, dynamic>? _userStats;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadUserStats();
  }

  void _loadUserProfile() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final metadata = user.userMetadata;
      setState(() {
        _email = user.email ?? '';
        _fullName = metadata?['full_name'] ?? metadata?['name'] ?? 'Kullanıcı';
        _avatarUrl = metadata?['avatar_url'] ?? '';
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUserStats() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      try {
        final stats = await _dbService.getUserStatistics(user.id);
        if (mounted) {
          setState(() {
            _userStats = stats;
            _isLoadingStats = false;
          });
        }
      } catch (e) {
        print('İstatistik yükleme hatası: $e');
        if (mounted) {
          setState(() => _isLoadingStats = false);
        }
      }
    } else {
      setState(() => _isLoadingStats = false);
    }
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Yakında eklenecek')));
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Çıkış Yap',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
          style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'İptal',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(
              'Çıkış Yap',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await supabase.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryRadialGradient,
      ),
      child: SafeArea(
        child: _isLoading
            ? const LoadingIndicator(message: 'Yükleniyor...')
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Profile Header
                    _buildProfileHeader(),
                    const SizedBox(height: 24),
                    // User Statistics
                    if (!_isLoadingStats && _userStats != null)
                      UserStatsCard(stats: _userStats!)
                    else if (_isLoadingStats)
                      const LoadingIndicator(
                        message: 'İstatistikler yükleniyor...',
                      ),
                    const SizedBox(height: 24),
                    // Menu Items
                    ProfileMenuItem(
                      icon: Icons.person_outline,
                      title: 'Hesap Bilgileri',
                      subtitle: 'Kişisel bilgilerinizi düzenleyin',
                      onTap: () => _showComingSoon(context),
                    ),
                    ProfileMenuItem(
                      icon: Icons.directions_car_outlined,
                      title: 'Rezervasyonlarım',
                      subtitle: 'Geçmiş ve aktif rezervasyonlar',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BookingsPage(),
                        ),
                      ),
                    ),
                    ProfileMenuItem(
                      icon: Icons.payment_outlined,
                      title: 'Ödeme Yöntemleri',
                      subtitle: 'Kayıtlı kartlarınızı yönetin',
                      onTap: () => _showComingSoon(context),
                    ),
                    ProfileMenuItem(
                      icon: Icons.notifications_outlined,
                      title: 'Bildirimler',
                      subtitle: 'Bildirim tercihlerinizi ayarlayın',
                      onTap: () => _showComingSoon(context),
                    ),
                    ProfileMenuItem(
                      icon: Icons.help_outline,
                      title: 'Yardım & Destek',
                      subtitle: 'SSS ve iletişim',
                      onTap: () => _showComingSoon(context),
                    ),
                    ProfileMenuItem(
                      icon: Icons.info_outline,
                      title: 'Hakkında',
                      subtitle: 'Uygulama bilgileri ve sürüm',
                      onTap: () => showAboutDialog(
                        context: context,
                        applicationName: 'Rent a Car',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '© 2025 Umutters',
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Logout Button
                    _buildLogoutButton(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        ProfileAvatar(fullName: _fullName, avatarUrl: _avatarUrl),
        const SizedBox(height: 16),
        Text(
          _fullName,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _email,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _handleLogout,
        icon: const Icon(Icons.logout, color: Colors.white),
        label: Text(
          'Çıkış Yap',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

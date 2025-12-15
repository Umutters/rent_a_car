import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_a_cart/core/theme/app_colors.dart';
import 'package:rent_a_cart/pages/dashboard/models/car.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rent_a_cart/core/services/database_service.dart';

class BookingSummaryPage extends StatefulWidget {
  final Car car;
  final DateTime startDate;
  final DateTime endDate;
  final int totalPrice;

  const BookingSummaryPage({
    super.key,
    required this.car,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
  });

  @override
  State<BookingSummaryPage> createState() => _BookingSummaryPageState();
}

class _BookingSummaryPageState extends State<BookingSummaryPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final DatabaseService _dbService = DatabaseService();
  bool _isProcessing = false;

  // Ekstra hizmetler
  List<Map<String, dynamic>> _rentalExtras = [];
  final Map<String, int> _selectedExtras = {}; // extra_id: quantity
  bool _isLoadingExtras = true;
  int _extrasTotal = 0;

  @override
  void initState() {
    super.initState();
    _loadRentalExtras();
  }

  Future<void> _loadRentalExtras() async {
    try {
      final extras = await _dbService.getRentalExtras();
      if (mounted) {
        setState(() {
          _rentalExtras = extras;
          _isLoadingExtras = false;
        });
      }
    } catch (e) {
      print('Ekstra hizmetler yüklenirken hata: $e');
      setState(() => _isLoadingExtras = false);
    }
  }

  void _toggleExtra(String extraId, num dailyRate) {
    setState(() {
      if (_selectedExtras.containsKey(extraId)) {
        _selectedExtras.remove(extraId);
      } else {
        _selectedExtras[extraId] = 1;
      }
      _calculateExtrasTotal();
    });
  }

  void _calculateExtrasTotal() {
    final totalDays = widget.endDate.difference(widget.startDate).inDays + 1;
    int total = 0;
    for (var entry in _selectedExtras.entries) {
      final extra = _rentalExtras.firstWhere(
        (e) => e['id'] == entry.key,
        orElse: () => {'daily_rate': 0},
      );
      total += ((extra['daily_rate'] as num).toInt() * entry.value * totalDays);
    }
    _extrasTotal = total;
  }

  int get _grandTotal => widget.totalPrice + _extrasTotal;

  Future<void> _confirmBooking() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen önce giriş yapın')));
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Stored Procedure kullanarak doğrulamalı rezervasyon oluştur
      // Trigger'lar otomatik olarak:
      // - Toplam fiyatı hesaplayacak
      // - Çift rezervasyonu engelleyecek
      // - Araç durumunu güncelleyecek
      final result = await _dbService.createBookingWithValidation(
        userId: user.id,
        carId: widget.car.id,
        startDate: widget.startDate,
        endDate: widget.endDate,
      );

      if (mounted && result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Rezervasyon başarıyla oluşturuldu! Toplam: ${result['total_price']} ₺',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back to home
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        // Hata mesajı procedure'den gelecek (trigger hataları dahil)
        String errorMessage = e.toString();
        if (errorMessage.contains(
          'Bu araç seçilen tarihler arasında zaten kiralanmış',
        )) {
          errorMessage = 'Bu araç seçilen tarihler arasında müsait değil!';
        } else if (errorMessage.contains('Başlangıç tarihi geçmişte olamaz')) {
          errorMessage = 'Geçmiş tarihlerde rezervasyon yapam azsınız!';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalDays = widget.endDate.difference(widget.startDate).inDays + 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Rezervasyon Özeti',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryRadialGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Car Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: widget.car.imageurl.isNotEmpty
                                ? Image.network(
                                    widget.car.imageurl,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              width: 100,
                                              height: 100,
                                              color: AppColors.surface,
                                              child: const Icon(
                                                Icons.directions_car,
                                              ),
                                            ),
                                  )
                                : Container(
                                    width: 100,
                                    height: 100,
                                    color: AppColors.surface,
                                    child: const Icon(Icons.directions_car),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${widget.car.brand} ${widget.car.model}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.car.year,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(AppColors.accent.red, AppColors.accent.green, AppColors.accent.blue, 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${widget.car.dailyRate} ₺/gün',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Rental Extras
                Text(
                  'Ek Hizmetler',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildExtrasSection(),
                const SizedBox(height: 24),

                // Booking Details
                Text(
                  'Rezervasyon Detayları',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.2)),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        'Başlangıç Tarihi',
                        '${widget.startDate.day}/${widget.startDate.month}/${widget.startDate.year}',
                      ),
                      const Divider(color: Colors.white24, height: 24),
                      _buildDetailRow(
                        'Bitiş Tarihi',
                        '${widget.endDate.day}/${widget.endDate.month}/${widget.endDate.year}',
                      ),
                      const Divider(color: Colors.white24, height: 24),
                      _buildDetailRow('Toplam Gün', '$totalDays gün'),
                      const Divider(color: Colors.white24, height: 24),
                      _buildDetailRow(
                        'Günlük Fiyat',
                        '${widget.car.dailyRate} ₺',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Total Price
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(AppColors.accent.red, AppColors.accent.green, AppColors.accent.blue, 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.accent, width: 2),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Araç Kirası',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${widget.totalPrice} ₺',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      if (_extrasTotal > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Ek Hizmetler',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '+$_extrasTotal ₺',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const Divider(color: Colors.white24, height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Toplam Tutar',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '$_grandTotal ₺',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _confirmBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      disabledBackgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isProcessing
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Rezervasyonu Onayla',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildExtrasSection() {
    if (_isLoadingExtras) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_rentalExtras.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 255, 255, 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Ek hizmet bulunmamaktadır.',
          style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
        ),
      );
    }

    final totalDays = widget.endDate.difference(widget.startDate).inDays + 1;

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.2)),
      ),
      child: Column(
        children: _rentalExtras.map((extra) {
          final isSelected = _selectedExtras.containsKey(extra['id']);
          final dailyRate = (extra['daily_rate'] as num).toInt();
          final totalRate = dailyRate * totalDays;

          return InkWell(
            onTap: () => _toggleExtra(extra['id'], dailyRate),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: const Color.fromRGBO(255, 255, 255, 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Checkbox
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.accent
                            : const Color.fromRGBO(255, 255, 255, 0.5),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(AppColors.accent.red, AppColors.accent.green, AppColors.accent.blue, 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getExtraIcon(extra['category'] ?? ''),
                      color: AppColors.accent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          extra['name'] ?? '',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (extra['description'] != null)
                          Text(
                            extra['description'],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '+$totalRate ₺',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '$dailyRate ₺/gün',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getExtraIcon(String category) {
    switch (category.toLowerCase()) {
      case 'safety':
        return Icons.shield;
      case 'comfort':
        return Icons.airline_seat_recline_extra;
      case 'technology':
        return Icons.wifi;
      case 'child':
        return Icons.child_care;
      default:
        return Icons.add_circle_outline;
    }
  }
}

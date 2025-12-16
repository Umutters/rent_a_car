import 'package:intl/intl.dart';

/// Tarih formatlama yardımcı fonksiyonları
class DateHelper {
  /// Tarih -> dd/MM/yyyy formatı
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Tarih -> dd MMM yyyy formatı
  static String formatDateLong(DateTime date) {
    return DateFormat('dd MMM yyyy', 'tr_TR').format(date);
  }

  /// İki tarih arası gün sayısı
  static int daysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays + 1;
  }

  /// Tarih aralığı string'i
  static String formatDateRange(DateTime start, DateTime end) {
    return '${formatDate(start)} - ${formatDate(end)}';
  }
}

/// Sayı formatlama yardımcı fonksiyonları
class NumberHelper {
  /// Para formatı (₺1.234)
  static String formatCurrency(num value) {
    return '₺${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  /// Sayı formatı (1.234)
  static String formatNumber(num value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  /// Güvenli parse
  static num parseNumber(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    return num.tryParse(value.toString()) ?? 0;
  }
}

/// String yardımcı fonksiyonları
class StringHelper {
  /// İlk harfi büyük yap
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Baş harfleri al (Umut Karabulut -> UK)
  static String getInitials(String name, {int maxLength = 2}) {
    if (name.isEmpty) return '';
    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }
    return words
        .take(maxLength)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
  }

  /// Metni kes ve ... ekle
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}

/// Validasyon yardımcı fonksiyonları
class ValidationHelper {
  /// Email validasyonu
  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  /// Telefon validasyonu
  static bool isValidPhone(String phone) {
    final regex = RegExp(r'^\+?[0-9]{10,14}$');
    return regex.hasMatch(phone.replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  }

  /// Boş string kontrolü
  static bool isNotEmpty(String? text) {
    return text != null && text.trim().isNotEmpty;
  }
}

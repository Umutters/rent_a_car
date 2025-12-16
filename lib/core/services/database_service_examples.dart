/// DATABASE SERVICE KULLANIM ÖRNEKLERİ
/// Bu dosya, uygulamanızda view, trigger ve procedure'ların nasıl kullanılacağını gösterir.

import 'package:rent_a_cart/core/services/database_service.dart';
import 'package:rent_a_cart/pages/dashboard/models/car.dart';

class DatabaseServiceExamples {
  final DatabaseService _dbService = DatabaseService();

  // ============================================
  // 1. VIEWS KULLANIMI
  // ============================================

  /// Örnek: İstatistikli araç listesi göster
  Future<void> exampleGetCarsWithStats() async {
    try {
      final carsWithStats = await _dbService.getAvailableCarsWithStats();

      for (var car in carsWithStats) {
        print('Araç: ${car['brand']} ${car['model']}');
        print('Toplam Rezervasyon: ${car['total_bookings']}');
        print('Favori Sayısı: ${car['favorite_count']}');
        print('Ortalama Puan: ${car['avg_rating']}');
        print('Popülerlik: ${car['popularity_status']}');
        print('---');
      }
    } catch (e) {
      print('Hata: $e');
    }
  }

  /// Örnek: Kullanıcı rezervasyon geçmişi (Past/Upcoming/Active)
  Future<void> exampleGetBookingHistory(String userId) async {
    try {
      final history = await _dbService.getUserBookingHistory(userId);

      for (var booking in history) {
        print('Araç: ${booking['car_name']}');
        print('Tarih: ${booking['start_date']} - ${booking['end_date']}');
        print('Durum: ${booking['status']}');
        print('Dönem: ${booking['booking_period']}'); // Past, Upcoming, Active
        print('Kiralama Günü: ${booking['rental_days']}');
        print('---');
      }
    } catch (e) {
      print('Hata: $e');
    }
  }

  /// Örnek: Araç müsaitlik takvimi
  Future<void> exampleGetAvailabilityCalendar(String carId) async {
    try {
      final calendar = await _dbService.getCarAvailabilityCalendar(carId);

      print('Araç Müsaitlik Durumu:');
      for (var booking in calendar) {
        print(
          '${booking['start_date']} - ${booking['end_date']}: ${booking['booking_status']}',
        );
      }
    } catch (e) {
      print('Hata: $e');
    }
  }

  // ============================================
  // 2. STORED PROCEDURES KULLANIMI
  // ============================================

  /// Örnek: Tarih aralığına göre müsait araç arama
  Future<List<Car>> exampleSearchAvailableCars() async {
    try {
      final cars = await _dbService.getAvailableCars(
        startDate: DateTime.now().add(Duration(days: 7)),
        endDate: DateTime.now().add(Duration(days: 10)),
        brand: 'Tesla', // Opsiyonel
        location: 'Istanbul, TR', // Opsiyonel
        minPrice: 1000, // Opsiyonel
        maxPrice: 2000, // Opsiyonel
      );

      print('Bulunan ${cars.length} araç:');
      for (var car in cars) {
        print('${car.brand} ${car.model} - ${car.dailyRate}₺/gün');
      }

      return cars;
    } catch (e) {
      print('Hata: $e');
      return [];
    }
  }

  /// Örnek: Doğrulamalı rezervasyon oluşturma
  Future<void> exampleCreateBooking(String userId, String carId) async {
    try {
      final result = await _dbService.createBookingWithValidation(
        userId: userId,
        carId: carId,
        startDate: DateTime.now().add(Duration(days: 1)),
        endDate: DateTime.now().add(Duration(days: 3)),
      );

      if (result['success'] == true) {
        print('Rezervasyon Oluşturuldu!');
        print('Booking ID: ${result['booking_id']}');
        print('Toplam Fiyat: ${result['total_price']}₺');
        print('Gün Sayısı: ${result['days']}');
      }
    } catch (e) {
      // Trigger hataları buradan gelir:
      // - "Bu araç seçilen tarihler arasında zaten kiralanmış!"
      // - "Başlangıç tarihi geçmişte olamaz!"
      print('Hata: $e');
    }
  }

  /// Örnek: Kullanıcı istatistikleri
  Future<void> exampleGetUserStats(String userId) async {
    try {
      final stats = await _dbService.getUserStatistics(userId);

      print('=== KULLANICI İSTATİSTİKLERİ ===');
      print('Toplam Rezervasyon: ${stats['total_bookings']}');
      print('Tamamlanan: ${stats['completed_bookings']}');
      print('Toplam Harcama: ${stats['total_spent']}₺');
      print('Favori Araç Sayısı: ${stats['favorite_cars']}');
      print('Yaklaşan Rezervasyonlar: ${stats['upcoming_bookings']}');
      print('Aktif Rezervasyonlar: ${stats['active_bookings']}');
    } catch (e) {
      print('Hata: $e');
    }
  }

  /// Örnek: Rezervasyon iptali
  Future<void> exampleCancelBooking(String bookingId, String userId) async {
    try {
      final result = await _dbService.cancelBooking(
        bookingId: bookingId,
        userId: userId,
      );

      if (result['success'] == true) {
        print('✓ ${result['message']}');
        // Trigger otomatik olarak aracın durumunu 'available' yapacak
      }
    } catch (e) {
      // Olası hatalar:
      // - "Bu rezervasyonu iptal etme yetkiniz yok!"
      // - "Tamamlanmış rezervasyonlar iptal edilemez!"
      print('Hata: $e');
    }
  }

  /// Örnek: Araç arama (metin bazlı)
  Future<void> exampleSearchCars(String searchText) async {
    try {
      final cars = await _dbService.searchCars(searchText: searchText);

      print('Arama sonuçları ("$searchText"):');
      for (var car in cars) {
        print('${car.brand} ${car.model} - ${car.location}');
      }
    } catch (e) {
      print('Hata: $e');
    }
  }

  // ============================================
  // 3. TRIGGER'LAR (Otomatik Çalışır)
  // ============================================

  /// NOT: Trigger'ları manuel çağırmanıza gerek yok!
  ///
  /// Uygulamanızda aktif olan trigger'lar:
  ///
  /// 1. update_car_status_on_booking
  ///    - Rezervasyon 'confirmed' olunca → Araç 'rented' olur
  ///    - Rezervasyon 'completed' veya 'cancelled' olunca → Araç 'available' olur
  ///    Kullanım: Rezervasyon INSERT/UPDATE yaptığınızda otomatik çalışır
  ///
  /// 2. calculate_booking_price
  ///    - total_price'ı otomatik hesaplar (günlük ücret × gün sayısı)
  ///    Kullanım: Rezervasyon INSERT/UPDATE yaptığınızda otomatik çalışır
  ///
  /// 3. prevent_double_booking
  ///    - Aynı araç için çakışan rezervasyonları engeller
  ///    - EXCEPTION fırlatır: "Bu araç seçilen tarihler arasında zaten kiralanmış!"
  ///    Kullanım: Rezervasyon INSERT/UPDATE yaptığınızda otomatik kontrol eder
  ///
  /// 4. update_updated_at_column
  ///    - Her UPDATE işleminde updated_at'ı NOW() yapar
  ///    Kullanım: cars, bookings tablolarında UPDATE yaptığınızda otomatik çalışır

  // ============================================
  // 4. PRAKTİK SENARYOLAR
  // ============================================

  /// Senaryo: Ana sayfa için popüler araçları getir
  Future<void> scenarioHomePage() async {
    try {
      // View kullanarak istatistiklerle birlikte getir
      final popularCars = await _dbService.getAvailableCarsWithStats();

      // Popülerlik durumuna göre sırala ve filtrele
      final popularOnes = popularCars
          .where(
            (car) =>
                car['popularity_status'] == 'Popular' ||
                car['popularity_status'] == 'Trending',
          )
          .take(5)
          .toList();

      print('Popüler Araçlar:');
      for (var car in popularOnes) {
        print('${car['brand']} ${car['model']} (${car['popularity_status']})');
      }
    } catch (e) {
      print('Hata: $e');
    }
  }

  /// Senaryo: Profil sayfası - Kullanıcı özeti
  Future<void> scenarioProfilePage(String userId) async {
    try {
      // 1. Kullanıcı istatistiklerini al
      final stats = await _dbService.getUserStatistics(userId);

      // 2. Son rezervasyonları al
      final history = await _dbService.getUserBookingHistory(userId);
      final recentBookings = history.take(3).toList();

      print('=== PROFİL ÖZETİ ===');
      print('Toplam Rezervasyon: ${stats['total_bookings']}');
      print('Toplam Harcama: ${stats['total_spent']}₺');
      print('\nSon Rezervasyonlar:');
      for (var booking in recentBookings) {
        print('- ${booking['car_name']} (${booking['booking_period']})');
      }
    } catch (e) {
      print('Hata: $e');
    }
  }

  /// Senaryo: Tarih seçim ekranı - Müsait araç kontrolü
  Future<bool> scenarioCheckAvailability({
    required String carId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Araç takvimini kontrol et
      final calendar = await _dbService.getCarAvailabilityCalendar(carId);

      // Seçilen tarihlerle çakışma var mı?
      for (var booking in calendar) {
        final bookingStart = DateTime.parse(booking['start_date']);
        final bookingEnd = DateTime.parse(booking['end_date']);

        if ((startDate.isAfter(bookingStart) &&
                startDate.isBefore(bookingEnd)) ||
            (endDate.isAfter(bookingStart) && endDate.isBefore(bookingEnd)) ||
            (startDate.isBefore(bookingStart) && endDate.isAfter(bookingEnd))) {
          print('Bu tarihler müsait değil!');
          return false;
        }
      }

      print('Araç müsait!');
      return true;
    } catch (e) {
      print('Hata: $e');
      return false;
    }
  }
}

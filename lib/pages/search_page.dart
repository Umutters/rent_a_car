import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_a_cart/core/theme/app_colors.dart';
import 'package:rent_a_cart/pages/dashboard/models/car.dart';
import 'package:rent_a_cart/pages/dashboard/widgets/car_card.dart';
import 'package:rent_a_cart/services/car_service.dart';
import 'package:rent_a_cart/services/location_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final CarService _carService = CarService();
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();
  final _supabase = Supabase.instance.client;

  List<Car> _allCars = [];
  List<Car> _filteredCars = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedLocationId;
  late final RealtimeChannel _favoritesChannel;

  // Filter options
  String? _selectedFuelType;
  String? _selectedTransmission;
  RangeValues _priceRange = const RangeValues(0, 10000);
  double _maxPrice = 10000;

  // Tarih filtreleri
  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _fuelTypes = [
    'Tümü',
    'Benzin',
    'Dizel',
    'Elektrik',
    'Hibrit',
  ];
  final List<String> _transmissions = ['Tümü', 'Otomatik', 'Manuel'];

  @override
  void initState() {
    super.initState();
    _loadSelectedLocation();
    _fetchLocations();
    _searchController.addListener(_onSearchChanged);
    _subscribeToFavorites();
  }

  Future<void> _loadSelectedLocation() async {
    final locationData = await _locationService.getSelectedLocation();
    setState(() {
      _selectedLocationId = locationData['id'];
    });
    _fetchAllCars();
  }

  Future<void> _fetchLocations() async {
    try {
      await _locationService.getLocationCities();
      // Cities are loaded but not currently used in filters
    } catch (e) {
      debugPrint('Error loading locations: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _supabase.removeChannel(_favoritesChannel);
    super.dispose();
  }

  void _subscribeToFavorites() {
    _favoritesChannel = _supabase
        .channel('search:favorites')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'favorites',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: _supabase.auth.currentUser?.id,
          ),
          callback: (payload) {
            debugPrint("Search: Favorilerde değişiklik algılandı: $payload");
            // CarCard'ları yenilemek için setState çağır
            if (mounted) {
              setState(() {});
            }
          },
        )
        .subscribe();
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  // Tarih seçici fonksiyonu
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          if (_startDate != null && picked.isBefore(_startDate!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Bitiş tarihi başlangıç tarihinden önce olamaz',
                  style: GoogleFonts.plusJakartaSans(),
                ),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          _endDate = picked;
        }

        // Tarihe göre araçları tekrar çek
        _fetchAllCars();
      });
    }
  }

  Future<void> _fetchAllCars() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Car> cars;

      // Eğer tarih seçilmişse, müsait araçları getir
      if (_startDate != null && _endDate != null) {
        debugPrint('Tarih filtreleri aktif: ${_startDate} - ${_endDate}');
        cars = await _carService.getAvailableCars(
          startDate: _startDate!,
          endDate: _endDate!,
          locationId: _selectedLocationId,
        );
        debugPrint('Müsait araç sayısı: ${cars.length}');
      } else {
        // Tarih seçilmemişse tüm araçları getir
        debugPrint('Tüm araçlar getiriliyor (tarih filtresi yok)');
        cars = await _carService.getAllCars(locationId: _selectedLocationId);
        debugPrint('Toplam araç sayısı: ${cars.length}');
      }

      // Araç markalarını logla
      debugPrint(
        'Gelen araçlar: ${cars.map((c) => '${c.brand} ${c.model}').join(', ')}',
      );

      if (mounted) {
        // Find max price for slider
        double maxPrice = 1000;
        for (var car in cars) {
          if (car.dailyRate > maxPrice) {
            maxPrice = car.dailyRate.toDouble();
          }
        }

        setState(() {
          _allCars = cars;
          _filteredCars = cars;
          _maxPrice = maxPrice + 500;
          _priceRange = RangeValues(0, _maxPrice);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Araçlar yüklenirken hata: $e";
        });
      }
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredCars = _allCars.where((car) {
        // Text search
        final matchesSearch =
            query.isEmpty ||
            car.brand.toLowerCase().contains(query) ||
            car.model.toLowerCase().contains(query) ||
            car.location.toLowerCase().contains(query);

        // Fuel type filter
        final matchesFuel =
            _selectedFuelType == null ||
            _selectedFuelType == 'Tümü' ||
            car.fuelType.toLowerCase() == _selectedFuelType!.toLowerCase();

        // Transmission filter
        final matchesTransmission =
            _selectedTransmission == null ||
            _selectedTransmission == 'Tümü' ||
            car.transmission.toLowerCase().contains(
              _selectedTransmission!.toLowerCase(),
            );

        // Price filter
        final matchesPrice =
            car.dailyRate >= _priceRange.start &&
            car.dailyRate <= _priceRange.end;

        return matchesSearch &&
            matchesFuel &&
            matchesTransmission &&
            matchesPrice;
      }).toList();
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryRadialGradient,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.tune,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Filtreler',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setModalState(() {
                              _selectedFuelType = null;
                              _selectedTransmission = null;
                              _priceRange = RangeValues(0, _maxPrice);
                            });
                            setState(() {});
                          },
                          icon: const Icon(
                            Icons.refresh_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          label: Text(
                            'Sıfırla',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Fuel Type Section
                    _buildFilterSection(
                      title: 'Yakıt Tipi',
                      icon: Icons.local_gas_station_rounded,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _fuelTypes.map((fuel) {
                          final isSelected = _selectedFuelType == fuel;
                          return _buildFilterChip(
                            label: fuel,
                            isSelected: isSelected,
                            onTap: () {
                              setModalState(() {
                                _selectedFuelType = isSelected ? null : fuel;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Transmission Section
                    _buildFilterSection(
                      title: 'Vites Tipi',
                      icon: Icons.settings_rounded,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _transmissions.map((trans) {
                          final isSelected = _selectedTransmission == trans;
                          return _buildFilterChip(
                            label: trans,
                            isSelected: isSelected,
                            onTap: () {
                              setModalState(() {
                                _selectedTransmission = isSelected
                                    ? null
                                    : trans;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Price Range Section
                    _buildFilterSection(
                      title: 'Fiyat Aralığı (Günlük)',
                      icon: Icons.attach_money_rounded,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildPriceTag(
                                '${_priceRange.start.round()} ₺',
                                'Min',
                              ),
                              Container(
                                width: 40,
                                height: 2,
                                color: AppColors.primary.withOpacity(0.3),
                              ),
                              _buildPriceTag(
                                '${_priceRange.end.round()} ₺',
                                'Max',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 4,
                              activeTrackColor: AppColors.primary.withOpacity(
                                0.2,
                              ),
                              inactiveTrackColor: AppColors.primary.withOpacity(
                                0.2,
                              ),
                              thumbColor: AppColors.primary,
                              overlayColor: AppColors.primary.withOpacity(0.2),
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 10,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 20,
                              ),
                            ),
                            child: RangeSlider(
                              values: _priceRange,
                              min: 0,
                              max: _maxPrice,
                              divisions: 20,
                              onChanged: (values) {
                                setModalState(() {
                                  _priceRange = values;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Apply Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _applyFilters();
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Filtreleri Uygula',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary, width: 1.5),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildPriceTag(String price, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryRadialGradient,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Search Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Araç Ara',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tarih seçiciler
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, true),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _startDate == null
                                        ? 'Başlangıç'
                                        : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: _startDate == null
                                          ? AppColors.textSecondary
                                          : AppColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: _startDate == null
                                          ? FontWeight.normal
                                          : FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, false),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _endDate == null
                                        ? 'Bitiş'
                                        : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: _endDate == null
                                          ? AppColors.textSecondary
                                          : AppColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: _endDate == null
                                          ? FontWeight.normal
                                          : FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Arama kutusu
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Marka, model...',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                color: AppColors.textSecondary,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppColors.textSecondary,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.clear,
                                        color: AppColors.textSecondary,
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.tune, color: Colors.white),
                          onPressed: _showFilterSheet,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Results count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_filteredCars.length} araç bulundu',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (_selectedFuelType != null ||
                      _selectedTransmission != null ||
                      _priceRange.start > 0 ||
                      _priceRange.end < _maxPrice ||
                      _startDate != null ||
                      _endDate != null)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedFuelType = null;
                          _selectedTransmission = null;
                          _priceRange = RangeValues(0, _maxPrice);
                          _startDate = null;
                          _endDate = null;
                        });
                        _fetchAllCars();
                      },
                      icon: const Icon(
                        Icons.clear_all,
                        size: 18,
                        color: AppColors.accent,
                      ),
                      label: Text(
                        'Temizle',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Results
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : _filteredCars.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Araç bulunamadı',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Farklı tarih veya filtre deneyin',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      itemCount: _filteredCars.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: CarCard(
                            key: ValueKey(_filteredCars[index].id),
                            car: _filteredCars[index],
                            onFavoriteChanged: () {
                              // Favori değiştiğinde UI'yı güncelle
                              if (mounted) {
                                setState(() {});
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 80), // Bottom nav space
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_a_cart/core/theme/app_colors.dart';
import 'package:rent_a_cart/pages/dashboard/models/car.dart';
import 'package:rent_a_cart/pages/dashboard/widgets/car_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();

  List<Car> _allCars = [];
  List<Car> _filteredCars = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filter options
  String? _selectedFuelType;
  String? _selectedTransmission;
  RangeValues _priceRange = const RangeValues(0, 10000);
  double _maxPrice = 10000;

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
    _fetchAllCars();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  Future<void> _fetchAllCars() async {
    try {
      final response = await supabase.from('cars').select();

      if (mounted) {
        final cars = (response as List).map((c) => Car.fromMap(c)).toList();

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
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: AppColors.primaryRadialGradient,
            ),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Filtreler',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setModalState(() {
                                  _selectedFuelType = null;
                                  _selectedTransmission = null;
                                  _priceRange = RangeValues(0, _maxPrice);
                                });
                                setState(() {});
                              },
                              child: Text(
                                'Sıfırla',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Fuel Type
                        Text(
                          'Yakıt Tipi',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _fuelTypes.map((fuel) {
                            final isSelected = _selectedFuelType == fuel;
                            return ChoiceChip(
                              label: Text(fuel),
                              selected: isSelected,
                              onSelected: (selected) {
                                setModalState(() {
                                  _selectedFuelType = selected ? fuel : null;
                                });
                              },
                              selectedColor: AppColors.accent,
                              backgroundColor: const Color.fromRGBO(255, 255, 255, 0.08),
                              labelStyle: GoogleFonts.plusJakartaSans(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.accent,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Transmission
                        Text(
                          'Vites',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _transmissions.map((trans) {
                            final isSelected = _selectedTransmission == trans;
                            return ChoiceChip(
                              label: Text(trans),
                              selected: isSelected,
                              onSelected: (selected) {
                                setModalState(() {
                                  _selectedTransmission = selected
                                      ? trans
                                      : null;
                                });
                              },
                              selectedColor: AppColors.accent,
                              backgroundColor: const Color.fromRGBO(255, 255, 255, 0.08),
                              labelStyle: GoogleFonts.plusJakartaSans(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.accent,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Price Range
                        Text(
                          'Fiyat Aralığı (Günlük)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        RangeSlider(
                          values: _priceRange,
                          min: 0,
                          max: _maxPrice,
                          divisions: 20,
                          activeColor: AppColors.accent,
                          labels: RangeLabels(
                            '${_priceRange.start.round()} ₺',
                            '${_priceRange.end.round()} ₺',
                          ),
                          onChanged: (values) {
                            setModalState(() {
                              _priceRange = values;
                            });
                          },
                        ),
                        Text(
                          '${_priceRange.start.round()} ₺ - ${_priceRange.end.round()} ₺',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color.fromRGBO(255, 255, 255, 0.8),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Apply Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _applyFilters();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Filtreleri Uygula',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
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
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(255, 255, 255, 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color.fromRGBO(255, 255, 255, 0.2),
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Marka, model veya lokasyon...',
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
                          color: Colors.transparent,
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
                      _priceRange.end < _maxPrice)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedFuelType = null;
                          _selectedTransmission = null;
                          _priceRange = RangeValues(0, _maxPrice);
                        });
                        _applyFilters();
                      },
                      icon: const Icon(
                        Icons.clear_all,
                        size: 18,
                        color: AppColors.accent,
                      ),
                      label: Text(
                        'Filtreleri Temizle',
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
                            'Farklı filtreler deneyin',
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
                          child: CarCard(car: _filteredCars[index]),
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

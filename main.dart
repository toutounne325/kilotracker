// ============================================================================
// Protection légale pour le trading, propriété exclusive de Pirate Pips ™.
// AVERTISSEMENT LÉGAL & DISCLAIMER : Ce logiciel et ses algorithmes de calcul
// sont la propriété exclusive de Pirate Pips ™. Toute reproduction,
// distribution ou modification non autorisée est strictement interdite.
// Les informations financières, fiscales et de trading fournies par les outils
// Pirate Pips ™ le sont à titre purement indicatif et technologique et ne
// constituent en aucun cas un conseil en investissement, fiscal ou juridique.
// Le trading sur les marchés financiers comporte un niveau de risque élevé.
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0E0E0E),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const PiratePipsKiloApp());
}

// ============================================================================
// 1. DESIGN TOKENS & CHARTE GRAPHIQUE PIRATE PIPS™
// ============================================================================
class PirateTheme {
  static const Color bgPrimary = Color(0xFF0E0E0E);
  static const Color bgSecondary = Color(0xFF161616);
  static const Color bgElevated = Color(0xFF1E1E1E);
  static const Color goldPrimary = Color(0xFFF5A623);
  static const Color goldSecondary = Color(0xFFE5A93C);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color bullGreen = Color(0xFF22C55E);
  static const Color bearRed = Color(0xFFEF4444);
  static const Color borderDark = Color(0xFF2A2A2A);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgPrimary,
      primaryColor: goldPrimary,
      colorScheme: const ColorScheme.dark(
        primary: goldPrimary,
        secondary: goldSecondary,
        surface: bgSecondary,
        error: bearRed,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: textWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgPrimary,
        foregroundColor: textWhite,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: bgSecondary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: borderDark, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgElevated,
        labelStyle: const TextStyle(color: textMuted, fontSize: 13),
        hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: goldPrimary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldPrimary,
          foregroundColor: Colors.black,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 2. LOGO OFFICIEL PIRATE PIPS™ (CUSTOM PAINTER)
// ============================================================================
class PiratePipsLogo extends StatelessWidget {
  final double size;
  const PiratePipsLogo({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PiratePipsLogoPainter(),
      ),
    );
  }
}

class _PiratePipsLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Fond circulaire noir profond
    final bgPaint = Paint()
      ..color = PirateTheme.bgPrimary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Halo doré externe
    final outerGoldRing = Paint()
      ..color = PirateTheme.goldPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.065;
    canvas.drawCircle(center, radius * 0.93, outerGoldRing);

    // Liseré doré interne fin
    final innerGoldRing = Paint()
      ..color = PirateTheme.goldSecondary.withOpacity(0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.02;
    canvas.drawCircle(center, radius * 0.80, innerGoldRing);

    // Bougie Haussière Verte (Gauche)
    final bullPaint = Paint()
      ..color = PirateTheme.bullGreen
      ..style = PaintingStyle.fill;
    final bullWickPaint = Paint()
      ..color = PirateTheme.bullGreen
      ..strokeWidth = size.width * 0.045
      ..strokeCap = StrokeCap.round;

    final leftX = size.width * 0.37;
    canvas.drawLine(
      Offset(leftX, size.height * 0.23),
      Offset(leftX, size.height * 0.75),
      bullWickPaint,
    );
    final bullRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(leftX, size.height * 0.47),
        width: size.width * 0.16,
        height: size.height * 0.30,
      ),
      Radius.circular(size.width * 0.03),
    );
    canvas.drawRRect(bullRect, bullPaint);

    // Bougie Baissière Rouge (Droite)
    final bearPaint = Paint()
      ..color = PirateTheme.bearRed
      ..style = PaintingStyle.fill;
    final bearWickPaint = Paint()
      ..color = PirateTheme.bearRed
      ..strokeWidth = size.width * 0.045
      ..strokeCap = StrokeCap.round;

    final rightX = size.width * 0.63;
    canvas.drawLine(
      Offset(rightX, size.height * 0.27),
      Offset(rightX, size.height * 0.78),
      bearWickPaint,
    );
    final bearRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(rightX, size.height * 0.55),
        width: size.width * 0.16,
        height: size.height * 0.28,
      ),
      Radius.circular(size.width * 0.03),
    );
    canvas.drawRRect(bearRect, bearPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// 3. MODÈLES DE DONNÉES (DRIVERS, VEHICLES, PLACES, TRIPS, TAX RATES)
// ============================================================================
class Driver {
  final String id;
  String firstName;
  String lastName;
  String status; // Gérant, Salarié, Indépendant

  Driver({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.status,
  });

  String get fullName => '$firstName $lastName'.trim();

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'status': status,
      };

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
        id: json['id'] ?? '',
        firstName: json['firstName'] ?? '',
        lastName: json['lastName'] ?? '',
        status: json['status'] ?? 'Gérant',
      );
}

class Vehicle {
  final String id;
  String name;
  String plate;
  String type; // Voiture, Moto, Utilitaire
  String engine; // Thermique Essence, Thermique Diesel, Hybride, Électrique
  int fiscalHp; // 3 à 7 (7 = 7 CV et plus)
  double odometerKm;

  Vehicle({
    required this.id,
    required this.name,
    required this.plate,
    required this.type,
    required this.engine,
    required this.fiscalHp,
    required this.odometerKm,
  });

  bool get isElectric => engine.toLowerCase().contains('lectrique');

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'plate': plate,
        'type': type,
        'engine': engine,
        'fiscalHp': fiscalHp,
        'odometerKm': odometerKm,
      };

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        plate: json['plate'] ?? '',
        type: json['type'] ?? 'Voiture',
        engine: json['engine'] ?? 'Thermique Diesel',
        fiscalHp: (json['fiscalHp'] ?? 5) as int,
        odometerKm: ((json['odometerKm'] ?? 0) as num).toDouble(),
      );
}

class SavedPlace {
  final String id;
  String label;
  String address;
  String category; // Maison, Siège, Dépôt, Client, Magasin Pro
  double? lat;
  double? lng;

  SavedPlace({
    required this.id,
    required this.label,
    required this.address,
    required this.category,
    this.lat,
    this.lng,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'address': address,
        'category': category,
        'lat': lat,
        'lng': lng,
      };

  factory SavedPlace.fromJson(Map<String, dynamic> json) => SavedPlace(
        id: json['id'] ?? '',
        label: json['label'] ?? '',
        address: json['address'] ?? '',
        category: json['category'] ?? 'Client',
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
      );
}

class WaypointStop {
  String label;
  String address;

  WaypointStop({required this.label, required this.address});

  Map<String, dynamic> toJson() => {
        'label': label,
        'address': address,
      };

  factory WaypointStop.fromJson(Map<String, dynamic> json) => WaypointStop(
        label: json['label'] ?? 'Étape',
        address: json['address'] ?? '',
      );
}

class FrenchBracketRow {
  double rateUpTo5000;
  double rate5001To20000;
  double fixed5001To20000;
  double rateOver20000;

  FrenchBracketRow({
    required this.rateUpTo5000,
    required this.rate5001To20000,
    required this.fixed5001To20000,
    required this.rateOver20000,
  });

  Map<String, dynamic> toJson() => {
        'rateUpTo5000': rateUpTo5000,
        'rate5001To20000': rate5001To20000,
        'fixed5001To20000': fixed5001To20000,
        'rateOver20000': rateOver20000,
      };

  factory FrenchBracketRow.fromJson(Map<String, dynamic> json) =>
      FrenchBracketRow(
        rateUpTo5000: ((json['rateUpTo5000'] ?? 0.5) as num).toDouble(),
        rate5001To20000: ((json['rate5001To20000'] ?? 0.3) as num).toDouble(),
        fixed5001To20000:
            ((json['fixed5001To20000'] ?? 1000.0) as num).toDouble(),
        rateOver20000: ((json['rateOver20000'] ?? 0.35) as num).toDouble(),
      );
}

class TaxRatesConfig {
  Map<int, FrenchBracketRow> frenchBrackets;
  double frenchElectricBonusPercent; // +20%
  double luxembourgRateEur; // 0.40 €/km
  double belgiumRateEur; // 0.43 €/km
  double germanyDienstreisenEur; // 0.30 €/km
  double germanyPendlerFirst20Eur; // 0.30 €/km
  double germanyPendlerAfter20Eur; // 0.38 €/km
  double switzerlandRateChf; // 0.70 CHF/km

  TaxRatesConfig({
    required this.frenchBrackets,
    this.frenchElectricBonusPercent = 20.0,
    this.luxembourgRateEur = 0.40,
    this.belgiumRateEur = 0.43,
    this.germanyDienstreisenEur = 0.30,
    this.germanyPendlerFirst20Eur = 0.30,
    this.germanyPendlerAfter20Eur = 0.38,
    this.switzerlandRateChf = 0.70,
  });

  factory TaxRatesConfig.defaults() {
    return TaxRatesConfig(
      frenchBrackets: {
        3: FrenchBracketRow(
          rateUpTo5000: 0.529,
          rate5001To20000: 0.316,
          fixed5001To20000: 1065.0,
          rateOver20000: 0.370,
        ),
        4: FrenchBracketRow(
          rateUpTo5000: 0.606,
          rate5001To20000: 0.340,
          fixed5001To20000: 1330.0,
          rateOver20000: 0.407,
        ),
        5: FrenchBracketRow(
          rateUpTo5000: 0.636,
          rate5001To20000: 0.357,
          fixed5001To20000: 1395.0,
          rateOver20000: 0.427,
        ),
        6: FrenchBracketRow(
          rateUpTo5000: 0.665,
          rate5001To20000: 0.374,
          fixed5001To20000: 1457.0,
          rateOver20000: 0.447,
        ),
        7: FrenchBracketRow(
          rateUpTo5000: 0.697,
          rate5001To20000: 0.394,
          fixed5001To20000: 1515.0,
          rateOver20000: 0.470,
        ),
      },
      frenchElectricBonusPercent: 20.0,
      luxembourgRateEur: 0.40,
      belgiumRateEur: 0.43,
      germanyDienstreisenEur: 0.30,
      germanyPendlerFirst20Eur: 0.30,
      germanyPendlerAfter20Eur: 0.38,
      switzerlandRateChf: 0.70,
    );
  }

  Map<String, dynamic> toJson() => {
        'frenchBrackets': frenchBrackets.map(
          (k, v) => MapEntry(k.toString(), v.toJson()),
        ),
        'frenchElectricBonusPercent': frenchElectricBonusPercent,
        'luxembourgRateEur': luxembourgRateEur,
        'belgiumRateEur': belgiumRateEur,
        'germanyDienstreisenEur': germanyDienstreisenEur,
        'germanyPendlerFirst20Eur': germanyPendlerFirst20Eur,
        'germanyPendlerAfter20Eur': germanyPendlerAfter20Eur,
        'switzerlandRateChf': switzerlandRateChf,
      };

  factory TaxRatesConfig.fromJson(Map<String, dynamic> json) {
    final defaults = TaxRatesConfig.defaults();
    final rawMap = json['frenchBrackets'] as Map<String, dynamic>?;
    final parsedBrackets = <int, FrenchBracketRow>{};
    if (rawMap != null) {
      rawMap.forEach((key, value) {
        final hp = int.tryParse(key) ?? 5;
        parsedBrackets[hp] =
            FrenchBracketRow.fromJson(value as Map<String, dynamic>);
      });
    } else {
      parsedBrackets.addAll(defaults.frenchBrackets);
    }
    return TaxRatesConfig(
      frenchBrackets: parsedBrackets,
      frenchElectricBonusPercent:
          ((json['frenchElectricBonusPercent'] ?? 20.0) as num).toDouble(),
      luxembourgRateEur:
          ((json['luxembourgRateEur'] ?? 0.40) as num).toDouble(),
      belgiumRateEur: ((json['belgiumRateEur'] ?? 0.43) as num).toDouble(),
      germanyDienstreisenEur:
          ((json['germanyDienstreisenEur'] ?? 0.30) as num).toDouble(),
      germanyPendlerFirst20Eur:
          ((json['germanyPendlerFirst20Eur'] ?? 0.30) as num).toDouble(),
      germanyPendlerAfter20Eur:
          ((json['germanyPendlerAfter20Eur'] ?? 0.38) as num).toDouble(),
      switzerlandRateChf:
          ((json['switzerlandRateChf'] ?? 0.70) as num).toDouble(),
    );
  }
}

class TripRecord {
  final String id;
  DateTime date;
  String timeLabel;
  String driverId;
  String vehicleId;
  String countryCode; // FR, LU, BE, DE, CH
  String origin;
  String destination;
  List<WaypointStop> waypoints;
  bool isRoundTrip;
  String purpose; // Client, Chantier, Réunion, Administratif, Domicile-Travail
  bool isProfessional; // true = Pro (Vert), false = Privé (Rouge)
  double mapsDistanceKm; // Distance aller ou aller-retour brute Google Maps
  double detourMarginPercent; // ex: 5%, 10%
  double totalDistanceKm; // Distance finale retenue
  double odometerStart;
  double odometerEnd;
  double reimbursementAmount;
  String currency; // EUR ou CHF
  String formulaApplied;
  String notes;
  String? receiptReference;

  TripRecord({
    required this.id,
    required this.date,
    required this.timeLabel,
    required this.driverId,
    required this.vehicleId,
    required this.countryCode,
    required this.origin,
    required this.destination,
    required this.waypoints,
    required this.isRoundTrip,
    required this.purpose,
    required this.isProfessional,
    required this.mapsDistanceKm,
    required this.detourMarginPercent,
    required this.totalDistanceKm,
    required this.odometerStart,
    required this.odometerEnd,
    required this.reimbursementAmount,
    required this.currency,
    required this.formulaApplied,
    required this.notes,
    this.receiptReference,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'timeLabel': timeLabel,
        'driverId': driverId,
        'vehicleId': vehicleId,
        'countryCode': countryCode,
        'origin': origin,
        'destination': destination,
        'waypoints': waypoints.map((w) => w.toJson()).toList(),
        'isRoundTrip': isRoundTrip,
        'purpose': purpose,
        'isProfessional': isProfessional,
        'mapsDistanceKm': mapsDistanceKm,
        'detourMarginPercent': detourMarginPercent,
        'totalDistanceKm': totalDistanceKm,
        'odometerStart': odometerStart,
        'odometerEnd': odometerEnd,
        'reimbursementAmount': reimbursementAmount,
        'currency': currency,
        'formulaApplied': formulaApplied,
        'notes': notes,
        'receiptReference': receiptReference,
      };

  factory TripRecord.fromJson(Map<String, dynamic> json) => TripRecord(
        id: json['id'] ?? '',
        date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
        timeLabel: json['timeLabel'] ?? '08:30',
        driverId: json['driverId'] ?? '',
        vehicleId: json['vehicleId'] ?? '',
        countryCode: json['countryCode'] ?? 'FR',
        origin: json['origin'] ?? '',
        destination: json['destination'] ?? '',
        waypoints: ((json['waypoints'] as List?) ?? [])
            .map((e) => WaypointStop.fromJson(e as Map<String, dynamic>))
            .toList(),
        isRoundTrip: (json['isRoundTrip'] ?? false) as bool,
        purpose: json['purpose'] ?? 'Client',
        isProfessional: (json['isProfessional'] ?? true) as bool,
        mapsDistanceKm: ((json['mapsDistanceKm'] ?? 0) as num).toDouble(),
        detourMarginPercent:
            ((json['detourMarginPercent'] ?? 0) as num).toDouble(),
        totalDistanceKm: ((json['totalDistanceKm'] ?? 0) as num).toDouble(),
        odometerStart: ((json['odometerStart'] ?? 0) as num).toDouble(),
        odometerEnd: ((json['odometerEnd'] ?? 0) as num).toDouble(),
        reimbursementAmount:
            ((json['reimbursementAmount'] ?? 0) as num).toDouble(),
        currency: json['currency'] ?? 'EUR',
        formulaApplied: json['formulaApplied'] ?? '',
        notes: json['notes'] ?? '',
        receiptReference: json['receiptReference'] as String?,
      );
}

// ============================================================================
// 4. MOTEUR LÉGAL & CALCULATEUR FISCAL MULTIDEVISES / MULTIPAYS
// ============================================================================
class TaxCalculationResult {
  final double amount;
  final String currency;
  final String formulaSummary;
  final String bracketLabel;

  TaxCalculationResult({
    required this.amount,
    required this.currency,
    required this.formulaSummary,
    required this.bracketLabel,
  });
}

class FiscalEngine {
  /// Calcule l'indemnité annuelle cumulée française pour une distance D (en km)
  static double computeFrenchAnnualAllowance({
    required double cumulativeKm,
    required int fiscalHp,
    required bool isElectric,
    required TaxRatesConfig config,
  }) {
    if (cumulativeKm <= 0) return 0.0;
    final clampedHp = fiscalHp.clamp(3, 7);
    final row =
        config.frenchBrackets[clampedHp] ?? config.frenchBrackets[5]!;

    double baseAllowance;
    if (cumulativeKm <= 5000.0) {
      baseAllowance = cumulativeKm * row.rateUpTo5000;
    } else if (cumulativeKm <= 20000.0) {
      baseAllowance =
          (cumulativeKm * row.rate5001To20000) + row.fixed5001To20000;
    } else {
      baseAllowance = cumulativeKm * row.rateOver20000;
    }

    if (isElectric) {
      baseAllowance *= (1.0 + (config.frenchElectricBonusPercent / 100.0));
    }
    return baseAllowance;
  }

  /// Calcule l'indemnité exacte d'un trajet selon le pays, le véhicule et le cumul annuel
  static TaxCalculationResult calculateTripAllowance({
    required String countryCode,
    required double tripDistanceKm,
    required double priorAnnualKmForVehicleFR,
    required Vehicle vehicle,
    required String purpose,
    required bool isProfessional,
    required TaxRatesConfig config,
  }) {
    if (!isProfessional || tripDistanceKm <= 0) {
      final curr = countryCode == 'CH' ? 'CHF' : 'EUR';
      return TaxCalculationResult(
        amount: 0.0,
        currency: curr,
        formulaSummary: 'Trajet privé (Non déductible)',
        bracketLabel: 'Privé - 0,00 $curr',
      );
    }

    switch (countryCode) {
      case 'FR':
        final clampedHp = vehicle.fiscalHp.clamp(3, 7);
        final row =
            config.frenchBrackets[clampedHp] ?? config.frenchBrackets[5]!;
        final beforeAllowance = computeFrenchAnnualAllowance(
          cumulativeKm: priorAnnualKmForVehicleFR,
          fiscalHp: clampedHp,
          isElectric: vehicle.isElectric,
          config: config,
        );
        final newCumulativeKm = priorAnnualKmForVehicleFR + tripDistanceKm;
        final afterAllowance = computeFrenchAnnualAllowance(
          cumulativeKm: newCumulativeKm,
          fiscalHp: clampedHp,
          isElectric: vehicle.isElectric,
          config: config,
        );
        final marginalAmount = math.max(0.0, afterAllowance - beforeAllowance);

        String bracketName;
        String formulaText;
        final elecSuffix = vehicle.isElectric
            ? ' (+${config.frenchElectricBonusPercent.toStringAsFixed(0)}% Élec)'
            : '';

        if (newCumulativeKm <= 5000) {
          bracketName = 'Tranche 1 (≤ 5 000 km)';
          formulaText =
              'FR ${clampedHp}CV : d × ${row.rateUpTo5000.toStringAsFixed(3)}€$elecSuffix';
        } else if (newCumulativeKm <= 20000) {
          bracketName = 'Tranche 2 (5 001 à 20 000 km)';
          formulaText =
              'FR ${clampedHp}CV : (d × ${row.rate5001To20000.toStringAsFixed(3)}€) + ${row.fixed5001To20000.toStringAsFixed(0)}€$elecSuffix';
        } else {
          bracketName = 'Tranche 3 (> 20 000 km)';
          formulaText =
              'FR ${clampedHp}CV : d × ${row.rateOver20000.toStringAsFixed(3)}€$elecSuffix';
        }

        return TaxCalculationResult(
          amount: marginalAmount,
          currency: 'EUR',
          formulaSummary: formulaText,
          bracketLabel: bracketName,
        );

      case 'LU':
        final amount = tripDistanceKm * config.luxembourgRateEur;
        return TaxCalculationResult(
          amount: amount,
          currency: 'EUR',
          formulaSummary:
              'Barème Grand-Ducal LU : ${config.luxembourgRateEur.toStringAsFixed(2)} €/km',
          bracketLabel: 'Forfait légal Luxembourg',
        );

      case 'BE':
        final amount = tripDistanceKm * config.belgiumRateEur;
        return TaxCalculationResult(
          amount: amount,
          currency: 'EUR',
          formulaSummary:
              'Forfait Fédéral BE : ${config.belgiumRateEur.toStringAsFixed(2)} €/km',
          bracketLabel: 'Forfait fédéral Belgique',
        );

      case 'DE':
        final isPendler = purpose.toLowerCase().contains('domicile') ||
            purpose.toLowerCase().contains('pendler');
        if (isPendler) {
          final first20 = math.min(tripDistanceKm, 20.0);
          final beyond20 = math.max(0.0, tripDistanceKm - 20.0);
          final amount = (first20 * config.germanyPendlerFirst20Eur) +
              (beyond20 * config.germanyPendlerAfter20Eur);
          return TaxCalculationResult(
            amount: amount,
            currency: 'EUR',
            formulaSummary:
                'DE Pendlerpauschale : 20km × ${config.germanyPendlerFirst20Eur.toStringAsFixed(2)}€ + >20km × ${config.germanyPendlerAfter20Eur.toStringAsFixed(2)}€',
            bracketLabel: 'Pendlerpauschale (DE)',
          );
        } else {
          final amount = tripDistanceKm * config.germanyDienstreisenEur;
          return TaxCalculationResult(
            amount: amount,
            currency: 'EUR',
            formulaSummary:
                'DE Dienstreisen : ${config.germanyDienstreisenEur.toStringAsFixed(2)} €/km',
            bracketLabel: 'Dienstreisen Pro (DE)',
          );
        }

      case 'CH':
        final amount = tripDistanceKm * config.switzerlandRateChf;
        return TaxCalculationResult(
          amount: amount,
          currency: 'CHF',
          formulaSummary:
              'Barème TCS / Fiscal CH : ${config.switzerlandRateChf.toStringAsFixed(2)} CHF/km',
          bracketLabel: 'Forfait Suisse (CHF)',
        );

      default:
        final amount = tripDistanceKm * 0.40;
        return TaxCalculationResult(
          amount: amount,
          currency: 'EUR',
          formulaSummary: 'Standard : 0.40 €/km',
          bracketLabel: 'Standard',
        );
    }
  }
}

// ============================================================================
// 5. SERVICE GOOGLE MAPS API + FALLBACK ROUTIER INTELLIGENT (OSRM/NOMINATIM)
// ============================================================================
class RouteCalculationResult {
  final double distanceKm;
  final String durationText;
  final String sourceLabel;

  RouteCalculationResult({
    required this.distanceKm,
    required this.durationText,
    required this.sourceLabel,
  });
}

class MapsRoutingService {
  /// Autocomplétion d'adresses : utilise Google Places Autocomplete si clé fournie,
  /// sinon combine les Favoris enregistrés + Nominatim OpenStreetMap.
  static Future<List<String>> autocompletePlaces({
    required String query,
    required String googleApiKey,
    required List<SavedPlace> savedPlaces,
  }) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return [];

    final results = <String>[];

    // 1. Recherche instantanée dans les adresses favorites
    for (final fav in savedPlaces) {
      if (fav.label.toLowerCase().contains(trimmed.toLowerCase()) ||
          fav.address.toLowerCase().contains(trimmed.toLowerCase())) {
        results.add('${fav.label} — ${fav.address}');
      }
    }

    // 2. Appel Google Places Autocomplete API si clé configurée
    if (googleApiKey.trim().isNotEmpty) {
      try {
        final uri = Uri.https(
          'maps.googleapis.com',
          '/maps/api/place/autocomplete/json',
          {
            'input': trimmed,
            'language': 'fr',
            'key': googleApiKey.trim(),
          },
        );
        final response =
            await http.get(uri).timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final predictions = (data['predictions'] as List?) ?? [];
          for (final p in predictions.take(5)) {
            final desc = p['description']?.toString() ?? '';
            if (desc.isNotEmpty && !results.contains(desc)) {
              results.add(desc);
            }
          }
          if (results.isNotEmpty) return results;
        }
      } catch (_) {
        // Bascule transparente vers le géocodeur de secours
      }
    }

    // 3. Fallback Nominatim OpenStreetMap (sans clé requise)
    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        {
          'q': trimmed,
          'format': 'json',
          'addressdetails': '1',
          'limit': '5',
          'accept-language': 'fr',
        },
      );
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'PiratePipsKiloTracker/1.0'},
      ).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List;
        for (final item in list) {
          final display = item['display_name']?.toString() ?? '';
          if (display.isNotEmpty && !results.contains(display)) {
            results.add(display);
          }
        }
      }
    } catch (_) {}

    return results;
  }

  /// Nettoie un libellé de favori ("Maison — 12 Rue...") pour ne garder que l'adresse postale
  static String extractPureAddress(String raw) {
    if (raw.contains(' — ')) {
      return raw.split(' — ').last.trim();
    }
    return raw.trim();
  }

  /// Calcul d'itinéraire multi-étapes (Départ -> Arrêts -> Arrivée)
  static Future<RouteCalculationResult> computeRouteDistance({
    required String origin,
    required String destination,
    required List<WaypointStop> waypoints,
    required String googleApiKey,
  }) async {
    final cleanOrigin = extractPureAddress(origin);
    final cleanDest = extractPureAddress(destination);
    final cleanWaypoints = waypoints
        .map((w) => extractPureAddress(w.address))
        .where((s) => s.isNotEmpty)
        .toList();

    // 1. Google Maps Directions API si clé renseignée
    if (googleApiKey.trim().isNotEmpty) {
      try {
        final params = <String, String>{
          'origin': cleanOrigin,
          'destination': cleanDest,
          'mode': 'driving',
          'language': 'fr',
          'key': googleApiKey.trim(),
        };
        if (cleanWaypoints.isNotEmpty) {
          params['waypoints'] = cleanWaypoints.join('|');
        }
        final uri = Uri.https(
          'maps.googleapis.com',
          '/maps/api/directions/json',
          params,
        );
        final response =
            await http.get(uri).timeout(const Duration(seconds: 6));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final routes = (data['routes'] as List?) ?? [];
          if (routes.isNotEmpty) {
            final legs = (routes.first['legs'] as List?) ?? [];
            double totalMeters = 0;
            int totalSeconds = 0;
            for (final leg in legs) {
              totalMeters +=
                  ((leg['distance']?['value'] ?? 0) as num).toDouble();
              totalSeconds += ((leg['duration']?['value'] ?? 0) as num).toInt();
            }
            final km = totalMeters / 1000.0;
            final mins = (totalSeconds / 60).round();
            return RouteCalculationResult(
              distanceKm: double.parse(km.toStringAsFixed(1)),
              durationText: '$mins min',
              sourceLabel: 'Google Maps Directions API',
            );
          }
        }
      } catch (_) {}
    }

    // 2. Routage routier réel OSRM + Nominatim (sans clé API)
    try {
      final allPoints = <String>[cleanOrigin, ...cleanWaypoints, cleanDest];
      final coords = <List<double>>[];

      for (final address in allPoints) {
        final geoUri = Uri.https(
          'nominatim.openstreetmap.org',
          '/search',
          {'q': address, 'format': 'json', 'limit': '1'},
        );
        final geoRes = await http.get(
          geoUri,
          headers: {'User-Agent': 'PiratePipsKiloTracker/1.0'},
        ).timeout(const Duration(seconds: 4));

        if (geoRes.statusCode == 200) {
          final list = jsonDecode(geoRes.body) as List;
          if (list.isNotEmpty) {
            final lat = double.tryParse(list.first['lat'].toString());
            final lon = double.tryParse(list.first['lon'].toString());
            if (lat != null && lon != null) {
              coords.add([lon, lat]);
            }
          }
        }
      }

      if (coords.length == allPoints.length && coords.length >= 2) {
        final coordPath = coords.map((c) => '${c[0]},${c[1]}').join(';');
        final osrmUri = Uri.parse(
          'https://router.project-osrm.org/route/v1/driving/$coordPath?overview=false',
        );
        final osrmRes =
            await http.get(osrmUri).timeout(const Duration(seconds: 5));
        if (osrmRes.statusCode == 200) {
          final data = jsonDecode(osrmRes.body) as Map<String, dynamic>;
          final routes = (data['routes'] as List?) ?? [];
          if (routes.isNotEmpty) {
            final meters =
                ((routes.first['distance'] ?? 0) as num).toDouble();
            final seconds =
                ((routes.first['duration'] ?? 0) as num).toDouble();
            final km = meters / 1000.0;
            final mins = (seconds / 60).round();
            return RouteCalculationResult(
              distanceKm: double.parse(km.toStringAsFixed(1)),
              durationText: '$mins min',
              sourceLabel: 'Calculateur Routier GPS (OSRM)',
            );
          }
        }
      }
    } catch (_) {}

    // 3. Estimation déterministe hors-ligne si absence de réseau
    final seed =
        cleanOrigin.length * 7 + cleanDest.length * 11 + cleanWaypoints.length * 19;
    final estimatedKm = 14.5 + (seed % 42) + (cleanWaypoints.length * 8.4);
    final mins = (estimatedKm * 1.15).round();
    return RouteCalculationResult(
      distanceKm: double.parse(estimatedKm.toStringAsFixed(1)),
      durationText: '$mins min',
      sourceLabel: 'Estimateur Hors-Ligne Pirate Pips™',
    );
  }
}

// ============================================================================
// 6. APPLICATION PRINCIPALE & SPLASH SCREEN PIRATE PIPS™
// ============================================================================
class PiratePipsKiloApp extends StatelessWidget {
  const PiratePipsKiloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pirate Pips™ KiloTracker',
      debugShowCheckedModeBanner: false,
      theme: PirateTheme.darkTheme,
      home: const SplashScreenWrapper(),
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper>
    with SingleTickerProviderStateMixin {
  bool _showSplash = true;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _animController.forward();

    Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() => _showSplash = false);
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return Scaffold(
        backgroundColor: PirateTheme.bgPrimary,
        body: Center(
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: PirateTheme.goldPrimary.withOpacity(0.28),
                        blurRadius: 36,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: const PiratePipsLogo(size: 118),
                ),
                const SizedBox(height: 24),
                const Text(
                  'PIRATE PIPS™',
                  style: TextStyle(
                    color: PirateTheme.textWhite,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: PirateTheme.goldPrimary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: PirateTheme.goldPrimary.withOpacity(0.5),
                    ),
                  ),
                  child: const Text(
                    'KILOTRACKER PRO • INDEMNITÉS KILOMÉTRIQUES',
                    style: TextStyle(
                      color: PirateTheme.goldPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: PirateTheme.goldPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Développé par Pirate Pips™',
                  style: TextStyle(
                    color: PirateTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return const MainShellScreen();
  }
}

// ============================================================================
// 7. SHELL PRINCIPAL & GESTION D'ÉTAT LOCAL-FIRST
// ============================================================================
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  List<Driver> _drivers = [];
  List<Vehicle> _vehicles = [];
  List<SavedPlace> _savedPlaces = [];
  List<TripRecord> _trips = [];
  TaxRatesConfig _taxConfig = TaxRatesConfig.defaults();

  String _defaultCountry = 'FR';
  double _defaultDetourMargin = 5.0;
  String _googleMapsApiKey = '';
  String _cloudSyncEndpoint = '';
  String? _lastCloudSyncStatus;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final prefs = await SharedPreferences.getInstance();

    // Conducteurs
    final rawDrivers = prefs.getString('pp_drivers_v1');
    if (rawDrivers != null) {
      final list = jsonDecode(rawDrivers) as List;
      _drivers = list
          .map((e) => Driver.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      _drivers = [
        Driver(
          id: 'drv_1',
          firstName: 'Antoine',
          lastName: 'Flory',
          status: 'Gérant',
        ),
        Driver(
          id: 'drv_2',
          firstName: 'Collaborateur',
          lastName: 'Commercial',
          status: 'Salarié',
        ),
      ];
    }

    // Véhicules
    final rawVehicles = prefs.getString('pp_vehicles_v1');
    if (rawVehicles != null) {
      final list = jsonDecode(rawVehicles) as List;
      _vehicles = list
          .map((e) => Vehicle.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      _vehicles = [
        Vehicle(
          id: 'veh_1',
          name: 'Mercedes-Benz GLC AMG',
          plate: 'PP-888-LU',
          type: 'Voiture',
          engine: 'Thermique Essence',
          fiscalHp: 7,
          odometerKm: 42500.0,
        ),
        Vehicle(
          id: 'veh_2',
          name: 'Ford Ranger Pick-up',
          plate: 'PP-404-FR',
          type: 'Utilitaire',
          engine: 'Thermique Diesel',
          fiscalHp: 7,
          odometerKm: 68200.0,
        ),
        Vehicle(
          id: 'veh_3',
          name: 'Berline Pro Électrique',
          plate: 'EV-2026-CH',
          type: 'Voiture',
          engine: 'Électrique',
          fiscalHp: 5,
          odometerKm: 15400.0,
        ),
      ];
    }

    // Adresses Favorites
    final rawPlaces = prefs.getString('pp_places_v1');
    if (rawPlaces != null) {
      final list = jsonDecode(rawPlaces) as List;
      _savedPlaces = list
          .map((e) => SavedPlace.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      _savedPlaces = [
        SavedPlace(
          id: 'plc_1',
          label: 'Maison (Domicile)',
          address: 'Uffheim, 68510, France',
          category: 'Maison',
        ),
        SavedPlace(
          id: 'plc_2',
          label: 'Siège Social Luxembourg',
          address: 'Boulevard Royal, L-2449 Luxembourg',
          category: 'Siège',
        ),
        SavedPlace(
          id: 'plc_3',
          label: 'Dépôt Logistique Grand Est',
          address: 'Avenue de Colmar, 68100 Mulhouse, France',
          category: 'Dépôt',
        ),
        SavedPlace(
          id: 'plc_4',
          label: 'Client Bâle / Suisse',
          address: 'Aeschenplatz, 4052 Basel, Suisse',
          category: 'Client',
        ),
      ];
    }

    // Barèmes fiscaux
    final rawTax = prefs.getString('pp_tax_config_v1');
    if (rawTax != null) {
      _taxConfig =
          TaxRatesConfig.fromJson(jsonDecode(rawTax) as Map<String, dynamic>);
    }

    // Paramètres généraux
    _defaultCountry = prefs.getString('pp_default_country') ?? 'FR';
    _defaultDetourMargin = prefs.getDouble('pp_default_margin') ?? 5.0;
    _googleMapsApiKey = prefs.getString('pp_gmaps_key') ?? '';
    _cloudSyncEndpoint = prefs.getString('pp_cloud_url') ?? '';

    // Trajets
    final rawTrips = prefs.getString('pp_trips_v1');
    if (rawTrips != null) {
      final list = jsonDecode(rawTrips) as List;
      _trips = list
          .map((e) => TripRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      // Exemples initiaux réalistes
      _trips = [
        TripRecord(
          id: 'trp_demo_1',
          date: DateTime.now().subtract(const Duration(days: 2)),
          timeLabel: '08:15',
          driverId: _drivers.first.id,
          vehicleId: _vehicles.first.id,
          countryCode: 'FR',
          origin: 'Uffheim, 68510, France',
          destination: 'Avenue de Colmar, 68100 Mulhouse, France',
          waypoints: [
            WaypointStop(
              label: 'Arrêt Magasin Pro',
              address: 'Sierentz, 68510, France',
            ),
          ],
          isRoundTrip: true,
          purpose: 'Chantier',
          isProfessional: true,
          mapsDistanceKm: 48.0,
          detourMarginPercent: 5.0,
          totalDistanceKm: 50.4,
          odometerStart: 42449.6,
          odometerEnd: 42500.0,
          reimbursementAmount: 35.13,
          currency: 'EUR',
          formulaApplied: 'FR 7CV : d × 0.697€',
          notes: 'Visite technique chantier + retrait matériel pro',
          receiptReference: 'TICKET-PARKING-01',
        ),
        TripRecord(
          id: 'trp_demo_2',
          date: DateTime.now().subtract(const Duration(days: 1)),
          timeLabel: '14:00',
          driverId: _drivers.first.id,
          vehicleId: _vehicles.first.id,
          countryCode: 'LU',
          origin: 'Boulevard Royal, L-2449 Luxembourg',
          destination: 'Kirchberg, Luxembourg',
          waypoints: [],
          isRoundTrip: true,
          purpose: 'Administratif',
          isProfessional: true,
          mapsDistanceKm: 18.0,
          detourMarginPercent: 5.0,
          totalDistanceKm: 18.9,
          odometerStart: 42500.0,
          odometerEnd: 42518.9,
          reimbursementAmount: 7.56,
          currency: 'EUR',
          formulaApplied: 'Barème Grand-Ducal LU : 0.40 €/km',
          notes: 'Rendez-vous banque & fiduciaire',
          receiptReference: null,
        ),
      ];
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _persistAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'pp_drivers_v1',
      jsonEncode(_drivers.map((d) => d.toJson()).toList()),
    );
    await prefs.setString(
      'pp_vehicles_v1',
      jsonEncode(_vehicles.map((v) => v.toJson()).toList()),
    );
    await prefs.setString(
      'pp_places_v1',
      jsonEncode(_savedPlaces.map((p) => p.toJson()).toList()),
    );
    await prefs.setString(
      'pp_trips_v1',
      jsonEncode(_trips.map((t) => t.toJson()).toList()),
    );
    await prefs.setString(
      'pp_tax_config_v1',
      jsonEncode(_taxConfig.toJson()),
    );
    await prefs.setString('pp_default_country', _defaultCountry);
    await prefs.setDouble('pp_default_margin', _defaultDetourMargin);
    await prefs.setString('pp_gmaps_key', _googleMapsApiKey);
    await prefs.setString('pp_cloud_url', _cloudSyncEndpoint);
  }

  /// Cumul annuel des kilomètres professionnels en France pour un véhicule donné
  double _getAnnualFrenchProKmForVehicle(String vehicleId, int year) {
    return _trips
        .where((t) =>
            t.vehicleId == vehicleId &&
            t.countryCode == 'FR' &&
            t.isProfessional &&
            t.date.year == year)
        .fold(0.0, (sum, t) => sum + t.totalDistanceKm);
  }

  void _addTripAndIncrementOdometer(TripRecord newTrip) {
    setState(() {
      _trips.insert(0, newTrip);
      final vIndex = _vehicles.indexWhere((v) => v.id == newTrip.vehicleId);
      if (vIndex != -1) {
        if (newTrip.odometerEnd > _vehicles[vIndex].odometerKm) {
          _vehicles[vIndex].odometerKm = newTrip.odometerEnd;
        } else {
          _vehicles[vIndex].odometerKm += newTrip.totalDistanceKm;
        }
      }
      _selectedIndex = 0; // Retour au Dashboard avec confirmation
    });
    _persistAll();
  }

  void _deleteTrip(String tripId) {
    setState(() {
      _trips.removeWhere((t) => t.id == tripId);
    });
    _persistAll();
  }

  Future<void> _triggerCloudSync() async {
    if (_cloudSyncEndpoint.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: PirateTheme.bearRed,
          content: Text(
            'Veuillez renseigner une URL Webhook/Cloud dans les Paramètres.',
          ),
        ),
      );
      return;
    }

    try {
      final payload = {
        'brand': 'Pirate Pips™ KiloTracker',
        'exportedAt': DateTime.now().toIso8601String(),
        'drivers': _drivers.map((e) => e.toJson()).toList(),
        'vehicles': _vehicles.map((e) => e.toJson()).toList(),
        'trips': _trips.map((e) => e.toJson()).toList(),
      };
      final res = await http
          .post(
            Uri.parse(_cloudSyncEndpoint.trim()),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 6));

      setState(() {
        _lastCloudSyncStatus =
            'Synchro Cloud réussie (HTTP ${res.statusCode}) à ${TimeOfDay.now().format(context)}';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: PirateTheme.bullGreen,
            content: Text(_lastCloudSyncStatus!),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _lastCloudSyncStatus = 'Mode Local-First actif (Cloud hors-ligne)';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: PirateTheme.bgPrimary,
        body: Center(
          child: CircularProgressIndicator(color: PirateTheme.goldPrimary),
        ),
      );
    }

    final pages = [
      DashboardTab(
        trips: _trips,
        drivers: _drivers,
        vehicles: _vehicles,
        taxConfig: _taxConfig,
        onNewTripTap: () => setState(() => _selectedIndex = 1),
        onOpenExportsTap: () => setState(() => _selectedIndex = 2),
      ),
      NewTripTab(
        drivers: _drivers,
        vehicles: _vehicles,
        savedPlaces: _savedPlaces,
        taxConfig: _taxConfig,
        defaultCountry: _defaultCountry,
        defaultMarginPercent: _defaultDetourMargin,
        googleMapsApiKey: _googleMapsApiKey,
        getPriorAnnualKmFR: _getAnnualFrenchProKmForVehicle,
        onSaveTrip: _addTripAndIncrementOdometer,
        onAddSavedPlace: (place) {
          setState(() => _savedPlaces.add(place));
          _persistAll();
        },
      ),
      HistoryAndExportsTab(
        trips: _trips,
        drivers: _drivers,
        vehicles: _vehicles,
        onDeleteTrip: _deleteTrip,
        onDuplicateReturnTrip: (trip) {
          final v = _vehicles.firstWhere(
            (veh) => veh.id == trip.vehicleId,
            orElse: () => _vehicles.first,
          );
          final priorKm = _getAnnualFrenchProKmForVehicle(v.id, DateTime.now().year);
          final calc = FiscalEngine.calculateTripAllowance(
            countryCode: trip.countryCode,
            tripDistanceKm: trip.totalDistanceKm,
            priorAnnualKmForVehicleFR: priorKm,
            vehicle: v,
            purpose: trip.purpose,
            isProfessional: trip.isProfessional,
            config: _taxConfig,
          );
          final duplicated = TripRecord(
            id: 'trp_${DateTime.now().millisecondsSinceEpoch}',
            date: DateTime.now(),
            timeLabel: TimeOfDay.now().format(context),
            driverId: trip.driverId,
            vehicleId: trip.vehicleId,
            countryCode: trip.countryCode,
            origin: trip.destination,
            destination: trip.origin,
            waypoints: trip.waypoints.reversed.toList(),
            isRoundTrip: false,
            purpose: trip.purpose,
            isProfessional: trip.isProfessional,
            mapsDistanceKm: trip.mapsDistanceKm,
            detourMarginPercent: trip.detourMarginPercent,
            totalDistanceKm: trip.totalDistanceKm,
            odometerStart: v.odometerKm,
            odometerEnd: v.odometerKm + trip.totalDistanceKm,
            reimbursementAmount: calc.amount,
            currency: calc.currency,
            formulaApplied: calc.formulaSummary,
            notes: 'Trajet retour généré automatiquement (${trip.notes})',
            receiptReference: trip.receiptReference,
          );
          _addTripAndIncrementOdometer(duplicated);
        },
      ),
      GarageAndProfilesTab(
        drivers: _drivers,
        vehicles: _vehicles,
        savedPlaces: _savedPlaces,
        onChanged: () {
          setState(() {});
          _persistAll();
        },
      ),
      FiscalSettingsAndAboutTab(
        taxConfig: _taxConfig,
        defaultCountry: _defaultCountry,
        defaultMargin: _defaultDetourMargin,
        googleMapsApiKey: _googleMapsApiKey,
        cloudSyncEndpoint: _cloudSyncEndpoint,
        lastCloudSyncStatus: _lastCloudSyncStatus,
        onUpdateSettings: ({
          required String country,
          required double margin,
          required String gmapsKey,
          required String cloudUrl,
        }) {
          setState(() {
            _defaultCountry = country;
            _defaultDetourMargin = margin;
            _googleMapsApiKey = gmapsKey;
            _cloudSyncEndpoint = cloudUrl;
          });
          _persistAll();
        },
        onTaxConfigChanged: () {
          setState(() {});
          _persistAll();
        },
        onTriggerCloudSync: _triggerCloudSync,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: PirateTheme.bgSecondary,
        title: Row(
          children: [
            const PiratePipsLogo(size: 34),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PIRATE PIPS™ KILOTRACKER',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                      color: PirateTheme.textWhite,
                    ),
                  ),
                  Text(
                    'Développé par Pirate Pips™ • Barèmes FR / LU / BE / DE / CH',
                    style: TextStyle(
                      fontSize: 10,
                      color: PirateTheme.goldPrimary.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: PirateTheme.goldPrimary.withOpacity(0.35),
          ),
        ),
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: PirateTheme.bgSecondary,
          border: Border(
            top: BorderSide(
              color: PirateTheme.goldPrimary.withOpacity(0.35),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (idx) => setState(() => _selectedIndex = idx),
          type: BottomNavigationBarType.fixed,
          backgroundColor: PirateTheme.bgSecondary,
          selectedItemColor: PirateTheme.goldPrimary,
          unselectedItemColor: PirateTheme.textMuted,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_road),
              label: 'Nouveau Trajet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Journal & PDF',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.garage),
              label: 'Garage & Profils',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tune),
              label: 'Fisc & Infos',
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 8. ONGLET 1 : TABLEAU DE BORD & STATISTIQUES PIRATE PIPS™
// ============================================================================
class DashboardTab extends StatefulWidget {
  final List<TripRecord> trips;
  final List<Driver> drivers;
  final List<Vehicle> vehicles;
  final TaxRatesConfig taxConfig;
  final VoidCallback onNewTripTap;
  final VoidCallback onOpenExportsTap;

  const DashboardTab({
    super.key,
    required this.trips,
    required this.drivers,
    required this.vehicles,
    required this.taxConfig,
    required this.onNewTripTap,
    required this.onOpenExportsTap,
  });

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  String _periodFilter = 'YEAR'; // MONTH, YEAR, ALL

  List<TripRecord> get _filteredTrips {
    final now = DateTime.now();
    return widget.trips.where((t) {
      if (_periodFilter == 'MONTH') {
        return t.date.year == now.year && t.date.month == now.month;
      } else if (_periodFilter == 'YEAR') {
        return t.date.year == now.year;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTrips;
    final proTrips = filtered.where((t) => t.isProfessional).toList();
    final privateTrips = filtered.where((t) => !t.isProfessional).toList();

    final totalProKm =
        proTrips.fold<double>(0.0, (s, t) => s + t.totalDistanceKm);
    final totalPrivateKm =
        privateTrips.fold<double>(0.0, (s, t) => s + t.totalDistanceKm);

    final totalEur = proTrips
        .where((t) => t.currency == 'EUR')
        .fold<double>(0.0, (s, t) => s + t.reimbursementAmount);
    final totalChf = proTrips
        .where((t) => t.currency == 'CHF')
        .fold<double>(0.0, (s, t) => s + t.reimbursementAmount);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Bandeau d'action rapide + Filtre temporel
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'TABLEAU DE BORD',
              style: TextStyle(
                color: PirateTheme.goldPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 1.2,
              ),
            ),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'MONTH', label: Text('Mois')),
                ButtonSegment(value: 'YEAR', label: Text('Année')),
                ButtonSegment(value: 'ALL', label: Text('Tout')),
              ],
              selected: {_periodFilter},
              onSelectionChanged: (s) =>
                  setState(() => _periodFilter = s.first),
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                textStyle: WidgetStateProperty.all(
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Cartes KPI principales cerclées d'Or
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A160B), Color(0xFF121212)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PirateTheme.goldPrimary, width: 1.4),
            boxShadow: [
              BoxShadow(
                color: PirateTheme.goldPrimary.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: PirateTheme.bullGreen.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.trending_up,
                      color: PirateTheme.bullGreen,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'SOLDE D\'INDEMNITÉS À REMBOURSER / DÉDUIRE',
                      style: TextStyle(
                        color: PirateTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${totalEur.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      color: PirateTheme.bullGreen,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (totalChf > 0) ...[
                    const SizedBox(width: 14),
                    Text(
                      '+ ${totalChf.toStringAsFixed(2)} CHF',
                      style: const TextStyle(
                        color: PirateTheme.goldPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: PirateTheme.borderDark),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MiniStatBadge(
                    label: 'KM PRO DÉDUCTIBLES',
                    value: '${totalProKm.toStringAsFixed(1)} km',
                    color: PirateTheme.goldPrimary,
                  ),
                  _MiniStatBadge(
                    label: 'TRAJETS PROS',
                    value: '${proTrips.length} trajets',
                    color: PirateTheme.bullGreen,
                  ),
                  _MiniStatBadge(
                    label: 'KM PRIVÉS (NON DÉD.)',
                    value: '${totalPrivateKm.toStringAsFixed(1)} km',
                    color: PirateTheme.bearRed,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Boutons d'action rapides CTA Or
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.onNewTripTap,
                icon: const Icon(Icons.add_road, size: 18),
                label: const Text('ENREGISTRER UN TRAJET'),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: widget.onOpenExportsTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: PirateTheme.goldPrimary,
                side: const BorderSide(color: PirateTheme.goldPrimary),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.picture_as_pdf, size: 18),
              label: const Text('EXPORT PDF / CSV'),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Répartition par Véhicule & Jauge Tranche Fiscale Française
        _buildSectionHeader(
          'RÉPARTITION PAR VÉHICULE & TRANCHES FISCALES',
          Icons.directions_car,
        ),
        const SizedBox(height: 10),
        ...widget.vehicles.map((v) {
          final vTrips =
              proTrips.where((t) => t.vehicleId == v.id).toList();
          final vKm =
              vTrips.fold<double>(0.0, (s, t) => s + t.totalDistanceKm);
          final vEur = vTrips
              .where((t) => t.currency == 'EUR')
              .fold<double>(0.0, (s, t) => s + t.reimbursementAmount);
          final vChf = vTrips
              .where((t) => t.currency == 'CHF')
              .fold<double>(0.0, (s, t) => s + t.reimbursementAmount);

          final progressTo20k = (vKm / 20000.0).clamp(0.0, 1.0);
          String frBracketStatus;
          if (vKm <= 5000) {
            frBracketStatus = 'Tranche 1 (0 - 5 000 km)';
          } else if (vKm <= 20000) {
            frBracketStatus = 'Tranche 2 (5 001 - 20 000 km)';
          } else {
            frBracketStatus = 'Tranche 3 (> 20 000 km)';
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: PirateTheme.bgSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: vKm > 0
                    ? PirateTheme.goldPrimary.withOpacity(0.45)
                    : PirateTheme.borderDark,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            v.type == 'Moto'
                                ? Icons.two_wheeler
                                : v.type == 'Utilitaire'
                                    ? Icons.local_shipping
                                    : Icons.directions_car,
                            color: PirateTheme.goldPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${v.name} (${v.plate})',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: PirateTheme.bgElevated,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${v.fiscalHp} CV • ${v.engine}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: PirateTheme.goldSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Odomètre : ${v.odometerKm.toStringAsFixed(0)} km',
                      style: const TextStyle(
                        color: PirateTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Pro : ${vKm.toStringAsFixed(1)} km  |  ${vEur.toStringAsFixed(2)} €${vChf > 0 ? " + ${vChf.toStringAsFixed(2)} CHF" : ""}',
                      style: const TextStyle(
                        color: PirateTheme.bullGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progressTo20k,
                    minHeight: 7,
                    backgroundColor: PirateTheme.bgElevated,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      PirateTheme.goldPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      frBracketStatus,
                      style: const TextStyle(
                        fontSize: 10,
                        color: PirateTheme.textMuted,
                      ),
                    ),
                    const Text(
                      'Seuils FR : 5 000 km / 20 000 km',
                      style: TextStyle(
                        fontSize: 10,
                        color: PirateTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 12),
        // Répartition par Conducteur
        _buildSectionHeader(
          'RÉPARTITION PAR CONDUCTEUR',
          Icons.people,
        ),
        const SizedBox(height: 10),
        ...widget.drivers.map((d) {
          final dTrips =
              proTrips.where((t) => t.driverId == d.id).toList();
          final dKm =
              dTrips.fold<double>(0.0, (s, t) => s + t.totalDistanceKm);
          final dEur = dTrips
              .where((t) => t.currency == 'EUR')
              .fold<double>(0.0, (s, t) => s + t.reimbursementAmount);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: PirateTheme.bgSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PirateTheme.borderDark),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor:
                          PirateTheme.goldPrimary.withOpacity(0.2),
                      child: const Icon(
                        Icons.person,
                        color: PirateTheme.goldPrimary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Statut : ${d.status}',
                          style: const TextStyle(
                            color: PirateTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${dEur.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        color: PirateTheme.bullGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${dKm.toStringAsFixed(1)} km (${dTrips.length} trajets)',
                      style: const TextStyle(
                        color: PirateTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: PirateTheme.goldPrimary, size: 17),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: PirateTheme.textWhite,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.9,
          ),
        ),
      ],
    );
  }
}

class _MiniStatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStatBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: PirateTheme.textMuted,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// 9. ONGLET 2 : SAISIE DE TRAJET, GOOGLE MAPS, ÉTAPES & MARGE DE PRÉCISION
// ============================================================================
class NewTripTab extends StatefulWidget {
  final List<Driver> drivers;
  final List<Vehicle> vehicles;
  final List<SavedPlace> savedPlaces;
  final TaxRatesConfig taxConfig;
  final String defaultCountry;
  final double defaultMarginPercent;
  final String googleMapsApiKey;
  final double Function(String vehicleId, int year) getPriorAnnualKmFR;
  final void Function(TripRecord trip) onSaveTrip;
  final void Function(SavedPlace place) onAddSavedPlace;

  const NewTripTab({
    super.key,
    required this.drivers,
    required this.vehicles,
    required this.savedPlaces,
    required this.taxConfig,
    required this.defaultCountry,
    required this.defaultMarginPercent,
    required this.googleMapsApiKey,
    required this.getPriorAnnualKmFR,
    required this.onSaveTrip,
    required this.onAddSavedPlace,
  });

  @override
  State<NewTripTab> createState() => _NewTripTabState();
}

class _NewTripTabState extends State<NewTripTab> {
  late String _selectedDriverId;
  late String _selectedVehicleId;
  late String _selectedCountry; // FR, LU, BE, DE, CH
  DateTime _selectedDate = DateTime.now();
  String _timeLabel = '08:30';

  final TextEditingController _originCtrl = TextEditingController();
  final TextEditingController _destCtrl = TextEditingController();
  final TextEditingController _mapsKmCtrl =
      TextEditingController(text: '25.0');
  final TextEditingController _odoStartCtrl = TextEditingController();
  final TextEditingController _odoEndCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  final List<WaypointStop> _waypoints = [];
  List<String> _originSuggestions = [];
  List<String> _destSuggestions = [];

  bool _isRoundTrip = false;
  bool _isProfessional = true; // Vert = Pro, Rouge = Privé
  String _purpose = 'Client';
  late double _detourMarginPercent;
  bool _isCalculatingRoute = false;
  String _routeSourceInfo = 'Saisie directe ou calcul GPS Google Maps';
  String? _receiptAttachmentTag;

  static const List<Map<String, String>> _countries = [
    {'code': 'FR', 'name': 'France (Tranches CV)'},
    {'code': 'LU', 'name': 'Luxembourg (Forfait)'},
    {'code': 'BE', 'name': 'Belgique (Forfait)'},
    {'code': 'DE', 'name': 'Allemagne (Dienstreisen / Pendler)'},
    {'code': 'CH', 'name': 'Suisse (CHF / TCS)'},
  ];

  static const List<String> _purposes = [
    'Client',
    'Chantier',
    'Réunion',
    'Administratif',
    'Domicile-Travail (Pendler)',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDriverId =
        widget.drivers.isNotEmpty ? widget.drivers.first.id : '';
    _selectedVehicleId =
        widget.vehicles.isNotEmpty ? widget.vehicles.first.id : '';
    _selectedCountry = widget.defaultCountry;
    _detourMarginPercent = widget.defaultMarginPercent;

    if (widget.savedPlaces.length >= 2) {
      _originCtrl.text = widget.savedPlaces[0].address;
      _destCtrl.text = widget.savedPlaces[1].address;
    }
    _syncOdometerFromVehicle();
  }

  @override
  void dispose() {
    _originCtrl.dispose();
    _destCtrl.dispose();
    _mapsKmCtrl.dispose();
    _odoStartCtrl.dispose();
    _odoEndCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Vehicle get _activeVehicle {
    return widget.vehicles.firstWhere(
      (v) => v.id == _selectedVehicleId,
      orElse: () => widget.vehicles.first,
    );
  }

  void _syncOdometerFromVehicle() {
    final v = _activeVehicle;
    _odoStartCtrl.text = v.odometerKm.toStringAsFixed(1);
    _recomputeTotalAndOdoEnd();
  }

  double get _baseMapsKm {
    final raw =
        double.tryParse(_mapsKmCtrl.text.replaceAll(',', '.')) ?? 0.0;
    return _isRoundTrip ? raw * 2.0 : raw;
  }

  double get _finalTotalKm {
    final base = _baseMapsKm;
    final withMargin = base * (1.0 + (_detourMarginPercent / 100.0));
    return double.parse(withMargin.toStringAsFixed(1));
  }

  void _recomputeTotalAndOdoEnd() {
    final start =
        double.tryParse(_odoStartCtrl.text.replaceAll(',', '.')) ?? 0.0;
    final end = start + _finalTotalKm;
    _odoEndCtrl.text = end.toStringAsFixed(1);
    setState(() {});
  }

  void _onManualOdoEndChanged(String val) {
    final start =
        double.tryParse(_odoStartCtrl.text.replaceAll(',', '.')) ?? 0.0;
    final end = double.tryParse(val.replaceAll(',', '.')) ?? start;
    if (end >= start) {
      final diff = end - start;
      final divisor = (1.0 + (_detourMarginPercent / 100.0)) *
          (_isRoundTrip ? 2.0 : 1.0);
      if (divisor > 0) {
        _mapsKmCtrl.text = (diff / divisor).toStringAsFixed(1);
      }
      setState(() {});
    }
  }

  Future<void> _runGoogleMapsRouteCalculation() async {
    if (_originCtrl.text.trim().isEmpty || _destCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: PirateTheme.bearRed,
          content: Text('Veuillez renseigner une adresse de départ et d\'arrivée.'),
        ),
      );
      return;
    }

    setState(() => _isCalculatingRoute = true);
    final res = await MapsRoutingService.computeRouteDistance(
      origin: _originCtrl.text,
      destination: _destCtrl.text,
      waypoints: _waypoints,
      googleApiKey: widget.googleMapsApiKey,
    );
    if (!mounted) return;
    setState(() {
      _isCalculatingRoute = false;
      _mapsKmCtrl.text = res.distanceKm.toStringAsFixed(1);
      _routeSourceInfo =
          '${res.sourceLabel} • Durée estimée : ${res.durationText}';
      _recomputeTotalAndOdoEnd();
    });
  }

  void _invertOriginAndDestination() {
    setState(() {
      final tmp = _originCtrl.text;
      _originCtrl.text = _destCtrl.text;
      _destCtrl.text = tmp;
      if (_waypoints.length > 1) {
        final reversed = _waypoints.reversed.toList();
        _waypoints
          ..clear()
          ..addAll(reversed);
      }
    });
  }

  void _showAddWaypointDialog() {
    final labelCtrl = TextEditingController(text: 'Arrêt Pro / Magasin');
    final addrCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PirateTheme.bgSecondary,
        title: const Text('Ajouter une étape intermédiaire'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'arrêt (ex: Fournisseur, Supermarché)',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: addrCtrl,
                decoration: const InputDecoration(
                  labelText: 'Adresse ou ville de l\'étape',
                ),
              ),
              const SizedBox(height: 12),
              if (widget.savedPlaces.isNotEmpty) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Ou choisir un favori :',
                    style: TextStyle(
                      fontSize: 11,
                      color: PirateTheme.goldPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: widget.savedPlaces.map((p) {
                    return ActionChip(
                      label: Text(
                        p.label,
                        style: const TextStyle(fontSize: 11),
                      ),
                      onPressed: () {
                        labelCtrl.text = p.label;
                        addrCtrl.text = p.address;
                      },
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (addrCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _waypoints.add(
                    WaypointStop(
                      label: labelCtrl.text.trim().isEmpty
                          ? 'Étape'
                          : labelCtrl.text.trim(),
                      address: addrCtrl.text.trim(),
                    ),
                  );
                });
                Navigator.pop(ctx);
                _runGoogleMapsRouteCalculation();
              }
            },
            child: const Text('Ajouter l\'étape'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = _activeVehicle;
    final priorAnnualKmFR =
        widget.getPriorAnnualKmFR(vehicle.id, _selectedDate.year);

    final previewCalc = FiscalEngine.calculateTripAllowance(
      countryCode: _selectedCountry,
      tripDistanceKm: _finalTotalKm,
      priorAnnualKmForVehicleFR: priorAnnualKmFR,
      vehicle: vehicle,
      purpose: _purpose,
      isProfessional: _isProfessional,
      config: widget.taxConfig,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. SÉLECTEUR RAPIDE : STATUT PRO / PRIVÉ (BOUGIE VERTE VS ROUGE)
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isProfessional = true),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _isProfessional
                        ? PirateTheme.bullGreen.withOpacity(0.2)
                        : PirateTheme.bgSecondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isProfessional
                          ? PirateTheme.bullGreen
                          : PirateTheme.borderDark,
                      width: 1.5,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: PirateTheme.bullGreen,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'PROFESSIONNEL (DÉDUCTIBLE)',
                        style: TextStyle(
                          color: PirateTheme.bullGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isProfessional = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: !_isProfessional
                        ? PirateTheme.bearRed.withOpacity(0.2)
                        : PirateTheme.bgSecondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: !_isProfessional
                          ? PirateTheme.bearRed
                          : PirateTheme.borderDark,
                      width: 1.5,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.trending_down,
                        color: PirateTheme.bearRed,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'PRIVÉ (NON DÉDUCTIBLE)',
                        style: TextStyle(
                          color: PirateTheme.bearRed,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 2. CONDUCTEUR, VÉHICULE & PAYS FISCAL
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PROFIL CONDUCTEUR, VÉHICULE & JURIDICTION FISCALE',
                  style: TextStyle(
                    color: PirateTheme.goldPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedDriverId,
                        decoration: const InputDecoration(
                          labelText: 'Conducteur actif',
                          prefixIcon: Icon(Icons.person, size: 18),
                        ),
                        items: widget.drivers.map((d) {
                          return DropdownMenuItem(
                            value: d.id,
                            child: Text(
                              '${d.fullName} (${d.status})',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedDriverId = val);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCountry,
                        decoration: const InputDecoration(
                          labelText: 'Barème Pays',
                          prefixIcon: Icon(Icons.flag, size: 18),
                        ),
                        items: _countries.map((c) {
                          return DropdownMenuItem(
                            value: c['code'],
                            child: Text(
                              '${c['code']} - ${c['name']!.split(' ').first}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedCountry = val);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedVehicleId,
                  decoration: const InputDecoration(
                    labelText: 'Véhicule utilisé',
                    prefixIcon: Icon(Icons.directions_car, size: 18),
                  ),
                  items: widget.vehicles.map((v) {
                    return DropdownMenuItem(
                      value: v.id,
                      child: Text(
                        '${v.name} • ${v.fiscalHp} CV • ${v.engine}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedVehicleId = val;
                        _syncOdometerFromVehicle();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 3. ITINÉRAIRE GOOGLE MAPS, FAVORIS & MULTI-ÉTAPES
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ITINÉRAIRE GOOGLE MAPS & ADRESSES FAVORITES',
                      style: TextStyle(
                        color: PirateTheme.goldPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: _invertOriginAndDestination,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: PirateTheme.goldPrimary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.swap_vert,
                              size: 15,
                              color: PirateTheme.goldPrimary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Inverser A ↔ B',
                              style: TextStyle(
                                fontSize: 11,
                                color: PirateTheme.goldPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Sélection rapide d'un favori pour Départ
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: widget.savedPlaces.map((fav) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          visualDensity: VisualDensity.compact,
                          avatar: const Icon(
                            Icons.star,
                            size: 14,
                            color: PirateTheme.goldPrimary,
                          ),
                          label: Text(
                            'A: ${fav.label}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          onPressed: () {
                            setState(() {
                              _originCtrl.text = fav.address;
                              _originSuggestions.clear();
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),

                // Champ Point A (Départ) avec Autocomplétion
                TextField(
                  controller: _originCtrl,
                  decoration: InputDecoration(
                    labelText: 'Point A — Adresse de départ',
                    prefixIcon: const Icon(
                      Icons.my_location,
                      color: PirateTheme.bullGreen,
                      size: 18,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => setState(() {
                        _originCtrl.clear();
                        _originSuggestions.clear();
                      }),
                    ),
                  ),
                  onChanged: (val) async {
                    final list = await MapsRoutingService.autocompletePlaces(
                      query: val,
                      googleApiKey: widget.googleMapsApiKey,
                      savedPlaces: widget.savedPlaces,
                    );
                    if (mounted) {
                      setState(() => _originSuggestions = list);
                    }
                  },
                ),
                if (_originSuggestions.isNotEmpty)
                  _buildAutocompleteDropdown(
                    suggestions: _originSuggestions,
                    onSelect: (selected) {
                      setState(() {
                        _originCtrl.text =
                            MapsRoutingService.extractPureAddress(selected);
                        _originSuggestions.clear();
                      });
                    },
                  ),

                // Liste des étapes intermédiaires (Waypoints)
                if (_waypoints.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ..._waypoints.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final stop = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: PirateTheme.bgElevated,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: PirateTheme.goldSecondary.withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.route,
                            color: PirateTheme.goldPrimary,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Arrêt ${idx + 1} (${stop.label}) : ${stop.address}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: PirateTheme.bearRed,
                              size: 18,
                            ),
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              setState(() => _waypoints.removeAt(idx));
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                const SizedBox(height: 8),
                // Bouton Ajouter une étape intermédiaire
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _showAddWaypointDialog,
                    icon: const Icon(
                      Icons.add,
                      size: 16,
                      color: PirateTheme.goldPrimary,
                    ),
                    label: const Text(
                      'Ajouter un arrêt intermédiaire (Magasin pro, Client, Chantier)',
                      style: TextStyle(
                        fontSize: 12,
                        color: PirateTheme.goldPrimary,
                      ),
                    ),
                  ),
                ),

                // Sélection rapide d'un favori pour Arrivée
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: widget.savedPlaces.map((fav) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          visualDensity: VisualDensity.compact,
                          avatar: const Icon(
                            Icons.place,
                            size: 14,
                            color: PirateTheme.goldSecondary,
                          ),
                          label: Text(
                            'B: ${fav.label}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          onPressed: () {
                            setState(() {
                              _destCtrl.text = fav.address;
                              _destSuggestions.clear();
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),

                // Champ Point B (Arrivée) avec Autocomplétion
                TextField(
                  controller: _destCtrl,
                  decoration: InputDecoration(
                    labelText: 'Point B — Adresse d\'arrivée',
                    prefixIcon: const Icon(
                      Icons.place,
                      color: PirateTheme.bearRed,
                      size: 18,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => setState(() {
                        _destCtrl.clear();
                        _destSuggestions.clear();
                      }),
                    ),
                  ),
                  onChanged: (val) async {
                    final list = await MapsRoutingService.autocompletePlaces(
                      query: val,
                      googleApiKey: widget.googleMapsApiKey,
                      savedPlaces: widget.savedPlaces,
                    );
                    if (mounted) {
                      setState(() => _destSuggestions = list);
                    }
                  },
                ),
                if (_destSuggestions.isNotEmpty)
                  _buildAutocompleteDropdown(
                    suggestions: _destSuggestions,
                    onSelect: (selected) {
                      setState(() {
                        _destCtrl.text =
                            MapsRoutingService.extractPureAddress(selected);
                        _destSuggestions.clear();
                      });
                    },
                  ),

                const SizedBox(height: 12),

                // Bouton Calculer l'itinéraire Google Maps + Toggle Aller-Retour
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isCalculatingRoute
                            ? null
                            : _runGoogleMapsRouteCalculation,
                        icon: _isCalculatingRoute
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Icon(Icons.calculate, size: 18),
                        label: Text(
                          _isCalculatingRoute
                              ? 'CALCUL GPS...'
                              : 'CALCULER KM GOOGLE MAPS',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _routeSourceInfo,
                  style: const TextStyle(
                    fontSize: 11,
                    color: PirateTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 8),

                // Switch Trajet Retour Identique (Aller-Retour x2)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: PirateTheme.goldPrimary,
                  title: const Text(
                    'Trajet retour identique (Aller-Retour ×2)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Double automatiquement la distance du tracé aller',
                    style: TextStyle(fontSize: 11, color: PirateTheme.textMuted),
                  ),
                  value: _isRoundTrip,
                  onChanged: (val) {
                    setState(() {
                      _isRoundTrip = val;
                      _recomputeTotalAndOdoEnd();
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 4. MARGE DE PRÉCISION / DÉTOURS & ODOMÈTRE
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'MARGE DE PRÉCISION / DÉTOURS & ODOMÈTRE',
                      style: TextStyle(
                        color: PirateTheme.goldPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: PirateTheme.goldPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '+${_detourMarginPercent.toStringAsFixed(0)} % détours',
                        style: const TextStyle(
                          color: PirateTheme.goldPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Slider(
                  value: _detourMarginPercent,
                  min: 0.0,
                  max: 25.0,
                  divisions: 25,
                  activeColor: PirateTheme.goldPrimary,
                  label: '+${_detourMarginPercent.toStringAsFixed(0)}%',
                  onChanged: (val) {
                    setState(() {
                      _detourMarginPercent = val;
                      _recomputeTotalAndOdoEnd();
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [0.0, 5.0, 10.0, 15.0].map((preset) {
                    final active =
                        (_detourMarginPercent - preset).abs() < 0.1;
                    return ChoiceChip(
                      label: Text('+${preset.toInt()}%'),
                      selected: active,
                      selectedColor: PirateTheme.goldPrimary,
                      labelStyle: TextStyle(
                        color: active ? Colors.black : PirateTheme.textWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                      onSelected: (_) {
                        setState(() {
                          _detourMarginPercent = preset;
                          _recomputeTotalAndOdoEnd();
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _mapsKmCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Km Maps (Aller)',
                          suffixText: 'km',
                        ),
                        onChanged: (_) => _recomputeTotalAndOdoEnd(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _odoStartCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Odomètre Départ',
                          suffixText: 'km',
                        ),
                        onChanged: (_) => _recomputeTotalAndOdoEnd(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _odoEndCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Odomètre Arrivée',
                          suffixText: 'km',
                        ),
                        onChanged: _onManualOdoEndChanged,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 5. QUALIFICATION DU TRAJET (DATE, OBJET, NOTE & PHOTO JUSTIFICATIF)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'QUALIFICATION FISCALE & JUSTIFICATIF',
                  style: TextStyle(
                    color: PirateTheme.goldPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) {
                            setState(() => _selectedDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date du trajet',
                            prefixIcon: Icon(Icons.calendar_today, size: 17),
                          ),
                          child: Text(
                            '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _purpose,
                        decoration: const InputDecoration(
                          labelText: 'Motif / Objet',
                        ),
                        items: _purposes.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Text(p, style: const TextStyle(fontSize: 12)),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _purpose = v);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _notesCtrl,
                  decoration: const InputDecoration(
                    labelText:
                        'Notes (Nom du client, dossier, chantier, référence)',
                    prefixIcon: Icon(Icons.edit, size: 18),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _receiptAttachmentTag =
                              'JUSTIF-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}.JPG';
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: PirateTheme.bullGreen,
                            content: Text(
                              'Justificatif photo attaché : $_receiptAttachmentTag',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: PirateTheme.goldPrimary,
                      ),
                      label: Text(
                        _receiptAttachmentTag == null
                            ? 'Joindre Photo Justificatif (Péage/Parking)'
                            : 'Photo : $_receiptAttachmentTag',
                        style: const TextStyle(
                          fontSize: 11,
                          color: PirateTheme.goldPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // 6. APERÇU DYNAMIQUE DE L'INDEMNITÉ & VALIDATION
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: PirateTheme.bgSecondary,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isProfessional
                  ? PirateTheme.bullGreen
                  : PirateTheme.bearRed,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL RETENU : ${_finalTotalKm.toStringAsFixed(1)} KM',
                        style: const TextStyle(
                          color: PirateTheme.goldPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        previewCalc.formulaSummary,
                        style: const TextStyle(
                          color: PirateTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        previewCalc.bracketLabel,
                        style: const TextStyle(
                          color: PirateTheme.goldSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${previewCalc.amount.toStringAsFixed(2)} ${previewCalc.currency}',
                    style: TextStyle(
                      color: _isProfessional
                          ? PirateTheme.bullGreen
                          : PirateTheme.bearRed,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final odoStart = double.tryParse(
                            _odoStartCtrl.text.replaceAll(',', '.')) ??
                        vehicle.odometerKm;
                    final odoEnd = double.tryParse(
                            _odoEndCtrl.text.replaceAll(',', '.')) ??
                        (odoStart + _finalTotalKm);

                    final record = TripRecord(
                      id: 'trp_${DateTime.now().millisecondsSinceEpoch}',
                      date: _selectedDate,
                      timeLabel: _timeLabel,
                      driverId: _selectedDriverId,
                      vehicleId: _selectedVehicleId,
                      countryCode: _selectedCountry,
                      origin: _originCtrl.text.trim(),
                      destination: _destCtrl.text.trim(),
                      waypoints: List<WaypointStop>.from(_waypoints),
                      isRoundTrip: _isRoundTrip,
                      purpose: _purpose,
                      isProfessional: _isProfessional,
                      mapsDistanceKm: _baseMapsKm,
                      detourMarginPercent: _detourMarginPercent,
                      totalDistanceKm: _finalTotalKm,
                      odometerStart: odoStart,
                      odometerEnd: odoEnd,
                      reimbursementAmount: previewCalc.amount,
                      currency: previewCalc.currency,
                      formulaApplied: previewCalc.formulaSummary,
                      notes: _notesCtrl.text.trim(),
                      receiptReference: _receiptAttachmentTag,
                    );

                    widget.onSaveTrip(record);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: PirateTheme.bullGreen,
                        content: Text(
                          'Trajet enregistré (+${_finalTotalKm.toStringAsFixed(1)} km • ${previewCalc.amount.toStringAsFixed(2)} ${previewCalc.currency}). Odomètre mis à jour.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('VALIDER ET ENREGISTRER LE TRAJET'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAutocompleteDropdown({
    required List<String> suggestions,
    required void Function(String) onSelect,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 8),
      decoration: BoxDecoration(
        color: PirateTheme.bgElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: PirateTheme.goldPrimary.withOpacity(0.5)),
      ),
      child: Column(
        children: suggestions.map((s) {
          return ListTile(
            dense: true,
            leading: const Icon(
              Icons.place,
              color: PirateTheme.goldPrimary,
              size: 16,
            ),
            title: Text(s, style: const TextStyle(fontSize: 12)),
            onTap: () => onSelect(s),
          );
        }).toList(),
      ),
    );
  }
}

// ============================================================================
// 10. ONGLET 3 : JOURNAL DES TRAJETS & EXPORTS COMPTABLES (PDF & CSV/XLSX)
// ============================================================================
class HistoryAndExportsTab extends StatelessWidget {
  final List<TripRecord> trips;
  final List<Driver> drivers;
  final List<Vehicle> vehicles;
  final void Function(String tripId) onDeleteTrip;
  final void Function(TripRecord trip) onDuplicateReturnTrip;

  const HistoryAndExportsTab({
    super.key,
    required this.trips,
    required this.drivers,
    required this.vehicles,
    required this.onDeleteTrip,
    required this.onDuplicateReturnTrip,
  });

  String _driverName(String id) {
    final d = drivers.where((e) => e.id == id).firstOrNull;
    return d?.fullName ?? 'Conducteur';
  }

  Vehicle? _vehicleObj(String id) {
    return vehicles.where((e) => e.id == id).firstOrNull;
  }

  String _generateCsvContent() {
    final sb = StringBuffer();
    sb.writeln(
      'Date;Conducteur;Vehicule;CV;Pays;Depart;Etapes;Arrivee;Motif;Statut;Km_Google_Maps;Marge_Pourcent;Total_Km;Montant_Indemnise;Devise;Odo_Depart;Odo_Arrivee;Notes',
    );
    for (final t in trips) {
      final v = _vehicleObj(t.vehicleId);
      final dateStr =
          '${t.date.day.toString().padLeft(2, '0')}/${t.date.month.toString().padLeft(2, '0')}/${t.date.year}';
      final steps = t.waypoints.map((w) => w.address).join(' -> ');
      sb.writeln(
        '$dateStr;${_driverName(t.driverId)};${v?.name ?? "Véhicule"};${v?.fiscalHp ?? 5};${t.countryCode};"${t.origin}";"$steps";"${t.destination}";${t.purpose};${t.isProfessional ? "PRO" : "PRIVE"};${t.mapsDistanceKm.toStringAsFixed(1)};+${t.detourMarginPercent.toStringAsFixed(0)}%;${t.totalDistanceKm.toStringAsFixed(1)};${t.reimbursementAmount.toStringAsFixed(2)};${t.currency};${t.odometerStart.toStringAsFixed(1)};${t.odometerEnd.toStringAsFixed(1)};"${t.notes}"',
      );
    }
    return sb.toString();
  }

  void _showAccountingPdfReportModal(BuildContext context) {
    final totalKm = trips
        .where((t) => t.isProfessional)
        .fold<double>(0.0, (s, t) => s + t.totalDistanceKm);
    final totalEur = trips
        .where((t) => t.isProfessional && t.currency == 'EUR')
        .fold<double>(0.0, (s, t) => s + t.reimbursementAmount);
    final totalChf = trips
        .where((t) => t.isProfessional && t.currency == 'CHF')
        .fold<double>(0.0, (s, t) => s + t.reimbursementAmount);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PirateTheme.bgPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.88,
        maxChildSize: 0.96,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      PiratePipsLogo(size: 32),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RAPPORT D\'INDEMNITÉS KILOMÉTRIQUES (FORMAT PDF)',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              color: PirateTheme.goldPrimary,
                            ),
                          ),
                          Text(
                            'Document justificatif conforme Expert-Comptable & Administration Fiscale',
                            style: TextStyle(
                              fontSize: 10,
                              color: PirateTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(color: PirateTheme.goldPrimary),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: PirateTheme.bgSecondary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: PirateTheme.borderDark),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Km Pro : ${totalKm.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Total EUR : ${totalEur.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        color: PirateTheme.bullGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Total CHF : ${totalChf.toStringAsFixed(2)} CHF',
                      style: const TextStyle(
                        color: PirateTheme.goldPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor:
                      WidgetStateProperty.all(PirateTheme.bgElevated),
                  columns: const [
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Conducteur')),
                    DataColumn(label: Text('Véhicule')),
                    DataColumn(label: Text('CV')),
                    DataColumn(label: Text('Départ')),
                    DataColumn(label: Text('Arrivée')),
                    DataColumn(label: Text('Motif')),
                    DataColumn(label: Text('Km Maps')),
                    DataColumn(label: Text('Marge')),
                    DataColumn(label: Text('Total km')),
                    DataColumn(label: Text('Montant indemnisé')),
                  ],
                  rows: trips.map((t) {
                    final v = _vehicleObj(t.vehicleId);
                    final dateStr =
                        '${t.date.day.toString().padLeft(2, '0')}/${t.date.month.toString().padLeft(2, '0')}/${t.date.year}';
                    return DataRow(
                      cells: [
                        DataCell(Text(dateStr)),
                        DataCell(Text(_driverName(t.driverId))),
                        DataCell(Text(v?.name ?? '-')),
                        DataCell(Text('${v?.fiscalHp ?? 5} CV')),
                        DataCell(Text(t.origin)),
                        DataCell(Text(t.destination)),
                        DataCell(Text('${t.purpose} (${t.countryCode})')),
                        DataCell(Text('${t.mapsDistanceKm.toStringAsFixed(1)} km')),
                        DataCell(
                            Text('+${t.detourMarginPercent.toStringAsFixed(0)}%')),
                        DataCell(Text(
                          '${t.totalDistanceKm.toStringAsFixed(1)} km',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )),
                        DataCell(Text(
                          '${t.reimbursementAmount.toStringAsFixed(2)} ${t.currency}',
                          style: TextStyle(
                            color: t.isProfessional
                                ? PirateTheme.bullGreen
                                : PirateTheme.bearRed,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _generateCsvContent()));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: PirateTheme.bullGreen,
                      content: Text(
                        'Rapport comptable copié dans le presse-papiers (prêt pour Excel / PDF).',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text(
                  'COPIER LE TABLEAU COMPTABLE COMPLET',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Bandeau Exports Comptables PDF & CSV/XLSX
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: PirateTheme.bgSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PirateTheme.goldPrimary),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'EXPORTS COMPTABLES & FISCAUX CONFORMES',
                style: TextStyle(
                  color: PirateTheme.goldPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Colonnes officielles : Date, Conducteur, Véhicule, CV, Départ, Arrivée, Motif, Km Google Maps, Marge, Total km, Montant indemnisé.',
                style: TextStyle(color: PirateTheme.textMuted, fontSize: 11),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showAccountingPdfReportModal(context),
                      icon: const Icon(Icons.picture_as_pdf, size: 17),
                      label: const Text(
                        'ÉTAT PDF COMPTABLE',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final csv = _generateCsvContent();
                        Clipboard.setData(ClipboardData(text: csv));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: PirateTheme.bullGreen,
                            content: Text(
                              'Export CSV / XLSX copié dans le presse-papiers !',
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: PirateTheme.goldPrimary,
                        side: const BorderSide(color: PirateTheme.goldPrimary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.table_chart, size: 17),
                      label: const Text(
                        'EXPORT CSV / XLSX',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        const Text(
          'HISTORIQUE DÉTAILLÉ DES TRAJETS',
          style: TextStyle(
            color: PirateTheme.textWhite,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 10),

        if (trips.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Aucun trajet enregistré.',
                style: TextStyle(color: PirateTheme.textMuted),
              ),
            ),
          ),

        ...trips.map((t) {
          final v = _vehicleObj(t.vehicleId);
          final dateStr =
              '${t.date.day.toString().padLeft(2, '0')}/${t.date.month.toString().padLeft(2, '0')}/${t.date.year}';
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: PirateTheme.bgSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: t.isProfessional
                    ? PirateTheme.bullGreen.withOpacity(0.45)
                    : PirateTheme.bearRed.withOpacity(0.45),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: t.isProfessional
                                ? PirateTheme.bullGreen.withOpacity(0.18)
                                : PirateTheme.bearRed.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            t.isProfessional ? 'PRO • ${t.purpose}' : 'PRIVÉ',
                            style: TextStyle(
                              color: t.isProfessional
                                  ? PirateTheme.bullGreen
                                  : PirateTheme.bearRed,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$dateStr • ${t.countryCode}',
                          style: const TextStyle(
                            color: PirateTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${t.reimbursementAmount.toStringAsFixed(2)} ${t.currency}',
                      style: TextStyle(
                        color: t.isProfessional
                            ? PirateTheme.bullGreen
                            : PirateTheme.bearRed,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'A: ${t.origin}',
                  style: const TextStyle(fontSize: 12),
                ),
                if (t.waypoints.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      'Étapes (${t.waypoints.length}) : ${t.waypoints.map((w) => w.label).join(", ")}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: PirateTheme.goldSecondary,
                      ),
                    ),
                  ),
                Text(
                  'B: ${t.destination}${t.isRoundTrip ? " (Aller-Retour ×2)" : ""}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_driverName(t.driverId)} • ${v?.name ?? "Véhicule"} (${v?.fiscalHp ?? 5} CV) • Maps: ${t.mapsDistanceKm.toStringAsFixed(1)} km (+${t.detourMarginPercent.toStringAsFixed(0)}%) = ${t.totalDistanceKm.toStringAsFixed(1)} km',
                  style: const TextStyle(
                    fontSize: 11,
                    color: PirateTheme.textMuted,
                  ),
                ),
                if (t.notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Note : ${t.notes}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: PirateTheme.textMuted,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => onDuplicateReturnTrip(t),
                      icon: const Icon(
                        Icons.repeat,
                        size: 15,
                        color: PirateTheme.goldPrimary,
                      ),
                      label: const Text(
                        'Générer Trajet Retour',
                        style: TextStyle(
                          fontSize: 11,
                          color: PirateTheme.goldPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => onDeleteTrip(t.id),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: PirateTheme.bearRed,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ============================================================================
// 11. ONGLET 4 : GARAGE (VÉHICULES), CONDUCTEURS & ADRESSES FAVORITES
// ============================================================================
class GarageAndProfilesTab extends StatefulWidget {
  final List<Driver> drivers;
  final List<Vehicle> vehicles;
  final List<SavedPlace> savedPlaces;
  final VoidCallback onChanged;

  const GarageAndProfilesTab({
    super.key,
    required this.drivers,
    required this.vehicles,
    required this.savedPlaces,
    required this.onChanged,
  });

  @override
  State<GarageAndProfilesTab> createState() => _GarageAndProfilesTabState();
}

class _GarageAndProfilesTabState extends State<GarageAndProfilesTab> {
  void _showAddVehicleDialog() {
    final nameCtrl = TextEditingController();
    final plateCtrl = TextEditingController();
    final odoCtrl = TextEditingController(text: '10000');
    String type = 'Voiture';
    String engine = 'Thermique Diesel';
    int fiscalHp = 5;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: PirateTheme.bgSecondary,
          title: const Text('Ajouter un véhicule au Garage'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Nom / Modèle'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: plateCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Immatriculation'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: ['Voiture', 'Moto', 'Utilitaire']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setModalState(() => type = v!),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: engine,
                  decoration: const InputDecoration(labelText: 'Motorisation'),
                  items: [
                    'Thermique Essence',
                    'Thermique Diesel',
                    'Hybride',
                    'Électrique',
                  ]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setModalState(() => engine = v!),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: fiscalHp,
                  decoration:
                      const InputDecoration(labelText: 'Puissance fiscale (CV)'),
                  items: [3, 4, 5, 6, 7]
                      .map(
                        (cv) => DropdownMenuItem(
                          value: cv,
                          child: Text(cv == 7 ? '7 CV et plus' : '$cv CV'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setModalState(() => fiscalHp = v!),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: odoCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Compteur kilométrique initial (Odomètre)',
                    suffixText: 'km',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  widget.vehicles.add(
                    Vehicle(
                      id: 'veh_${DateTime.now().millisecondsSinceEpoch}',
                      name: nameCtrl.text.trim(),
                      plate: plateCtrl.text.trim().isEmpty
                          ? 'AA-000-AA'
                          : plateCtrl.text.trim(),
                      type: type,
                      engine: engine,
                      fiscalHp: fiscalHp,
                      odometerKm: double.tryParse(odoCtrl.text) ?? 0.0,
                    ),
                  );
                  widget.onChanged();
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDriverDialog() {
    final firstCtrl = TextEditingController();
    final lastCtrl = TextEditingController();
    String status = 'Gérant';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: PirateTheme.bgSecondary,
          title: const Text('Nouveau Profil Conducteur'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstCtrl,
                decoration: const InputDecoration(labelText: 'Prénom'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: lastCtrl,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(labelText: 'Statut'),
                items: ['Gérant', 'Salarié', 'Indépendant']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setModalState(() => status = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (firstCtrl.text.trim().isNotEmpty) {
                  widget.drivers.add(
                    Driver(
                      id: 'drv_${DateTime.now().millisecondsSinceEpoch}',
                      firstName: firstCtrl.text.trim(),
                      lastName: lastCtrl.text.trim(),
                      status: status,
                    ),
                  );
                  widget.onChanged();
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPlaceDialog() {
    final labelCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    String category = 'Client';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: PirateTheme.bgSecondary,
          title: const Text('Nouvelle Adresse Favorite'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nom du favori (ex: Siège, Maison, Client X)',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: addrCtrl,
                decoration:
                    const InputDecoration(labelText: 'Adresse postale complète'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(labelText: 'Catégorie'),
                items: ['Maison', 'Siège', 'Dépôt', 'Client', 'Magasin Pro']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setModalState(() => category = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (labelCtrl.text.trim().isNotEmpty &&
                    addrCtrl.text.trim().isNotEmpty) {
                  widget.savedPlaces.add(
                    SavedPlace(
                      id: 'plc_${DateTime.now().millisecondsSinceEpoch}',
                      label: labelCtrl.text.trim(),
                      address: addrCtrl.text.trim(),
                      category: category,
                    ),
                  );
                  widget.onChanged();
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Section Véhicules
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'GARAGE MULTI-VÉHICULES',
              style: TextStyle(
                color: PirateTheme.goldPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _showAddVehicleDialog,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Véhicule', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...widget.vehicles.map((v) {
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: PirateTheme.goldPrimary.withOpacity(0.18),
                child: Icon(
                  v.isElectric ? Icons.bolt : Icons.directions_car,
                  color: PirateTheme.goldPrimary,
                ),
              ),
              title: Text(
                '${v.name} (${v.plate})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${v.type} • ${v.engine} • ${v.fiscalHp == 7 ? "7 CV+" : "${v.fiscalHp} CV"}\nOdomètre : ${v.odometerKm.toStringAsFixed(1)} km',
                style: const TextStyle(fontSize: 12),
              ),
              isThreeLine: true,
              trailing: widget.vehicles.length > 1
                  ? IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: PirateTheme.bearRed,
                      ),
                      onPressed: () {
                        widget.vehicles.removeWhere((item) => item.id == v.id);
                        widget.onChanged();
                      },
                    )
                  : null,
            ),
          );
        }),

        const SizedBox(height: 18),
        // Section Conducteurs
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'PROFILS CONDUCTEURS',
              style: TextStyle(
                color: PirateTheme.goldPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _showAddDriverDialog,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Conducteur', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...widget.drivers.map((d) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: PirateTheme.bgElevated,
                child: Icon(Icons.person, color: PirateTheme.goldPrimary),
              ),
              title: Text(
                d.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Statut : ${d.status}'),
              trailing: widget.drivers.length > 1
                  ? IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: PirateTheme.bearRed,
                      ),
                      onPressed: () {
                        widget.drivers.removeWhere((item) => item.id == d.id);
                        widget.onChanged();
                      },
                    )
                  : null,
            ),
          );
        }),

        const SizedBox(height: 18),
        // Section Adresses Favorites
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'RÉPERTOIRE D\'ADRESSES FAVORITES',
              style: TextStyle(
                color: PirateTheme.goldPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _showAddPlaceDialog,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Favori', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...widget.savedPlaces.map((p) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.star, color: PirateTheme.goldPrimary),
              title: Text(
                '${p.label} (${p.category})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              subtitle: Text(p.address, style: const TextStyle(fontSize: 12)),
              trailing: IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: PirateTheme.bearRed,
                ),
                onPressed: () {
                  widget.savedPlaces.removeWhere((item) => item.id == p.id);
                  widget.onChanged();
                },
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ============================================================================
// 12. ONGLET 5 : BARÈMES FISCAUX ÉDITABLES, API GOOGLE MAPS & À PROPOS
// ============================================================================
class FiscalSettingsAndAboutTab extends StatefulWidget {
  final TaxRatesConfig taxConfig;
  final String defaultCountry;
  final double defaultMargin;
  final String googleMapsApiKey;
  final String cloudSyncEndpoint;
  final String? lastCloudSyncStatus;
  final void Function({
    required String country,
    required double margin,
    required String gmapsKey,
    required String cloudUrl,
  }) onUpdateSettings;
  final VoidCallback onTaxConfigChanged;
  final VoidCallback onTriggerCloudSync;

  const FiscalSettingsAndAboutTab({
    super.key,
    required this.taxConfig,
    required this.defaultCountry,
    required this.defaultMargin,
    required this.googleMapsApiKey,
    required this.cloudSyncEndpoint,
    required this.lastCloudSyncStatus,
    required this.onUpdateSettings,
    required this.onTaxConfigChanged,
    required this.onTriggerCloudSync,
  });

  @override
  State<FiscalSettingsAndAboutTab> createState() =>
      _FiscalSettingsAndAboutTabState();
}

class _FiscalSettingsAndAboutTabState extends State<FiscalSettingsAndAboutTab> {
  late TextEditingController _luCtrl;
  late TextEditingController _beCtrl;
  late TextEditingController _deDiensCtrl;
  late TextEditingController _dePendler1Ctrl;
  late TextEditingController _dePendler2Ctrl;
  late TextEditingController _chCtrl;
  late TextEditingController _elecBonusCtrl;
  late TextEditingController _gmapsKeyCtrl;
  late TextEditingController _cloudUrlCtrl;
  late String _country;
  late double _margin;

  @override
  void initState() {
    super.initState();
    _country = widget.defaultCountry;
    _margin = widget.defaultMargin;
    _luCtrl = TextEditingController(
      text: widget.taxConfig.luxembourgRateEur.toStringAsFixed(2),
    );
    _beCtrl = TextEditingController(
      text: widget.taxConfig.belgiumRateEur.toStringAsFixed(2),
    );
    _deDiensCtrl = TextEditingController(
      text: widget.taxConfig.germanyDienstreisenEur.toStringAsFixed(2),
    );
    _dePendler1Ctrl = TextEditingController(
      text: widget.taxConfig.germanyPendlerFirst20Eur.toStringAsFixed(2),
    );
    _dePendler2Ctrl = TextEditingController(
      text: widget.taxConfig.germanyPendlerAfter20Eur.toStringAsFixed(2),
    );
    _chCtrl = TextEditingController(
      text: widget.taxConfig.switzerlandRateChf.toStringAsFixed(2),
    );
    _elecBonusCtrl = TextEditingController(
      text: widget.taxConfig.frenchElectricBonusPercent.toStringAsFixed(0),
    );
    _gmapsKeyCtrl = TextEditingController(text: widget.googleMapsApiKey);
    _cloudUrlCtrl = TextEditingController(text: widget.cloudSyncEndpoint);
  }

  @override
  void dispose() {
    _luCtrl.dispose();
    _beCtrl.dispose();
    _deDiensCtrl.dispose();
    _dePendler1Ctrl.dispose();
    _dePendler2Ctrl.dispose();
    _chCtrl.dispose();
    _elecBonusCtrl.dispose();
    _gmapsKeyCtrl.dispose();
    _cloudUrlCtrl.dispose();
    super.dispose();
  }

  void _saveRates() {
    widget.taxConfig.luxembourgRateEur =
        double.tryParse(_luCtrl.text.replaceAll(',', '.')) ?? 0.40;
    widget.taxConfig.belgiumRateEur =
        double.tryParse(_beCtrl.text.replaceAll(',', '.')) ?? 0.43;
    widget.taxConfig.germanyDienstreisenEur =
        double.tryParse(_deDiensCtrl.text.replaceAll(',', '.')) ?? 0.30;
    widget.taxConfig.germanyPendlerFirst20Eur =
        double.tryParse(_dePendler1Ctrl.text.replaceAll(',', '.')) ?? 0.30;
    widget.taxConfig.germanyPendlerAfter20Eur =
        double.tryParse(_dePendler2Ctrl.text.replaceAll(',', '.')) ?? 0.38;
    widget.taxConfig.switzerlandRateChf =
        double.tryParse(_chCtrl.text.replaceAll(',', '.')) ?? 0.70;
    widget.taxConfig.frenchElectricBonusPercent =
        double.tryParse(_elecBonusCtrl.text.replaceAll(',', '.')) ?? 20.0;

    widget.onTaxConfigChanged();
    widget.onUpdateSettings(
      country: _country,
      margin: _margin,
      gmapsKey: _gmapsKeyCtrl.text.trim(),
      cloudUrl: _cloudUrlCtrl.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: PirateTheme.bullGreen,
        content: Text('Barèmes fiscaux et paramètres enregistrés avec succès.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. BARÈMES INTERNATIONAUX ÉDITABLES
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PARAMÈTRES FISCAUX & BARÈMES LÉGAUX (FR / LU / BE / DE / CH)',
                  style: TextStyle(
                    color: PirateTheme.goldPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _luCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Luxembourg (€/km)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _beCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Belgique (€/km)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _deDiensCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Allemagne Dienstreisen (€/km)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _chCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Suisse TCS (CHF/km)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _dePendler1Ctrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'DE Pendler ≤ 20km (€/km)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _dePendler2Ctrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'DE Pendler > 20km (€/km)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _elecBonusCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'France — Majoration Véhicule 100% Électrique (%)',
                    suffixText: '%',
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'BARÈME KILOMÉTRIQUE FRANÇAIS PAR TRANCHES (3 CV À 7 CV+)',
                  style: TextStyle(
                    color: PirateTheme.goldSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    visualDensity: VisualDensity.compact,
                    columns: const [
                      DataColumn(label: Text('CV')),
                      DataColumn(label: Text('≤ 5 000 km')),
                      DataColumn(label: Text('5 001 à 20 000 km')),
                      DataColumn(label: Text('> 20 000 km')),
                    ],
                    rows: [3, 4, 5, 6, 7].map((hp) {
                      final r = widget.taxConfig.frenchBrackets[hp]!;
                      return DataRow(
                        cells: [
                          DataCell(Text(hp == 7 ? '7 CV+' : '$hp CV')),
                          DataCell(Text('d × ${r.rateUpTo5000}')),
                          DataCell(Text(
                              '(d × ${r.rate5001To20000}) + ${r.fixed5001To20000.toInt()}€')),
                          DataCell(Text('d × ${r.rateOver20000}')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 2. CONFIGURATION GOOGLE MAPS API & CLOUD SYNC OPTIONNEL
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'INTÉGRATION GOOGLE MAPS API & SYNCHRONISATION CLOUD',
                  style: TextStyle(
                    color: PirateTheme.goldPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _gmapsKeyCtrl,
                  decoration: const InputDecoration(
                    labelText:
                        'Clé API Google Maps (Places Autocomplete + Directions)',
                    hintText: 'AIzaSy... (Optionnel : routage GPS actif par défaut)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _cloudUrlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Endpoint Cloud Sync (Webhook REST JSON optionnel)',
                    hintText: 'https://...',
                  ),
                ),
                if (widget.lastCloudSyncStatus != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    widget.lastCloudSyncStatus!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: PirateTheme.bullGreen,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _saveRates,
                        icon: const Icon(Icons.check_circle, size: 18),
                        label: const Text('ENREGISTRER LES PARAMÈTRES'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: widget.onTriggerCloudSync,
                      icon: const Icon(
                        Icons.cloud_upload,
                        size: 18,
                        color: PirateTheme.goldPrimary,
                      ),
                      label: const Text(
                        'SYNC CLOUD',
                        style: TextStyle(color: PirateTheme.goldPrimary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 3. ÉCRAN À PROPOS / MENTIONS DE MARQUE PIRATE PIPS™
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: PirateTheme.bgSecondary,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: PirateTheme.goldPrimary, width: 1.2),
          ),
          child: const Column(
            children: [
              PiratePipsLogo(size: 70),
              SizedBox(height: 12),
              Text(
                'Développé par Pirate Pips™',
                style: TextStyle(
                  color: PirateTheme.textWhite,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Protection légale, propriété exclusive de Pirate Pips™.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: PirateTheme.goldPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Architecture Local-First avec synchronisation Cloud optionnelle • Moteur fiscal multi-juridictions (France, Luxembourg, Belgique, Allemagne, Suisse).',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: PirateTheme.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

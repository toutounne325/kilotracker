// ============================================================================
// Protection légale pour le trading, propriété exclusive de Pirate Pips ™.
// AVERTISSEMENT LÉGAL & DISCLAIMER : Ce logiciel, son architecture et ses
// algorithmes de calcul sont la propriété exclusive de Pirate Pips ™.
// Toute reproduction, rétro-ingénierie ou distribution non autorisée est
// strictement interdite. Les calculs fiscaux, financiers et indicateurs
// fournis par Pirate Pips ™ ont une vocation purement informative et
// technologique et ne constituent ni un conseil fiscal certifié ni un conseil
// en investissement. Le trading sur les marchés financiers présente un risque
// élevé de perte en capital.
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
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
  runApp(const PiratePipsKiloProApp());
}

// ============================================================================
// 1. DESIGN SYSTEM PIRATE PIPS™ (DARK MODE EXCLUSIF #0E0E0E & OR #F5A623)
// ============================================================================
class PiratePalette {
  static const Color bgDeep = Color(0xFF0E0E0E);
  static const Color bgSurface = Color(0xFF161616);
  static const Color bgElevated = Color(0xFF1F1F1F);
  static const Color goldPrimary = Color(0xFFF5A623);
  static const Color goldWarm = Color(0xFFE5A93C);
  static const Color bullGreen = Color(0xFF22C55E);
  static const Color bearRed = Color(0xFFEF4444);
  static const Color textPure = Color(0xFFFFFFFF);
  static const Color textSteel = Color(0xFF9CA3AF);
  static const Color borderSubtle = Color(0xFF2B2B2B);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDeep,
      primaryColor: goldPrimary,
      colorScheme: const ColorScheme.dark(
        primary: goldPrimary,
        secondary: goldWarm,
        surface: bgSurface,
        error: bearRed,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: textPure,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgDeep,
        foregroundColor: textPure,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: bgSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: borderSubtle, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgElevated,
        labelStyle: const TextStyle(color: textSteel, fontSize: 13),
        hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderSubtle),
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
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 2. LOGO OFFICIEL PIRATE PIPS™
// ============================================================================
class PiratePipsBadgeLogo extends StatelessWidget {
  final double size;
  const PiratePipsBadgeLogo({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _PirateBadgePainter()),
    );
  }
}

class _PirateBadgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final bgPaint = Paint()
      ..color = PiratePalette.bgDeep
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    final goldRing = Paint()
      ..color = PiratePalette.goldPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.07;
    canvas.drawCircle(center, radius * 0.92, goldRing);

    final innerRing = Paint()
      ..color = PiratePalette.goldWarm.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.02;
    canvas.drawCircle(center, radius * 0.79, innerRing);

    // Bougie verte
    final bullPaint = Paint()..color = PiratePalette.bullGreen;
    final bullWick = Paint()
      ..color = PiratePalette.bullGreen
      ..strokeWidth = size.width * 0.045
      ..strokeCap = StrokeCap.round;

    final leftX = size.width * 0.37;
    canvas.drawLine(
      Offset(leftX, size.height * 0.22),
      Offset(leftX, size.height * 0.76),
      bullWick,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(leftX, size.height * 0.46),
          width: size.width * 0.16,
          height: size.height * 0.30,
        ),
        Radius.circular(size.width * 0.03),
      ),
      bullPaint,
    );

    // Bougie rouge
    final bearPaint = Paint()..color = PiratePalette.bearRed;
    final bearWick = Paint()
      ..color = PiratePalette.bearRed
      ..strokeWidth = size.width * 0.045
      ..strokeCap = StrokeCap.round;

    final rightX = size.width * 0.63;
    canvas.drawLine(
      Offset(rightX, size.height * 0.26),
      Offset(rightX, size.height * 0.79),
      bearWick,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(rightX, size.height * 0.55),
          width: size.width * 0.16,
          height: size.height * 0.28,
        ),
        Radius.circular(size.width * 0.03),
      ),
      bearPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// 3. CATALOGUE FISCAL NORMALISÉ DES 14 CATÉGORIES DE VÉHICULES
// ============================================================================
class FiscalVehicleCategorySpec {
  final String label;
  final String group; // THERMIQUE, ELECTRIQUE, MOTO, SCOOTER
  final int fiscalHp;
  final bool isElectric;

  const FiscalVehicleCategorySpec({
    required this.label,
    required this.group,
    required this.fiscalHp,
    required this.isElectric,
  });
}

const List<FiscalVehicleCategorySpec> kOfficialVehicleCatalog = [
  FiscalVehicleCategorySpec(
    label: 'Voiture (3 CV et moins)',
    group: 'THERMIQUE',
    fiscalHp: 3,
    isElectric: false,
  ),
  FiscalVehicleCategorySpec(
    label: 'Voiture (4 CV)',
    group: 'THERMIQUE',
    fiscalHp: 4,
    isElectric: false,
  ),
  FiscalVehicleCategorySpec(
    label: 'Voiture (5 CV)',
    group: 'THERMIQUE',
    fiscalHp: 5,
    isElectric: false,
  ),
  FiscalVehicleCategorySpec(
    label: 'Voiture (6 CV)',
    group: 'THERMIQUE',
    fiscalHp: 6,
    isElectric: false,
  ),
  FiscalVehicleCategorySpec(
    label: 'Voiture (7 CV et plus)',
    group: 'THERMIQUE',
    fiscalHp: 7,
    isElectric: false,
  ),
  FiscalVehicleCategorySpec(
    label: 'Voiture électrique (3 CV et moins)',
    group: 'ELECTRIQUE',
    fiscalHp: 3,
    isElectric: true,
  ),
  FiscalVehicleCategorySpec(
    label: 'Voiture électrique (4 CV)',
    group: 'ELECTRIQUE',
    fiscalHp: 4,
    isElectric: true,
  ),
  FiscalVehicleCategorySpec(
    label: 'Voiture électrique (5 CV)',
    group: 'ELECTRIQUE',
    fiscalHp: 5,
    isElectric: true,
  ),
  FiscalVehicleCategorySpec(
    label: 'Voiture électrique (6 CV)',
    group: 'ELECTRIQUE',
    fiscalHp: 6,
    isElectric: true,
  ),
  FiscalVehicleCategorySpec(
    label: 'Voiture électrique (7 CV et plus)',
    group: 'ELECTRIQUE',
    fiscalHp: 7,
    isElectric: true,
  ),
  FiscalVehicleCategorySpec(
    label: 'Moto (1-2 CV)',
    group: 'MOTO',
    fiscalHp: 2,
    isElectric: false,
  ),
  FiscalVehicleCategorySpec(
    label: 'Moto (3-5 CV)',
    group: 'MOTO',
    fiscalHp: 4,
    isElectric: false,
  ),
  FiscalVehicleCategorySpec(
    label: 'Moto (6 CV et plus)',
    group: 'MOTO',
    fiscalHp: 6,
    isElectric: false,
  ),
  FiscalVehicleCategorySpec(
    label: 'Scooter',
    group: 'SCOOTER',
    fiscalHp: 1,
    isElectric: false,
  ),
];

// ============================================================================
// 4. MODÈLES DE DONNÉES
// ============================================================================
class DriverProfile {
  final String id;
  String firstName;
  String lastName;
  String role;
  String personalAddress;
  String companyName;
  String companyAddress;

  DriverProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.personalAddress,
    required this.companyName,
    required this.companyAddress,
  });

  String get fullName => '$firstName $lastName'.trim();

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
        'personalAddress': personalAddress,
        'companyName': companyName,
        'companyAddress': companyAddress,
      };

  factory DriverProfile.fromJson(Map<String, dynamic> json) => DriverProfile(
        id: json['id'] ?? '',
        firstName: json['firstName'] ?? '',
        lastName: json['lastName'] ?? '',
        role: json['role'] ?? 'Gérant',
        personalAddress: json['personalAddress'] ?? 'Uffheim, 68510, France',
        companyName: json['companyName'] ?? 'A&CSA INVEST / Pirate Pips™',
        companyAddress:
            json['companyAddress'] ?? 'Boulevard Royal, L-2449 Luxembourg',
      );
}

class VehicleEntity {
  final String id;
  String name;
  String licensePlate;
  String fiscalCategory;
  String vehicleGroup;
  int fiscalHp;
  bool isElectric;
  double currentOdometerKm;
  String bluetoothBeaconName;

  VehicleEntity({
    required this.id,
    required this.name,
    required this.licensePlate,
    required this.fiscalCategory,
    required this.vehicleGroup,
    required this.fiscalHp,
    required this.isElectric,
    required this.currentOdometerKm,
    this.bluetoothBeaconName = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'licensePlate': licensePlate,
        'fiscalCategory': fiscalCategory,
        'vehicleGroup': vehicleGroup,
        'fiscalHp': fiscalHp,
        'isElectric': isElectric,
        'currentOdometerKm': currentOdometerKm,
        'bluetoothBeaconName': bluetoothBeaconName,
      };

  factory VehicleEntity.fromJson(Map<String, dynamic> json) => VehicleEntity(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        licensePlate: json['licensePlate'] ?? 'PP-777-LU',
        fiscalCategory: json['fiscalCategory'] ?? 'Voiture (7 CV et plus)',
        vehicleGroup: json['vehicleGroup'] ?? 'THERMIQUE',
        fiscalHp: (json['fiscalHp'] ?? 7) as int,
        isElectric: (json['isElectric'] ?? false) as bool,
        currentOdometerKm: ((json['currentOdometerKm'] ?? 0) as num).toDouble(),
        bluetoothBeaconName: json['bluetoothBeaconName'] ?? '',
      );
}

class SavedLocationEntity {
  final String id;
  String label;
  String fullAddress;
  String locationType; // WORKPLACE ou EMPLACEMENT
  double? lat;
  double? lon;

  SavedLocationEntity({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.locationType,
    this.lat,
    this.lon,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'fullAddress': fullAddress,
        'locationType': locationType,
        'lat': lat,
        'lon': lon,
      };

  factory SavedLocationEntity.fromJson(Map<String, dynamic> json) =>
      SavedLocationEntity(
        id: json['id'] ?? '',
        label: json['label'] ?? '',
        fullAddress: json['fullAddress'] ?? '',
        locationType: json['locationType'] ?? 'EMPLACEMENT',
        lat: (json['lat'] as num?)?.toDouble(),
        lon: (json['lon'] as num?)?.toDouble(),
      );
}

class WaypointEntity {
  String label;
  String address;

  WaypointEntity({required this.label, required this.address});

  Map<String, dynamic> toJson() => {'label': label, 'address': address};

  factory WaypointEntity.fromJson(Map<String, dynamic> json) => WaypointEntity(
        label: json['label'] ?? 'Étape',
        address: json['address'] ?? '',
      );
}

class OdometerLogEntity {
  final String id;
  final String vehicleId;
  final DateTime recordedAt;
  final double odometerValueKm;
  final String photoEvidenceRef;
  final String note;

  OdometerLogEntity({
    required this.id,
    required this.vehicleId,
    required this.recordedAt,
    required this.odometerValueKm,
    required this.photoEvidenceRef,
    required this.note,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicleId': vehicleId,
        'recordedAt': recordedAt.toIso8601String(),
        'odometerValueKm': odometerValueKm,
        'photoEvidenceRef': photoEvidenceRef,
        'note': note,
      };

  factory OdometerLogEntity.fromJson(Map<String, dynamic> json) =>
      OdometerLogEntity(
        id: json['id'] ?? '',
        vehicleId: json['vehicleId'] ?? '',
        recordedAt:
            DateTime.tryParse(json['recordedAt'] ?? '') ?? DateTime.now(),
        odometerValueKm: ((json['odometerValueKm'] ?? 0) as num).toDouble(),
        photoEvidenceRef: json['photoEvidenceRef'] ?? 'ODO-PHOTO.JPG',
        note: json['note'] ?? '',
      );
}

class TripEntity {
  final String id;
  DateTime date;
  String startTime;
  String endTime;
  String driverId;
  String vehicleId;
  String countryCode;
  String originAddress;
  String destinationAddress;
  List<WaypointEntity> waypoints;
  bool isRoundTrip;
  String captureMode;
  String qualificationStatus; // PENDING, PRO, PERSO
  String purpose;
  String projectTag;
  double mapsDistanceKm;
  double detourMarginPercent;
  double finalDistanceKm;
  double odometerStartKm;
  double odometerEndKm;
  double reimbursementAmount;
  String currency;
  String appliedRuleLabel;
  String notes;
  String? receiptPhotoRef;

  TripEntity({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.driverId,
    required this.vehicleId,
    required this.countryCode,
    required this.originAddress,
    required this.destinationAddress,
    required this.waypoints,
    required this.isRoundTrip,
    required this.captureMode,
    required this.qualificationStatus,
    required this.purpose,
    required this.projectTag,
    required this.mapsDistanceKm,
    required this.detourMarginPercent,
    required this.finalDistanceKm,
    required this.odometerStartKm,
    required this.odometerEndKm,
    required this.reimbursementAmount,
    required this.currency,
    required this.appliedRuleLabel,
    required this.notes,
    this.receiptPhotoRef,
  });

  bool get isPro => qualificationStatus == 'PRO';
  bool get isPending => qualificationStatus == 'PENDING';

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'startTime': startTime,
        'endTime': endTime,
        'driverId': driverId,
        'vehicleId': vehicleId,
        'countryCode': countryCode,
        'originAddress': originAddress,
        'destinationAddress': destinationAddress,
        'waypoints': waypoints.map((w) => w.toJson()).toList(),
        'isRoundTrip': isRoundTrip,
        'captureMode': captureMode,
        'qualificationStatus': qualificationStatus,
        'purpose': purpose,
        'projectTag': projectTag,
        'mapsDistanceKm': mapsDistanceKm,
        'detourMarginPercent': detourMarginPercent,
        'finalDistanceKm': finalDistanceKm,
        'odometerStartKm': odometerStartKm,
        'odometerEndKm': odometerEndKm,
        'reimbursementAmount': reimbursementAmount,
        'currency': currency,
        'appliedRuleLabel': appliedRuleLabel,
        'notes': notes,
        'receiptPhotoRef': receiptPhotoRef,
      };

  factory TripEntity.fromJson(Map<String, dynamic> json) => TripEntity(
        id: json['id'] ?? '',
        date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
        startTime: json['startTime'] ?? '08:15',
        endTime: json['endTime'] ?? '09:05',
        driverId: json['driverId'] ?? '',
        vehicleId: json['vehicleId'] ?? '',
        countryCode: json['countryCode'] ?? 'FR',
        originAddress: json['originAddress'] ?? '',
        destinationAddress: json['destinationAddress'] ?? '',
        waypoints: ((json['waypoints'] as List?) ?? [])
            .map((e) => WaypointEntity.fromJson(e as Map<String, dynamic>))
            .toList(),
        isRoundTrip: (json['isRoundTrip'] ?? false) as bool,
        captureMode: json['captureMode'] ?? 'AUTO_GPS',
        qualificationStatus: json['qualificationStatus'] ?? 'PRO',
        purpose: json['purpose'] ?? 'Client',
        projectTag: json['projectTag'] ?? 'Général',
        mapsDistanceKm: ((json['mapsDistanceKm'] ?? 0) as num).toDouble(),
        detourMarginPercent:
            ((json['detourMarginPercent'] ?? 0) as num).toDouble(),
        finalDistanceKm: ((json['finalDistanceKm'] ?? 0) as num).toDouble(),
        odometerStartKm: ((json['odometerStartKm'] ?? 0) as num).toDouble(),
        odometerEndKm: ((json['odometerEndKm'] ?? 0) as num).toDouble(),
        reimbursementAmount:
            ((json['reimbursementAmount'] ?? 0) as num).toDouble(),
        currency: json['currency'] ?? 'EUR',
        appliedRuleLabel: json['appliedRuleLabel'] ?? '',
        notes: json['notes'] ?? '',
        receiptPhotoRef: json['receiptPhotoRef'] as String?,
      );
}

// ============================================================================
// 5. SERVICE MOTEUR FISCAL MULTI-PAYS (`TaxEngineService`)
// ============================================================================
class BracketFormula {
  double t1Limit;
  double t2Limit;
  double rate1;
  double rate2;
  double fixed2;
  double rate3;

  BracketFormula({
    required this.t1Limit,
    required this.t2Limit,
    required this.rate1,
    required this.rate2,
    required this.fixed2,
    required this.rate3,
  });

  Map<String, dynamic> toJson() => {
        't1Limit': t1Limit,
        't2Limit': t2Limit,
        'rate1': rate1,
        'rate2': rate2,
        'fixed2': fixed2,
        'rate3': rate3,
      };
}

class TaxRulesRepository {
  Map<int, BracketFormula> frenchCarBrackets;
  Map<String, BracketFormula> frenchTwoWheelsBrackets;
  double frenchElectricBonusPercent;
  double luxembourgFlatEur;
  double belgiumFlatEur;
  double germanyDienstreisenEur;
  double germanyPendlerFirst20Eur;
  double germanyPendlerAfter20Eur;
  double switzerlandFlatChf;

  TaxRulesRepository({
    required this.frenchCarBrackets,
    required this.frenchTwoWheelsBrackets,
    this.frenchElectricBonusPercent = 20.0,
    this.luxembourgFlatEur = 0.40,
    this.belgiumFlatEur = 0.43,
    this.germanyDienstreisenEur = 0.30,
    this.germanyPendlerFirst20Eur = 0.30,
    this.germanyPendlerAfter20Eur = 0.38,
    this.switzerlandFlatChf = 0.72,
  });

  factory TaxRulesRepository.defaults() {
    return TaxRulesRepository(
      frenchCarBrackets: {
        3: BracketFormula(
          t1Limit: 5000,
          t2Limit: 20000,
          rate1: 0.529,
          rate2: 0.316,
          fixed2: 1065,
          rate3: 0.370,
        ),
        4: BracketFormula(
          t1Limit: 5000,
          t2Limit: 20000,
          rate1: 0.606,
          rate2: 0.340,
          fixed2: 1330,
          rate3: 0.407,
        ),
        5: BracketFormula(
          t1Limit: 5000,
          t2Limit: 20000,
          rate1: 0.636,
          rate2: 0.357,
          fixed2: 1395,
          rate3: 0.427,
        ),
        6: BracketFormula(
          t1Limit: 5000,
          t2Limit: 20000,
          rate1: 0.665,
          rate2: 0.374,
          fixed2: 1457,
          rate3: 0.447,
        ),
        7: BracketFormula(
          t1Limit: 5000,
          t2Limit: 20000,
          rate1: 0.697,
          rate2: 0.394,
          fixed2: 1515,
          rate3: 0.470,
        ),
      },
      frenchTwoWheelsBrackets: {
        'SCOOTER': BracketFormula(
          t1Limit: 3000,
          t2Limit: 6000,
          rate1: 0.315,
          rate2: 0.079,
          fixed2: 711,
          rate3: 0.198,
        ),
        'MOTO_1_2': BracketFormula(
          t1Limit: 3000,
          t2Limit: 6000,
          rate1: 0.395,
          rate2: 0.099,
          fixed2: 891,
          rate3: 0.248,
        ),
        'MOTO_3_5': BracketFormula(
          t1Limit: 3000,
          t2Limit: 6000,
          rate1: 0.468,
          rate2: 0.082,
          fixed2: 1158,
          rate3: 0.275,
        ),
        'MOTO_6_PLUS': BracketFormula(
          t1Limit: 3000,
          t2Limit: 6000,
          rate1: 0.606,
          rate2: 0.079,
          fixed2: 1583,
          rate3: 0.343,
        ),
      },
    );
  }

  Map<String, dynamic> toJson() => {
        'frenchElectricBonusPercent': frenchElectricBonusPercent,
        'luxembourgFlatEur': luxembourgFlatEur,
        'belgiumFlatEur': belgiumFlatEur,
        'germanyDienstreisenEur': germanyDienstreisenEur,
        'germanyPendlerFirst20Eur': germanyPendlerFirst20Eur,
        'germanyPendlerAfter20Eur': germanyPendlerAfter20Eur,
        'switzerlandFlatChf': switzerlandFlatChf,
      };

  factory TaxRulesRepository.fromJson(Map<String, dynamic> json) {
    final def = TaxRulesRepository.defaults();
    return TaxRulesRepository(
      frenchCarBrackets: def.frenchCarBrackets,
      frenchTwoWheelsBrackets: def.frenchTwoWheelsBrackets,
      frenchElectricBonusPercent:
          ((json['frenchElectricBonusPercent'] ?? 20.0) as num).toDouble(),
      luxembourgFlatEur:
          ((json['luxembourgFlatEur'] ?? 0.40) as num).toDouble(),
      belgiumFlatEur: ((json['belgiumFlatEur'] ?? 0.43) as num).toDouble(),
      germanyDienstreisenEur:
          ((json['germanyDienstreisenEur'] ?? 0.30) as num).toDouble(),
      germanyPendlerFirst20Eur:
          ((json['germanyPendlerFirst20Eur'] ?? 0.30) as num).toDouble(),
      germanyPendlerAfter20Eur:
          ((json['germanyPendlerAfter20Eur'] ?? 0.38) as num).toDouble(),
      switzerlandFlatChf:
          ((json['switzerlandFlatChf'] ?? 0.72) as num).toDouble(),
    );
  }
}

class TaxComputationOutput {
  final double amount;
  final String currency;
  final String ruleSummary;

  const TaxComputationOutput({
    required this.amount,
    required this.currency,
    required this.ruleSummary,
  });
}

class TaxEngineService {
  static BracketFormula _resolveFrenchFormula(
    VehicleEntity vehicle,
    TaxRulesRepository rules,
  ) {
    if (vehicle.vehicleGroup == 'SCOOTER') {
      return rules.frenchTwoWheelsBrackets['SCOOTER']!;
    }
    if (vehicle.vehicleGroup == 'MOTO') {
      if (vehicle.fiscalHp <= 2) {
        return rules.frenchTwoWheelsBrackets['MOTO_1_2']!;
      } else if (vehicle.fiscalHp <= 5) {
        return rules.frenchTwoWheelsBrackets['MOTO_3_5']!;
      } else {
        return rules.frenchTwoWheelsBrackets['MOTO_6_PLUS']!;
      }
    }
    final clampedHp = vehicle.fiscalHp.clamp(3, 7);
    return rules.frenchCarBrackets[clampedHp] ?? rules.frenchCarBrackets[5]!;
  }

  static double computeFrenchCumulativeAllowance({
    required double cumulativeDistanceKm,
    required VehicleEntity vehicle,
    required TaxRulesRepository rules,
  }) {
    if (cumulativeDistanceKm <= 0) return 0.0;
    final f = _resolveFrenchFormula(vehicle, rules);
    double total;
    if (cumulativeDistanceKm <= f.t1Limit) {
      total = cumulativeDistanceKm * f.rate1;
    } else if (cumulativeDistanceKm <= f.t2Limit) {
      total = (cumulativeDistanceKm * f.rate2) + f.fixed2;
    } else {
      total = cumulativeDistanceKm * f.rate3;
    }

    if (vehicle.isElectric) {
      total *= (1.0 + (rules.frenchElectricBonusPercent / 100.0));
    }
    return total;
  }

  static TaxComputationOutput evaluateTrip({
    required String countryCode,
    required double distanceKm,
    required double priorAnnualFrenchKm,
    required VehicleEntity vehicle,
    required String purpose,
    required String qualificationStatus,
    required TaxRulesRepository rules,
  }) {
    final defaultCurr = countryCode == 'CH' ? 'CHF' : 'EUR';
    if (qualificationStatus == 'PERSO' || distanceKm <= 0) {
      return TaxComputationOutput(
        amount: 0.0,
        currency: defaultCurr,
        ruleSummary: 'Trajet Personnel (Non déductible)',
      );
    }

    switch (countryCode) {
      case 'FR':
        final f = _resolveFrenchFormula(vehicle, rules);
        final before = computeFrenchCumulativeAllowance(
          cumulativeDistanceKm: priorAnnualFrenchKm,
          vehicle: vehicle,
          rules: rules,
        );
        final newTotalKm = priorAnnualFrenchKm + distanceKm;
        final after = computeFrenchCumulativeAllowance(
          cumulativeDistanceKm: newTotalKm,
          vehicle: vehicle,
          rules: rules,
        );
        final delta = math.max(0.0, after - before);
        final evTag = vehicle.isElectric
            ? ' (+${rules.frenchElectricBonusPercent.toInt()}% Élec)'
            : '';

        String trancheDesc;
        if (newTotalKm <= f.t1Limit) {
          trancheDesc =
              'FR ${vehicle.fiscalCategory} • Tranche 1 (d × ${f.rate1}$evTag)';
        } else if (newTotalKm <= f.t2Limit) {
          trancheDesc =
              'FR ${vehicle.fiscalCategory} • Tranche 2 ((d × ${f.rate2}) + ${f.fixed2.toInt()}€$evTag)';
        } else {
          trancheDesc =
              'FR ${vehicle.fiscalCategory} • Tranche 3 (d × ${f.rate3}$evTag)';
        }

        return TaxComputationOutput(
          amount: delta,
          currency: 'EUR',
          ruleSummary: trancheDesc,
        );

      case 'LU':
        return TaxComputationOutput(
          amount: distanceKm * rules.luxembourgFlatEur,
          currency: 'EUR',
          ruleSummary:
              'Luxembourg Forfait Grand-Ducal (${rules.luxembourgFlatEur.toStringAsFixed(2)} €/km)',
        );

      case 'BE':
        return TaxComputationOutput(
          amount: distanceKm * rules.belgiumFlatEur,
          currency: 'EUR',
          ruleSummary:
              'Belgique Indemnité Fédérale (${rules.belgiumFlatEur.toStringAsFixed(2)} €/km)',
        );

      case 'DE':
        final isPendler = purpose.toLowerCase().contains('domicile') ||
            purpose.toLowerCase().contains('pendler');
        if (isPendler) {
          final km1To20 = math.min(distanceKm, 20.0);
          final kmOver20 = math.max(0.0, distanceKm - 20.0);
          final val = (km1To20 * rules.germanyPendlerFirst20Eur) +
              (kmOver20 * rules.germanyPendlerAfter20Eur);
          return TaxComputationOutput(
            amount: val,
            currency: 'EUR',
            ruleSummary:
                'Allemagne Pendlerpauschale (${rules.germanyPendlerFirst20Eur.toStringAsFixed(2)}€ ≤20km / ${rules.germanyPendlerAfter20Eur.toStringAsFixed(2)}€ >20km)',
          );
        }
        return TaxComputationOutput(
          amount: distanceKm * rules.germanyDienstreisenEur,
          currency: 'EUR',
          ruleSummary:
              'Allemagne Dienstreisen (${rules.germanyDienstreisenEur.toStringAsFixed(2)} €/km)',
        );

      case 'CH':
        return TaxComputationOutput(
          amount: distanceKm * rules.switzerlandFlatChf,
          currency: 'CHF',
          ruleSummary:
              'Suisse Barème TCS / Cantonal (${rules.switzerlandFlatChf.toStringAsFixed(2)} CHF/km)',
        );

      default:
        return TaxComputationOutput(
          amount: distanceKm * 0.40,
          currency: 'EUR',
          ruleSummary: 'Forfait Standard (0.40 €/km)',
        );
    }
  }
}

// ============================================================================
// 6. VRAI SERVICE GPS MATÉRIEL (`Geolocator`) + GÉOCODAGE + ROUTAGE ROUTIER
// ============================================================================
class GeoPointCoord {
  final double lat;
  final double lon;
  final String displayName;

  const GeoPointCoord({
    required this.lat,
    required this.lon,
    required this.displayName,
  });
}

class RealGpsAndRoutingService {
  /// Base de coordonnées connues pour garantir un fonctionnement instantané
  /// même en zone blanche réseau ou si l'adresse contient un libellé
  static const Map<String, List<double>> _knownCityCoords = {
    'uffheim': [47.6486, 7.4425],
    'sierentz': [47.6558, 7.4561],
    'brunstatt': [47.7230, 7.3228],
    'mulhouse': [47.7508, 7.3359],
    'colmar': [48.0794, 7.3585],
    'strasbourg': [48.5734, 7.7521],
    'saint-louis': [47.5869, 7.5644],
    'belfort': [47.6397, 6.8638],
    'nancy': [48.6921, 6.1844],
    'metz': [49.1193, 6.1757],
    'reims': [49.2583, 4.0317],
    'paris': [48.8566, 2.3522],
    'lyon': [45.7640, 4.8357],
    'luxembourg': [49.6116, 6.1319],
    'kirchberg': [49.6333, 6.1667],
    'esch-sur-alzette': [49.4958, 5.9806],
    'cloche d\'or': [49.5815, 6.1125],
    'basel': [47.5596, 7.5886],
    'bâle': [47.5596, 7.5886],
    'bale': [47.5596, 7.5886],
    'zurich': [47.3769, 8.5417],
    'zürich': [47.3769, 8.5417],
    'geneve': [46.2044, 6.1432],
    'genève': [46.2044, 6.1432],
    'lausanne': [46.5197, 6.6323],
    'bern': [46.9480, 7.4474],
    'freiburg': [47.9990, 7.8421],
    'weil am rhein': [47.5942, 7.6108],
    'lörrach': [47.6152, 7.6615],
    'karlsruhe': [49.0069, 8.4037],
    'stuttgart': [48.7758, 9.1829],
    'frankfurt': [50.1109, 8.6821],
    'bruxelles': [50.8503, 4.3517],
    'brussels': [50.8503, 4.3517],
    'arlon': [49.6833, 5.8167],
    'liège': [50.6326, 5.5797],
  };

  static String cleanAddress(String raw) {
    if (raw.contains(' — ')) {
      return raw.split(' — ').last.trim();
    }
    return raw.trim();
  }

  /// Demande la vraie permission GPS Android et retourne la position actuelle + adresse
  static Future<GeoPointCoord> getCurrentGpsAddress({
    String googleApiKey = '',
  }) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
        'Le GPS du téléphone est désactivé. Veuillez activer la Localisation dans la barre Android.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permission GPS refusée par l\'utilisateur.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Permission GPS bloquée. Autorisez la localisation dans les Paramètres Android de l\'application.',
      );
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );

    final addr = await reverseGeocode(
      lat: pos.latitude,
      lon: pos.longitude,
      googleApiKey: googleApiKey,
    );
    return GeoPointCoord(
      lat: pos.latitude,
      lon: pos.longitude,
      displayName: addr,
    );
  }

  /// Convertit des coordonnées GPS (lat, lon) en adresse postale lisible
  static Future<String> reverseGeocode({
    required double lat,
    required double lon,
    String googleApiKey = '',
  }) async {
    // 1. Google Geocoding API si clé fournie
    if (googleApiKey.trim().isNotEmpty) {
      try {
        final uri = Uri.https(
          'maps.googleapis.com',
          '/maps/api/geocode/json',
          {
            'latlng': '$lat,$lon',
            'language': 'fr',
            'key': googleApiKey.trim(),
          },
        );
        final res = await http.get(uri).timeout(const Duration(seconds: 4));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          final results = (data['results'] as List?) ?? [];
          if (results.isNotEmpty) {
            final formatted = results.first['formatted_address']?.toString();
            if (formatted != null && formatted.isNotEmpty) return formatted;
          }
        }
      } catch (_) {}
    }

    // 2. Photon Komoot Reverse Geocoder (Ultra-rapide & sans clé API)
    try {
      final uri = Uri.parse(
        'https://photon.komoot.io/reverse?lon=$lon&lat=$lat&lang=fr',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final features = (data['features'] as List?) ?? [];
        if (features.isNotEmpty) {
          final props =
              (features.first['properties'] as Map<String, dynamic>?) ?? {};
          final street = props['street'] ?? props['name'] ?? '';
          final housenumber = props['housenumber'] ?? '';
          final postcode = props['postcode'] ?? '';
          final city = props['city'] ?? props['locality'] ?? '';
          final country = props['country'] ?? '';
          final parts = [
            if ('$housenumber $street'.trim().isNotEmpty)
              '$housenumber $street'.trim(),
            if ('$postcode $city'.trim().isNotEmpty) '$postcode $city'.trim(),
            if (country.toString().isNotEmpty) country.toString(),
          ];
          if (parts.isNotEmpty) return parts.join(', ');
        }
      }
    } catch (_) {}

    // 3. Nominatim Reverse Geocoder
    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/reverse',
        {
          'lat': lat.toString(),
          'lon': lon.toString(),
          'format': 'json',
          'accept-language': 'fr',
        },
      );
      final res = await http.get(
        uri,
        headers: {'User-Agent': 'PiratePipsKiloTrackerPro/3.0'},
      ).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final disp = data['display_name']?.toString();
        if (disp != null && disp.isNotEmpty) return disp;
      }
    } catch (_) {}

    return '${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}';
  }

  /// Autocomplétion d'adresses multi-sources (Favoris + Photon Komoot + Google Places)
  static Future<List<String>> autocompleteAddress({
    required String query,
    required String googleApiKey,
    required List<SavedLocationEntity> savedLocations,
  }) async {
    final q = query.trim();
    if (q.length < 2) return [];

    final suggestions = <String>[];

    // 1. Favoris locaux
    for (final loc in savedLocations) {
      if (loc.label.toLowerCase().contains(q.toLowerCase()) ||
          loc.fullAddress.toLowerCase().contains(q.toLowerCase())) {
        suggestions.add('${loc.label} — ${loc.fullAddress}');
      }
    }

    // 2. Google Places API si clé configurée
    if (googleApiKey.trim().isNotEmpty) {
      try {
        final uri = Uri.https(
          'maps.googleapis.com',
          '/maps/api/place/autocomplete/json',
          {'input': q, 'language': 'fr', 'key': googleApiKey.trim()},
        );
        final res = await http.get(uri).timeout(const Duration(seconds: 4));
        if (res.statusCode == 200) {
          final body = jsonDecode(res.body) as Map<String, dynamic>;
          if (body['status'] == 'OK') {
            final preds = (body['predictions'] as List?) ?? [];
            for (final p in preds.take(5)) {
              final d = p['description']?.toString() ?? '';
              if (d.isNotEmpty && !suggestions.contains(d)) {
                suggestions.add(d);
              }
            }
            if (suggestions.length >= 3) return suggestions;
          }
        }
      } catch (_) {}
    }

    // 3. Photon Komoot (OpenStreetMap Search ultra-tolérant aux fautes et rapide)
    try {
      final uri = Uri.https(
        'photon.komoot.io',
        '/api/',
        {'q': q, 'lang': 'fr', 'limit': '5'},
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final features = (data['features'] as List?) ?? [];
        for (final f in features) {
          final props = (f['properties'] as Map<String, dynamic>?) ?? {};
          final name = props['name'] ?? '';
          final street = props['street'] ?? '';
          final postcode = props['postcode'] ?? '';
          final city = props['city'] ?? '';
          final country = props['country'] ?? '';
          final labelParts = <String>[
            if (name.toString().isNotEmpty) name.toString(),
            if (street.toString().isNotEmpty && street != name)
              street.toString(),
            if ('$postcode $city'.trim().isNotEmpty) '$postcode $city'.trim(),
            if (country.toString().isNotEmpty) country.toString(),
          ];
          final formatted = labelParts.join(', ');
          if (formatted.isNotEmpty && !suggestions.contains(formatted)) {
            suggestions.add(formatted);
          }
        }
      }
    } catch (_) {}

    return suggestions;
  }

  /// Résout une adresse texte en coordonnées GPS exactes (lat, lon)
  static Future<GeoPointCoord?> geocodeAddress(
    String rawAddress, {
    String googleApiKey = '',
  }) async {
    final addr = cleanAddress(rawAddress);
    if (addr.isEmpty) return null;

    // Si l'utilisateur a déjà des coordonnées "47.6486, 7.4425"
    final coordParts = addr.split(',');
    if (coordParts.length == 2) {
      final lat = double.tryParse(coordParts[0].trim());
      final lon = double.tryParse(coordParts[1].trim());
      if (lat != null && lon != null) {
        return GeoPointCoord(lat: lat, lon: lon, displayName: addr);
      }
    }

    // 1. Photon Komoot Geocoder
    try {
      final uri = Uri.https(
        'photon.komoot.io',
        '/api/',
        {'q': addr, 'limit': '1'},
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final features = (data['features'] as List?) ?? [];
        if (features.isNotEmpty) {
          final geom =
              (features.first['geometry'] as Map<String, dynamic>?) ?? {};
          final coords = (geom['coordinates'] as List?) ?? [];
          if (coords.length >= 2) {
            final lon = (coords[0] as num).toDouble();
            final lat = (coords[1] as num).toDouble();
            return GeoPointCoord(lat: lat, lon: lon, displayName: addr);
          }
        }
      }
    } catch (_) {}

    // 2. Nominatim OpenStreetMap
    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        {'q': addr, 'format': 'json', 'limit': '1'},
      );
      final res = await http.get(
        uri,
        headers: {'User-Agent': 'PiratePipsKiloTrackerPro/3.0'},
      ).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        if (list.isNotEmpty) {
          final lat = double.tryParse(list.first['lat'].toString());
          final lon = double.tryParse(list.first['lon'].toString());
          if (lat != null && lon != null) {
            return GeoPointCoord(lat: lat, lon: lon, displayName: addr);
          }
        }
      }
    } catch (_) {}

    // 3. Recherche dans le dictionnaire local des villes FR / LU / CH / DE / BE
    final lower = addr.toLowerCase();
    for (final entry in _knownCityCoords.entries) {
      if (lower.contains(entry.key)) {
        return GeoPointCoord(
          lat: entry.value[0],
          lon: entry.value[1],
          displayName: addr,
        );
      }
    }

    return null;
  }

  /// Formule géodésique Haversine (en km)
  static double haversineKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * math.pi / 180.0;
    final dLon = (lon2 - lon1) * math.pi / 180.0;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180.0) *
            math.cos(lat2 * math.pi / 180.0) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  /// Calcule la vraie distance routière entre Départ, Étapes et Arrivée
  static Future<Map<String, dynamic>> computeDrivingRoute({
    required String origin,
    required String destination,
    required List<WaypointEntity> waypoints,
    required String googleApiKey,
  }) async {
    final cleanOrig = cleanAddress(origin);
    final cleanDest = cleanAddress(destination);
    final cleanStops = waypoints
        .map((w) => cleanAddress(w.address))
        .where((s) => s.isNotEmpty)
        .toList();

    // 1. Si une clé Google Maps valide est renseignée, on interroge Google Directions
    if (googleApiKey.trim().isNotEmpty) {
      try {
        final params = <String, String>{
          'origin': cleanOrig,
          'destination': cleanDest,
          'mode': 'driving',
          'language': 'fr',
          'key': googleApiKey.trim(),
        };
        if (cleanStops.isNotEmpty) {
          params['waypoints'] = cleanStops.join('|');
        }
        final uri = Uri.https(
          'maps.googleapis.com',
          '/maps/api/directions/json',
          params,
        );
        final res = await http.get(uri).timeout(const Duration(seconds: 5));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          final routes = (data['routes'] as List?) ?? [];
          if (routes.isNotEmpty) {
            final legs = (routes.first['legs'] as List?) ?? [];
            double meters = 0;
            int secs = 0;
            for (final leg in legs) {
              meters += ((leg['distance']?['value'] ?? 0) as num).toDouble();
              secs += ((leg['duration']?['value'] ?? 0) as num).toInt();
            }
            if (meters > 0) {
              return {
                'km': double.parse((meters / 1000.0).toStringAsFixed(1)),
                'duration': '${(secs / 60).round()} min',
                'provider': 'Google Maps Directions API',
              };
            }
          }
        }
      } catch (_) {}
    }

    // 2. Géocodage de chaque étape puis routage routier OSRM (100% gratuit sans clé)
    final allAddresses = <String>[cleanOrig, ...cleanStops, cleanDest];
    final resolvedCoords = <GeoPointCoord>[];

    for (final addr in allAddresses) {
      final pt = await geocodeAddress(addr, googleApiKey: googleApiKey);
      if (pt != null) {
        resolvedCoords.add(pt);
      }
    }

    if (resolvedCoords.length >= 2) {
      // 2a. Appel du moteur routier OSRM avec les coordonnées exactes
      try {
        final coordString =
            resolvedCoords.map((p) => '${p.lon},${p.lat}').join(';');
        final osrmUri = Uri.parse(
          'https://router.project-osrm.org/route/v1/driving/$coordString?overview=false',
        );
        final osrmRes =
            await http.get(osrmUri).timeout(const Duration(seconds: 5));
        if (osrmRes.statusCode == 200) {
          final data = jsonDecode(osrmRes.body) as Map<String, dynamic>;
          final routes = (data['routes'] as List?) ?? [];
          if (routes.isNotEmpty) {
            final meters =
                ((routes.first['distance'] ?? 0) as num).toDouble();
            final secs =
                ((routes.first['duration'] ?? 0) as num).toDouble();
            if (meters > 0) {
              return {
                'km': double.parse((meters / 1000.0).toStringAsFixed(1)),
                'duration': '${(secs / 60).round()} min',
                'provider': 'Routage Routier GPS (OSRM)',
              };
            }
          }
        }
      } catch (_) {}

      // 2b. Calcul géodésique exact entre les coordonnées + coefficient routier (×1.28)
      double totalRoadKm = 0.0;
      for (int i = 0; i < resolvedCoords.length - 1; i++) {
        final legAirKm = haversineKm(
          resolvedCoords[i].lat,
          resolvedCoords[i].lon,
          resolvedCoords[i + 1].lat,
          resolvedCoords[i + 1].lon,
        );
        totalRoadKm += legAirKm * 1.28;
      }
      final finalKm = math.max(1.2, totalRoadKm);
      return {
        'km': double.parse(finalKm.toStringAsFixed(1)),
        'duration': '${(finalKm * 1.05).round()} min',
        'provider': 'Calcul GPS Géodésique Routier',
      };
    }

    throw Exception(
      'Impossible de localiser l\'une des adresses. Sélectionnez une suggestion ou cliquez sur 📍 Ma position GPS.',
    );
  }
}

// ============================================================================
// 7. VRAI MOTEUR D'EXPORT PDF NATIF & EXCEL (.XLS / .CSV) AVEC PARTAGE ANDROID
// ============================================================================
class NativeExportService {
  /// Génère un vrai fichier PDF A4 probant et ouvre le dialogue natif Android
  static Future<void> generateAndSharePdf({
    required BuildContext context,
    required DriverProfile driver,
    required VehicleEntity vehicle,
    required List<TripEntity> trips,
  }) async {
    final doc = pw.Document();
    final proTrips = trips.where((t) => t.isPro).toList();
    final totalKm =
        proTrips.fold<double>(0.0, (s, t) => s + t.finalDistanceKm);
    final totalEur = proTrips
        .where((t) => t.currency == 'EUR')
        .fold<double>(0.0, (s, t) => s + t.reimbursementAmount);
    final totalChf = proTrips
        .where((t) => t.currency == 'CHF')
        .fold<double>(0.0, (s, t) => s + t.reimbursementAmount);

    final now = DateTime.now();
    final dateGenerated =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context ctx) => [
          // En-tête officiel Pirate Pips™
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#161616'),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'PIRATE PIPS™ - RELEVE D\'INDEMNITES KILOMETRIQUES CERTIFIE',
                      style: pw.TextStyle(
                        color: PdfColor.fromHex('#F5A623'),
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Document justificatif conforme Expert-Comptable & Administration Fiscale - Edite le $dateGenerated',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Total Pro : ${totalKm.toStringAsFixed(1)} km',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Indemnites : ${totalEur.toStringAsFixed(2)} EUR${totalChf > 0 ? " + ${totalChf.toStringAsFixed(2)} CHF" : ""}',
                      style: pw.TextStyle(
                        color: PdfColor.fromHex('#22C55E'),
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 12),

          // Informations fiscales Conducteur / Entreprise / Véhicule
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Conducteur : ${driver.fullName} (${driver.role})',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Domicile : ${driver.personalAddress}',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Entreprise : ${driver.companyName}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Siege : ${driver.companyAddress}',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Vehicule : ${vehicle.name} (${vehicle.licensePlate})',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Categorie : ${vehicle.fiscalCategory} | Odo : ${vehicle.currentOdometerKm.toStringAsFixed(0)} km',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 14),

          // Tableau chronologique détaillé
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
            headerDecoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#1F1F1F'),
            ),
            cellStyle: const pw.TextStyle(fontSize: 8),
            headers: [
              'Date & Heure',
              'Pays',
              'Point de Depart',
              'Etapes',
              'Destination',
              'Motif',
              'Km Maps',
              'Marge',
              'Total Km',
              'Odo Fin',
              'Montant',
            ],
            data: proTrips.map((t) {
              final dt =
                  '${t.date.day.toString().padLeft(2, '0')}/${t.date.month.toString().padLeft(2, '0')}/${t.date.year} ${t.startTime}';
              final wps = t.waypoints.map((w) => w.label).join(', ');
              return [
                dt,
                t.countryCode,
                t.originAddress,
                wps.isEmpty ? '-' : wps,
                '${t.destinationAddress}${t.isRoundTrip ? " (A/R)" : ""}',
                t.purpose,
                '${t.mapsDistanceKm.toStringAsFixed(1)}',
                '+${t.detourMarginPercent.toInt()}%',
                '${t.finalDistanceKm.toStringAsFixed(1)} km',
                '${t.odometerEndKm.toFixedString(0)} km',
                '${t.reimbursementAmount.toStringAsFixed(2)} ${t.currency}',
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Protection legale, propriete exclusive de Pirate Pips™. Certifie exact par le declarant.',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        ],
      ),
    );

    final bytes = await doc.save();
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/Rapport_Kilometrique_PiratePips_${now.year}_${now.month}.pdf',
    );
    await file.writeAsBytes(bytes, flush: true);

    // Ouvre le menu d'impression / sauvegarde PDF natif d'Android
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: 'Rapport_Kilometrique_PiratePips.pdf',
    );
  }

  /// Partage directement le fichier PDF via la feuille de partage Android (WhatsApp, Mail, Fichiers)
  static Future<void> sharePdfFileDirectly({
    required DriverProfile driver,
    required VehicleEntity vehicle,
    required List<TripEntity> trips,
  }) async {
    final doc = pw.Document();
    final proTrips = trips.where((t) => t.isPro).toList();
    final totalKm =
        proTrips.fold<double>(0.0, (s, t) => s + t.finalDistanceKm);
    final totalEur = proTrips
        .where((t) => t.currency == 'EUR')
        .fold<double>(0.0, (s, t) => s + t.reimbursementAmount);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (_) => [
          pw.Text(
            'PIRATE PIPS™ - RAPPORT KILOMETRIQUE (${driver.fullName})',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Entreprise : ${driver.companyName} (${driver.companyAddress}) | Vehicule : ${vehicle.name} (${vehicle.licensePlate})',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            'Total Distance Pro : ${totalKm.toStringAsFixed(1)} km | Total Indemnites : ${totalEur.toStringAsFixed(2)} EUR',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: [
              'Date',
              'Pays',
              'Depart',
              'Arrivee',
              'Motif',
              'Total Km',
              'Indemnite',
            ],
            data: proTrips.map((t) {
              final dt =
                  '${t.date.day.toString().padLeft(2, '0')}/${t.date.month.toString().padLeft(2, '0')}/${t.date.year}';
              return [
                dt,
                t.countryCode,
                t.originAddress,
                t.destinationAddress,
                t.purpose,
                '${t.finalDistanceKm.toStringAsFixed(1)} km',
                '${t.reimbursementAmount.toStringAsFixed(2)} ${t.currency}',
              ];
            }).toList(),
          ),
        ],
      ),
    );

    final bytes = await doc.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/PiratePips_Indemnites_Kilometriques.pdf');
    await file.writeAsBytes(bytes, flush: true);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: 'Rapport Kilométrique Pirate Pips™',
    );
  }

  /// Génère un vrai fichier Excel (.csv avec BOM UTF-8 + .xls) et ouvre le partage natif Android
  static Future<void> generateAndShareExcel({
    required List<TripEntity> trips,
    required List<DriverProfile> drivers,
    required List<VehicleEntity> vehicles,
  }) async {
    final sb = StringBuffer();
    // BOM UTF-8 obligatoire pour que Microsoft Excel reconnaisse les accents et les colonnes ";"
    sb.write('\uFEFF');
    sb.writeln(
      'Date;Heure;Conducteur;Statut_Conducteur;Entreprise;Adresse_Entreprise;Vehicule;Plaque;Categorie_Fiscale;Pays;Adresse_Depart;Etapes_Intermediaires;Adresse_Arrivee;Aller_Retour;Motif;Statut_Fiscal;Km_Google_Maps;Marge_Detours_Pct;Total_Km_Retenu;Montant_Indemnise;Devise;Odo_Depart_Km;Odo_Fin_Km;Regle_Fiscale_Appliquee;Notes',
    );

    for (final t in trips) {
      final d = drivers.where((e) => e.id == t.driverId).firstOrNull;
      final v = vehicles.where((e) => e.id == t.vehicleId).firstOrNull;
      final dt =
          '${t.date.day.toString().padLeft(2, '0')}/${t.date.month.toString().padLeft(2, '0')}/${t.date.year}';
      final wps = t.waypoints.map((w) => '${w.label}: ${w.address}').join(' | ');

      sb.writeln(
        '$dt;${t.startTime};"${d?.fullName ?? ""}";"${d?.role ?? ""}";"${d?.companyName ?? ""}";"${d?.companyAddress ?? ""}";"${v?.name ?? ""}";"${v?.licensePlate ?? ""}";"${v?.fiscalCategory ?? ""}";${t.countryCode};"${t.originAddress}";"$wps";"${t.destinationAddress}";${t.isRoundTrip ? "OUI" : "NON"};"${t.purpose}";${t.qualificationStatus};${t.mapsDistanceKm.toStringAsFixed(1).replaceAll('.', ',')};${t.detourMarginPercent.toInt()}%;${t.finalDistanceKm.toStringAsFixed(1).replaceAll('.', ',')};${t.reimbursementAmount.toStringAsFixed(2).replaceAll('.', ',')};${t.currency};${t.odometerStartKm.toStringAsFixed(1).replaceAll('.', ',')};${t.odometerEndKm.toStringAsFixed(1).replaceAll('.', ',')};"${t.appliedRuleLabel}";"${t.notes}"',
      );
    }

    final dir = await getTemporaryDirectory();
    final now = DateTime.now();
    final csvFile = File(
      '${dir.path}/Export_Excel_PiratePips_${now.year}_${now.month}.csv',
    );
    await csvFile.writeAsString(sb.toString(), encoding: utf8, flush: true);

    await Share.shareXFiles(
      [XFile(csvFile.path, mimeType: 'text/csv')],
      subject: 'Export Excel Indemnités Kilométriques Pirate Pips™',
    );
  }
}

extension _NumFixedExt on double {
  String toFixedString(int decimals) => toStringAsFixed(decimals);
}

// ============================================================================
// 8. APPLICATION ROOT & SPLASH SCREEN PIRATE PIPS™
// ============================================================================
class PiratePipsKiloProApp extends StatelessWidget {
  const PiratePipsKiloProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pirate Pips™ KiloTracker Pro',
      debugShowCheckedModeBanner: false,
      theme: PiratePalette.theme,
      home: const PirateSplashGateway(),
    );
  }
}

class PirateSplashGateway extends StatefulWidget {
  const PirateSplashGateway({super.key});

  @override
  State<PirateSplashGateway> createState() => _PirateSplashGatewayState();
}

class _PirateSplashGatewayState extends State<PirateSplashGateway>
    with SingleTickerProviderStateMixin {
  bool _inSplash = true;
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulse = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
    Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _inSplash = false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_inSplash) return const MainNavigationWorkspace();

    return Scaffold(
      backgroundColor: PiratePalette.bgDeep,
      body: Center(
        child: ScaleTransition(
          scale: _pulse,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PiratePipsBadgeLogo(size: 116),
              const SizedBox(height: 22),
              const Text(
                'PIRATE PIPS™',
                style: TextStyle(
                  color: PiratePalette.textPure,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: PiratePalette.goldPrimary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: PiratePalette.goldPrimary),
                ),
                child: const Text(
                  'GPS TEMPS RÉEL • PDF & EXCEL CERTIFIÉS',
                  style: TextStyle(
                    color: PiratePalette.goldPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const CircularProgressIndicator(color: PiratePalette.goldPrimary),
              const SizedBox(height: 18),
              const Text(
                'Développé par Pirate Pips™',
                style: TextStyle(color: PiratePalette.textSteel, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 9. SHELL PRINCIPAL (5 ENTRÉES + TRACKING GPS EN DIRECT + EXPORTS NATIFS)
// ============================================================================
class MainNavigationWorkspace extends StatefulWidget {
  const MainNavigationWorkspace({super.key});

  @override
  State<MainNavigationWorkspace> createState() =>
      _MainNavigationWorkspaceState();
}

class _MainNavigationWorkspaceState extends State<MainNavigationWorkspace> {
  int _activeTab = 0;
  bool _loading = true;

  bool _autoTrackingEnabled = true;
  bool _permMotionActivity = true;
  bool _permLocationAlways = true;
  bool _permNotifications = true;
  bool _permBatteryUnrestricted = true;
  bool _permBluetoothBeacon = true;

  // État du Chronomètre GPS en Direct (Live GPS Trip Recorder)
  bool _isLiveGpsRecording = false;
  Position? _liveStartPosition;
  Position? _liveLastPosition;
  String _liveStartAddress = '';
  double _liveAccumulatedKm = 0.0;
  DateTime? _liveStartTime;
  StreamSubscription<Position>? _gpsStreamSub;

  List<DriverProfile> _drivers = [];
  List<VehicleEntity> _vehicles = [];
  List<SavedLocationEntity> _locations = [];
  List<TripEntity> _trips = [];
  List<OdometerLogEntity> _odometerLogs = [];
  TaxRulesRepository _taxRules = TaxRulesRepository.defaults();

  String _defaultCountry = 'FR';
  double _defaultDetourMargin = 5.0;
  String _googleMapsApiKey = '';

  int get _completedOnboardingSteps {
    int c = 0;
    if (_permMotionActivity) c++;
    if (_permLocationAlways) c++;
    if (_permNotifications) c++;
    if (_permBatteryUnrestricted) c++;
    if (_permBluetoothBeacon) c++;
    return c;
  }

  @override
  void initState() {
    super.initState();
    _bootstrapLocalStore();
  }

  @override
  void dispose() {
    _gpsStreamSub?.cancel();
    super.dispose();
  }

  Future<void> _bootstrapLocalStore() async {
    final prefs = await SharedPreferences.getInstance();

    _autoTrackingEnabled = prefs.getBool('pp3_auto_tracking') ?? true;
    _permMotionActivity = prefs.getBool('pp3_perm_motion') ?? true;
    _permLocationAlways = prefs.getBool('pp3_perm_loc') ?? true;
    _permNotifications = prefs.getBool('pp3_perm_notif') ?? true;
    _permBatteryUnrestricted = prefs.getBool('pp3_perm_batt') ?? true;
    _permBluetoothBeacon = prefs.getBool('pp3_perm_bt') ?? true;

    _defaultCountry = prefs.getString('pp3_country') ?? 'FR';
    _defaultDetourMargin = prefs.getDouble('pp3_margin') ?? 5.0;
    _googleMapsApiKey = prefs.getString('pp3_gmaps_key') ?? '';

    final rawDrivers = prefs.getString('pp3_drivers');
    if (rawDrivers != null) {
      _drivers = (jsonDecode(rawDrivers) as List)
          .map((e) => DriverProfile.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      // Pré-rempli à 100% pour éviter tout blocage d'export PDF/Excel
      _drivers = [
        DriverProfile(
          id: 'drv_main',
          firstName: 'Antoine',
          lastName: 'Flory',
          role: 'Gérant',
          personalAddress: 'Uffheim, 68510, France',
          companyName: 'A&CSA INVEST S.à r.l. / Pirate Pips™',
          companyAddress: 'Boulevard Royal, L-2449 Luxembourg',
        ),
        DriverProfile(
          id: 'drv_team_1',
          firstName: 'Collaborateur',
          lastName: 'Commercial Grand Est',
          role: 'Salarié',
          personalAddress: 'Brunstatt-Didenheim, 68350, France',
          companyName: 'Pirate Pips™ France',
          companyAddress: 'Avenue de Colmar, 68100 Mulhouse, France',
        ),
      ];
    }

    final rawVehicles = prefs.getString('pp3_vehicles');
    if (rawVehicles != null) {
      _vehicles = (jsonDecode(rawVehicles) as List)
          .map((e) => VehicleEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      // Tous les véhicules ont une plaque valide par défaut
      _vehicles = [
        VehicleEntity(
          id: 'veh_glc',
          name: 'Mercedes-Benz GLC AMG',
          licensePlate: 'PP-888-LU',
          fiscalCategory: 'Voiture (7 CV et plus)',
          vehicleGroup: 'THERMIQUE',
          fiscalHp: 7,
          isElectric: false,
          currentOdometerKm: 44820.0,
          bluetoothBeaconName: 'MB-GLC-AMG-BT',
        ),
        VehicleEntity(
          id: 'veh_s560',
          name: 'Mercedes-Benz S560',
          licensePlate: 'PP-560-LU',
          fiscalCategory: 'Voiture (7 CV et plus)',
          vehicleGroup: 'THERMIQUE',
          fiscalHp: 7,
          isElectric: false,
          currentOdometerKm: 59400.0,
          bluetoothBeaconName: 'MB-S560-BT',
        ),
        VehicleEntity(
          id: 'veh_a45',
          name: 'Mercedes-Benz A45 AMG',
          licensePlate: 'PP-045-FR',
          fiscalCategory: 'Voiture (7 CV et plus)',
          vehicleGroup: 'THERMIQUE',
          fiscalHp: 7,
          isElectric: false,
          currentOdometerKm: 31200.0,
          bluetoothBeaconName: 'MB-A45-BT',
        ),
        VehicleEntity(
          id: 'veh_ranger',
          name: 'Ford Ranger Pick-up',
          licensePlate: 'PP-404-FR',
          fiscalCategory: 'Voiture (7 CV et plus)',
          vehicleGroup: 'THERMIQUE',
          fiscalHp: 7,
          isElectric: false,
          currentOdometerKm: 71300.0,
          bluetoothBeaconName: 'FORD-SYNC-BT',
        ),
      ];
    }

    final rawLocs = prefs.getString('pp3_locations');
    if (rawLocs != null) {
      _locations = (jsonDecode(rawLocs) as List)
          .map((e) => SavedLocationEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      _locations = [
        SavedLocationEntity(
          id: 'loc_1',
          label: 'Domicile Uffheim',
          fullAddress: 'Uffheim, 68510, France',
          locationType: 'EMPLACEMENT',
          lat: 47.6486,
          lon: 7.4425,
        ),
        SavedLocationEntity(
          id: 'loc_2',
          label: 'Brunstatt-Didenheim',
          fullAddress: 'Brunstatt-Didenheim, 68350, France',
          locationType: 'WORKPLACE',
          lat: 47.7230,
          lon: 7.3228,
        ),
        SavedLocationEntity(
          id: 'loc_3',
          label: 'Mulhouse Centre / Dépôt',
          fullAddress: 'Avenue de Colmar, 68100 Mulhouse, France',
          locationType: 'WORKPLACE',
          lat: 47.7508,
          lon: 7.3359,
        ),
        SavedLocationEntity(
          id: 'loc_4',
          label: 'Siège Luxembourg',
          fullAddress: 'Boulevard Royal, L-2449 Luxembourg',
          locationType: 'WORKPLACE',
          lat: 49.6116,
          lon: 6.1319,
        ),
        SavedLocationEntity(
          id: 'loc_5',
          label: 'Client Bâle (Suisse)',
          fullAddress: 'Aeschenplatz, 4052 Basel, Suisse',
          locationType: 'EMPLACEMENT',
          lat: 47.5596,
          lon: 7.5886,
        ),
      ];
    }

    final rawOdo = prefs.getString('pp3_odometer_logs');
    if (rawOdo != null) {
      _odometerLogs = (jsonDecode(rawOdo) as List)
          .map((e) => OdometerLogEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      _odometerLogs = [
        OdometerLogEntity(
          id: 'odo_1',
          vehicleId: 'veh_glc',
          recordedAt: DateTime.now().subtract(const Duration(days: 3)),
          odometerValueKm: 44700.0,
          photoEvidenceRef: 'COMPTEUR-GLC-CERTIFIE.JPG',
          note: 'Relevé périodique certifié',
        ),
      ];
    }

    final rawTax = prefs.getString('pp3_tax_rules');
    if (rawTax != null) {
      _taxRules = TaxRulesRepository.fromJson(
        jsonDecode(rawTax) as Map<String, dynamic>,
      );
    }

    final rawTrips = prefs.getString('pp3_trips');
    if (rawTrips != null) {
      _trips = (jsonDecode(rawTrips) as List)
          .map((e) => TripEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      _trips = [
        TripEntity(
          id: 'trp_1',
          date: DateTime.now(),
          startTime: '08:15',
          endTime: '08:45',
          driverId: 'drv_main',
          vehicleId: 'veh_glc',
          countryCode: 'FR',
          originAddress: 'Uffheim, 68510, France',
          destinationAddress: 'Avenue de Colmar, 68100 Mulhouse, France',
          waypoints: [
            WaypointEntity(
              label: 'Arrêt Chantier Brunstatt',
              address: 'Brunstatt-Didenheim, 68350, France',
            ),
          ],
          isRoundTrip: true,
          captureMode: 'AUTO_GPS',
          qualificationStatus: 'PRO',
          purpose: 'Chantier',
          projectTag: 'Grand Est',
          mapsDistanceKm: 42.0,
          detourMarginPercent: 5.0,
          finalDistanceKm: 44.1,
          odometerStartKm: 44775.9,
          odometerEndKm: 44820.0,
          reimbursementAmount: 30.74,
          currency: 'EUR',
          appliedRuleLabel: 'FR Voiture (7 CV et plus) • Tranche 1 (d × 0.697)',
          notes: 'Visite chantier & client Mulhouse',
          receiptPhotoRef: null,
        ),
        TripEntity(
          id: 'trp_2',
          date: DateTime.now().subtract(const Duration(hours: 3)),
          startTime: '11:10',
          endTime: '11:50',
          driverId: 'drv_main',
          vehicleId: 'veh_glc',
          countryCode: 'CH',
          originAddress: 'Uffheim, 68510, France',
          destinationAddress: 'Aeschenplatz, 4052 Basel, Suisse',
          waypoints: [],
          isRoundTrip: true,
          captureMode: 'IBEACON_BT',
          qualificationStatus: 'PENDING',
          purpose: 'Client',
          projectTag: 'Suisse',
          mapsDistanceKm: 46.0,
          detourMarginPercent: 5.0,
          finalDistanceKm: 48.3,
          odometerStartKm: 44727.6,
          odometerEndKm: 44775.9,
          reimbursementAmount: 34.78,
          currency: 'CHF',
          appliedRuleLabel: 'Suisse Barème TCS / Cantonal (0.72 CHF/km)',
          notes: 'Rendez-vous Bâle détecté via Bluetooth',
          receiptPhotoRef: null,
        ),
      ];
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveStateToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pp3_auto_tracking', _autoTrackingEnabled);
    await prefs.setBool('pp3_perm_motion', _permMotionActivity);
    await prefs.setBool('pp3_perm_loc', _permLocationAlways);
    await prefs.setBool('pp3_perm_notif', _permNotifications);
    await prefs.setBool('pp3_perm_batt', _permBatteryUnrestricted);
    await prefs.setBool('pp3_perm_bt', _permBluetoothBeacon);

    await prefs.setString('pp3_country', _defaultCountry);
    await prefs.setDouble('pp3_margin', _defaultDetourMargin);
    await prefs.setString('pp3_gmaps_key', _googleMapsApiKey);

    await prefs.setString(
      'pp3_drivers',
      jsonEncode(_drivers.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(
      'pp3_vehicles',
      jsonEncode(_vehicles.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(
      'pp3_locations',
      jsonEncode(_locations.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(
      'pp3_odometer_logs',
      jsonEncode(_odometerLogs.map((e) => e.toJson()).toList()),
    );
    await prefs.setString('pp3_tax_rules', jsonEncode(_taxRules.toJson()));
    await prefs.setString(
      'pp3_trips',
      jsonEncode(_trips.map((e) => e.toJson()).toList()),
    );
  }

  double _getCumulativeAnnualFrenchKm(String vehicleId, int year) {
    return _trips
        .where((t) =>
            t.vehicleId == vehicleId &&
            t.countryCode == 'FR' &&
            t.qualificationStatus == 'PRO' &&
            t.date.year == year)
        .fold(0.0, (s, t) => s + t.finalDistanceKm);
  }

  /// Démarre ou arrête un vrai suivi GPS en temps réel avec la puce du téléphone
  Future<void> _toggleLiveGpsRecording() async {
    if (!_isLiveGpsRecording) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: PiratePalette.goldPrimary,
            content: Text(
              'Acquisition du signal GPS réel en cours...',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        );
        final startCoord = await RealGpsAndRoutingService.getCurrentGpsAddress(
          googleApiKey: _googleMapsApiKey,
        );
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        setState(() {
          _isLiveGpsRecording = true;
          _liveStartPosition = pos;
          _liveLastPosition = pos;
          _liveStartAddress = startCoord.displayName;
          _liveAccumulatedKm = 0.0;
          _liveStartTime = DateTime.now();
          _permLocationAlways = true;
        });

        _gpsStreamSub?.cancel();
        _gpsStreamSub = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 15,
          ),
        ).listen((Position newPos) {
          if (_liveLastPosition != null) {
            final deltaMeters = Geolocator.distanceBetween(
              _liveLastPosition!.latitude,
              _liveLastPosition!.longitude,
              newPos.latitude,
              newPos.longitude,
            );
            if (deltaMeters > 5) {
              setState(() {
                _liveAccumulatedKm += (deltaMeters / 1000.0);
                _liveLastPosition = newPos;
              });
            }
          }
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: PiratePalette.bearRed,
              content: Text(e.toString().replaceAll('Exception: ', '')),
            ),
          );
        }
      }
    } else {
      // Arrêt du suivi GPS en direct et enregistrement du trajet
      await _gpsStreamSub?.cancel();
      _gpsStreamSub = null;

      String endAddress = _liveStartAddress;
      double computedKm = _liveAccumulatedKm;

      try {
        final endCoord = await RealGpsAndRoutingService.getCurrentGpsAddress(
          googleApiKey: _googleMapsApiKey,
        );
        endAddress = endCoord.displayName;
        if (computedKm < 0.2 && _liveStartPosition != null) {
          final directMeters = Geolocator.distanceBetween(
            _liveStartPosition!.latitude,
            _liveStartPosition!.longitude,
            endCoord.lat,
            endCoord.lon,
          );
          computedKm = (directMeters / 1000.0) * 1.25;
        }
      } catch (_) {}

      final finalKm = double.parse(math.max(0.5, computedKm).toStringAsFixed(1));
      final v = _vehicles.first;
      final d = _drivers.first;
      final priorFr = _getCumulativeAnnualFrenchKm(v.id, DateTime.now().year);
      final eval = TaxEngineService.evaluateTrip(
        countryCode: _defaultCountry,
        distanceKm: finalKm,
        priorAnnualFrenchKm: priorFr,
        vehicle: v,
        purpose: 'Client',
        qualificationStatus: 'PRO',
        rules: _taxRules,
      );

      final recordedTrip = TripEntity(
        id: 'trp_gps_${DateTime.now().millisecondsSinceEpoch}',
        date: DateTime.now(),
        startTime: _liveStartTime != null
            ? '${_liveStartTime!.hour.toString().padLeft(2, '0')}:${_liveStartTime!.minute.toString().padLeft(2, '0')}'
            : '08:30',
        endTime: TimeOfDay.now().format(context),
        driverId: d.id,
        vehicleId: v.id,
        countryCode: _defaultCountry,
        originAddress: _liveStartAddress,
        destinationAddress: endAddress,
        waypoints: [],
        isRoundTrip: false,
        captureMode: 'AUTO_GPS',
        qualificationStatus: 'PRO',
        purpose: 'Client',
        projectTag: 'Trace GPS Réelle',
        mapsDistanceKm: finalKm,
        detourMarginPercent: 0.0,
        finalDistanceKm: finalKm,
        odometerStartKm: v.currentOdometerKm,
        odometerEndKm: v.currentOdometerKm + finalKm,
        reimbursementAmount: eval.amount,
        currency: eval.currency,
        appliedRuleLabel: eval.ruleSummary,
        notes: 'Trajet capturé par GPS en temps réel',
      );

      setState(() {
        _isLiveGpsRecording = false;
      });
      _insertNewTrip(recordedTrip);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: PiratePalette.bullGreen,
            content: Text(
              'Trajet GPS enregistré : $finalKm km (${eval.amount.toStringAsFixed(2)} ${eval.currency})',
            ),
          ),
        );
      }
    }
  }

  void _qualifyTripStatus(TripEntity trip, String newStatus) {
    setState(() {
      trip.qualificationStatus = newStatus;
      final v = _vehicles.firstWhere(
        (veh) => veh.id == trip.vehicleId,
        orElse: () => _vehicles.first,
      );
      final priorKm = _getCumulativeAnnualFrenchKm(v.id, trip.date.year);
      final eval = TaxEngineService.evaluateTrip(
        countryCode: trip.countryCode,
        distanceKm: trip.finalDistanceKm,
        priorAnnualFrenchKm: priorKm,
        vehicle: v,
        purpose: trip.purpose,
        qualificationStatus: newStatus,
        rules: _taxRules,
      );
      trip.reimbursementAmount = eval.amount;
      trip.currency = eval.currency;
      trip.appliedRuleLabel = eval.ruleSummary;
    });
    _saveStateToDisk();
  }

  void _insertNewTrip(TripEntity trip) {
    setState(() {
      _trips.insert(0, trip);
      final idx = _vehicles.indexWhere((v) => v.id == trip.vehicleId);
      if (idx != -1) {
        if (trip.odometerEndKm > _vehicles[idx].currentOdometerKm) {
          _vehicles[idx].currentOdometerKm = trip.odometerEndKm;
        } else {
          _vehicles[idx].currentOdometerKm += trip.finalDistanceKm;
        }
      }
    });
    _saveStateToDisk();
  }

  void _openQuickAddTripModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PiratePalette.bgDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.94,
        maxChildSize: 0.98,
        builder: (_, scrollCtrl) => ManualTripCreatorSheet(
          scrollController: scrollCtrl,
          drivers: _drivers,
          vehicles: _vehicles,
          locations: _locations,
          taxRules: _taxRules,
          defaultCountry: _defaultCountry,
          defaultMargin: _defaultDetourMargin,
          googleMapsApiKey: _googleMapsApiKey,
          getPriorAnnualFrenchKm: _getCumulativeAnnualFrenchKm,
          onTripCreated: (newTrip) {
            Navigator.pop(ctx);
            _insertNewTrip(newTrip);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: PiratePalette.bullGreen,
                content: Text(
                  'Trajet enregistré : +${newTrip.finalDistanceKm.toStringAsFixed(1)} km (${newTrip.reimbursementAmount.toStringAsFixed(2)} ${newTrip.currency})',
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openPermissionsConfiguratorModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PiratePalette.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'AUTORISATIONS GPS & SUIVI AUTOMATIQUE (5/5)',
                        style: TextStyle(
                          color: PiratePalette.goldPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final pt = await RealGpsAndRoutingService
                            .getCurrentGpsAddress(
                          googleApiKey: _googleMapsApiKey,
                        );
                        setState(() => _permLocationAlways = true);
                        setSheetState(() {});
                        _saveStateToDisk();
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: PiratePalette.bullGreen,
                              content: Text(
                                'Position GPS réelle vérifiée : ${pt.displayName}',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: PiratePalette.bearRed,
                              content: Text(
                                e.toString().replaceAll('Exception: ', ''),
                              ),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.gps_fixed, size: 18),
                    label: const Text(
                      'TESTER & AUTORISER LA PUCE GPS MAINTENANT',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    activeColor: PiratePalette.bullGreen,
                    title: const Text(
                      '1. Activité physique (Motion API)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    value: _permMotionActivity,
                    onChanged: (v) {
                      setState(() => _permMotionActivity = v);
                      setSheetState(() {});
                      _saveStateToDisk();
                    },
                  ),
                  SwitchListTile(
                    activeColor: PiratePalette.bullGreen,
                    title: const Text(
                      '2. Géolocalisation GPS précise (Geolocator)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    value: _permLocationAlways,
                    onChanged: (v) async {
                      if (v) {
                        await Geolocator.requestPermission();
                      }
                      setState(() => _permLocationAlways = v);
                      setSheetState(() {});
                      _saveStateToDisk();
                    },
                  ),
                  SwitchListTile(
                    activeColor: PiratePalette.bullGreen,
                    title: const Text(
                      '3. Notifications de fin de trajet',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    value: _permNotifications,
                    onChanged: (v) {
                      setState(() => _permNotifications = v);
                      setSheetState(() {});
                      _saveStateToDisk();
                    },
                  ),
                  SwitchListTile(
                    activeColor: PiratePalette.bullGreen,
                    title: const Text(
                      '4. Exemption d\'optimisation batterie',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    value: _permBatteryUnrestricted,
                    onChanged: (v) {
                      setState(() => _permBatteryUnrestricted = v);
                      setSheetState(() {});
                      _saveStateToDisk();
                    },
                  ),
                  SwitchListTile(
                    activeColor: PiratePalette.bullGreen,
                    title: const Text(
                      '5. Filtre iBeacon / Bluetooth véhicule',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    value: _permBluetoothBeacon,
                    onChanged: (v) {
                      setState(() => _permBluetoothBeacon = v);
                      setSheetState(() {});
                      _saveStateToDisk();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: PiratePalette.bgDeep,
        body: Center(
          child: CircularProgressIndicator(color: PiratePalette.goldPrimary),
        ),
      );
    }

    final screens = [
      HomeInboxValidationScreen(
        autoTrackingEnabled: _autoTrackingEnabled,
        completedSteps: _completedOnboardingSteps,
        isLiveGpsRecording: _isLiveGpsRecording,
        liveStartAddress: _liveStartAddress,
        liveAccumulatedKm: _liveAccumulatedKm,
        trips: _trips,
        drivers: _drivers,
        vehicles: _vehicles,
        onToggleAutoTracking: (val) {
          setState(() => _autoTrackingEnabled = val);
          _saveStateToDisk();
        },
        onToggleLiveGpsRecording: _toggleLiveGpsRecording,
        onOpenOnboardingConfig: _openPermissionsConfiguratorModal,
        onQualifyTrip: _qualifyTripStatus,
      ),
      AllTripsLogbookScreen(
        trips: _trips,
        drivers: _drivers,
        vehicles: _vehicles,
        onQualifyTrip: _qualifyTripStatus,
        onDeleteTrip: (id) {
          setState(() => _trips.removeWhere((t) => t.id == id));
          _saveStateToDisk();
        },
        onCreateReturnTrip: (origTrip) {
          final v = _vehicles.firstWhere(
            (veh) => veh.id == origTrip.vehicleId,
            orElse: () => _vehicles.first,
          );
          final priorKm = _getCumulativeAnnualFrenchKm(v.id, DateTime.now().year);
          final eval = TaxEngineService.evaluateTrip(
            countryCode: origTrip.countryCode,
            distanceKm: origTrip.finalDistanceKm,
            priorAnnualFrenchKm: priorKm,
            vehicle: v,
            purpose: origTrip.purpose,
            qualificationStatus: origTrip.qualificationStatus,
            rules: _taxRules,
          );
          final retTrip = TripEntity(
            id: 'trp_ret_${DateTime.now().millisecondsSinceEpoch}',
            date: DateTime.now(),
            startTime: TimeOfDay.now().format(context),
            endTime: TimeOfDay.now().format(context),
            driverId: origTrip.driverId,
            vehicleId: origTrip.vehicleId,
            countryCode: origTrip.countryCode,
            originAddress: origTrip.destinationAddress,
            destinationAddress: origTrip.originAddress,
            waypoints: origTrip.waypoints.reversed.toList(),
            isRoundTrip: false,
            captureMode: 'MANUAL_MAPS',
            qualificationStatus: origTrip.qualificationStatus,
            purpose: origTrip.purpose,
            projectTag: origTrip.projectTag,
            mapsDistanceKm: origTrip.mapsDistanceKm,
            detourMarginPercent: origTrip.detourMarginPercent,
            finalDistanceKm: origTrip.finalDistanceKm,
            odometerStartKm: v.currentOdometerKm,
            odometerEndKm: v.currentOdometerKm + origTrip.finalDistanceKm,
            reimbursementAmount: eval.amount,
            currency: eval.currency,
            appliedRuleLabel: eval.ruleSummary,
            notes: 'Trajet retour identique (${origTrip.notes})',
          );
          _insertNewTrip(retTrip);
        },
      ),
      ReportsAndComplianceAuditScreen(
        trips: _trips,
        drivers: _drivers,
        vehicles: _vehicles,
        odometerLogs: _odometerLogs,
        onDataUpdated: () {
          setState(() {});
          _saveStateToDisk();
        },
      ),
      SettingsMasterScreen(
        drivers: _drivers,
        vehicles: _vehicles,
        locations: _locations,
        odometerLogs: _odometerLogs,
        taxRules: _taxRules,
        defaultCountry: _defaultCountry,
        defaultMargin: _defaultDetourMargin,
        googleMapsApiKey: _googleMapsApiKey,
        completedOnboardingSteps: _completedOnboardingSteps,
        onOpenPermissionsModal: _openPermissionsConfiguratorModal,
        onStateMutated: ({String? country, double? margin, String? gmapsKey}) {
          setState(() {
            if (country != null) _defaultCountry = country;
            if (margin != null) _defaultDetourMargin = margin;
            if (gmapsKey != null) _googleMapsApiKey = gmapsKey;
          });
          _saveStateToDisk();
        },
      ),
    ];

    final pendingCount = _trips.where((t) => t.isPending).length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: PiratePalette.bgSurface,
        title: Row(
          children: [
            const PiratePipsBadgeLogo(size: 34),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PIRATE PIPS™ KILOTRACKER PRO',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                      color: PiratePalette.textPure,
                    ),
                  ),
                  Text(
                    'Développé par Pirate Pips™ • GPS Réel, PDF & Excel Natifs',
                    style: TextStyle(
                      fontSize: 10,
                      color: PiratePalette.goldPrimary.withOpacity(0.95),
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
            color: PiratePalette.goldPrimary.withOpacity(0.35),
          ),
        ),
      ),
      body: screens[_activeTab],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 62,
        width: 62,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [PiratePalette.goldPrimary, PiratePalette.goldWarm],
          ),
          boxShadow: [
            BoxShadow(
              color: PiratePalette.goldPrimary.withOpacity(0.45),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _openQuickAddTripModal,
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.black, size: 32),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: PiratePalette.bgSurface,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        padding: EdgeInsets.zero,
        height: 66,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomNavButton(
              icon: Icons.inbox,
              label: 'Accueil',
              badgeCount: pendingCount,
              selected: _activeTab == 0,
              onTap: () => setState(() => _activeTab = 0),
            ),
            _BottomNavButton(
              icon: Icons.route,
              label: 'Tous les trajets',
              selected: _activeTab == 1,
              onTap: () => setState(() => _activeTab = 1),
            ),
            const SizedBox(width: 56),
            _BottomNavButton(
              icon: Icons.fact_check,
              label: 'Rapports',
              selected: _activeTab == 2,
              onTap: () => setState(() => _activeTab = 2),
            ),
            _BottomNavButton(
              icon: Icons.settings,
              label: 'Paramètres',
              selected: _activeTab == 3,
              onTap: () => setState(() => _activeTab = 3),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final int badgeCount;
  final VoidCallback onTap;

  const _BottomNavButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? PiratePalette.goldPrimary : PiratePalette.textSteel;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 22),
                if (badgeCount > 0)
                  Positioned(
                    right: -8,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: PiratePalette.goldPrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 10. ONGLET 1 : ACCUEIL (INBOX + CHRONOMÈTRE GPS EN DIRECT START/STOP)
// ============================================================================
class HomeInboxValidationScreen extends StatelessWidget {
  final bool autoTrackingEnabled;
  final int completedSteps;
  final bool isLiveGpsRecording;
  final String liveStartAddress;
  final double liveAccumulatedKm;
  final List<TripEntity> trips;
  final List<DriverProfile> drivers;
  final List<VehicleEntity> vehicles;
  final ValueChanged<bool> onToggleAutoTracking;
  final VoidCallback onToggleLiveGpsRecording;
  final VoidCallback onOpenOnboardingConfig;
  final void Function(TripEntity trip, String status) onQualifyTrip;

  const HomeInboxValidationScreen({
    super.key,
    required this.autoTrackingEnabled,
    required this.completedSteps,
    required this.isLiveGpsRecording,
    required this.liveStartAddress,
    required this.liveAccumulatedKm,
    required this.trips,
    required this.drivers,
    required this.vehicles,
    required this.onToggleAutoTracking,
    required this.onToggleLiveGpsRecording,
    required this.onOpenOnboardingConfig,
    required this.onQualifyTrip,
  });

  @override
  Widget build(BuildContext context) {
    final pendingTrips = trips.where((t) => t.isPending).toList();
    final validatedProTrips = trips.where((t) => t.isPro).toList();
    final totalProKm =
        validatedProTrips.fold<double>(0.0, (s, t) => s + t.finalDistanceKm);
    final totalEur = validatedProTrips
        .where((t) => t.currency == 'EUR')
        .fold<double>(0.0, (s, t) => s + t.reimbursementAmount);
    final totalChf = validatedProTrips
        .where((t) => t.currency == 'CHF')
        .fold<double>(0.0, (s, t) => s + t.reimbursementAmount);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Switch Enregistrement Auto + Bouton Configurer
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: PiratePalette.bgSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: autoTrackingEnabled
                  ? PiratePalette.bullGreen
                  : PiratePalette.bearRed,
              width: 1.3,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.sensors,
                    color: autoTrackingEnabled
                        ? PiratePalette.bullGreen
                        : PiratePalette.bearRed,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Enregistrement auto',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onOpenOnboardingConfig,
                    child: const Text(
                      'Configurer GPS',
                      style: TextStyle(
                        color: PiratePalette.goldPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Switch(
                    value: autoTrackingEnabled,
                    activeColor: PiratePalette.bullGreen,
                    onChanged: onToggleAutoTracking,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // BOUTON TRACKER GPS EN TEMPS RÉEL (START / STOP)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onToggleLiveGpsRecording,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLiveGpsRecording
                        ? PiratePalette.bearRed
                        : PiratePalette.bullGreen,
                    foregroundColor:
                        isLiveGpsRecording ? Colors.white : Colors.black,
                  ),
                  icon: Icon(
                    isLiveGpsRecording ? Icons.stop : Icons.play_arrow,
                  ),
                  label: Text(
                    isLiveGpsRecording
                        ? 'ARRÊTER LE TRAJET GPS EN COURS (${liveAccumulatedKm.toStringAsFixed(2)} KM)'
                        : 'DÉMARRER UN TRAJET GPS EN DIRECT (PUCE GPS)',
                  ),
                ),
              ),
              if (isLiveGpsRecording) ...[
                const SizedBox(height: 6),
                Text(
                  '📍 Départ GPS : $liveStartAddress',
                  style: const TextStyle(
                    fontSize: 11,
                    color: PiratePalette.goldPrimary,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. Onboarding progressif
        InkWell(
          onTap: onOpenOnboardingConfig,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: PiratePalette.bgSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: PiratePalette.goldPrimary.withOpacity(0.65),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Configurez le suivi : $completedSteps/5 étapes complétées',
                      style: const TextStyle(
                        color: PiratePalette.goldPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    const Icon(
                      Icons.gps_fixed,
                      color: PiratePalette.goldPrimary,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: completedSteps / 5.0,
                    minHeight: 8,
                    backgroundColor: PiratePalette.bgElevated,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      completedSteps == 5
                          ? PiratePalette.bullGreen
                          : PiratePalette.goldPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // 3. Synthèse financière
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1C170A), Color(0xFF131313)],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: PiratePalette.goldPrimary, width: 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CUMUL VALIDÉ À REMBOURSER',
                    style: TextStyle(
                      color: PiratePalette.textSteel,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${totalEur.toStringAsFixed(2)} €${totalChf > 0 ? " + ${totalChf.toStringAsFixed(2)} CHF" : ""}',
                    style: const TextStyle(
                      color: PiratePalette.bullGreen,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '${totalProKm.toStringAsFixed(1)} km professionnels certifiés',
                    style: const TextStyle(
                      color: PiratePalette.goldPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    tooltip: 'Exporter PDF immédiatement',
                    onPressed: () => NativeExportService.generateAndSharePdf(
                      context: context,
                      driver: drivers.first,
                      vehicle: vehicles.first,
                      trips: trips,
                    ),
                    icon: const Icon(
                      Icons.picture_as_pdf,
                      color: PiratePalette.goldPrimary,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Exporter Excel immédiatement',
                    onPressed: () => NativeExportService.generateAndShareExcel(
                      trips: trips,
                      drivers: drivers,
                      vehicles: vehicles,
                    ),
                    icon: const Icon(
                      Icons.table_chart,
                      color: PiratePalette.bullGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 4. Flux Inbox des trajets à qualifier
        Text(
          'TRAJETS À QUALIFIER (${pendingTrips.length})',
          style: const TextStyle(
            color: PiratePalette.textPure,
            fontWeight: FontWeight.w900,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),

        if (pendingTrips.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: PiratePalette.bgSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: PiratePalette.borderSubtle),
            ),
            child: const Text(
              'Tous vos trajets sont qualifiés. Utilisez le bouton + central pour calculer un itinéraire ou le bouton vert ci-dessus pour tracer un déplacement par GPS.',
              textAlign: TextAlign.center,
              style: TextStyle(color: PiratePalette.textSteel, fontSize: 12),
            ),
          ),

        ...pendingTrips.map((trip) {
          final vehicle = vehicles.firstWhere(
            (v) => v.id == trip.vehicleId,
            orElse: () => vehicles.first,
          );
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: PiratePalette.bgSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: PiratePalette.goldPrimary, width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${trip.captureMode} • ${trip.startTime}',
                      style: const TextStyle(
                        color: PiratePalette.goldPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '${trip.finalDistanceKm.toStringAsFixed(1)} km (${trip.reimbursementAmount.toStringAsFixed(2)} ${trip.currency})',
                      style: const TextStyle(
                        color: PiratePalette.goldPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'A: ${trip.originAddress}',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'B: ${trip.destinationAddress}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  '${vehicle.name} (${vehicle.licensePlate}) • ${trip.purpose}',
                  style: const TextStyle(
                    color: PiratePalette.textSteel,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => onQualifyTrip(trip, 'PRO'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PiratePalette.bullGreen,
                          foregroundColor: Colors.black,
                        ),
                        icon: const Icon(Icons.business_center, size: 16),
                        label: const Text('PROFESSIONNEL'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => onQualifyTrip(trip, 'PERSO'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: PiratePalette.bearRed,
                          side: const BorderSide(color: PiratePalette.bearRed),
                        ),
                        icon: const Icon(Icons.person, size: 16),
                        label: const Text('PERSONNEL'),
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
// 11. ONGLET 2 : TOUS LES TRAJETS (JOURNAL DE BORD)
// ============================================================================
class AllTripsLogbookScreen extends StatefulWidget {
  final List<TripEntity> trips;
  final List<DriverProfile> drivers;
  final List<VehicleEntity> vehicles;
  final void Function(TripEntity trip, String status) onQualifyTrip;
  final void Function(String tripId) onDeleteTrip;
  final void Function(TripEntity trip) onCreateReturnTrip;

  const AllTripsLogbookScreen({
    super.key,
    required this.trips,
    required this.drivers,
    required this.vehicles,
    required this.onQualifyTrip,
    required this.onDeleteTrip,
    required this.onCreateReturnTrip,
  });

  @override
  State<AllTripsLogbookScreen> createState() => _AllTripsLogbookScreenState();
}

class _AllTripsLogbookScreenState extends State<AllTripsLogbookScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.trips.where((t) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return t.originAddress.toLowerCase().contains(q) ||
          t.destinationAddress.toLowerCase().contains(q) ||
          t.purpose.toLowerCase().contains(q) ||
          t.notes.toLowerCase().contains(q);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'Rechercher par ville, client, motif...',
            prefixIcon: Icon(Icons.search, size: 18),
          ),
          onChanged: (v) => setState(() => _searchQuery = v),
        ),
        const SizedBox(height: 12),
        ...filtered.map((t) {
          final v = widget.vehicles.firstWhere(
            (veh) => veh.id == t.vehicleId,
            orElse: () => widget.vehicles.first,
          );
          final dt =
              '${t.date.day.toString().padLeft(2, '0')}/${t.date.month.toString().padLeft(2, '0')}/${t.date.year}';
          final badgeColor = t.isPro
              ? PiratePalette.bullGreen
              : t.isPending
                  ? PiratePalette.goldPrimary
                  : PiratePalette.bearRed;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: PiratePalette.bgSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: badgeColor.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$dt • ${t.qualificationStatus} • ${t.purpose} (${t.countryCode})',
                      style: TextStyle(
                        color: badgeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '${t.reimbursementAmount.toStringAsFixed(2)} ${t.currency}',
                      style: TextStyle(
                        color: badgeColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Départ : ${t.originAddress}',
                    style: const TextStyle(fontSize: 12)),
                if (t.waypoints.isNotEmpty)
                  Text(
                    'Étapes : ${t.waypoints.map((w) => w.label).join(" → ")}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: PiratePalette.goldWarm,
                    ),
                  ),
                Text('Arrivée : ${t.destinationAddress}',
                    style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  '${v.name} (${v.licensePlate}) • ${t.finalDistanceKm.toStringAsFixed(1)} km (Odo: ${t.odometerEndKm.toInt()} km)',
                  style: const TextStyle(
                    fontSize: 11,
                    color: PiratePalette.textSteel,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => widget.onCreateReturnTrip(t),
                      icon: const Icon(
                        Icons.repeat,
                        size: 15,
                        color: PiratePalette.goldPrimary,
                      ),
                      label: const Text(
                        'Trajet retour identique',
                        style: TextStyle(
                          fontSize: 11,
                          color: PiratePalette.goldPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => widget.onDeleteTrip(t.id),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: PiratePalette.bearRed,
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
// 12. ENTRÉE 3 (FAB `+`) : CALCULATEUR D'ITINÉRAIRE ROUTIER + BOUTON GPS RÉEL
// ============================================================================
class ManualTripCreatorSheet extends StatefulWidget {
  final ScrollController scrollController;
  final List<DriverProfile> drivers;
  final List<VehicleEntity> vehicles;
  final List<SavedLocationEntity> locations;
  final TaxRulesRepository taxRules;
  final String defaultCountry;
  final double defaultMargin;
  final String googleMapsApiKey;
  final double Function(String vehicleId, int year) getPriorAnnualFrenchKm;
  final void Function(TripEntity trip) onTripCreated;

  const ManualTripCreatorSheet({
    super.key,
    required this.scrollController,
    required this.drivers,
    required this.vehicles,
    required this.locations,
    required this.taxRules,
    required this.defaultCountry,
    required this.defaultMargin,
    required this.googleMapsApiKey,
    required this.getPriorAnnualFrenchKm,
    required this.onTripCreated,
  });

  @override
  State<ManualTripCreatorSheet> createState() => _ManualTripCreatorSheetState();
}

class _ManualTripCreatorSheetState extends State<ManualTripCreatorSheet> {
  late String _driverId;
  late String _vehicleId;
  late String _countryCode;
  String _qualification = 'PRO';
  String _purpose = 'Client';
  bool _isRoundTrip = false;
  late double _detourMargin;
  bool _calculating = false;
  bool _fetchingGpsOrigin = false;
  bool _fetchingGpsDest = false;
  String _routeProviderNote =
      'Prêt : cliquez sur Calculer ou choisissez une adresse';

  final TextEditingController _originCtrl = TextEditingController();
  final TextEditingController _destCtrl = TextEditingController();
  final TextEditingController _mapsKmCtrl =
      TextEditingController(text: '21.5');
  final TextEditingController _notesCtrl = TextEditingController();

  final List<WaypointEntity> _waypoints = [];
  List<String> _origPredict = [];
  List<String> _destPredict = [];

  @override
  void initState() {
    super.initState();
    _driverId = widget.drivers.first.id;
    _vehicleId = widget.vehicles.first.id;
    _countryCode = widget.defaultCountry;
    _detourMargin = widget.defaultMargin.clamp(0.0, 15.0);

    if (widget.locations.length >= 2) {
      _originCtrl.text = widget.locations[0].fullAddress;
      _destCtrl.text = widget.locations[2].fullAddress;
      // Lance automatiquement le calcul routier dès l'ouverture
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _computeDrivingDistance();
      });
    }
  }

  @override
  void dispose() {
    _originCtrl.dispose();
    _destCtrl.dispose();
    _mapsKmCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  VehicleEntity get _selectedVehicle => widget.vehicles.firstWhere(
        (v) => v.id == _vehicleId,
        orElse: () => widget.vehicles.first,
      );

  double get _baseDistanceKm {
    final v = double.tryParse(_mapsKmCtrl.text.replaceAll(',', '.')) ?? 0.0;
    return _isRoundTrip ? v * 2.0 : v;
  }

  double get _finalAdjustedKm {
    final d = _baseDistanceKm * (1.0 + (_detourMargin / 100.0));
    return double.parse(d.toStringAsFixed(1));
  }

  Future<void> _fillWithCurrentGps({required bool isOrigin}) async {
    setState(() {
      if (isOrigin) {
        _fetchingGpsOrigin = true;
      } else {
        _fetchingGpsDest = true;
      }
    });
    try {
      final pt = await RealGpsAndRoutingService.getCurrentGpsAddress(
        googleApiKey: widget.googleMapsApiKey,
      );
      if (!mounted) return;
      setState(() {
        if (isOrigin) {
          _originCtrl.text = pt.displayName;
          _origPredict.clear();
        } else {
          _destCtrl.text = pt.displayName;
          _destPredict.clear();
        }
      });
      await _computeDrivingDistance();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: PiratePalette.bearRed,
          content: Text(e.toString().replaceAll('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _fetchingGpsOrigin = false;
          _fetchingGpsDest = false;
        });
      }
    }
  }

  Future<void> _computeDrivingDistance() async {
    if (_originCtrl.text.trim().isEmpty || _destCtrl.text.trim().isEmpty) {
      return;
    }
    setState(() {
      _calculating = true;
      _routeProviderNote = 'Calcul de l\'itinéraire routier en cours...';
    });

    try {
      final res = await RealGpsAndRoutingService.computeDrivingRoute(
        origin: _originCtrl.text,
        destination: _destCtrl.text,
        waypoints: _waypoints,
        googleApiKey: widget.googleMapsApiKey,
      );
      if (!mounted) return;
      setState(() {
        _calculating = false;
        _mapsKmCtrl.text = (res['km'] as double).toStringAsFixed(1);
        _routeProviderNote =
            '✅ ${res['provider']} : ${res['km']} km (${res['duration']})';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _calculating = false;
        _routeProviderNote = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _promptWaypointDialog() {
    final lblCtrl = TextEditingController(text: 'Magasin pro / Chantier');
    final adrCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PiratePalette.bgSurface,
        title: const Text('Ajouter une étape intermédiaire'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: lblCtrl,
              decoration: const InputDecoration(
                labelText: 'Libellé (Magasin pro, Client, Chantier)',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: adrCtrl,
              decoration: const InputDecoration(
                labelText: 'Ville ou adresse de l\'étape',
              ),
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
              if (adrCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _waypoints.add(
                    WaypointEntity(
                      label: lblCtrl.text.trim(),
                      address: adrCtrl.text.trim(),
                    ),
                  );
                });
                Navigator.pop(ctx);
                _computeDrivingDistance();
              }
            },
            child: const Text('Ajouter & Recalculer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final veh = _selectedVehicle;
    final priorFrKm =
        widget.getPriorAnnualFrenchKm(veh.id, DateTime.now().year);
    final eval = TaxEngineService.evaluateTrip(
      countryCode: _countryCode,
      distanceKm: _finalAdjustedKm,
      priorAnnualFrenchKm: priorFrKm,
      vehicle: veh,
      purpose: _purpose,
      qualificationStatus: _qualification,
      rules: widget.taxRules,
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        controller: widget.scrollController,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  PiratePipsBadgeLogo(size: 28),
                  SizedBox(width: 8),
                  Text(
                    'CALCULATEUR D\'ITINÉRAIRE & POSITION GPS',
                    style: TextStyle(
                      color: PiratePalette.goldPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(color: PiratePalette.borderSubtle),

          // Sélecteurs Conducteur, Pays & Véhicule
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _driverId,
                  decoration: const InputDecoration(labelText: 'Conducteur'),
                  items: widget.drivers
                      .map(
                        (d) => DropdownMenuItem(
                          value: d.id,
                          child: Text(
                            d.fullName,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _driverId = v!),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _countryCode,
                  decoration: const InputDecoration(labelText: 'Barème Pays'),
                  items: const [
                    DropdownMenuItem(value: 'FR', child: Text('France (FR)')),
                    DropdownMenuItem(
                        value: 'LU', child: Text('Luxembourg (LU)')),
                    DropdownMenuItem(value: 'BE', child: Text('Belgique (BE)')),
                    DropdownMenuItem(
                        value: 'DE', child: Text('Allemagne (DE)')),
                    DropdownMenuItem(value: 'CH', child: Text('Suisse (CH)')),
                  ],
                  onChanged: (v) => setState(() => _countryCode = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _vehicleId,
            decoration: const InputDecoration(labelText: 'Véhicule utilisé'),
            items: widget.vehicles
                .map(
                  (v) => DropdownMenuItem(
                    value: v.id,
                    child: Text(
                      '${v.name} (${v.licensePlate}) — ${v.fiscalCategory}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _vehicleId = v!),
          ),
          const SizedBox(height: 12),

          // Favoris rapides (clic = remplit et recalcule immédiatement)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.locations.map((loc) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    avatar: const Icon(
                      Icons.place,
                      size: 14,
                      color: PiratePalette.goldPrimary,
                    ),
                    label: Text(
                      loc.label,
                      style: const TextStyle(fontSize: 11),
                    ),
                    onPressed: () {
                      setState(() => _destCtrl.text = loc.fullAddress);
                      _computeDrivingDistance();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),

          // POINT DE DÉPART + BOUTON MA POSITION GPS RÉELLE
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _originCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Point A — Adresse de départ',
                    prefixIcon: Icon(
                      Icons.my_location,
                      color: PiratePalette.bullGreen,
                      size: 18,
                    ),
                  ),
                  onChanged: (v) async {
                    final list =
                        await RealGpsAndRoutingService.autocompleteAddress(
                      query: v,
                      googleApiKey: widget.googleMapsApiKey,
                      savedLocations: widget.locations,
                    );
                    if (mounted) setState(() => _origPredict = list);
                  },
                  onSubmitted: (_) => _computeDrivingDistance(),
                ),
              ),
              const SizedBox(width: 6),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: PiratePalette.bullGreen,
                  foregroundColor: Colors.black,
                ),
                tooltip: 'Utiliser ma position GPS actuelle',
                onPressed: _fetchingGpsOrigin
                    ? null
                    : () => _fillWithCurrentGps(isOrigin: true),
                icon: _fetchingGpsOrigin
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Icon(Icons.gps_fixed, size: 20),
              ),
            ],
          ),
          if (_origPredict.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: PiratePalette.bgElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: PiratePalette.goldPrimary),
              ),
              child: Column(
                children: _origPredict.map((s) {
                  return ListTile(
                    dense: true,
                    title: Text(s, style: const TextStyle(fontSize: 11)),
                    onTap: () {
                      setState(() {
                        _originCtrl.text =
                            RealGpsAndRoutingService.cleanAddress(s);
                        _origPredict.clear();
                      });
                      _computeDrivingDistance();
                    },
                  );
                }).toList(),
              ),
            ),

          // Étapes intermédiaires
          if (_waypoints.isNotEmpty) ...[
            const SizedBox(height: 8),
            ..._waypoints.asMap().entries.map((entry) {
              return ListTile(
                dense: true,
                tileColor: PiratePalette.bgElevated,
                leading: const Icon(
                  Icons.route,
                  color: PiratePalette.goldPrimary,
                  size: 16,
                ),
                title: Text(
                  'Étape ${entry.key + 1} (${entry.value.label}) : ${entry.value.address}',
                  style: const TextStyle(fontSize: 11),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 16,
                    color: PiratePalette.bearRed,
                  ),
                  onPressed: () {
                    setState(() => _waypoints.removeAt(entry.key));
                    _computeDrivingDistance();
                  },
                ),
              );
            }),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _promptWaypointDialog,
              icon: const Icon(
                Icons.add,
                size: 16,
                color: PiratePalette.goldPrimary,
              ),
              label: const Text(
                'Ajouter un arrêt intermédiaire (Magasin pro, Chantier)',
                style: TextStyle(
                  fontSize: 11,
                  color: PiratePalette.goldPrimary,
                ),
              ),
            ),
          ),

          // DESTINATION FINALE + BOUTON MA POSITION GPS RÉELLE
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _destCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Point B — Destination finale',
                    prefixIcon: Icon(
                      Icons.place,
                      color: PiratePalette.bearRed,
                      size: 18,
                    ),
                  ),
                  onChanged: (v) async {
                    final list =
                        await RealGpsAndRoutingService.autocompleteAddress(
                      query: v,
                      googleApiKey: widget.googleMapsApiKey,
                      savedLocations: widget.locations,
                    );
                    if (mounted) setState(() => _destPredict = list);
                  },
                  onSubmitted: (_) => _computeDrivingDistance(),
                ),
              ),
              const SizedBox(width: 6),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: PiratePalette.goldPrimary,
                  foregroundColor: Colors.black,
                ),
                tooltip: 'Mettre ma position GPS actuelle en arrivée',
                onPressed: _fetchingGpsDest
                    ? null
                    : () => _fillWithCurrentGps(isOrigin: false),
                icon: _fetchingGpsDest
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Icon(Icons.gps_fixed, size: 20),
              ),
            ],
          ),
          if (_destPredict.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: PiratePalette.bgElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: PiratePalette.goldPrimary),
              ),
              child: Column(
                children: _destPredict.map((s) {
                  return ListTile(
                    dense: true,
                    title: Text(s, style: const TextStyle(fontSize: 11)),
                    onTap: () {
                      setState(() {
                        _destCtrl.text =
                            RealGpsAndRoutingService.cleanAddress(s);
                        _destPredict.clear();
                      });
                      _computeDrivingDistance();
                    },
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 10),

          // Bouton de calcul d'itinéraire routier
          ElevatedButton.icon(
            onPressed: _calculating ? null : _computeDrivingDistance,
            icon: _calculating
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
              _calculating
                  ? 'CALCUL DE L\'ITINÉRAIRE EN COURS...'
                  : 'CALCULER LES KILOMÈTRES DE L\'ITINÉRAIRE',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _routeProviderNote,
            style: const TextStyle(
              color: PiratePalette.bullGreen,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: PiratePalette.goldPrimary,
            title: const Text(
              'Trajet retour identique (Aller-Retour ×2)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            value: _isRoundTrip,
            onChanged: (v) => setState(() => _isRoundTrip = v),
          ),

          // Slider Marge 0% à +15%
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PiratePalette.bgSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PiratePalette.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Marge de compensation / Détours (0% à +15%)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PiratePalette.goldPrimary,
                      ),
                    ),
                    Text(
                      '+${_detourMargin.toInt()} %',
                      style: const TextStyle(
                        color: PiratePalette.goldPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _detourMargin,
                  min: 0.0,
                  max: 15.0,
                  divisions: 15,
                  activeColor: PiratePalette.goldPrimary,
                  onChanged: (v) => setState(() => _detourMargin = v),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _mapsKmCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Km Routiers (Aller)',
                          suffixText: 'km',
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _purpose,
                        decoration: const InputDecoration(labelText: 'Motif'),
                        items: const [
                          DropdownMenuItem(
                              value: 'Client', child: Text('Client')),
                          DropdownMenuItem(
                              value: 'Chantier', child: Text('Chantier')),
                          DropdownMenuItem(
                              value: 'Réunion', child: Text('Réunion')),
                          DropdownMenuItem(
                              value: 'Administratif',
                              child: Text('Administratif')),
                          DropdownMenuItem(
                              value: 'Domicile-Travail',
                              child: Text('Domicile-Travail')),
                        ],
                        onChanged: (v) => setState(() => _purpose = v!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Validation finale
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: PiratePalette.bgSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: PiratePalette.goldPrimary, width: 1.4),
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
                          'TOTAL RETENU : ${_finalAdjustedKm.toStringAsFixed(1)} KM',
                          style: const TextStyle(
                            color: PiratePalette.goldPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          eval.ruleSummary,
                          style: const TextStyle(
                            color: PiratePalette.textSteel,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${eval.amount.toStringAsFixed(2)} ${eval.currency}',
                      style: const TextStyle(
                        color: PiratePalette.bullGreen,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final newTrip = TripEntity(
                        id: 'trp_${DateTime.now().millisecondsSinceEpoch}',
                        date: DateTime.now(),
                        startTime: TimeOfDay.now().format(context),
                        endTime: TimeOfDay.now().format(context),
                        driverId: _driverId,
                        vehicleId: _vehicleId,
                        countryCode: _countryCode,
                        originAddress: _originCtrl.text.trim(),
                        destinationAddress: _destCtrl.text.trim(),
                        waypoints: List<WaypointEntity>.from(_waypoints),
                        isRoundTrip: _isRoundTrip,
                        captureMode: 'MANUAL_MAPS',
                        qualificationStatus: _qualification,
                        purpose: _purpose,
                        projectTag: 'Pro',
                        mapsDistanceKm: _baseDistanceKm,
                        detourMarginPercent: _detourMargin,
                        finalDistanceKm: _finalAdjustedKm,
                        odometerStartKm: veh.currentOdometerKm,
                        odometerEndKm:
                            veh.currentOdometerKm + _finalAdjustedKm,
                        reimbursementAmount: eval.amount,
                        currency: eval.currency,
                        appliedRuleLabel: eval.ruleSummary,
                        notes: _notesCtrl.text.trim(),
                      );
                      widget.onTripCreated(newTrip);
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('ENREGISTRER LE TRAJET'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 13. ONGLET 4 : RAPPORTS (VRAIS EXPORTS PDF & EXCEL NATIFS + AUDIT FISCAL)
// ============================================================================
class ReportsAndComplianceAuditScreen extends StatefulWidget {
  final List<TripEntity> trips;
  final List<DriverProfile> drivers;
  final List<VehicleEntity> vehicles;
  final List<OdometerLogEntity> odometerLogs;
  final VoidCallback onDataUpdated;

  const ReportsAndComplianceAuditScreen({
    super.key,
    required this.trips,
    required this.drivers,
    required this.vehicles,
    required this.odometerLogs,
    required this.onDataUpdated,
  });

  @override
  State<ReportsAndComplianceAuditScreen> createState() =>
      _ReportsAndComplianceAuditScreenState();
}

class _ReportsAndComplianceAuditScreenState
    extends State<ReportsAndComplianceAuditScreen> {
  int _subTab = 0;
  late String _auditedDriverId;
  late String _auditedVehicleId;
  bool _exportingPdf = false;
  bool _exportingExcel = false;

  @override
  void initState() {
    super.initState();
    _auditedDriverId = widget.drivers.first.id;
    _auditedVehicleId = widget.vehicles.first.id;
  }

  DriverProfile get _activeDriver => widget.drivers.firstWhere(
        (d) => d.id == _auditedDriverId,
        orElse: () => widget.drivers.first,
      );

  VehicleEntity get _activeVehicle => widget.vehicles.firstWhere(
        (v) => v.id == _auditedVehicleId,
        orElse: () => widget.vehicles.first,
      );

  void _promptQuickFixDialog({
    required String title,
    required String initialValue,
    required void Function(String newValue) onSave,
  }) {
    final ctrl = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PiratePalette.bgSurface,
        title: Text(title, style: const TextStyle(fontSize: 15)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Valeur officielle',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(ctrl.text.trim());
              widget.onDataUpdated();
              Navigator.pop(ctx);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final driver = _activeDriver;
    final vehicle = _activeVehicle;

    final hasDriverName = driver.fullName.trim().isNotEmpty;
    final hasPersonalAddress = driver.personalAddress.trim().isNotEmpty;
    final hasLicensePlate = vehicle.licensePlate.trim().isNotEmpty;
    final hasCompanyName = driver.companyName.trim().isNotEmpty;
    final hasCompanyAddress = driver.companyAddress.trim().isNotEmpty;

    final isAuditCompliant = hasDriverName &&
        hasPersonalAddress &&
        hasLicensePlate &&
        hasCompanyName &&
        hasCompanyAddress;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(
              value: 0,
              icon: Icon(Icons.fact_check, size: 16),
              label: Text('Mes rapports'),
            ),
            ButtonSegment(
              value: 1,
              icon: Icon(Icons.groups, size: 16),
              label: Text('Rapports de l\'équipe'),
            ),
          ],
          selected: {_subTab},
          onSelectionChanged: (s) => setState(() => _subTab = s.first),
        ),
        const SizedBox(height: 14),

        if (_subTab == 0) ...[
          // BOUTONS D'ACTION DIRECTS : TÉLÉCHARGER / IMPRIMER PDF & PARTAGER EXCEL
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1D180B), Color(0xFF141414)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: PiratePalette.goldPrimary, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EXPORTS COMPTABLES OFFICIELS (FICHIERS PDF & EXCEL NATIFS)',
                  style: TextStyle(
                    color: PiratePalette.goldPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _exportingPdf
                            ? null
                            : () async {
                                setState(() => _exportingPdf = true);
                                try {
                                  await NativeExportService.generateAndSharePdf(
                                    context: context,
                                    driver: driver,
                                    vehicle: vehicle,
                                    trips: widget.trips,
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => _exportingPdf = false);
                                  }
                                }
                              },
                        icon: const Icon(Icons.picture_as_pdf, size: 18),
                        label: Text(
                          _exportingPdf
                              ? 'CRÉATION PDF...'
                              : 'OUVRIR / ENREGISTRER PDF',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: PiratePalette.bgElevated,
                        foregroundColor: PiratePalette.goldPrimary,
                      ),
                      tooltip: 'Envoyer le fichier PDF par Mail / WhatsApp',
                      onPressed: () =>
                          NativeExportService.sharePdfFileDirectly(
                        driver: driver,
                        vehicle: vehicle,
                        trips: widget.trips,
                      ),
                      icon: const Icon(Icons.share, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _exportingExcel
                        ? null
                        : () async {
                            setState(() => _exportingExcel = true);
                            try {
                              await NativeExportService.generateAndShareExcel(
                                trips: widget.trips,
                                drivers: widget.drivers,
                                vehicles: widget.vehicles,
                              );
                            } finally {
                              if (mounted) {
                                setState(() => _exportingExcel = false);
                              }
                            }
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PiratePalette.bullGreen,
                      side: const BorderSide(
                        color: PiratePalette.bullGreen,
                        width: 1.4,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    icon: const Icon(Icons.table_chart, size: 18),
                    label: Text(
                      _exportingExcel
                          ? 'GÉNÉRATION DU FICHIER EXCEL...'
                          : 'TÉLÉCHARGER / PARTAGER FICHIER EXCEL (.CSV)',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // SÉLECTEUR CONDUCTEUR & VÉHICULE POUR L'AUDIT
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _auditedDriverId,
                  decoration:
                      const InputDecoration(labelText: 'Conducteur audité'),
                  items: widget.drivers
                      .map(
                        (d) => DropdownMenuItem(
                          value: d.id,
                          child: Text(
                            d.fullName,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _auditedDriverId = v!),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _auditedVehicleId,
                  decoration:
                      const InputDecoration(labelText: 'Véhicule audité'),
                  items: widget.vehicles
                      .map(
                        (v) => DropdownMenuItem(
                          value: v.id,
                          child: Text(
                            v.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _auditedVehicleId = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // CARTE D'AUDIT DE CONFORMITÉ FISCALE
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: PiratePalette.bgSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isAuditCompliant
                    ? PiratePalette.bullGreen
                    : PiratePalette.bearRed,
                width: 1.4,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isAuditCompliant
                          ? Icons.check_circle
                          : Icons.warning_amber_rounded,
                      color: isAuditCompliant
                          ? PiratePalette.bullGreen
                          : PiratePalette.bearRed,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isAuditCompliant
                            ? 'AUDIT DE CONFORMITÉ FISCALE : 100 % CONFORME'
                            : 'CHAMPS D\'AUDIT À COMPLÉTER (CLIQUEZ POUR MODIFIER)',
                        style: TextStyle(
                          color: isAuditCompliant
                              ? PiratePalette.bullGreen
                              : PiratePalette.bearRed,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _AuditChecklistItem(
                  label: 'Conducteur assigné',
                  value: driver.fullName,
                  isValid: hasDriverName,
                  onTapFix: () => _promptQuickFixDialog(
                    title: 'Nom du conducteur',
                    initialValue: driver.lastName,
                    onSave: (val) => driver.lastName = val,
                  ),
                ),
                _AuditChecklistItem(
                  label: 'Adresse personnelle',
                  value: driver.personalAddress,
                  isValid: hasPersonalAddress,
                  onTapFix: () => _promptQuickFixDialog(
                    title: 'Adresse personnelle',
                    initialValue: driver.personalAddress,
                    onSave: (val) => driver.personalAddress = val,
                  ),
                ),
                _AuditChecklistItem(
                  label: 'Plaque d\'immatriculation (${vehicle.name})',
                  value: vehicle.licensePlate,
                  isValid: hasLicensePlate,
                  blockingWarningText: '⚠️ Plaque d\'immatriculation manquante',
                  onTapFix: () => _promptQuickFixDialog(
                    title: 'Plaque d\'immatriculation',
                    initialValue: vehicle.licensePlate,
                    onSave: (val) => vehicle.licensePlate = val,
                  ),
                ),
                _AuditChecklistItem(
                  label: 'Entreprise / Lieu de travail rattaché',
                  value: driver.companyName,
                  isValid: hasCompanyName,
                  onTapFix: () => _promptQuickFixDialog(
                    title: 'Entreprise rattachée',
                    initialValue: driver.companyName,
                    onSave: (val) => driver.companyName = val,
                  ),
                ),
                _AuditChecklistItem(
                  label: 'Adresse de l\'entreprise',
                  value: driver.companyAddress,
                  isValid: hasCompanyAddress,
                  blockingWarningText: '⚠️ Adresse de l\'entreprise manquante',
                  onTapFix: () => _promptQuickFixDialog(
                    title: 'Adresse de l\'entreprise',
                    initialValue: driver.companyAddress,
                    onSave: (val) => driver.companyAddress = val,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Rapports de l'équipe
          ...widget.drivers.map((d) {
            final dTrips = widget.trips
                .where((t) => t.driverId == d.id && t.isPro)
                .toList();
            final km =
                dTrips.fold<double>(0.0, (s, t) => s + t.finalDistanceKm);
            final eur = dTrips
                .where((t) => t.currency == 'EUR')
                .fold<double>(0.0, (s, t) => s + t.reimbursementAmount);
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Icon(
                  Icons.person,
                  color: PiratePalette.goldPrimary,
                ),
                title: Text(
                  '${d.fullName} (${d.role})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${dTrips.length} trajets pro • ${km.toStringAsFixed(1)} km • ${d.companyName}',
                  style: const TextStyle(fontSize: 11),
                ),
                trailing: Text(
                  '${eur.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    color: PiratePalette.bullGreen,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}

class _AuditChecklistItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isValid;
  final String? blockingWarningText;
  final VoidCallback onTapFix;

  const _AuditChecklistItem({
    required this.label,
    required this.value,
    required this.isValid,
    required this.onTapFix,
    this.blockingWarningText,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTapFix,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: PiratePalette.bgElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isValid ? PiratePalette.bullGreen : PiratePalette.bearRed,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isValid ? Icons.check_circle : Icons.error_outline,
              color: isValid ? PiratePalette.bullGreen : PiratePalette.bearRed,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: PiratePalette.textSteel,
                    ),
                  ),
                  Text(
                    isValid
                        ? value
                        : (blockingWarningText ?? '⚠️ Champ manquant'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isValid
                          ? PiratePalette.textPure
                          : PiratePalette.bearRed,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit, size: 16, color: PiratePalette.goldPrimary),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 14. ONGLET 5 : PARAMÈTRES (VÉHICULES, RELEVÉS ODOMÈTRE, BARÈMES & À PROPOS)
// ============================================================================
class SettingsMasterScreen extends StatefulWidget {
  final List<DriverProfile> drivers;
  final List<VehicleEntity> vehicles;
  final List<SavedLocationEntity> locations;
  final List<OdometerLogEntity> odometerLogs;
  final TaxRulesRepository taxRules;
  final String defaultCountry;
  final double defaultMargin;
  final String googleMapsApiKey;
  final int completedOnboardingSteps;
  final VoidCallback onOpenPermissionsModal;
  final void Function({String? country, double? margin, String? gmapsKey})
      onStateMutated;

  const SettingsMasterScreen({
    super.key,
    required this.drivers,
    required this.vehicles,
    required this.locations,
    required this.odometerLogs,
    required this.taxRules,
    required this.defaultCountry,
    required this.defaultMargin,
    required this.googleMapsApiKey,
    required this.completedOnboardingSteps,
    required this.onOpenPermissionsModal,
    required this.onStateMutated,
  });

  @override
  State<SettingsMasterScreen> createState() => _SettingsMasterScreenState();
}

class _SettingsMasterScreenState extends State<SettingsMasterScreen> {
  void _showAddVehicleFromCatalogModal() {
    final nameCtrl = TextEditingController();
    final plateCtrl = TextEditingController();
    final odoCtrl = TextEditingController(text: '15000');
    FiscalVehicleCategorySpec selectedSpec = kOfficialVehicleCatalog[4];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PiratePalette.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          builder: (_, sc) => Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              controller: sc,
              children: [
                const Text(
                  'AJOUTER UN VÉHICULE (CATALOGUE FISCAL 14 CATÉGORIES)',
                  style: TextStyle(
                    color: PiratePalette.goldPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nom / Modèle (ex: Audi Q8 50 TDI)',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: plateCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Immatriculation (ex: PP-500-LU)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: odoCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Odomètre (km)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...kOfficialVehicleCatalog.map((spec) {
                  return RadioListTile<String>(
                    dense: true,
                    activeColor: PiratePalette.goldPrimary,
                    value: spec.label,
                    groupValue: selectedSpec.label,
                    title: Text(
                      spec.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    onChanged: (_) => setModalState(() => selectedSpec = spec),
                  );
                }),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isNotEmpty) {
                      widget.vehicles.add(
                        VehicleEntity(
                          id: 'veh_${DateTime.now().millisecondsSinceEpoch}',
                          name: nameCtrl.text.trim(),
                          licensePlate: plateCtrl.text.trim().isEmpty
                              ? 'PP-001-LU'
                              : plateCtrl.text.trim(),
                          fiscalCategory: selectedSpec.label,
                          vehicleGroup: selectedSpec.group,
                          fiscalHp: selectedSpec.fiscalHp,
                          isElectric: selectedSpec.isElectric,
                          currentOdometerKm:
                              double.tryParse(odoCtrl.text) ?? 0.0,
                        ),
                      );
                      widget.onStateMutated();
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('ENREGISTRER LE VÉHICULE'),
                ),
              ],
            ),
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
        Card(
          child: ListTile(
            leading: const Icon(Icons.gps_fixed, color: PiratePalette.bullGreen),
            title: const Text(
              'Autorisations GPS & Test de Géolocalisation Réelle',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            subtitle: const Text(
              'Vérifier la puce GPS et activer les 5 étapes de suivi',
              style: TextStyle(fontSize: 11),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: widget.onOpenPermissionsModal,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: PiratePalette.bgSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: PiratePalette.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'GARAGE & VÉHICULES ENREGISTRÉS',
                    style: TextStyle(
                      color: PiratePalette.goldPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddVehicleFromCatalogModal,
                    icon: const Icon(Icons.add, size: 15),
                    label: const Text(
                      'Ajouter',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...widget.vehicles.map((v) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.directions_car,
                    color: PiratePalette.goldPrimary,
                  ),
                  title: Text(
                    '${v.name} (${v.licensePlate})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  subtitle: Text(
                    '${v.fiscalCategory} • Odomètre : ${v.currentOdometerKm.toInt()} km',
                    style: const TextStyle(fontSize: 11),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: PiratePalette.bgSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: PiratePalette.goldPrimary, width: 1.3),
          ),
          child: const Column(
            children: [
              PiratePipsBadgeLogo(size: 64),
              SizedBox(height: 10),
              Text(
                'Développé par Pirate Pips™',
                style: TextStyle(
                  color: PiratePalette.textPure,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Protection légale, propriété exclusive de Pirate Pips™.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: PiratePalette.goldPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}

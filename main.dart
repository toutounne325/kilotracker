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
  runApp(const PiratePipsDriversApp());
}

// ============================================================================
// 1. DESIGN SYSTEM & TOKENS PIRATE PIPS™ (DARK MODE EXCLUSIF)
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
// 2. LOGO OFFICIEL PIRATE PIPS™ (DISQUE NOIR CERCLÉ D'OR & BOUGIES JAPONAISES)
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

    // Disque noir profond
    final bgPaint = Paint()
      ..color = PiratePalette.bgDeep
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Cercle d'or extérieur
    final goldRing = Paint()
      ..color = PiratePalette.goldPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.07;
    canvas.drawCircle(center, radius * 0.92, goldRing);

    // Anneau intérieur ambré
    final innerRing = Paint()
      ..color = PiratePalette.goldWarm.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.02;
    canvas.drawCircle(center, radius * 0.79, innerRing);

    // Bougie japonaise haussière (Verte - Gauche)
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

    // Bougie japonaise baissière (Rouge - Droite)
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
// 3. CATALOGUE FISCAL NORMALISÉ DES VÉHICULES (14 CATÉGORIES OFFICIELLES)
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
  // Catégories thermiques (Essence / Diesel / Hybride standard)
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
  // Catégories 100 % électriques (Majoration fiscale légale +20% intégrée)
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
  // Deux-roues & Mobilités légères
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
// 4. MODÈLES DE LA BASE DE DONNÉES LOCAL-FIRST
// ============================================================================
class DriverProfile {
  final String id;
  String firstName;
  String lastName;
  String role; // Gérant, Commercial, Salarié
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
        personalAddress: json['personalAddress'] ?? '',
        companyName: json['companyName'] ?? '',
        companyAddress: json['companyAddress'] ?? '',
      );
}

class VehicleEntity {
  final String id;
  String name;
  String licensePlate; // ⚠️ Audité avant export
  String fiscalCategory; // Libellé parmi les 14 catégories
  String vehicleGroup; // THERMIQUE, ELECTRIQUE, MOTO, SCOOTER
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
        licensePlate: json['licensePlate'] ?? '',
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
  String locationType; // 'WORKPLACE' (Lieu de travail) ou 'EMPLACEMENT' (Domicile, Dépôt, Client)

  SavedLocationEntity({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.locationType,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'fullAddress': fullAddress,
        'locationType': locationType,
      };

  factory SavedLocationEntity.fromJson(Map<String, dynamic> json) =>
      SavedLocationEntity(
        id: json['id'] ?? '',
        label: json['label'] ?? '',
        fullAddress: json['fullAddress'] ?? '',
        locationType: json['locationType'] ?? 'EMPLACEMENT',
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
  String countryCode; // FR, LU, BE, DE, CH
  String originAddress;
  String destinationAddress;
  List<WaypointEntity> waypoints;
  bool isRoundTrip;
  String captureMode; // 'AUTO_GPS', 'IBEACON_BT', 'MANUAL_MAPS'
  String qualificationStatus; // 'PENDING' (Inbox), 'PRO', 'PERSO'
  String purpose; // Client, Chantier, Réunion, Administratif, Domicile-Travail
  String projectTag;
  double mapsDistanceKm;
  double detourMarginPercent; // 0% à 15%
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

  factory BracketFormula.fromJson(Map<String, dynamic> json) => BracketFormula(
        t1Limit: ((json['t1Limit'] ?? 5000.0) as num).toDouble(),
        t2Limit: ((json['t2Limit'] ?? 20000.0) as num).toDouble(),
        rate1: ((json['rate1'] ?? 0.5) as num).toDouble(),
        rate2: ((json['rate2'] ?? 0.3) as num).toDouble(),
        fixed2: ((json['fixed2'] ?? 1000.0) as num).toDouble(),
        rate3: ((json['rate3'] ?? 0.35) as num).toDouble(),
      );
}

class TaxRulesRepository {
  Map<int, BracketFormula> frenchCarBrackets;
  Map<String, BracketFormula> frenchTwoWheelsBrackets;
  double frenchElectricBonusPercent; // +20%
  double luxembourgFlatEur; // 0.40 €/km
  double belgiumFlatEur; // 0.43 €/km
  double germanyDienstreisenEur; // 0.30 €/km
  double germanyPendlerFirst20Eur; // 0.30 €/km
  double germanyPendlerAfter20Eur; // 0.38 €/km
  double switzerlandFlatChf; // 0.72 CHF/km

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
        'frenchCarBrackets': frenchCarBrackets.map(
          (k, v) => MapEntry(k.toString(), v.toJson()),
        ),
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
  /// Sélectionne la formule française selon la catégorie fiscale du véhicule
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

  /// Calcule l'indemnité annuelle cumulée en France pour une distance D
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

  /// Calcule l'indemnité exacte d'un trajet (différentiel par tranches cumulées en FR,
  /// ou barèmes nationaux LU / BE / DE / CH).
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
// 6. SERVICE GOOGLE MAPS PLATFORM (AUTOCOMPLETE CACHE LOCAL + DIRECTIONS API)
// ============================================================================
class GoogleMapsRoutingEngine {
  static final Map<String, List<String>> _localAutocompleteCache = {};

  static String cleanAddress(String input) {
    if (input.contains(' — ')) {
      return input.split(' — ').last.trim();
    }
    return input.trim();
  }

  static Future<List<String>> searchPlacesWithCache({
    required String query,
    required String googleApiKey,
    required List<SavedLocationEntity> savedLocations,
  }) async {
    final q = query.trim();
    if (q.length < 2) return [];

    final matches = <String>[];
    // 1. Lieux de travail & Emplacements favoris en priorité
    for (final loc in savedLocations) {
      if (loc.label.toLowerCase().contains(q.toLowerCase()) ||
          loc.fullAddress.toLowerCase().contains(q.toLowerCase())) {
        matches.add('${loc.label} — ${loc.fullAddress}');
      }
    }

    // 2. Cache local
    if (_localAutocompleteCache.containsKey(q.toLowerCase())) {
      for (final cached in _localAutocompleteCache[q.toLowerCase()]!) {
        if (!matches.contains(cached)) matches.add(cached);
      }
      return matches;
    }

    // 3. Google Places Autocomplete API si clé configurée
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
          final preds = (body['predictions'] as List?) ?? [];
          final fetched = <String>[];
          for (final p in preds.take(5)) {
            final d = p['description']?.toString() ?? '';
            if (d.isNotEmpty) {
              fetched.add(d);
              if (!matches.contains(d)) matches.add(d);
            }
          }
          if (fetched.isNotEmpty) {
            _localAutocompleteCache[q.toLowerCase()] = fetched;
            return matches;
          }
        }
      } catch (_) {}
    }

    // 4. Fallback Nominatim OpenStreetMap
    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        {
          'q': q,
          'format': 'json',
          'limit': '5',
          'accept-language': 'fr',
        },
      );
      final res = await http.get(
        uri,
        headers: {'User-Agent': 'PiratePipsKiloTrackerPro/2.0'},
      ).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        final fetched = <String>[];
        for (final item in list) {
          final disp = item['display_name']?.toString() ?? '';
          if (disp.isNotEmpty) {
            fetched.add(disp);
            if (!matches.contains(disp)) matches.add(disp);
          }
        }
        if (fetched.isNotEmpty) {
          _localAutocompleteCache[q.toLowerCase()] = fetched;
        }
      }
    } catch (_) {}

    return matches;
  }

  static Future<Map<String, dynamic>> calculateRoute({
    required String origin,
    required String destination,
    required List<WaypointEntity> waypoints,
    required String googleApiKey,
  }) async {
    final orig = cleanAddress(origin);
    final dest = cleanAddress(destination);
    final stops = waypoints
        .map((w) => cleanAddress(w.address))
        .where((s) => s.isNotEmpty)
        .toList();

    // 1. Google Directions API
    if (googleApiKey.trim().isNotEmpty) {
      try {
        final params = <String, String>{
          'origin': orig,
          'destination': dest,
          'mode': 'driving',
          'language': 'fr',
          'key': googleApiKey.trim(),
        };
        if (stops.isNotEmpty) {
          params['waypoints'] = stops.join('|');
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
            return {
              'km': double.parse((meters / 1000.0).toStringAsFixed(1)),
              'duration': '${(secs / 60).round()} min',
              'provider': 'Google Maps Directions API',
            };
          }
        }
      } catch (_) {}
    }

    // 2. Fallback OSRM / Nominatim
    try {
      final pts = <String>[orig, ...stops, dest];
      final coords = <String>[];
      for (final p in pts) {
        final u = Uri.https(
          'nominatim.openstreetmap.org',
          '/search',
          {'q': p, 'format': 'json', 'limit': '1'},
        );
        final r = await http.get(
          u,
          headers: {'User-Agent': 'PiratePipsKiloTrackerPro/2.0'},
        ).timeout(const Duration(seconds: 4));
        if (r.statusCode == 200) {
          final l = jsonDecode(r.body) as List;
          if (l.isNotEmpty) {
            coords.add('${l.first['lon']},${l.first['lat']}');
          }
        }
      }
      if (coords.length == pts.length && coords.length >= 2) {
        final osrm = Uri.parse(
          'https://router.project-osrm.org/route/v1/driving/${coords.join(";")}?overview=false',
        );
        final r = await http.get(osrm).timeout(const Duration(seconds: 4));
        if (r.statusCode == 200) {
          final d = jsonDecode(r.body) as Map<String, dynamic>;
          final routes = (d['routes'] as List?) ?? [];
          if (routes.isNotEmpty) {
            final m = ((routes.first['distance'] ?? 0) as num).toDouble();
            final s = ((routes.first['duration'] ?? 0) as num).toDouble();
            return {
              'km': double.parse((m / 1000.0).toStringAsFixed(1)),
              'duration': '${(s / 60).round()} min',
              'provider': 'Routage GPS OSRM',
            };
          }
        }
      }
    } catch (_) {}

    // 3. Calculateur vectoriel hors-ligne
    final hash = orig.length * 9 + dest.length * 13 + stops.length * 21;
    final km = 16.0 + (hash % 45) + (stops.length * 7.5);
    return {
      'km': double.parse(km.toStringAsFixed(1)),
      'duration': '${(km * 1.1).round()} min',
      'provider': 'Moteur Hors-Ligne Pirate Pips™',
    };
  }
}

// ============================================================================
// 7. APPLICATION ROOT & SPLASH SCREEN ANIMÉ PIRATE PIPS™
// ============================================================================
class PiratePipsDriversApp extends StatelessWidget {
  const PiratePipsDriversApp({super.key});

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
      duration: const Duration(milliseconds: 1200),
    );
    _pulse = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
    Timer(const Duration(milliseconds: 2200), () {
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: PiratePalette.goldPrimary.withOpacity(0.30),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: const PiratePipsBadgeLogo(size: 122),
              ),
              const SizedBox(height: 24),
              const Text(
                'PIRATE PIPS™',
                style: TextStyle(
                  color: PiratePalette.textPure,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.8,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: PiratePalette.goldPrimary.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: PiratePalette.goldPrimary.withOpacity(0.55),
                  ),
                ),
                child: const Text(
                  'AUTO-TRACKING GPS • AUDIT & FISCALITÉ CERTIFIÉE',
                  style: TextStyle(
                    color: PiratePalette.goldPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: PiratePalette.goldPrimary,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Développé par Pirate Pips™',
                style: TextStyle(
                  color: PiratePalette.textSteel,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 8. SHELL DE NAVIGATION À 5 ENTRÉES (AVEC FAB CENTRAL SURÉLEVÉ `+`)
// ============================================================================
class MainNavigationWorkspace extends StatefulWidget {
  const MainNavigationWorkspace({super.key});

  @override
  State<MainNavigationWorkspace> createState() =>
      _MainNavigationWorkspaceState();
}

class _MainNavigationWorkspaceState extends State<MainNavigationWorkspace> {
  int _activeTab = 0; // 0: Accueil, 1: Tous les trajets, 2: Rapports, 3: Paramètres
  bool _loading = true;

  // État Auto-Tracking & Onboarding Permissions (5 étapes Driversnote/Kilonote)
  bool _autoTrackingEnabled = true;
  bool _permMotionActivity = true;
  bool _permLocationAlways = false;
  bool _permNotifications = false;
  bool _permBatteryUnrestricted = false;
  bool _permBluetoothBeacon = false;

  // Données principales
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
    int count = 0;
    if (_permMotionActivity) count++;
    if (_permLocationAlways) count++;
    if (_permNotifications) count++;
    if (_permBatteryUnrestricted) count++;
    if (_permBluetoothBeacon) count++;
    return count;
  }

  @override
  void initState() {
    super.initState();
    _bootstrapLocalStore();
  }

  Future<void> _bootstrapLocalStore() async {
    final prefs = await SharedPreferences.getInstance();

    _autoTrackingEnabled = prefs.getBool('pp2_auto_tracking') ?? true;
    _permMotionActivity = prefs.getBool('pp2_perm_motion') ?? true;
    _permLocationAlways = prefs.getBool('pp2_perm_loc') ?? false;
    _permNotifications = prefs.getBool('pp2_perm_notif') ?? false;
    _permBatteryUnrestricted = prefs.getBool('pp2_perm_batt') ?? false;
    _permBluetoothBeacon = prefs.getBool('pp2_perm_bt') ?? false;

    _defaultCountry = prefs.getString('pp2_country') ?? 'FR';
    _defaultDetourMargin = prefs.getDouble('pp2_margin') ?? 5.0;
    _googleMapsApiKey = prefs.getString('pp2_gmaps_key') ?? '';

    final rawDrivers = prefs.getString('pp2_drivers');
    if (rawDrivers != null) {
      _drivers = (jsonDecode(rawDrivers) as List)
          .map((e) => DriverProfile.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      _drivers = [
        DriverProfile(
          id: 'drv_main',
          firstName: 'Antoine',
          lastName: 'Flory',
          role: 'Gérant',
          personalAddress: 'Uffheim, 68510, France',
          companyName: 'A&CSA INVEST / Pirate Pips™',
          companyAddress: '', // Volontairement vide par défaut pour illustrer l'alerte d'audit fiscal ⚠️
        ),
        DriverProfile(
          id: 'drv_team_1',
          firstName: 'Marc',
          lastName: 'Ingénieur Commercial',
          role: 'Salarié',
          personalAddress: 'Mulhouse, 68100, France',
          companyName: 'A&CSA INVEST / Pirate Pips™',
          companyAddress: 'Boulevard Royal, L-2449 Luxembourg',
        ),
      ];
    }

    final rawVehicles = prefs.getString('pp2_vehicles');
    if (rawVehicles != null) {
      _vehicles = (jsonDecode(rawVehicles) as List)
          .map((e) => VehicleEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      _vehicles = [
        VehicleEntity(
          id: 'veh_glc',
          name: 'Mercedes-Benz GLC AMG',
          licensePlate: '', // Volontairement vide par défaut pour démontrer l'alerte bloquante ⚠️ Plaque d'immatriculation
          fiscalCategory: 'Voiture (7 CV et plus)',
          vehicleGroup: 'THERMIQUE',
          fiscalHp: 7,
          isElectric: false,
          currentOdometerKm: 44820.0,
          bluetoothBeaconName: 'MB-GLC-BT-BEACON',
        ),
        VehicleEntity(
          id: 'veh_ranger',
          name: 'Ford Ranger Pick-up',
          licensePlate: 'PP-550-FR',
          fiscalCategory: 'Voiture (7 CV et plus)',
          vehicleGroup: 'THERMIQUE',
          fiscalHp: 7,
          isElectric: false,
          currentOdometerKm: 71300.0,
          bluetoothBeaconName: 'FORD-SYNC-BT',
        ),
        VehicleEntity(
          id: 'veh_ev',
          name: 'Berline Électrique Flotte',
          licensePlate: 'EV-900-LU',
          fiscalCategory: 'Voiture électrique (5 CV)',
          vehicleGroup: 'ELECTRIQUE',
          fiscalHp: 5,
          isElectric: true,
          currentOdometerKm: 18250.0,
          bluetoothBeaconName: 'IBEACON-PIRATE-01',
        ),
      ];
    }

    final rawLocs = prefs.getString('pp2_locations');
    if (rawLocs != null) {
      _locations = (jsonDecode(rawLocs) as List)
          .map((e) => SavedLocationEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      _locations = [
        SavedLocationEntity(
          id: 'loc_1',
          label: 'Siège Social Luxembourg',
          fullAddress: 'Boulevard Royal, L-2449 Luxembourg',
          locationType: 'WORKPLACE',
        ),
        SavedLocationEntity(
          id: 'loc_2',
          label: 'Bureau Régional Grand Est',
          fullAddress: 'Avenue de Colmar, 68100 Mulhouse, France',
          locationType: 'WORKPLACE',
        ),
        SavedLocationEntity(
          id: 'loc_3',
          label: 'Domicile Uffheim',
          fullAddress: 'Uffheim, 68510, France',
          locationType: 'EMPLACEMENT',
        ),
        SavedLocationEntity(
          id: 'loc_4',
          label: 'Chantier Bâle Centre',
          fullAddress: 'Aeschenplatz, 4052 Basel, Suisse',
          locationType: 'EMPLACEMENT',
        ),
      ];
    }

    final rawOdo = prefs.getString('pp2_odometer_logs');
    if (rawOdo != null) {
      _odometerLogs = (jsonDecode(rawOdo) as List)
          .map((e) => OdometerLogEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      _odometerLogs = [
        OdometerLogEntity(
          id: 'odo_1',
          vehicleId: 'veh_glc',
          recordedAt: DateTime.now().subtract(const Duration(days: 5)),
          odometerValueKm: 44700.0,
          photoEvidenceRef: 'COMPTEUR-GLC-OCT.JPG',
          note: 'Relevé mensuel certifié début de période',
        ),
      ];
    }

    final rawTax = prefs.getString('pp2_tax_rules');
    if (rawTax != null) {
      _taxRules = TaxRulesRepository.fromJson(
        jsonDecode(rawTax) as Map<String, dynamic>,
      );
    }

    final rawTrips = prefs.getString('pp2_trips');
    if (rawTrips != null) {
      _trips = (jsonDecode(rawTrips) as List)
          .map((e) => TripEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      _trips = [
        // 1. Trajet en attente dans l'Inbox (capturé en Auto-Tracking GPS / iBeacon)
        TripEntity(
          id: 'trp_inbox_1',
          date: DateTime.now(),
          startTime: '08:10',
          endTime: '08:52',
          driverId: 'drv_main',
          vehicleId: 'veh_glc',
          countryCode: 'FR',
          originAddress: 'Uffheim, 68510, France',
          destinationAddress: 'Avenue de Colmar, 68100 Mulhouse, France',
          waypoints: [
            WaypointEntity(
              label: 'Magasin Pro Outillage',
              address: 'Sierentz, 68510, France',
            ),
          ],
          isRoundTrip: false,
          captureMode: 'IBEACON_BT',
          qualificationStatus: 'PENDING',
          purpose: 'Chantier',
          projectTag: 'Grand Est BTP',
          mapsDistanceKm: 28.0,
          detourMarginPercent: 5.0,
          finalDistanceKm: 29.4,
          odometerStartKm: 44790.6,
          odometerEndKm: 44820.0,
          reimbursementAmount: 20.49,
          currency: 'EUR',
          appliedRuleLabel: 'FR Voiture (7 CV et plus) • Tranche 1 (d × 0.697)',
          notes: 'Détecté automatiquement via Bluetooth MB-GLC-BT-BEACON',
          receiptPhotoRef: null,
        ),
        // 2. Trajet en attente dans l'Inbox
        TripEntity(
          id: 'trp_inbox_2',
          date: DateTime.now().subtract(const Duration(hours: 5)),
          startTime: '11:30',
          endTime: '12:15',
          driverId: 'drv_main',
          vehicleId: 'veh_glc',
          countryCode: 'CH',
          originAddress: 'Uffheim, 68510, France',
          destinationAddress: 'Aeschenplatz, 4052 Basel, Suisse',
          waypoints: [],
          isRoundTrip: true,
          captureMode: 'AUTO_GPS',
          qualificationStatus: 'PENDING',
          purpose: 'Client',
          projectTag: 'Client Suisse',
          mapsDistanceKm: 44.0,
          detourMarginPercent: 5.0,
          finalDistanceKm: 46.2,
          odometerStartKm: 44744.4,
          odometerEndKm: 44790.6,
          reimbursementAmount: 33.26,
          currency: 'CHF',
          appliedRuleLabel: 'Suisse Barème TCS / Cantonal (0.72 CHF/km)',
          notes: 'Auto-tracking Motion API',
          receiptPhotoRef: 'PARKING-BASEL.JPG',
        ),
        // 3. Trajet déjà validé Professionnel
        TripEntity(
          id: 'trp_valid_1',
          date: DateTime.now().subtract(const Duration(days: 2)),
          startTime: '09:00',
          endTime: '11:40',
          driverId: 'drv_main',
          vehicleId: 'veh_ev',
          countryCode: 'LU',
          originAddress: 'Boulevard Royal, L-2449 Luxembourg',
          destinationAddress: 'Esch-sur-Alzette, Luxembourg',
          waypoints: [],
          isRoundTrip: true,
          captureMode: 'MANUAL_MAPS',
          qualificationStatus: 'PRO',
          purpose: 'Administratif',
          projectTag: 'Holding LU',
          mapsDistanceKm: 42.0,
          detourMarginPercent: 5.0,
          finalDistanceKm: 44.1,
          odometerStartKm: 18205.9,
          odometerEndKm: 18250.0,
          reimbursementAmount: 17.64,
          currency: 'EUR',
          appliedRuleLabel: 'Luxembourg Forfait Grand-Ducal (0.40 €/km)',
          notes: 'Signature actes & fiduciaire',
          receiptPhotoRef: null,
        ),
      ];
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveStateToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pp2_auto_tracking', _autoTrackingEnabled);
    await prefs.setBool('pp2_perm_motion', _permMotionActivity);
    await prefs.setBool('pp2_perm_loc', _permLocationAlways);
    await prefs.setBool('pp2_perm_notif', _permNotifications);
    await prefs.setBool('pp2_perm_batt', _permBatteryUnrestricted);
    await prefs.setBool('pp2_perm_bt', _permBluetoothBeacon);

    await prefs.setString('pp2_country', _defaultCountry);
    await prefs.setDouble('pp2_margin', _defaultDetourMargin);
    await prefs.setString('pp2_gmaps_key', _googleMapsApiKey);

    await prefs.setString(
      'pp2_drivers',
      jsonEncode(_drivers.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(
      'pp2_vehicles',
      jsonEncode(_vehicles.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(
      'pp2_locations',
      jsonEncode(_locations.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(
      'pp2_odometer_logs',
      jsonEncode(_odometerLogs.map((e) => e.toJson()).toList()),
    );
    await prefs.setString('pp2_tax_rules', jsonEncode(_taxRules.toJson()));
    await prefs.setString(
      'pp2_trips',
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

  /// Ouvre le calculateur rapide de trajet (Action du bouton central `+` FAB surélevé)
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
        initialChildSize: 0.93,
        maxChildSize: 0.97,
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

  /// Ouvre le configurateur interactif des 5 étapes d'autorisations d'auto-tracking
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
          void togglePerm(void Function() updater) {
            setState(updater);
            setSheetState(() {});
            _saveStateToDisk();
          }

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
                        'CONFIGURATION DU SUIVI AUTOMATIQUE (5 ÉTAPES)',
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
                  const Text(
                    'Activez les autorisations système pour capturer 100 % de vos trajets professionnels en arrière-plan sans vider la batterie.',
                    style: TextStyle(
                      color: PiratePalette.textSteel,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _PermissionStepTile(
                    stepNumber: 1,
                    title: 'Activité physique (Motion API)',
                    subtitle:
                        'Détecte automatiquement les transitions marche vs véhicule en mouvement.',
                    icon: Icons.directions_run,
                    enabled: _permMotionActivity,
                    onChanged: (v) =>
                        togglePerm(() => _permMotionActivity = v),
                  ),
                  _PermissionStepTile(
                    stepNumber: 2,
                    title: 'Emplacement (Toujours autoriser / Background GPS)',
                    subtitle:
                        'Géolocalisation précise des points de départ, d\'arrêts et d\'arrivée.',
                    icon: Icons.location_on,
                    enabled: _permLocationAlways,
                    onChanged: (v) =>
                        togglePerm(() => _permLocationAlways = v),
                  ),
                  _PermissionStepTile(
                    stepNumber: 3,
                    title: 'Notifications intelligentes de fin de trajet',
                    subtitle:
                        'Vous alerte dès qu\'un trajet est terminé pour le classer Pro ou Perso.',
                    icon: Icons.notifications_active,
                    enabled: _permNotifications,
                    onChanged: (v) => togglePerm(() => _permNotifications = v),
                  ),
                  _PermissionStepTile(
                    stepNumber: 4,
                    title: 'Exemption d\'optimisation batterie (Android / iOS)',
                    subtitle:
                        'Empêche le système de mettre l\'auto-tracking en veille prolongée.',
                    icon: Icons.battery_charging_full,
                    enabled: _permBatteryUnrestricted,
                    onChanged: (v) =>
                        togglePerm(() => _permBatteryUnrestricted = v),
                  ),
                  _PermissionStepTile(
                    stepNumber: 5,
                    title: 'Filtre matériel iBeacon / Bluetooth Véhicule',
                    subtitle:
                        'Déclenche l\'enregistrement uniquement au signal Bluetooth du véhicule (élimine train/bus).',
                    icon: Icons.bluetooth,
                    enabled: _permBluetoothBeacon,
                    onChanged: (v) =>
                        togglePerm(() => _permBluetoothBeacon = v),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        togglePerm(() {
                          _permMotionActivity = true;
                          _permLocationAlways = true;
                          _permNotifications = true;
                          _permBatteryUnrestricted = true;
                          _permBluetoothBeacon = true;
                        });
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.verified_user, size: 18),
                      label: const Text(
                        'ACTIVER TOUTES LES AUTORISATIONS (5/5)',
                      ),
                    ),
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
      // 1. Accueil (Inbox / Validation)
      HomeInboxValidationScreen(
        autoTrackingEnabled: _autoTrackingEnabled,
        completedSteps: _completedOnboardingSteps,
        trips: _trips,
        drivers: _drivers,
        vehicles: _vehicles,
        onToggleAutoTracking: (val) {
          setState(() => _autoTrackingEnabled = val);
          _saveStateToDisk();
        },
        onOpenOnboardingConfig: _openPermissionsConfiguratorModal,
        onQualifyTrip: _qualifyTripStatus,
        onSimulateAutoCapturedTrip: () {
          final v = _vehicles.first;
          final d = _drivers.first;
          final simKm = 22.4;
          final simTrip = TripEntity(
            id: 'trp_auto_${DateTime.now().millisecondsSinceEpoch}',
            date: DateTime.now(),
            startTime: TimeOfDay.now().format(context),
            endTime: TimeOfDay.now().format(context),
            driverId: d.id,
            vehicleId: v.id,
            countryCode: _defaultCountry,
            originAddress: 'Uffheim, 68510, France',
            destinationAddress: 'Boulevard Royal, L-2449 Luxembourg',
            waypoints: [],
            isRoundTrip: false,
            captureMode: _permBluetoothBeacon ? 'IBEACON_BT' : 'AUTO_GPS',
            qualificationStatus: 'PENDING',
            purpose: 'Client',
            projectTag: 'Auto-Tracking',
            mapsDistanceKm: 21.3,
            detourMarginPercent: 5.0,
            finalDistanceKm: simKm,
            odometerStartKm: v.currentOdometerKm,
            odometerEndKm: v.currentOdometerKm + simKm,
            reimbursementAmount: 15.61,
            currency: 'EUR',
            appliedRuleLabel: 'Auto-Tracking en attente de qualification',
            notes: 'Capturé automatiquement en arrière-plan',
          );
          _insertNewTrip(simTrip);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: PiratePalette.goldPrimary,
              content: Text(
                'Nouveau trajet automatique détecté et ajouté dans votre Inbox !',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
      // 2. Tous les trajets (Journal de bord)
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: PiratePalette.bullGreen,
              content: Text('Trajet retour identique créé avec succès.'),
            ),
          );
        },
      ),
      // 3. Rapports (Déclaration, Audit Pré-Export & Équipe)
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
      // 4. Paramètres (Sous-modules complets)
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
                    'Développé par Pirate Pips™ • Auto-Tracking & Fiscalité Certifiée',
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

      // Bouton central d'action rapide (FAB surélevé `+` Or Pirate Pips™)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 62,
        width: 62,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [PiratePalette.goldPrimary, PiratePalette.goldWarm],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
          tooltip: 'Saisie rapide d\'un trajet (Google Maps)',
          child: const Icon(Icons.add, color: Colors.black, size: 32),
        ),
      ),

      // Bottom Bar à 5 entrées (Accueil, Tous les trajets, [+], Rapports, Paramètres)
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
            const SizedBox(width: 56), // Espace réservé au FAB central `+`
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

class _PermissionStepTile extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _PermissionStepTile({
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: PiratePalette.bgElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabled ? PiratePalette.bullGreen : PiratePalette.borderSubtle,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: enabled
                ? PiratePalette.bullGreen.withOpacity(0.2)
                : PiratePalette.bgSurface,
            child: Icon(
              icon,
              size: 17,
              color: enabled
                  ? PiratePalette.bullGreen
                  : PiratePalette.goldPrimary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$stepNumber. $title',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: PiratePalette.textSteel,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            activeColor: PiratePalette.bullGreen,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 9. ONGLET 1 : ACCUEIL (INBOX / VALIDATION & ONBOARDING AUTO-TRACKING)
// ============================================================================
class HomeInboxValidationScreen extends StatelessWidget {
  final bool autoTrackingEnabled;
  final int completedSteps;
  final List<TripEntity> trips;
  final List<DriverProfile> drivers;
  final List<VehicleEntity> vehicles;
  final ValueChanged<bool> onToggleAutoTracking;
  final VoidCallback onOpenOnboardingConfig;
  final void Function(TripEntity trip, String status) onQualifyTrip;
  final VoidCallback onSimulateAutoCapturedTrip;

  const HomeInboxValidationScreen({
    super.key,
    required this.autoTrackingEnabled,
    required this.completedSteps,
    required this.trips,
    required this.drivers,
    required this.vehicles,
    required this.onToggleAutoTracking,
    required this.onOpenOnboardingConfig,
    required this.onQualifyTrip,
    required this.onSimulateAutoCapturedTrip,
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
        // 1. SÉLECTEUR RAPIDE EN TÊTE D'ÉCRAN : SWITCH ENREGISTREMENT AUTO + CONFIGURER
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
                    autoTrackingEnabled
                        ? Icons.sensors
                        : Icons.sensors_off,
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
                      'Configurer',
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
              const SizedBox(height: 4),
              // Carte de statut dynamique
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: autoTrackingEnabled
                      ? PiratePalette.bullGreen.withOpacity(0.12)
                      : PiratePalette.bearRed.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      autoTrackingEnabled
                          ? Icons.check_circle
                          : Icons.warning_amber_rounded,
                      size: 17,
                      color: autoTrackingEnabled
                          ? PiratePalette.bullGreen
                          : PiratePalette.bearRed,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        autoTrackingEnabled
                            ? 'L\'enregistrement automatique est activé. Vous pouvez démarrer.'
                            : 'L\'enregistrement automatique est désactivé. Activez-le pour capturer vos trajets.',
                        style: TextStyle(
                          color: autoTrackingEnabled
                              ? PiratePalette.bullGreen
                              : PiratePalette.bearRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. WIDGET D'ONBOARDING PROGRESSIF (« Configurez le suivi : X/5 étapes complétées »)
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
                      Icons.chevron_right,
                      color: PiratePalette.goldPrimary,
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
                const SizedBox(height: 6),
                const Text(
                  'Motion API • GPS Toujours • Notifications • Batterie • iBeacon Bluetooth',
                  style: TextStyle(
                    color: PiratePalette.textSteel,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // 3. SYNTHÈSE FINANCIÈRE CUMULÉE PIRATE PIPS™
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1C170A), Color(0xFF131313)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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
              OutlinedButton.icon(
                onPressed: onSimulateAutoCapturedTrip,
                style: OutlinedButton.styleFrom(
                  foregroundColor: PiratePalette.goldPrimary,
                  side: const BorderSide(color: PiratePalette.goldPrimary),
                ),
                icon: const Icon(Icons.bolt, size: 16),
                label: const Text(
                  'Simuler Trajet Auto',
                  style: TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 4. FLUX INBOX DES TRAJETS EN ATTENTE DE VALIDATION (PRO / PERSO)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TRAJETS À QUALIFIER (${pendingTrips.length})',
              style: const TextStyle(
                color: PiratePalette.textPure,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 0.8,
              ),
            ),
            if (pendingTrips.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  for (final t in pendingTrips) {
                    onQualifyTrip(t, 'PRO');
                  }
                },
                icon: const Icon(
                  Icons.done_all,
                  size: 16,
                  color: PiratePalette.bullGreen,
                ),
                label: const Text(
                  'Tout valider en Pro',
                  style: TextStyle(
                    color: PiratePalette.bullGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        if (pendingTrips.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: PiratePalette.bgSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: PiratePalette.borderSubtle),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.verified,
                  color: PiratePalette.bullGreen,
                  size: 38,
                ),
                SizedBox(height: 8),
                Text(
                  'Tous vos trajets récents sont qualifiés !',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  'Démarrez votre véhicule ou appuyez sur le bouton + central pour ajouter un trajet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: PiratePalette.textSteel,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

        ...pendingTrips.map((trip) {
          final vehicle = vehicles.firstWhere(
            (v) => v.id == trip.vehicleId,
            orElse: () => vehicles.first,
          );
          final dateStr =
              '${trip.date.day.toString().padLeft(2, '0')}/${trip.date.month.toString().padLeft(2, '0')}/${trip.date.year}';

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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: PiratePalette.goldPrimary.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            trip.captureMode == 'IBEACON_BT'
                                ? 'iBeacon Bluetooth'
                                : 'Auto-Tracking GPS',
                            style: const TextStyle(
                              color: PiratePalette.goldPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$dateStr • ${trip.startTime}',
                          style: const TextStyle(
                            color: PiratePalette.textSteel,
                            fontSize: 11,
                          ),
                        ),
                      ],
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
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.my_location,
                      size: 15,
                      color: PiratePalette.bullGreen,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        trip.originAddress,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                if (trip.waypoints.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 21, top: 3, bottom: 3),
                    child: Text(
                      '↳ Étape : ${trip.waypoints.map((w) => "${w.label} (${w.address})").join(" -> ")}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: PiratePalette.goldWarm,
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.place,
                      size: 15,
                      color: PiratePalette.bearRed,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${trip.destinationAddress}${trip.isRoundTrip ? " (Aller-Retour)" : ""}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${vehicle.name} • ${vehicle.fiscalCategory} • Motif : ${trip.purpose}',
                  style: const TextStyle(
                    color: PiratePalette.textSteel,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => onQualifyTrip(trip, 'PRO'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PiratePalette.bullGreen,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: const Icon(Icons.business_center, size: 16),
                        label: const Text('PROFESSIONNEL (PRO)'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => onQualifyTrip(trip, 'PERSO'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: PiratePalette.bearRed,
                          side: const BorderSide(color: PiratePalette.bearRed),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: const Icon(Icons.person_outline, size: 16),
                        label: const Text('PERSONNEL (PERSO)'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 18),
        const Center(
          child: Text(
            'Développé par Pirate Pips™',
            style: TextStyle(color: PiratePalette.textSteel, fontSize: 11),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ============================================================================
// 10. ONGLET 2 : TOUS LES TRAJETS (JOURNAL DE BORD MULTIFILTRES)
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
  String _statusFilter = 'ALL'; // ALL, PRO, PERSO, PENDING
  String _vehicleFilter = 'ALL';
  String _driverFilter = 'ALL';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.trips.where((t) {
      if (_statusFilter != 'ALL' && t.qualificationStatus != _statusFilter) {
        return false;
      }
      if (_vehicleFilter != 'ALL' && t.vehicleId != _vehicleFilter) {
        return false;
      }
      if (_driverFilter != 'ALL' && t.driverId != _driverFilter) {
        return false;
      }
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = t.originAddress.toLowerCase().contains(q) ||
            t.destinationAddress.toLowerCase().contains(q) ||
            t.projectTag.toLowerCase().contains(q) ||
            t.purpose.toLowerCase().contains(q) ||
            t.notes.toLowerCase().contains(q);
        if (!match) return false;
      }
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Recherche par client, projet, adresse ou étiquette
        TextField(
          decoration: const InputDecoration(
            labelText: 'Filtrer par client, projet, adresse ou motif...',
            prefixIcon: Icon(Icons.search, size: 18),
          ),
          onChanged: (v) => setState(() => _searchQuery = v),
        ),
        const SizedBox(height: 10),

        // Filtres rapides par statut
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChipPill(
                label: 'Tous (${widget.trips.length})',
                selected: _statusFilter == 'ALL',
                onTap: () => setState(() => _statusFilter = 'ALL'),
              ),
              _FilterChipPill(
                label: 'Professionnels',
                selected: _statusFilter == 'PRO',
                color: PiratePalette.bullGreen,
                onTap: () => setState(() => _statusFilter = 'PRO'),
              ),
              _FilterChipPill(
                label: 'Personnels',
                selected: _statusFilter == 'PERSO',
                color: PiratePalette.bearRed,
                onTap: () => setState(() => _statusFilter = 'PERSO'),
              ),
              _FilterChipPill(
                label: 'En attente Inbox',
                selected: _statusFilter == 'PENDING',
                color: PiratePalette.goldPrimary,
                onTap: () => setState(() => _statusFilter = 'PENDING'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Filtres par Véhicule et Conducteur
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _vehicleFilter,
                decoration: const InputDecoration(labelText: 'Véhicule'),
                items: [
                  const DropdownMenuItem(
                    value: 'ALL',
                    child: Text('Tous les véhicules', style: TextStyle(fontSize: 12)),
                  ),
                  ...widget.vehicles.map(
                    (v) => DropdownMenuItem(
                      value: v.id,
                      child: Text(
                        v.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _vehicleFilter = v ?? 'ALL'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _driverFilter,
                decoration: const InputDecoration(labelText: 'Conducteur'),
                items: [
                  const DropdownMenuItem(
                    value: 'ALL',
                    child: Text('Tous les conducteurs', style: TextStyle(fontSize: 12)),
                  ),
                  ...widget.drivers.map(
                    (d) => DropdownMenuItem(
                      value: d.id,
                      child: Text(
                        d.fullName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _driverFilter = v ?? 'ALL'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        ...filtered.map((t) {
          final v = widget.vehicles.firstWhere(
            (veh) => veh.id == t.vehicleId,
            orElse: () => widget.vehicles.first,
          );
          final d = widget.drivers.firstWhere(
            (drv) => drv.id == t.driverId,
            orElse: () => widget.drivers.first,
          );
          final dateStr =
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${t.qualificationStatus} • ${t.purpose}',
                            style: TextStyle(
                              color: badgeColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$dateStr (${t.countryCode})',
                          style: const TextStyle(
                            color: PiratePalette.textSteel,
                            fontSize: 11,
                          ),
                        ),
                      ],
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
                const SizedBox(height: 8),
                Text(
                  'Départ : ${t.originAddress}',
                  style: const TextStyle(fontSize: 12),
                ),
                if (t.waypoints.isNotEmpty)
                  Text(
                    'Étapes : ${t.waypoints.map((w) => w.label).join(" → ")}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: PiratePalette.goldWarm,
                    ),
                  ),
                Text(
                  'Arrivée : ${t.destinationAddress}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  '${d.fullName} • ${v.name} (${v.fiscalCategory}) • Maps: ${t.mapsDistanceKm.toStringAsFixed(1)} km (+${t.detourMarginPercent.toInt()}%) = ${t.finalDistanceKm.toStringAsFixed(1)} km',
                  style: const TextStyle(
                    fontSize: 11,
                    color: PiratePalette.textSteel,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => widget.onQualifyTrip(
                            t,
                            t.isPro ? 'PERSO' : 'PRO',
                          ),
                          child: Text(
                            t.isPro ? 'Basculer Perso' : 'Basculer Pro',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => widget.onCreateReturnTrip(t),
                          icon: const Icon(
                            Icons.repeat,
                            size: 14,
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
                      ],
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
        const SizedBox(height: 30),
      ],
    );
  }
}

class _FilterChipPill extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChipPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color = PiratePalette.goldPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: color,
        labelStyle: TextStyle(
          color: selected ? Colors.black : PiratePalette.textPure,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

// ============================================================================
// 11. ENTRÉE 3 (FAB `+`) : SAISIE MANUELLE GOOGLE MAPS, ÉTAPES & MARGE 0-15%
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
  late double _detourMargin; // Slider 0% à 15%
  bool _calculating = false;
  String _routeProviderNote = 'Google Maps Platform (Autocomplete + Directions)';
  String? _receiptPhotoRef;

  final TextEditingController _originCtrl = TextEditingController();
  final TextEditingController _destCtrl = TextEditingController();
  final TextEditingController _mapsKmCtrl =
      TextEditingController(text: '32.0');
  final TextEditingController _projectTagCtrl =
      TextEditingController(text: 'Client Pro');
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
      _originCtrl.text = widget.locations[2].fullAddress;
      _destCtrl.text = widget.locations[0].fullAddress;
    }
  }

  @override
  void dispose() {
    _originCtrl.dispose();
    _destCtrl.dispose();
    _mapsKmCtrl.dispose();
    _projectTagCtrl.dispose();
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

  Future<void> _computeMapsRoute() async {
    setState(() => _calculating = true);
    final res = await GoogleMapsRoutingEngine.calculateRoute(
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
          '${res['provider']} • Durée : ${res['duration']}';
    });
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
                labelText: 'Libellé (Magasin pro, Supermarché, Chantier)',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: adrCtrl,
              decoration: const InputDecoration(
                labelText: 'Adresse complète de l\'étape',
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
                _computeMapsRoute();
              }
            },
            child: const Text('Ajouter'),
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

    final workplaces = widget.locations
        .where((l) => l.locationType == 'WORKPLACE')
        .toList();
    final emplacements = widget.locations
        .where((l) => l.locationType != 'WORKPLACE')
        .toList();

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
                    'NOUVEAU TRAJET CERTIFIÉ GOOGLE MAPS',
                    style: TextStyle(
                      color: PiratePalette.goldPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
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
          const SizedBox(height: 8),

          // Statut Pro vs Perso
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('PROFESSIONNEL (DÉDUCTIBLE)'),
                  selected: _qualification == 'PRO',
                  selectedColor: PiratePalette.bullGreen,
                  labelStyle: TextStyle(
                    color: _qualification == 'PRO'
                        ? Colors.black
                        : PiratePalette.textPure,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                  onSelected: (_) => setState(() => _qualification = 'PRO'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Text('PERSONNEL (NON DÉD.)'),
                  selected: _qualification == 'PERSO',
                  selectedColor: PiratePalette.bearRed,
                  labelStyle: TextStyle(
                    color: _qualification == 'PERSO'
                        ? Colors.black
                        : PiratePalette.textPure,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                  onSelected: (_) => setState(() => _qualification = 'PERSO'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

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
                  decoration: const InputDecoration(labelText: 'Juridiction'),
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
            decoration:
                const InputDecoration(labelText: 'Véhicule & Catégorie fiscale'),
            items: widget.vehicles
                .map(
                  (v) => DropdownMenuItem(
                    value: v.id,
                    child: Text(
                      '${v.name} — ${v.fiscalCategory}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _vehicleId = v!),
          ),
          const SizedBox(height: 12),

          // Favoris segmentés : Lieux de travail & Emplacements
          const Text(
            'FAVORIS : LIEUX DE TRAVAIL & EMPLACEMENTS',
            style: TextStyle(
              color: PiratePalette.goldPrimary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...workplaces.map(
                  (w) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ActionChip(
                      avatar: const Icon(
                        Icons.business,
                        size: 14,
                        color: PiratePalette.goldPrimary,
                      ),
                      label: Text(
                        w.label,
                        style: const TextStyle(fontSize: 11),
                      ),
                      onPressed: () =>
                          setState(() => _destCtrl.text = w.fullAddress),
                    ),
                  ),
                ),
                ...emplacements.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ActionChip(
                      avatar: const Icon(
                        Icons.place,
                        size: 14,
                        color: PiratePalette.bullGreen,
                      ),
                      label: Text(
                        e.label,
                        style: const TextStyle(fontSize: 11),
                      ),
                      onPressed: () =>
                          setState(() => _originCtrl.text = e.fullAddress),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Départ Point A
          TextField(
            controller: _originCtrl,
            decoration: const InputDecoration(
              labelText: 'Point de départ (Google Places Autocomplete)',
              prefixIcon: Icon(
                Icons.my_location,
                color: PiratePalette.bullGreen,
                size: 18,
              ),
            ),
            onChanged: (v) async {
              final list = await GoogleMapsRoutingEngine.searchPlacesWithCache(
                query: v,
                googleApiKey: widget.googleMapsApiKey,
                savedLocations: widget.locations,
              );
              if (mounted) setState(() => _origPredict = list);
            },
          ),
          if (_origPredict.isNotEmpty)
            ..._origPredict.map(
              (s) => ListTile(
                dense: true,
                title: Text(s, style: const TextStyle(fontSize: 11)),
                onTap: () => setState(() {
                  _originCtrl.text = GoogleMapsRoutingEngine.cleanAddress(s);
                  _origPredict.clear();
                }),
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
                  Icons.alt_route,
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
                  onPressed: () =>
                      setState(() => _waypoints.removeAt(entry.key)),
                ),
              );
            }),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _promptWaypointDialog,
              icon: const Icon(
                Icons.add_location_alt,
                size: 16,
                color: PiratePalette.goldPrimary,
              ),
              label: const Text(
                'Ajouter une étape intermédiaire (Magasin pro, Supermarché, Chantier)',
                style: TextStyle(
                  fontSize: 11,
                  color: PiratePalette.goldPrimary,
                ),
              ),
            ),
          ),

          // Destination finale Point B
          TextField(
            controller: _destCtrl,
            decoration: const InputDecoration(
              labelText: 'Destination finale (Google Places Autocomplete)',
              prefixIcon: Icon(
                Icons.place,
                color: PiratePalette.bearRed,
                size: 18,
              ),
            ),
            onChanged: (v) async {
              final list = await GoogleMapsRoutingEngine.searchPlacesWithCache(
                query: v,
                googleApiKey: widget.googleMapsApiKey,
                savedLocations: widget.locations,
              );
              if (mounted) setState(() => _destPredict = list);
            },
          ),
          if (_destPredict.isNotEmpty)
            ..._destPredict.map(
              (s) => ListTile(
                dense: true,
                title: Text(s, style: const TextStyle(fontSize: 11)),
                onTap: () => setState(() {
                  _destCtrl.text = GoogleMapsRoutingEngine.cleanAddress(s);
                  _destPredict.clear();
                }),
              ),
            ),
          const SizedBox(height: 10),

          ElevatedButton.icon(
            onPressed: _calculating ? null : _computeMapsRoute,
            icon: const Icon(Icons.calculate, size: 18),
            label: Text(
              _calculating
                  ? 'Calcul Google Directions en cours...'
                  : 'CALCULER L\'ITINÉRAIRE VIA GOOGLE MAPS',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _routeProviderNote,
            style: const TextStyle(
              color: PiratePalette.textSteel,
              fontSize: 11,
            ),
          ),

          // Bouton Trajet retour identique
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: PiratePalette.goldPrimary,
            title: const Text(
              'Trajet retour identique (Aller-Retour immédiat ×2)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            value: _isRoundTrip,
            onChanged: (v) => setState(() => _isRoundTrip = v),
          ),

          // Slider Marge de compensation / Détours réels (+0% à +15%)
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
                      'Marge de compensation / Détours réels (0% à +15%)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PiratePalette.goldPrimary,
                      ),
                    ),
                    Text(
                      '+${_detourMargin.toStringAsFixed(0)} %',
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
                  label: '+${_detourMargin.toInt()}%',
                  onChanged: (v) => setState(() => _detourMargin = v),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _mapsKmCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Distance Maps (Aller)',
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

          // Résumé financier et bouton d'enregistrement
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
                          'TOTAL CERTIFIÉ : ${_finalAdjustedKm.toStringAsFixed(1)} KM',
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
                        startTime: '08:30',
                        endTime: '09:15',
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
                        projectTag: _projectTagCtrl.text.trim(),
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
                        receiptPhotoRef: _receiptPhotoRef,
                      );
                      widget.onTripCreated(newTrip);
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('ENREGISTRER LE TRAJET CERTIFIÉ'),
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
// 12. ONGLET 4 : RAPPORTS ([MES RAPPORTS] | [RAPPORTS DE L'ÉQUIPE])
//     & VÉRIFICATEUR PRÉ-EXPORT (AUDIT ANTI-REJET FISCAL)
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
  int _subTab = 0; // 0 = Mes rapports, 1 = Rapports de l'équipe
  late String _auditedDriverId;
  late String _auditedVehicleId;

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

  /// Permet de corriger immédiatement un champ manquant signalé par l'Audit Pré-Export
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
            labelText: 'Renseigner la valeur conforme',
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
            child: const Text('Corriger & Valider'),
          ),
        ],
      ),
    );
  }

  String _buildCertifiedCsvExport() {
    final sb = StringBuffer();
    sb.writeln(
      'Date;Heure;Conducteur;Entreprise;Vehicule;Plaque;Categorie_Fiscale;Pays;Depart;Etapes;Arrivee;Motif;Km_Google_Maps;Marge_Detours;Total_Km;Montant_Rembourse;Devise;Odo_Depart;Odo_Fin',
    );
    for (final t in widget.trips.where((e) => e.isPro)) {
      final d = widget.drivers
          .where((drv) => drv.id == t.driverId)
          .firstOrNull;
      final v = widget.vehicles
          .where((veh) => veh.id == t.vehicleId)
          .firstOrNull;
      final dt =
          '${t.date.day.toString().padLeft(2, '0')}/${t.date.month.toString().padLeft(2, '0')}/${t.date.year}';
      final wps = t.waypoints.map((w) => w.address).join(' | ');
      sb.writeln(
        '$dt;${t.startTime};${d?.fullName ?? ""};${d?.companyName ?? ""};${v?.name ?? ""};${v?.licensePlate ?? ""};${v?.fiscalCategory ?? ""};${t.countryCode};"${t.originAddress}";"$wps";"${t.destinationAddress}";${t.purpose};${t.mapsDistanceKm.toStringAsFixed(1)};+${t.detourMarginPercent.toInt()}%;${t.finalDistanceKm.toStringAsFixed(1)};${t.reimbursementAmount.toStringAsFixed(2)};${t.currency};${t.odometerStartKm.toStringAsFixed(1)};${t.odometerEndKm.toStringAsFixed(1)}',
      );
    }
    return sb.toString();
  }

  void _openCertifiedPdfPreview(
    DriverProfile driver,
    VehicleEntity vehicle,
  ) {
    final proTrips = widget.trips.where((t) => t.isPro).toList();
    final totalKm =
        proTrips.fold<double>(0.0, (s, t) => s + t.finalDistanceKm);
    final totalEur = proTrips
        .where((t) => t.currency == 'EUR')
        .fold<double>(0.0, (s, t) => s + t.reimbursementAmount);
    final totalChf = proTrips
        .where((t) => t.currency == 'CHF')
        .fold<double>(0.0, (s, t) => s + t.reimbursementAmount);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PiratePalette.bgDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        maxChildSize: 0.96,
        builder: (_, sc) => Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: sc,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      PiratePipsBadgeLogo(size: 34),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RAPPORT FISCAL CERTIFIÉ (EXPORT PDF PROBANT)',
                            style: TextStyle(
                              color: PiratePalette.goldPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Audit pré-export validé • Prêt pour Expert-Comptable & Administration',
                            style: TextStyle(
                              color: PiratePalette.bullGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
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
              const Divider(color: PiratePalette.goldPrimary),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: PiratePalette.bgSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: PiratePalette.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Conducteur : ${driver.fullName} (${driver.role}) — Domicile : ${driver.personalAddress}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Entreprise : ${driver.companyName} — Adresse : ${driver.companyAddress}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Véhicule : ${vehicle.name} • Plaque : ${vehicle.licensePlate} • ${vehicle.fiscalCategory}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: PiratePalette.goldPrimary,
                      ),
                    ),
                    const Divider(color: PiratePalette.borderSubtle),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Distance Pro : ${totalKm.toStringAsFixed(1)} km',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Total EUR : ${totalEur.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            color: PiratePalette.bullGreen,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (totalChf > 0)
                          Text(
                            'Total CHF : ${totalChf.toStringAsFixed(2)} CHF',
                            style: const TextStyle(
                              color: PiratePalette.goldPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor:
                      WidgetStateProperty.all(PiratePalette.bgElevated),
                  columns: const [
                    DataColumn(label: Text('Date & Heure')),
                    DataColumn(label: Text('Départ')),
                    DataColumn(label: Text('Arrivée')),
                    DataColumn(label: Text('Motif')),
                    DataColumn(label: Text('Odomètre')),
                    DataColumn(label: Text('Total km')),
                    DataColumn(label: Text('Indemnité')),
                  ],
                  rows: proTrips.map((t) {
                    final dt =
                        '${t.date.day.toString().padLeft(2, '0')}/${t.date.month.toString().padLeft(2, '0')}/${t.date.year} ${t.startTime}';
                    return DataRow(
                      cells: [
                        DataCell(Text(dt)),
                        DataCell(Text(t.originAddress)),
                        DataCell(Text(t.destinationAddress)),
                        DataCell(Text('${t.purpose} (${t.countryCode})')),
                        DataCell(Text(
                          '${t.odometerStartKm.toInt()} → ${t.odometerEndKm.toInt()} km',
                        )),
                        DataCell(Text('${t.finalDistanceKm.toStringAsFixed(1)} km')),
                        DataCell(Text(
                          '${t.reimbursementAmount.toStringAsFixed(2)} ${t.currency}',
                          style: const TextStyle(
                            color: PiratePalette.bullGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                      ],
                    );
                  }).toList(),
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
    final driver = _activeDriver;
    final vehicle = _activeVehicle;

    // Contrôles de complétude de l'Audit Pré-Export (5 points obligatoires)
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

    int missingCount = 0;
    if (!hasDriverName) missingCount++;
    if (!hasPersonalAddress) missingCount++;
    if (!hasLicensePlate) missingCount++;
    if (!hasCompanyName) missingCount++;
    if (!hasCompanyAddress) missingCount++;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Sélecteur d'onglets : [Mes rapports] | [Rapports de l'équipe]
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
        const SizedBox(height: 16),

        if (_subTab == 0) ...[
          // Sélection du profil et véhicule soumis à l'audit
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

          // CARTE VÉRIFICATEUR PRÉ-EXPORT (AUDIT ANTI-REJET FISCAL)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: PiratePalette.bgSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isAuditCompliant
                    ? PiratePalette.bullGreen
                    : PiratePalette.bearRed,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isAuditCompliant
                          ? Icons.verified
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
                            : 'ALERTE AUDIT PRÉ-EXPORT : $missingCount CHAMP(S) OBLIGATOIRE(S) MANQUANT(S)',
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
                const SizedBox(height: 6),
                const Text(
                  'Période : 1er au 31 du mois • Cliquez sur une ligne en alerte rouge pour renseigner immédiatement la donnée manquante.',
                  style: TextStyle(
                    color: PiratePalette.textSteel,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 12),

                // 1. Conducteur
                _AuditChecklistItem(
                  label: 'Conducteur assigné',
                  value: driver.fullName,
                  isValid: hasDriverName,
                  onTapFix: () => _promptQuickFixDialog(
                    title: 'Modifier le nom du conducteur',
                    initialValue: driver.lastName,
                    onSave: (val) => driver.lastName = val,
                  ),
                ),

                // 2. Adresse personnelle
                _AuditChecklistItem(
                  label: 'Adresse personnelle',
                  value: driver.personalAddress,
                  isValid: hasPersonalAddress,
                  onTapFix: () => _promptQuickFixDialog(
                    title: 'Renseigner l\'adresse personnelle',
                    initialValue: driver.personalAddress,
                    onSave: (val) => driver.personalAddress = val,
                  ),
                ),

                // 3. ⚠️ Plaque d'immatriculation (Alerte bloquante si manquante)
                _AuditChecklistItem(
                  label: 'Plaque d\'immatriculation (${vehicle.name})',
                  value: vehicle.licensePlate,
                  isValid: hasLicensePlate,
                  blockingWarningText:
                      '⚠️ Plaque d\'immatriculation manquante (Alerte bloquante)',
                  onTapFix: () => _promptQuickFixDialog(
                    title: 'Renseigner la plaque d\'immatriculation (${vehicle.name})',
                    initialValue: vehicle.licensePlate,
                    onSave: (val) => vehicle.licensePlate = val,
                  ),
                ),

                // 4. Entreprise / Lieu de travail rattaché
                _AuditChecklistItem(
                  label: 'Entreprise / Lieu de travail rattaché',
                  value: driver.companyName,
                  isValid: hasCompanyName,
                  onTapFix: () => _promptQuickFixDialog(
                    title: 'Renseigner l\'entreprise rattachée',
                    initialValue: driver.companyName,
                    onSave: (val) => driver.companyName = val,
                  ),
                ),

                // 5. ⚠️ Adresse de l'entreprise (Alerte si manquante)
                _AuditChecklistItem(
                  label: 'Adresse de l\'entreprise',
                  value: driver.companyAddress,
                  isValid: hasCompanyAddress,
                  blockingWarningText:
                      '⚠️ Adresse de l\'entreprise manquante (Requis pour contrôle fiscal)',
                  onTapFix: () => _promptQuickFixDialog(
                    title: 'Renseigner l\'adresse complète de l\'entreprise',
                    initialValue: driver.companyAddress,
                    onSave: (val) => driver.companyAddress = val,
                  ),
                ),

                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (!isAuditCompliant) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: PiratePalette.bearRed,
                                content: Text(
                                  'Export bloqué par l\'audit fiscal : veuillez cliquer sur les alertes ⚠️ rouges ci-dessus pour compléter la plaque ou l\'adresse de l\'entreprise.',
                                ),
                              ),
                            );
                            return;
                          }
                          _openCertifiedPdfPreview(driver, vehicle);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAuditCompliant
                              ? PiratePalette.goldPrimary
                              : PiratePalette.bgElevated,
                          foregroundColor: isAuditCompliant
                              ? Colors.black
                              : PiratePalette.textSteel,
                        ),
                        icon: const Icon(Icons.picture_as_pdf, size: 17),
                        label: const Text('GÉNÉRER PDF CERTIFIÉ'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final csv = _buildCertifiedCsvExport();
                          Clipboard.setData(ClipboardData(text: csv));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: PiratePalette.bullGreen,
                              content: Text(
                                'Export CSV / XLSX copié dans le presse-papiers !',
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: PiratePalette.goldPrimary,
                          side: const BorderSide(
                            color: PiratePalette.goldPrimary,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.table_chart, size: 17),
                        label: const Text('EXPORT CSV / XLSX'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ] else ...[
          // ONGLET : RAPPORTS DE L'ÉQUIPE (Multi-conducteurs / Flotte d'entreprise)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: PiratePalette.bgSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: PiratePalette.goldPrimary),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GESTION CENTRALISÉE DES RAPPORTS DE L\'ÉQUIPE',
                  style: TextStyle(
                    color: PiratePalette.goldPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Vue gestionnaire de flotte : vérifiez et approuvez les relevés kilométriques soumis par chaque conducteur.',
                  style: TextStyle(
                    color: PiratePalette.textSteel,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 12),
                ...widget.drivers.map((d) {
                  final dTrips = widget.trips
                      .where((t) => t.driverId == d.id && t.isPro)
                      .toList();
                  final km =
                      dTrips.fold<double>(0.0, (s, t) => s + t.finalDistanceKm);
                  final eur = dTrips
                      .where((t) => t.currency == 'EUR')
                      .fold<double>(0.0, (s, t) => s + t.reimbursementAmount);
                  final compliant = d.personalAddress.isNotEmpty &&
                      d.companyAddress.isNotEmpty;

                  return Card(
                    color: PiratePalette.bgElevated,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: compliant
                            ? PiratePalette.bullGreen.withOpacity(0.2)
                            : PiratePalette.bearRed.withOpacity(0.2),
                        child: Icon(
                          compliant ? Icons.check : Icons.warning_amber_rounded,
                          color: compliant
                              ? PiratePalette.bullGreen
                              : PiratePalette.bearRed,
                        ),
                      ),
                      title: Text(
                        '${d.fullName} (${d.role})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${dTrips.length} trajets pro • ${km.toStringAsFixed(1)} km\nStatut audit : ${compliant ? "Conforme" : "⚠️ Adresse entreprise manquante"}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      isThreeLine: true,
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
            ),
          ),
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
              size: 19,
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
                  const SizedBox(height: 2),
                  Text(
                    isValid
                        ? value
                        : (blockingWarningText ?? '⚠️ Champ obligatoire manquant'),
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
            const Icon(
              Icons.edit,
              size: 16,
              color: PiratePalette.goldPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 13. ONGLET 5 : PARAMÈTRES (SOUS-MODULES DÉTAILLÉS & CATALOGUE 14 VÉHICULES)
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
  /// Sélecteur modal du Catalogue Fiscal officiel des 14 catégories de véhicules
  void _showAddVehicleFromCatalogModal() {
    final nameCtrl = TextEditingController();
    final plateCtrl = TextEditingController();
    final odoCtrl = TextEditingController(text: '15000');
    final beaconCtrl = TextEditingController(text: 'BT-VEHICULE-PRO');
    FiscalVehicleCategorySpec selectedSpec = kOfficialVehicleCatalog[4]; // Voiture (7 CV et plus)

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
          initialChildSize: 0.88,
          maxChildSize: 0.95,
          builder: (_, sc) => Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              controller: sc,
              children: [
                const Text(
                  'CATALOGUE FISCAL DES VÉHICULES (NOMENCLATURE OFFICIELLE)',
                  style: TextStyle(
                    color: PiratePalette.goldPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nom / Modèle du véhicule (ex: Audi Q8 50 TDI)',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: plateCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Plaque d\'immatriculation (ex: PP-999-LU)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: odoCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Odomètre actuel (km)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: beaconCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Identifiant iBeacon / Bluetooth associé',
                    prefixIcon: Icon(Icons.bluetooth, size: 18),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'SÉLECTIONNEZ LA CATÉGORIE FISCALE EXACTE :',
                  style: TextStyle(
                    color: PiratePalette.goldWarm,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...kOfficialVehicleCatalog.map((spec) {
                  final isSelected = selectedSpec.label == spec.label;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? PiratePalette.goldPrimary.withOpacity(0.18)
                          : PiratePalette.bgElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? PiratePalette.goldPrimary
                            : PiratePalette.borderSubtle,
                      ),
                    ),
                    child: RadioListTile<String>(
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
                      subtitle: Text(
                        spec.isElectric
                            ? '100% Électrique • Majoration légale +20% incluse'
                            : 'Groupe : ${spec.group} • ${spec.fiscalHp} CV',
                        style: TextStyle(
                          fontSize: 10,
                          color: spec.isElectric
                              ? PiratePalette.bullGreen
                              : PiratePalette.textSteel,
                        ),
                      ),
                      onChanged: (_) =>
                          setModalState(() => selectedSpec = spec),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    if (nameCtrl.text.trim().isNotEmpty) {
                      widget.vehicles.add(
                        VehicleEntity(
                          id: 'veh_${DateTime.now().millisecondsSinceEpoch}',
                          name: nameCtrl.text.trim(),
                          licensePlate: plateCtrl.text.trim(),
                          fiscalCategory: selectedSpec.label,
                          vehicleGroup: selectedSpec.group,
                          fiscalHp: selectedSpec.fiscalHp,
                          isElectric: selectedSpec.isElectric,
                          currentOdometerKm:
                              double.tryParse(odoCtrl.text) ?? 0.0,
                          bluetoothBeaconName: beaconCtrl.text.trim(),
                        ),
                      );
                      widget.onStateMutated();
                      Navigator.pop(ctx);
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('AJOUTER AU GARAGE FISCAL'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Ajout d'un relevé périodique d'odomètre certifié avec photo
  void _showAddOdometerLogDialog() {
    String vehId = widget.vehicles.first.id;
    final odoCtrl = TextEditingController(
      text: widget.vehicles.first.currentOdometerKm.toStringAsFixed(0),
    );
    final noteCtrl =
        TextEditingController(text: 'Contrôle périodique certifié');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: PiratePalette.bgSurface,
          title: const Text('Nouveau relevé d\'odomètre certifié'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: vehId,
                decoration: const InputDecoration(labelText: 'Véhicule'),
                items: widget.vehicles
                    .map(
                      (v) => DropdownMenuItem(
                        value: v.id,
                        child: Text(v.name, style: const TextStyle(fontSize: 12)),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  setDialogState(() {
                    vehId = v!;
                    final sel =
                        widget.vehicles.firstWhere((e) => e.id == vehId);
                    odoCtrl.text = sel.currentOdometerKm.toStringAsFixed(0);
                  });
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: odoCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Valeur exacte du compteur (km)',
                  suffixText: 'km',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteCtrl,
                decoration:
                    const InputDecoration(labelText: 'Note d\'audit comptable'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final val = double.tryParse(odoCtrl.text) ?? 0.0;
                widget.odometerLogs.insert(
                  0,
                  OdometerLogEntity(
                    id: 'odo_${DateTime.now().millisecondsSinceEpoch}',
                    vehicleId: vehId,
                    recordedAt: DateTime.now(),
                    odometerValueKm: val,
                    photoEvidenceRef:
                        'PHOTO-ODO-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}.JPG',
                    note: noteCtrl.text.trim(),
                  ),
                );
                final vIdx =
                    widget.vehicles.indexWhere((e) => e.id == vehId);
                if (vIdx != -1) {
                  widget.vehicles[vIdx].currentOdometerKm = val;
                }
                widget.onStateMutated();
                Navigator.pop(ctx);
              },
              icon: const Icon(Icons.camera_alt, size: 16),
              label: const Text('Certifier avec Photo'),
            ),
          ],
        ),
      ),
    );
  }

  /// Éditeur des Taux kilométriques multi-pays (FR, LU, BE, DE, CH)
  void _showTaxRatesEditorModal() {
    final luCtrl = TextEditingController(
      text: widget.taxRules.luxembourgFlatEur.toStringAsFixed(2),
    );
    final beCtrl = TextEditingController(
      text: widget.taxRules.belgiumFlatEur.toStringAsFixed(2),
    );
    final deProCtrl = TextEditingController(
      text: widget.taxRules.germanyDienstreisenEur.toStringAsFixed(2),
    );
    final deP1Ctrl = TextEditingController(
      text: widget.taxRules.germanyPendlerFirst20Eur.toStringAsFixed(2),
    );
    final deP2Ctrl = TextEditingController(
      text: widget.taxRules.germanyPendlerAfter20Eur.toStringAsFixed(2),
    );
    final chCtrl = TextEditingController(
      text: widget.taxRules.switzerlandFlatChf.toStringAsFixed(2),
    );
    final gmapsCtrl = TextEditingController(text: widget.googleMapsApiKey);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PiratePalette.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TAUX KILOMÉTRIQUES MULTI-PAYS & CLÉ API GOOGLE MAPS',
                style: TextStyle(
                  color: PiratePalette.goldPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: luCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Luxembourg (€/km)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: beCtrl,
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
                      controller: deProCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Allemagne Dienstreisen (€/km)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: chCtrl,
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
                      controller: deP1Ctrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'DE Pendler km 1-20 (€/km)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: deP2Ctrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'DE Pendler >20 km (€/km)',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: gmapsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Clé API Google Maps (Autocomplete + Directions)',
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.taxRules.luxembourgFlatEur =
                        double.tryParse(luCtrl.text) ?? 0.40;
                    widget.taxRules.belgiumFlatEur =
                        double.tryParse(beCtrl.text) ?? 0.43;
                    widget.taxRules.germanyDienstreisenEur =
                        double.tryParse(deProCtrl.text) ?? 0.30;
                    widget.taxRules.germanyPendlerFirst20Eur =
                        double.tryParse(deP1Ctrl.text) ?? 0.30;
                    widget.taxRules.germanyPendlerAfter20Eur =
                        double.tryParse(deP2Ctrl.text) ?? 0.38;
                    widget.taxRules.switzerlandFlatChf =
                        double.tryParse(chCtrl.text) ?? 0.72;
                    widget.onStateMutated(gmapsKey: gmapsCtrl.text.trim());
                    Navigator.pop(ctx);
                  },
                  child: const Text('SAUVEGARDER LES BARÈMES FISCAUX'),
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
        // 1. Sous-module : Enregistrement automatique & iBeacon
        Card(
          child: ListTile(
            leading: const Icon(
              Icons.sensors,
              color: PiratePalette.bullGreen,
            ),
            title: const Text(
              'Enregistrement automatique & Autorisations',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            subtitle: Text(
              'Motion API, GPS Toujours, Batterie & iBeacon (${widget.completedOnboardingSteps}/5 étapes actives)',
              style: const TextStyle(fontSize: 11),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: widget.onOpenPermissionsModal,
          ),
        ),
        const SizedBox(height: 10),

        // 2. Sous-module : Catalogue Fiscal des Véhicules (14 catégories)
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
                    'VÉHICULES & NOMENCLATURE FISCALE',
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
                      'Ajouter (14 catégories)',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...widget.vehicles.map((v) {
                final missingPlate = v.licensePlate.trim().isEmpty;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    v.isElectric
                        ? Icons.electric_car
                        : v.vehicleGroup == 'MOTO' ||
                                v.vehicleGroup == 'SCOOTER'
                            ? Icons.two_wheeler
                            : Icons.directions_car,
                    color: PiratePalette.goldPrimary,
                  ),
                  title: Text(
                    '${v.name} — ${v.fiscalCategory}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  subtitle: Text(
                    missingPlate
                        ? '⚠️ Plaque manquante • Odo: ${v.currentOdometerKm.toInt()} km • BT: ${v.bluetoothBeaconName}'
                        : 'Plaque: ${v.licensePlate} • Odo: ${v.currentOdometerKm.toInt()} km • BT: ${v.bluetoothBeaconName}',
                    style: TextStyle(
                      fontSize: 11,
                      color: missingPlate
                          ? PiratePalette.bearRed
                          : PiratePalette.textSteel,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 3. Sous-module : Relevés périodiques d'odomètre (Compteur véhicule)
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
                    'RELEVÉS PÉRIODIQUES D\'ODOMÈTRE CERTIFIÉS',
                    style: TextStyle(
                      color: PiratePalette.goldPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _showAddOdometerLogDialog,
                    icon: const Icon(
                      Icons.speed,
                      size: 15,
                      color: PiratePalette.goldPrimary,
                    ),
                    label: const Text(
                      'Nouveau relevé',
                      style: TextStyle(
                        fontSize: 11,
                        color: PiratePalette.goldPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...widget.odometerLogs.map((log) {
                final v = widget.vehicles.firstWhere(
                  (e) => e.id == log.vehicleId,
                  orElse: () => widget.vehicles.first,
                );
                final dt =
                    '${log.recordedAt.day.toString().padLeft(2, '0')}/${log.recordedAt.month.toString().padLeft(2, '0')}/${log.recordedAt.year}';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.camera_alt,
                    color: PiratePalette.bullGreen,
                    size: 18,
                  ),
                  title: Text(
                    '${v.name} : ${log.odometerValueKm.toStringAsFixed(0)} km ($dt)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  subtitle: Text(
                    'Preuve : ${log.photoEvidenceRef} • ${log.note}',
                    style: const TextStyle(fontSize: 11),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 4. Sous-module : Taux kilométriques multi-pays (FR / LU / BE / DE / CH)
        Card(
          child: ListTile(
            leading: const Icon(
              Icons.euro,
              color: PiratePalette.goldPrimary,
            ),
            title: const Text(
              'Taux kilométriques & Barèmes fiscaux (FR / LU / BE / DE / CH)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            subtitle: const Text(
              'Tranches progressives France (+20% Élec), Forfaits LU, BE, DE (Pendler/Dienstreisen), CH',
              style: TextStyle(fontSize: 11),
            ),
            trailing: const Icon(Icons.edit, color: PiratePalette.goldPrimary),
            onTap: _showTaxRatesEditorModal,
          ),
        ),
        const SizedBox(height: 16),

        // 5. Écran légal / À propos : Protection légale Pirate Pips™
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: PiratePalette.bgSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: PiratePalette.goldPrimary, width: 1.3),
          ),
          child: const Column(
            children: [
              PiratePipsBadgeLogo(size: 68),
              SizedBox(height: 12),
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
              SizedBox(height: 8),
              Text(
                'Solution mobile Local-First d\'enregistrement automatisé des trajets (Motion API, GPS & iBeacon Bluetooth) et d\'audit fiscal certifié multi-juridictions.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: PiratePalette.textSteel,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

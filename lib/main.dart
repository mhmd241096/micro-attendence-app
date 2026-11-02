// ============================================================================
// MICROBIOLOGY & IMMUNOLOGY ACADEMIC PORTAL — NATIVE MOBILE EDITION
// Faculty of Pharmacy • Beni-Suef University (BSU)
// Compatible with Flutter 3.24.5 Stable
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

typedef JsonMap = Map<String, dynamic>;
typedef StringDropItem = DropdownMenuItem<String>;
typedef IntDropItem = DropdownMenuItem<int>;

JsonMap asJsonMap(dynamic raw) {
  if (raw is Map) {
    return Map<String, dynamic>.from(raw);
  }
  return <String, dynamic>{};
}

List<JsonMap> asJsonMapList(dynamic raw) {
  if (raw is List) {
    return raw.map((dynamic e) => asJsonMap(e)).toList();
  }
  return <JsonMap>[];
}

List<String> asStringList(dynamic raw) {
  if (raw is List) {
    return raw.map((dynamic e) => e?.toString() ?? '').where((String s) => s.isNotEmpty).toList();
  }
  return <String>[];
}

const String kDefaultWebAppUrl =
    'https://script.google.com/macros/s/AKfycbygFGReaYRWp4gZqhjkc7iTbJXhfxC3rq5-w_qhYxcq9UCgfFQlOUOvC7MPf7En-FnG4A/exec';

/// Exact Original Rounded-Square Badge (with BSNU & Arabic text removed, untouched design)
const String kOriginalBadgeBase64 = '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';

late final Uint8List kOriginalBadgeBytes;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  kOriginalBadgeBytes = base64Decode(kOriginalBadgeBase64);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MicroDeptFlutterApp());
}

// ============================================================================
// DESIGN SYSTEM PALETTE & CATALOG CONSTANTS (MATCHING admin.html & Code.gs)
// ============================================================================
class AppColors {
  static const Color navyBar = Color(0xFF0F172A);
  static const Color navyDeep = Color(0xFF161B29);
  static const Color emeraldDark = Color(0xFF0B4A40);
  static const Color emeraldMid = Color(0xFF134E4A);
  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldLight = Color(0xFF34D399);
  static const Color emeraldSoft = Color(0xFFECFDF5);
  static const Color gold = Color(0xFFF5B82E);
  static const Color goldSoft = Color(0xFFFEF3C7);
  static const Color goldDark = Color(0xFFB45309);
  static const Color sky = Color(0xFF0284C7);
  static const Color skySoft = Color(0xFFE0F2FE);
  static const Color bgSurface = Color(0xFFF8FAFC);
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color textMain = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color danger = Color(0xFFE11D48);
  static const Color dangerSoft = Color(0xFFFFE4E6);
}

const List<String> kTrackKeys = <String>[
  'BSNU_Clinical',
  'BSNU_General',
  'BSU_General',
  'BSU_Clinical',
];

const Map<String, String> kTrackLabels = <String, String>{
  'BSNU_Clinical': 'BSNU Clinical (الأهلية كلينيكال)',
  'BSNU_General': 'BSNU General (الأهلية جنرال)',
  'BSU_General': 'BSU General (الحكومية جنرال)',
  'BSU_Clinical': 'BSU Clinical (الحكومية كلينيكال)',
};

const List<JsonMap> kSubjectCatalog = <JsonMap>[
  <String, dynamic>{'key': 'basicMicro', 'altKey': 'basic_micro', 'name': 'Basic Microbiology'},
  <String, dynamic>{'key': 'parasitology', 'altKey': 'parasitology', 'name': 'Parasitology'},
  <String, dynamic>{'key': 'biotech', 'altKey': 'biotechnology', 'name': 'Biotechnology'},
  <String, dynamic>{'key': 'pharmaMicro', 'altKey': 'pharm_micro', 'name': 'Pharmaceutical Microbiology'},
  <String, dynamic>{'key': 'medicalMicro', 'altKey': 'medical_micro', 'name': 'Medical Microbiology'},
  <String, dynamic>{'key': 'cellBiology', 'altKey': 'cell_biology', 'name': 'Cell Biology'},
  <String, dynamic>{'key': 'publicHealth', 'altKey': 'public_health', 'name': 'Public Health'},
  <String, dynamic>{'key': 'infectionControl', 'altKey': 'infection_control', 'name': 'Infection Control'},
  <String, dynamic>{'key': 'antimicrobialStewardship', 'altKey': 'antimicrobial', 'name': 'Antimicrobial Stewardship'},
];

const List<JsonMap> kActionPermDefinitions = <JsonMap>[
  <String, dynamic>{
    'key': 'ACT_REVIEW_EXCUSES',
    'label': 'مراجعة الأعذار الطبية (Approve / Reject Excuses)',
  },
  <String, dynamic>{
    'key': 'ACT_EDIT_ATTENDANCE',
    'label': 'تعديل الغياب المباشر (Edit Attendance P/A/E)',
  },
  <String, dynamic>{
    'key': 'ACT_EDIT_DATES',
    'label': 'تعديل تواريخ السكاشن (Section Dates 1–12)',
  },
  <String, dynamic>{
    'key': 'ACT_REVIEW_APPEALS',
    'label': 'مراجعة تظلمات الدرجات وإضافة البونص (Grade Appeals)',
  },
  <String, dynamic>{
    'key': 'ACT_EDIT_GRADES',
    'label': 'تعديل شيت الدرجات وإضافة/حذف طالب (Edit Grades Sheet)',
  },
  <String, dynamic>{
    'key': 'ACT_TOGGLE_VISIBILITY',
    'label': 'إعلان وحجب المقررات للطلاب (Toggle Visibility)',
  },
  <String, dynamic>{
    'key': 'ACT_CHANGE_CRED',
    'label': 'تعديل اسم المستخدم وكلمة المرور الشخصية (Account)',
  },
];

const Map<int, String> kDefaultSectionDates = <int, String>{
  1: '28/09/2026',
  2: '05/10/2026',
  3: '12/10/2026',
  4: '19/10/2026',
  5: '26/10/2026',
  6: '02/11/2026',
  7: '09/11/2026',
  8: '16/11/2026',
  9: '23/11/2026',
  10: '30/11/2026',
  11: '07/12/2026',
  12: '14/12/2026',
};

String resolveTrackKey(String university, String program) {
  final String u = university.toLowerCase();
  final String p = program.toLowerCase();
  final bool isBsnu = u.contains('national') || u.contains('bsnu');
  final bool isClinical = p.contains('clinical');
  if (isBsnu && isClinical) return 'BSNU_Clinical';
  if (isBsnu && !isClinical) return 'BSNU_General';
  if (!isBsnu && isClinical) return 'BSU_Clinical';
  return 'BSU_General';
}

JsonMap? findSubjectByNameOrKey(String raw) {
  final String clean = raw.trim().toLowerCase();
  for (final JsonMap item in kSubjectCatalog) {
    if (item['key'].toString().toLowerCase() == clean ||
        item['altKey'].toString().toLowerCase() == clean ||
        item['name'].toString().toLowerCase() == clean) {
      return item;
    }
  }
  return null;
}

bool isDoctorCourseAllowed(List<String> perms, String trackKey, String subjectNameOrKey) {
  if (perms.isEmpty) return false;
  if (perms.contains('ALL') || perms.contains('ROLE_SUPER_ADMIN')) return true;
  final JsonMap? item = findSubjectByNameOrKey(subjectNameOrKey);
  final String canonicalKey = item != null ? item['key'].toString() : subjectNameOrKey;
  final String altKey = item != null ? item['altKey'].toString() : subjectNameOrKey;
  return perms.contains('${trackKey}__$canonicalKey') || perms.contains('${trackKey}__$altKey');
}

bool isDoctorActionAllowed(List<String> perms, String actionKey) {
  if (perms.isEmpty) return false;
  if (perms.contains('ALL') || perms.contains('ROLE_SUPER_ADMIN')) return true;
  final bool hasAnyActionToken = perms.any((String p) => p.startsWith('ACT_'));
  if (!hasAnyActionToken) return true;
  return perms.contains(actionKey);
}

List<String> buildAll36CoursePerms() {
  final List<String> list = <String>[];
  for (final String tk in kTrackKeys) {
    for (final JsonMap s in kSubjectCatalog) {
      list.add('${tk}__${s['key']}');
    }
  }
  return list;
}

List<String> buildDefaultActionPerms() {
  return kActionPermDefinitions.map((JsonMap a) => a['key'].toString()).toList();
}

// ============================================================================
// REST API CLIENT FOR Code.gs (FOLLOWS 302 REDIRECTS AUTOMATICALLY)
// ============================================================================
class PortalApiService {
  static String _webAppUrl = kDefaultWebAppUrl;

  static String get webAppUrl => _webAppUrl;

  static Future<void> initSavedUrl() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? saved = prefs.getString('custom_gas_webapp_url');
      if (saved != null && saved.trim().startsWith('http')) {
        _webAppUrl = saved.trim();
      }
    } catch (_) {}
  }

  static Future<void> setWebAppUrl(String newUrl) async {
    final String clean = newUrl.trim();
    if (clean.isEmpty) return;
    _webAppUrl = clean;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('custom_gas_webapp_url', clean);
    } catch (_) {}
  }

  static Future<dynamic> callAction(String action, [List<dynamic> args = const <dynamic>[]]) async {
    final String bodyJson = jsonEncode(<String, dynamic>{
      'action': action,
      'args': args,
    });

    final http.Client client = http.Client();
    try {
      Uri currentUri = Uri.parse(_webAppUrl);
      http.Request req = http.Request('POST', currentUri)
        ..followRedirects = false
        ..headers['Content-Type'] = 'text/plain;charset=utf-8'
        ..body = bodyJson;

      http.StreamedResponse streamed = await client.send(req).timeout(const Duration(seconds: 45));
      int redirects = 0;

      while ((streamed.statusCode == 301 ||
              streamed.statusCode == 302 ||
              streamed.statusCode == 303 ||
              streamed.statusCode == 307 ||
              streamed.statusCode == 308) &&
          redirects < 5) {
        final String? location = streamed.headers['location'] ?? streamed.headers['Location'];
        if (location == null || location.isEmpty) break;
        currentUri = Uri.parse(location);
        final http.Request getReq = http.Request('GET', currentUri)..followRedirects = true;
        streamed = await client.send(getReq).timeout(const Duration(seconds: 45));
        redirects++;
      }

      final String responseText = await streamed.stream.bytesToString();
      if (responseText.trim().isEmpty) {
        return <String, dynamic>{'success': false, 'message': 'Empty response from server.'};
      }
      return jsonDecode(responseText);
    } catch (err) {
      return <String, dynamic>{
        'success': false,
        'message': 'Connection error: $err',
      };
    } finally {
      client.close();
    }
  }
}

// ============================================================================
// ORIGINAL ROUNDED-SQUARE BADGE WIDGET (UNALTERED DESIGN, NO CIRCLE CROP)
// ============================================================================
class OriginalBadgeLogo extends StatelessWidget {
  final double size;
  final double borderRadius;
  final bool showGoldBorder;

  const OriginalBadgeLogo({
    super.key,
    this.size = 44,
    this.borderRadius = 11,
    this.showGoldBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: showGoldBorder
            ? Border.all(color: AppColors.gold.withOpacity(0.85), width: size > 70 ? 2.0 : 1.3)
            : null,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.24),
            blurRadius: size * 0.22,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius > 1.5 ? borderRadius - 1.2 : borderRadius),
        child: Image.memory(
          kOriginalBadgeBytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}

// ============================================================================
// FACEBOOK-STYLE FLOATING TOP CIRCULAR REFRESH INDICATOR
// ============================================================================
class TopFloatingCircularLoader extends StatelessWidget {
  final bool isLoading;
  final String? label;

  const TopFloatingCircularLoader({
    super.key,
    required this.isLoading,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isLoading,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutBack,
        offset: isLoading ? Offset.zero : const Offset(0, -2.2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isLoading ? 1.0 : 0.0,
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              padding: EdgeInsets.symmetric(
                horizontal: (label != null && label!.isNotEmpty) ? 13 : 9,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.gold.withOpacity(0.7),
                  width: 1.3,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.navyBar.withOpacity(0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      backgroundColor: Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.emeraldDark),
                    ),
                  ),
                  if (label != null && label!.isNotEmpty) ...<Widget>[
                    const SizedBox(width: 8),
                    Text(
                      label!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navyBar,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ROOT APPLICATION WIDGET (CLAMPED MOBILE FONT SCALE)
// ============================================================================
class MicroDeptFlutterApp extends StatefulWidget {
  const MicroDeptFlutterApp({super.key});

  @override
  State<MicroDeptFlutterApp> createState() => _MicroDeptFlutterAppState();
}

class _MicroDeptFlutterAppState extends State<MicroDeptFlutterApp> {
  bool _showIntro = true;

  @override
  void initState() {
    super.initState();
    PortalApiService.initSavedUrl();
  }

  void _completeIntro() {
    if (!mounted) return;
    setState(() => _showIntro = false);
  }

  void _replayIntro() {
    if (!mounted) return;
    setState(() => _showIntro = true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Microbiology & Immunology Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        visualDensity: VisualDensity.compact,
        scaffoldBackgroundColor: AppColors.bgSurface,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.emeraldDark,
          primary: AppColors.navyBar,
          secondary: AppColors.gold,
          surface: Colors.white,
        ),
        fontFamily: 'Roboto',
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          filled: true,
          fillColor: AppColors.bgSurface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
          hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: AppColors.cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: AppColors.cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: AppColors.emeraldDark, width: 1.4),
          ),
        ),
      ),
      builder: (BuildContext context, Widget? child) {
        final MediaQueryData mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 520),
        child: _showIntro
            ? YouTubeOriginalStyleIntroScreen(
                key: const ValueKey<String>('yt_original_intro'),
                onFinished: _completeIntro,
              )
            : MainAdminSuperShell(
                key: const ValueKey<String>('main_admin_super_shell'),
                onReplayIntro: _replayIntro,
              ),
      ),
    );
  }
}

// ============================================================================
// YOUTUBE ORIGINALS STYLE STUDIO INTRO ANIMATION (100% ENGLISH, ORIGINAL ART)
// - Beat 1: Original Rounded-Square Badge + Center Slogan snap into focus
// - Beat 2: Razor-sharp central bar expands horizontally, then SPLITS into
//           Top Bar & Bottom Bar while "MICROBIOLOGY & IMMUNOLOGY" emerges
//           from the aperture between them
// - Beat 3: "Microbiology Department" & "Faculty of Pharmacy, Beni-Suef University"
//           slide up cleanly below the bottom bar
// ============================================================================
class YouTubeOriginalStyleIntroScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const YouTubeOriginalStyleIntroScreen({
    super.key,
    required this.onFinished,
  });

  @override
  State<YouTubeOriginalStyleIntroScreen> createState() =>
      _YouTubeOriginalStyleIntroScreenState();
}

class _YouTubeOriginalStyleIntroScreenState
    extends State<YouTubeOriginalStyleIntroScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Beat 1 (0.00 -> 0.28): Badge & Slogan in center
  late final Animation<double> _badgeOpacity;
  late final Animation<double> _badgeScale;
  late final Animation<double> _sheenSweep;
  late final Animation<double> _sloganOpacity;
  late final Animation<double> _sloganTracking;

  // Beat 2 (0.24 -> 0.66): Horizontal bar draw + Vertical Split-Bar Aperture + Word Emerge
  late final Animation<double> _barDrawWidth;
  late final Animation<double> _barSplitDistance;
  late final Animation<double> _wordSlideY;
  late final Animation<double> _wordScale;

  // Beat 3 (0.60 -> 0.90): Lower institutional lockup reveal
  late final Animation<double> _subOpacity;
  late final Animation<double> _subSlideY;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4400),
    );

    const Cubic ytFastOutSlowIn = Cubic(0.16, 1.0, 0.3, 1.0);
    const Cubic ytApertureSplit = Cubic(0.22, 1.0, 0.36, 1.0);

    _badgeOpacity = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.02, 0.22, curve: Curves.easeOut),
    );
    _badgeScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.02, 0.28, curve: ytFastOutSlowIn),
      ),
    );
    _sheenSweep = Tween<double>(begin: -1.2, end: 2.2).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.10, 0.48, curve: Curves.easeInOut),
      ),
    );

    _sloganOpacity = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.08, 0.26, curve: Curves.easeOut),
    );
    _sloganTracking = Tween<double>(begin: 2.4, end: 0.6).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.08, 0.30, curve: ytFastOutSlowIn),
      ),
    );

    // Center laser bar shoots horizontally from center (0 -> 1 width)
    _barDrawWidth = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.24, 0.38, curve: ytFastOutSlowIn),
    );

    // Top bar & bottom bar split open vertically from the center
    _barSplitDistance = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.36, 0.66, curve: ytApertureSplit),
    );

    // Department word emerges out from between the two splitting bars
    _wordSlideY = Tween<double>(begin: 18.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.38, 0.68, curve: ytFastOutSlowIn),
      ),
    );
    _wordScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.38, 0.68, curve: ytFastOutSlowIn),
      ),
    );

    // Subtitle underneath: "Microbiology Department • Faculty of Pharmacy, Beni-Suef University"
    _subOpacity = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.60, 0.86, curve: Curves.easeOut),
    );
    _subSlideY = Tween<double>(begin: 14.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.60, 0.86, curve: ytFastOutSlowIn),
      ),
    );

    _ctrl.forward().whenComplete(() {
      if (mounted) {
        Future<void>.delayed(const Duration(milliseconds: 280), () {
          if (mounted) widget.onFinished();
        });
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060E14),
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (BuildContext context, Widget? _) {
          final double maxBarWidth = (MediaQuery.of(context).size.width - 48).clamp(220.0, 380.0);
          final double currentBarWidth = maxBarWidth * _barDrawWidth.value;
          final double apertureHeight = 68.0 * _barSplitDistance.value;

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.0, -0.1),
                radius: 1.1,
                colors: <Color>[
                  Color(0xFF0E3831),
                  Color(0xFF081C20),
                  Color(0xFF050B11),
                ],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: <Widget>[
                  // Subtle top-right Skip button
                  Positioned(
                    top: 8,
                    right: 12,
                    child: TextButton(
                      onPressed: widget.onFinished,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white54,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: Size.zero,
                      ),
                      child: const Text(
                        'SKIP ›',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),

                  // Center YouTube Originals Motion Lockup
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          // 1. Original Rounded-Square Badge with Studio Specular Sheen
                          Opacity(
                            opacity: _badgeOpacity.value,
                            child: Transform.scale(
                              scale: _badgeScale.value,
                              child: Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Container(
                                    width: 132,
                                    height: 132,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color: AppColors.emerald.withOpacity(0.22),
                                          blurRadius: 36,
                                          spreadRadius: 2,
                                        ),
                                        BoxShadow(
                                          color: AppColors.gold.withOpacity(0.18),
                                          blurRadius: 24,
                                        ),
                                      ],
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Stack(
                                      children: <Widget>[
                                        Image.memory(
                                          kOriginalBadgeBytes,
                                          width: 124,
                                          height: 124,
                                          fit: BoxFit.cover,
                                        ),
                                        // Specular studio light sweep across the badge
                                        Positioned.fill(
                                          child: FractionalTranslation(
                                            translation: Offset(_sheenSweep.value, 0),
                                            child: Transform.rotate(
                                              angle: -0.45,
                                              child: Container(
                                                width: 46,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: <Color>[
                                                      Colors.white.withOpacity(0.0),
                                                      Colors.white.withOpacity(0.24),
                                                      Colors.white.withOpacity(0.0),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // 2. Center Slogan
                          Opacity(
                            opacity: _sloganOpacity.value,
                            child: Text(
                              'UNDERSTANDING MICROBES, STRENGTHENING HEALTH',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: _sloganTracking.value,
                                color: AppColors.gold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // 3. YouTube Originals Split-Bar Aperture Reveal
                          if (_barDrawWidth.value > 0.01)
                            SizedBox(
                              width: maxBarWidth,
                              height: 76,
                              child: Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  // Emerging Title clipped strictly inside the opening between Top Bar & Bottom Bar
                                  ClipRect(
                                    child: SizedBox(
                                      width: currentBarWidth,
                                      height: apertureHeight,
                                      child: Center(
                                        child: Transform.translate(
                                          offset: Offset(0, _wordSlideY.value),
                                          child: Transform.scale(
                                            scale: _wordScale.value,
                                            child: const Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Text(
                                                  'MICROBIOLOGY & IMMUNOLOGY',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 16.5,
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: 1.3,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // TOP SPLITTING BAR
                                  Transform.translate(
                                    offset: Offset(0, -apertureHeight / 2),
                                    child: Container(
                                      width: currentBarWidth,
                                      height: 2.6,
                                      decoration: BoxDecoration(
                                        color: AppColors.gold,
                                        borderRadius: BorderRadius.circular(99),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                            color: AppColors.gold.withOpacity(0.65),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // BOTTOM SPLITTING BAR
                                  Transform.translate(
                                    offset: Offset(0, apertureHeight / 2),
                                    child: Container(
                                      width: currentBarWidth,
                                      height: 2.6,
                                      decoration: BoxDecoration(
                                        color: AppColors.gold,
                                        borderRadius: BorderRadius.circular(99),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                            color: AppColors.gold.withOpacity(0.65),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            const SizedBox(height: 76),

                          const SizedBox(height: 14),

                          // 4. Lower Institutional Lockup:
                          // "Microbiology Department" / "Faculty of Pharmacy, Beni-Suef University"
                          Opacity(
                            opacity: _subOpacity.value,
                            child: Transform.translate(
                              offset: Offset(0, _subSlideY.value),
                              child: Column(
                                children: <Widget>[
                                  const Text(
                                    'Microbiology Department',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.6,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Faculty of Pharmacy, Beni-Suef University',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.4,
                                      color: Colors.white.withOpacity(0.75),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
}

// ============================================================================
// MAIN SHELL: DOCTOR ADMIN + SUPER ADMIN (PRESERVING FULL DESIGN & EDGE HANDLE)
// ============================================================================
class MainAdminSuperShell extends StatefulWidget {
  final VoidCallback onReplayIntro;

  const MainAdminSuperShell({
    super.key,
    required this.onReplayIntro,
  });

  @override
  State<MainAdminSuperShell> createState() => _MainAdminSuperShellState();
}

class _MainAdminSuperShellState extends State<MainAdminSuperShell> {
  final PageController _pageController = PageController(initialPage: 0);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _currentPageIndex = 0; // 0 = Doctor Admin, 1 = Super Admin
  bool _isDoctorLoggedIn = false;
  bool _isSuperAdminLoggedIn = false;
  String _loggedDoctorName = '';
  String _loggedDoctorUser = '';
  String _loggedSuperUser = '';

  bool _globalLoading = false;
  String? _loadingMessage;

  bool get _isAnyLoggedIn => _isDoctorLoggedIn || _isSuperAdminLoggedIn;

  void _setGlobalLoading(bool loading, [String? msg]) {
    if (!mounted) return;
    setState(() {
      _globalLoading = loading;
      _loadingMessage = msg;
    });
  }

  Future<void> _switchToRolePage(int index, {bool showSpinner = false}) async {
    if (_currentPageIndex == index) return;
    if (showSpinner) {
      _setGlobalLoading(
        true,
        index == 1 ? 'Switching to Super Admin...' : 'Switching to Doctor Admin...',
      );
    }
    setState(() => _currentPageIndex = index);
    if (_pageController.hasClients) {
      await _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
    }
    if (showSpinner) {
      await Future<void>.delayed(const Duration(milliseconds: 260));
      _setGlobalLoading(false);
    }
  }

  void _openStudentPortalModal() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const StudentPortalModalScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSuperAdmin = _currentPageIndex == 1;

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildNavigationDrawer(isSuperAdmin),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(!_isAnyLoggedIn ? 82 : 46),
        child: AppBar(
          backgroundColor: AppColors.navyBar,
          foregroundColor: Colors.white,
          elevation: 0,
          titleSpacing: 4,
          title: Row(
            children: <Widget>[
              GestureDetector(
                onTap: widget.onReplayIntro,
                child: const OriginalBadgeLogo(size: 30, borderRadius: 7, showGoldBorder: true),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'MICROBIOLOGY & IMMUNOLOGY',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      isSuperAdmin
                          ? (_isSuperAdminLoggedIn
                              ? 'Super Admin Master • @$_loggedSuperUser'
                              : 'Faculty of Pharmacy • Super Admin Hub')
                          : (_isDoctorLoggedIn
                              ? 'Doctor Hub • $_loggedDoctorName'
                              : 'Faculty of Pharmacy • Doctor Admin Hub'),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            // Post-Login Role Switch Button in Top Bar
            if (_isAnyLoggedIn)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: OutlinedButton.icon(
                  onPressed: () => _switchToRolePage(isSuperAdmin ? 0 : 1, showSpinner: true),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isSuperAdmin ? AppColors.emeraldLight : AppColors.gold,
                    side: BorderSide(
                      color: isSuperAdmin
                          ? AppColors.emeraldLight.withOpacity(0.7)
                          : AppColors.gold.withOpacity(0.8),
                    ),
                    backgroundColor: Colors.white.withOpacity(0.06),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                  ),
                  icon: Icon(
                    isSuperAdmin ? Icons.medical_services_rounded : Icons.admin_panel_settings_rounded,
                    size: 13,
                  ),
                  label: Text(
                    isSuperAdmin ? 'Doctor Admin' : 'Super Admin',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ),
              ),

            // Small Top-Right Student Button
            Padding(
              padding: const EdgeInsets.only(right: 8, left: 2),
              child: ElevatedButton.icon(
                onPressed: _openStudentPortalModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: const Color(0xFF111827),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                ),
                icon: const Icon(Icons.school_rounded, size: 13),
                label: const Text(
                  'Students',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
          bottom: !_isAnyLoggedIn
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(36),
                  child: Container(
                    color: AppColors.navyDeep,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _switchToRolePage(0, showSpinner: true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color: !isSuperAdmin ? AppColors.emeraldDark : Colors.transparent,
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                  color: !isSuperAdmin
                                      ? AppColors.emerald.withOpacity(0.55)
                                      : Colors.transparent,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '👨‍🏫 Doctor Admin Portal',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: !isSuperAdmin ? AppColors.gold : Colors.white60,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _switchToRolePage(1, showSpinner: true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color: isSuperAdmin ? AppColors.emeraldDark : Colors.transparent,
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                  color: isSuperAdmin
                                      ? AppColors.gold.withOpacity(0.55)
                                      : Colors.transparent,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '🛡️ Super Admin (Master)',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: isSuperAdmin ? AppColors.gold : Colors.white60,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
        ),
      ),
      body: Stack(
        children: <Widget>[
          PageView(
            controller: _pageController,
            physics: _isAnyLoggedIn
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            onPageChanged: (int idx) {
              setState(() => _currentPageIndex = idx);
            },
            children: <Widget>[
              DoctorAdminWorkspace(
                onLoadingChanged: _setGlobalLoading,
                onAuthStateChanged: (bool loggedIn, String docName, String docUser) {
                  setState(() {
                    _isDoctorLoggedIn = loggedIn;
                    _loggedDoctorName = docName;
                    _loggedDoctorUser = docUser;
                  });
                },
                onSwitchToSuperAdmin: () => _switchToRolePage(1, showSpinner: true),
              ),
              SuperAdminWorkspace(
                onLoadingChanged: _setGlobalLoading,
                onAuthStateChanged: (bool loggedIn, String masterUser) {
                  setState(() {
                    _isSuperAdminLoggedIn = loggedIn;
                    _loggedSuperUser = masterUser;
                  });
                },
              ),
            ],
          ),

          // Side Edge Swipe Handle (shown before login, matching original design)
          if (!_isAnyLoggedIn)
            Positioned(
              right: isSuperAdmin ? null : 0,
              left: isSuperAdmin ? 0 : null,
              top: MediaQuery.of(context).size.height * 0.36,
              child: GestureDetector(
                onTap: () => _switchToRolePage(isSuperAdmin ? 0 : 1, showSpinner: true),
                onHorizontalDragEnd: (DragEndDetails details) {
                  if ((details.primaryVelocity ?? 0) < -150 && !isSuperAdmin) {
                    _switchToRolePage(1, showSpinner: true);
                  } else if ((details.primaryVelocity ?? 0) > 150 && isSuperAdmin) {
                    _switchToRolePage(0, showSpinner: true);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColors.navyBar.withOpacity(0.94),
                    borderRadius: BorderRadius.horizontal(
                      left: isSuperAdmin ? Radius.zero : const Radius.circular(11),
                      right: isSuperAdmin ? const Radius.circular(11) : Radius.zero,
                    ),
                    border: Border.all(color: AppColors.gold, width: 1.2),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        isSuperAdmin ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_new_rounded,
                        color: AppColors.gold,
                        size: 12,
                      ),
                      const SizedBox(height: 5),
                      RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          isSuperAdmin ? 'DOCTOR ADMIN' : 'SUPER ADMIN',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          TopFloatingCircularLoader(
            isLoading: _globalLoading,
            label: _loadingMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationDrawer(bool isSuperAdmin) {
    return Drawer(
      backgroundColor: AppColors.navyBar,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[AppColors.emeraldDark, AppColors.navyDeep],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border(bottom: BorderSide(color: AppColors.gold, width: 1.5)),
              ),
              child: const Row(
                children: <Widget>[
                  OriginalBadgeLogo(size: 48, borderRadius: 11, showGoldBorder: true),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'MICROBIOLOGY & IMMUNOLOGY',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11.5),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Faculty of Pharmacy • BSU',
                          style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              dense: true,
              selected: !isSuperAdmin,
              selectedTileColor: Colors.white10,
              leading: const Icon(Icons.medical_information_rounded, color: AppColors.emeraldLight, size: 19),
              title: const Text('Doctor Admin Portal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
              subtitle: const Text('Attendance, Excuses, Grades & Appeals', style: TextStyle(color: Colors.white60, fontSize: 10)),
              onTap: () {
                Navigator.pop(context);
                _switchToRolePage(0, showSpinner: true);
              },
            ),
            ListTile(
              dense: true,
              selected: isSuperAdmin,
              selectedTileColor: Colors.white10,
              leading: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.gold, size: 19),
              title: const Text('Super Admin Master Control', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
              subtitle: const Text('Doctors 36-Matrix, Dates, Archive & Audit', style: TextStyle(color: Colors.white60, fontSize: 10)),
              onTap: () {
                Navigator.pop(context);
                _switchToRolePage(1, showSpinner: true);
              },
            ),
            const Divider(color: Colors.white24, height: 18),
            ListTile(
              dense: true,
              leading: const Icon(Icons.school_rounded, color: AppColors.gold, size: 19),
              title: const Text('Student Portal View', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
              subtitle: const Text('Check Attendance, Grades & Submit Appeals', style: TextStyle(color: Colors.white60, fontSize: 10)),
              onTap: () {
                Navigator.pop(context);
                _openStudentPortalModal();
              },
            ),
            ListTile(
              dense: true,
              leading: const Icon(Icons.play_circle_outline_rounded, color: Colors.white70, size: 19),
              title: const Text('Replay Intro Animation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11.5)),
              onTap: () {
                Navigator.pop(context);
                widget.onReplayIntro();
              },
            ),
          ],
        ),
      ),
    );
  }
}


// ============================================================================
// DOCTOR ADMIN WORKSPACE (PRESERVING 100% OF admin.html + main_fixed.dart DESIGN
// WITH COMPACT MOBILE FONTS: STAFF HOME + ATTENDANCE SUBPAGE + GRADES SUBPAGE)
// ============================================================================
class DoctorAdminWorkspace extends StatefulWidget {
  final void Function(bool loading, [String? label]) onLoadingChanged;
  final void Function(bool loggedIn, String doctorName, String username) onAuthStateChanged;
  final VoidCallback onSwitchToSuperAdmin;

  const DoctorAdminWorkspace({
    super.key,
    required this.onLoadingChanged,
    required this.onAuthStateChanged,
    required this.onSwitchToSuperAdmin,
  });

  @override
  State<DoctorAdminWorkspace> createState() => _DoctorAdminWorkspaceState();
}

class _DoctorAdminWorkspaceState extends State<DoctorAdminWorkspace>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Subpage navigation matching admin.html: 'home', 'attendance', 'grades'
  String _staffSubpage = 'home';
  String _pendingTargetSubpage = 'attendance';

  // Doctor auth session
  final TextEditingController _userCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _newUserCtrl = TextEditingController();
  final TextEditingController _newPassCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _loggedIn = false;
  bool _isPromotedSuperAdmin = false;
  bool _showCredDrawer = false;
  String? _loginError;
  String _doctorName = '';
  String _username = '';
  String _password = '';
  List<String> _permissions = <String>[];
  JsonMap _visibilityMap = <String, dynamic>{};

  // Subpage 1: Attendance & Excuses state (matching main_fixed.dart + admin.html)
  int _attInnerTab = 0; // 0 = Medical Excuses Inspector, 1 = Direct Attendance & Roster
  String _attUni = 'Beni-Suef University';
  String _attProg = 'Clinical';
  String _attSubj = 'Basic Microbiology';
  String _attStatusFilter = 'All';
  final TextEditingController _attSearchCtrl = TextEditingController();

  List<JsonMap> _allExcuses = <JsonMap>[];
  List<JsonMap> _filteredExcuses = <JsonMap>[];
  int _selectedExcuseIdx = 0;
  int _selectedPhotoIdx = 0;
  JsonMap? _selectedStudentAttRecord;
  bool _loadingStudentAttRecord = false;
  String? _statusActionMsg;
  bool _statusActionSuccess = true;

  // Direct Attendance Single Student & Full Roster state
  final TextEditingController _dirIdCtrl = TextEditingController();
  JsonMap? _dirSingleRecord;
  final Map<int, String> _dirSingleSecEdits = <int, String>{};
  final TextEditingController _dirSingleMarksCtrl = TextEditingController();

  List<JsonMap> _rosterStudents = <JsonMap>[];
  String _rosterSheetName = '';
  final TextEditingController _rosterSearchCtrl = TextEditingController();
  final Map<String, String> _rosterDirtyMap = <String, String>{};

  // Subpage 2: Grades, Sheets & Appeals state
  int _grdInnerTab = 0; // 0 = Appeals Review, 1 = Live Grades Sheet, 2 = Visibility Switches
  String _grdUni = 'Beni-Suef University';
  String _grdProg = 'Clinical';
  String _grdSubj = 'Basic Microbiology';

  List<JsonMap> _appealsList = <JsonMap>[];
  String _appealFilter = 'All';
  final TextEditingController _appealSearchCtrl = TextEditingController();

  JsonMap? _gradesSheetData;
  bool _showAddStudentDrawer = false;
  final TextEditingController _newStIdCtrl = TextEditingController();
  final TextEditingController _newStNameCtrl = TextEditingController();
  final TextEditingController _newStPerCtrl = TextEditingController();
  final TextEditingController _newStPracCtrl = TextEditingController();
  final TextEditingController _gradesSearchCtrl = TextEditingController();
  final Map<int, JsonMap> _gradesDirtyEdits = <int, JsonMap>{};

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _newUserCtrl.dispose();
    _newPassCtrl.dispose();
    _attSearchCtrl.dispose();
    _dirIdCtrl.dispose();
    _dirSingleMarksCtrl.dispose();
    _rosterSearchCtrl.dispose();
    _appealSearchCtrl.dispose();
    _newStIdCtrl.dispose();
    _newStNameCtrl.dispose();
    _newStPerCtrl.dispose();
    _newStPracCtrl.dispose();
    _gradesSearchCtrl.dispose();
    super.dispose();
  }

  void _showToast(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? AppColors.danger : AppColors.navyBar,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(99),
          side: BorderSide(color: isError ? Colors.white24 : AppColors.gold),
        ),
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
    );
  }

  List<String> _allowedSubjectsFor(String uni, String prog) {
    final String tk = resolveTrackKey(uni, prog);
    final List<String> list = <String>[];
    for (final JsonMap s in kSubjectCatalog) {
      final String name = s['name'].toString();
      if (isDoctorCourseAllowed(_permissions, tk, name)) {
        list.add(name);
      }
    }
    return list.isEmpty ? kSubjectCatalog.map((JsonMap e) => e['name'].toString()).toList() : list;
  }

  void _navigateSubpage(String target) {
    if (target == 'superadmin') {
      widget.onSwitchToSuperAdmin();
      return;
    }
    setState(() {
      if (target == 'attendance' || target == 'grades') {
        _pendingTargetSubpage = target;
      }
      _staffSubpage = target;
    });
    if (_loggedIn) {
      if (target == 'attendance' && _allExcuses.isEmpty) {
        _loadAllExcuses();
      } else if (target == 'grades' && _appealsList.isEmpty) {
        _loadDoctorAppeals();
      }
    }
  }

  Future<void> _doDoctorLogin() async {
    final String u = _userCtrl.text.trim();
    final String p = _passCtrl.text.trim();
    if (u.isEmpty || p.isEmpty) {
      setState(() => _loginError = 'Please enter both username and password.');
      return;
    }
    setState(() => _loginError = null);
    widget.onLoadingChanged(true, 'Verifying Doctor Credentials...');
    final dynamic res = await PortalApiService.callAction('verifyDoctorLogin', <dynamic>[u, p]);
    widget.onLoadingChanged(false);

    final JsonMap map = asJsonMap(res);
    if (map['success'] == true) {
      final List<String> perms = asStringList(map['permissions']);
      setState(() {
        _loggedIn = true;
        _username = map['username']?.toString() ?? u;
        _password = p;
        _doctorName = map['doctorName']?.toString() ?? u;
        _isPromotedSuperAdmin = map['role'] == 'superadmin' ||
            map['isSuperAdmin'] == true ||
            perms.contains('ROLE_SUPER_ADMIN');
        _permissions = perms.isEmpty ? <String>['ALL'] : perms;
        _visibilityMap = asJsonMap(map['visibility']);
        _newUserCtrl.text = _username;
        _newPassCtrl.text = _password;

        final List<String> attAllowed = _allowedSubjectsFor(_attUni, _attProg);
        if (!attAllowed.contains(_attSubj)) _attSubj = attAllowed.first;
        final List<String> grdAllowed = _allowedSubjectsFor(_grdUni, _grdProg);
        if (!grdAllowed.contains(_grdSubj)) _grdSubj = grdAllowed.first;

        if (_staffSubpage == 'home') {
          _staffSubpage = _pendingTargetSubpage;
        }
      });
      widget.onAuthStateChanged(true, _doctorName, _username);
      _showToast('✅ Welcome, $_doctorName');
      await _loadAllExcuses();
    } else {
      setState(() {
        _loginError = map['message']?.toString() ?? 'Invalid doctor username or password.';
      });
    }
  }

  void _logoutDoctor() {
    setState(() {
      _loggedIn = false;
      _passCtrl.clear();
      _allExcuses.clear();
      _filteredExcuses.clear();
      _selectedStudentAttRecord = null;
      _showCredDrawer = false;
      _staffSubpage = 'home';
    });
    widget.onAuthStateChanged(false, '', '');
  }

  Future<void> _saveOwnCredentials() async {
    if (!isDoctorActionAllowed(_permissions, 'ACT_CHANGE_CRED')) {
      _showToast('Super Admin has disabled credential changes for your account.', isError: true);
      return;
    }
    final String nextU = _newUserCtrl.text.trim();
    final String nextP = _newPassCtrl.text.trim();
    if (nextU.isEmpty || nextP.isEmpty) {
      _showToast('Enter new username and password.', isError: true);
      return;
    }
    widget.onLoadingChanged(true, 'Updating Credentials...');
    final dynamic res = await PortalApiService.callAction(
      'updateOwnDoctorCredentials',
      <dynamic>[_username, _password, nextU, nextP],
    );
    widget.onLoadingChanged(false);
    final JsonMap m = asJsonMap(res);
    if (m['success'] == true) {
      setState(() {
        _username = m['newUsername']?.toString() ?? nextU;
        _password = m['newPassword']?.toString() ?? nextP;
        _showCredDrawer = false;
      });
      widget.onAuthStateChanged(true, _doctorName, _username);
      _showToast('✅ Credentials updated successfully!');
    } else {
      _showToast(m['message']?.toString() ?? 'Could not update credentials.', isError: true);
    }
  }

  // ==========================================================================
  // ATTENDANCE & EXCUSES METHODS (MATCHING main_fixed.dart + admin.html)
  // ==========================================================================
  Future<void> _loadAllExcuses() async {
    widget.onLoadingChanged(true, 'Syncing Excuse Requests...');
    final dynamic res = await PortalApiService.callAction('getStudents');
    widget.onLoadingChanged(false);
    if (res is List) {
      setState(() {
        _allExcuses = asJsonMapList(res);
      });
      _applyExcuseFilters();
    }
  }

  void _applyExcuseFilters() {
    final String q = _attSearchCtrl.text.trim().toLowerCase();
    final bool filterBsnu = _attUni.toLowerCase().contains('national') || _attUni.toLowerCase().contains('bsnu');
    final bool filterClin = _attProg.toLowerCase().contains('clinical');

    final List<JsonMap> list = _allExcuses.where((JsonMap s) {
      final String u = (s['university'] ?? '').toString().toLowerCase();
      final String p = (s['program'] ?? '').toString().toLowerCase();
      final String subj = (s['subject'] ?? '').toString();
      final String st = (s['status'] ?? 'Pending').toString();

      final bool isItemBsnu = u.contains('national') || u.contains('bsnu');
      final bool isItemClin = p.contains('clinical');
      if (isItemBsnu != filterBsnu) return false;
      if (isItemClin != filterClin) return false;
      if (subj.toLowerCase() != _attSubj.toLowerCase()) return false;
      if (_attStatusFilter != 'All' && st.toLowerCase() != _attStatusFilter.toLowerCase()) return false;

      if (q.isNotEmpty) {
        final String name = (s['name'] ?? '').toString().toLowerCase();
        final String sid = (s['studentId'] ?? '').toString().toLowerCase();
        if (!name.contains(q) && !sid.contains(q)) return false;
      }
      return true;
    }).toList();

    setState(() {
      _filteredExcuses = list;
      _selectedExcuseIdx = 0;
      _selectedPhotoIdx = 0;
      _statusActionMsg = null;
    });

    if (_filteredExcuses.isNotEmpty) {
      _loadAttendanceForSelectedStudent(_filteredExcuses[0]);
    } else {
      setState(() => _selectedStudentAttRecord = null);
    }
  }

  Future<void> _loadAttendanceForSelectedStudent(JsonMap student) async {
    setState(() {
      _loadingStudentAttRecord = true;
      _selectedStudentAttRecord = null;
    });
    final dynamic res = await PortalApiService.callAction(
      'getStudentAttendanceForDoctor',
      <dynamic>[
        student['university'],
        student['program'],
        student['subject'],
        student['studentId'],
      ],
    );
    if (!mounted) return;
    setState(() {
      _loadingStudentAttRecord = false;
      _selectedStudentAttRecord = asJsonMap(res);
    });
  }

  Future<void> _changeExcuseStatus(String newStatus) async {
    if (!isDoctorActionAllowed(_permissions, 'ACT_REVIEW_EXCUSES')) {
      _showToast('Approving/Rejecting excuses is disabled for your account.', isError: true);
      return;
    }
    if (_filteredExcuses.isEmpty) return;
    final JsonMap current = _filteredExcuses[_selectedExcuseIdx];
    final int row = int.tryParse(current['row']?.toString() ?? '0') ?? 0;

    widget.onLoadingChanged(
      true,
      newStatus == 'Approved' ? 'Approving & Syncing Sheet...' : 'Rejecting Excuse...',
    );
    final dynamic res = await PortalApiService.callAction(
      'updateStatus',
      <dynamic>[row, newStatus, _doctorName, _username],
    );
    widget.onLoadingChanged(false);

    final JsonMap sync = asJsonMap(res);
    setState(() {
      current['status'] = newStatus;
      for (final JsonMap item in _allExcuses) {
        if (item['row'] == current['row']) {
          item['status'] = newStatus;
        }
      }
      _statusActionSuccess = newStatus == 'Approved';
      if (newStatus == 'Approved') {
        if (sync['updated'] == true) {
          final String secs = (sync['sections'] is List) ? (sync['sections'] as List).join(', ') : '';
          _statusActionMsg = '✅ Approved — Converted to (E) in Section $secs';
        } else {
          _statusActionMsg = '✅ Approved (${sync['note'] ?? 'Synced'})';
        }
      } else {
        _statusActionMsg = '✖ Rejected — Locked from re-submitting.';
      }
    });
    await _loadAttendanceForSelectedStudent(current);
  }

  Future<void> _lookupDirectSingleStudent() async {
    final String sid = _dirIdCtrl.text.trim();
    if (sid.isEmpty) {
      _showToast('Enter Student ID first.', isError: true);
      return;
    }
    widget.onLoadingChanged(true, 'Searching Student Attendance...');
    final dynamic res = await PortalApiService.callAction(
      'getStudentAttendanceForDoctor',
      <dynamic>[_attUni, _attProg, _attSubj, sid],
    );
    widget.onLoadingChanged(false);
    final JsonMap m = asJsonMap(res);
    if (m['found'] == true) {
      final Map<int, String> secMap = <int, String>{};
      for (final JsonMap s in asJsonMapList(m['sections'])) {
        final int n = int.tryParse(s['sectionNumber']?.toString() ?? '0') ?? 0;
        final String raw = (s['rawStatus']?.toString() ?? '').toUpperCase();
        if (n >= 1 && n <= 12) secMap[n] = (raw == 'A' || raw == 'E') ? raw : 'P';
      }
      setState(() {
        _dirSingleRecord = m;
        _dirSingleSecEdits
          ..clear()
          ..addAll(secMap);
        _dirSingleMarksCtrl.text = asJsonMap(m['stats'])['attendanceMarks']?.toString() ?? '5';
      });
    } else {
      _showToast(m['error']?.toString() ?? 'Student ID not found.', isError: true);
    }
  }

  Future<void> _saveDirectSingleStudent() async {
    if (!isDoctorActionAllowed(_permissions, 'ACT_EDIT_ATTENDANCE')) {
      _showToast('Direct attendance editing is disabled.', isError: true);
      return;
    }
    if (_dirSingleRecord == null) return;
    final Map<String, String> secs = <String, String>{};
    _dirSingleSecEdits.forEach((int k, String v) => secs[k.toString()] = v);

    widget.onLoadingChanged(true, 'Saving Student Attendance...');
    final dynamic res = await PortalApiService.callAction(
      'updateStudentAttendanceDirect',
      <dynamic>[
        <String, dynamic>{
          'isMaster': false,
          'actorUsername': _username,
          'actorPassword': _password,
          'actorDoctorName': _doctorName,
          'university': _attUni,
          'program': _attProg,
          'subject': _attSubj,
          'studentId': _dirSingleRecord!['studentId'],
          'sections': secs,
          'attendanceMarks': _dirSingleMarksCtrl.text.trim(),
        },
      ],
    );
    widget.onLoadingChanged(false);
    final JsonMap m = asJsonMap(res);
    if (m['success'] == true) {
      setState(() => _dirSingleRecord = asJsonMap(m['updatedRecord']));
      _showToast(m['message']?.toString() ?? 'Saved successfully.');
    } else {
      _showToast(m['message']?.toString() ?? 'Failed to save.', isError: true);
    }
  }

  Future<void> _loadFullRoster() async {
    widget.onLoadingChanged(true, 'Loading Subject Roster...');
    final dynamic res = await PortalApiService.callAction(
      'getSubjectAttendanceRoster',
      <dynamic>[_username, _password, false, _attUni, _attProg, _attSubj],
    );
    widget.onLoadingChanged(false);
    final JsonMap m = asJsonMap(res);
    if (m['success'] == true) {
      setState(() {
        _rosterSheetName = m['sheetName']?.toString() ?? '';
        _rosterStudents = asJsonMapList(m['students']);
        _rosterDirtyMap.clear();
      });
      _showToast('Loaded ${_rosterStudents.length} students.');
    } else {
      _showToast(m['message']?.toString() ?? 'Failed to load roster.', isError: true);
    }
  }

  Future<void> _saveBulkRoster() async {
    if (_rosterDirtyMap.isEmpty) {
      _showToast('No changes to save.', isError: true);
      return;
    }
    final List<JsonMap> changes = <JsonMap>[];
    _rosterDirtyMap.forEach((String k, String v) {
      final List<String> p = k.split('|');
      if (p.length == 2) {
        changes.add(<String, dynamic>{
          'studentId': p[0],
          'sectionNumber': int.tryParse(p[1]) ?? 1,
          'newValue': v,
        });
      }
    });
    widget.onLoadingChanged(true, 'Saving ${changes.length} updates...');
    final dynamic res = await PortalApiService.callAction(
      'saveBulkAttendanceChanges',
      <dynamic>[
        <String, dynamic>{
          'isMaster': false,
          'actorUsername': _username,
          'actorPassword': _password,
          'actorDoctorName': _doctorName,
          'university': _attUni,
          'program': _attProg,
          'subject': _attSubj,
          'changes': changes,
        },
      ],
    );
    widget.onLoadingChanged(false);
    final JsonMap m = asJsonMap(res);
    if (m['success'] == true) {
      _showToast(m['message']?.toString() ?? 'Bulk changes saved.');
      await _loadFullRoster();
    } else {
      _showToast(m['message']?.toString() ?? 'Error saving roster.', isError: true);
    }
  }

  // ==========================================================================
  // SUBPAGE 2 METHODS: GRADES, LIVE SHEETS, APPEALS & VISIBILITY
  // ==========================================================================
  bool _isCourseVisible(String trackKey, String subjNameOrKey) {
    final JsonMap? item = findSubjectByNameOrKey(subjNameOrKey);
    final String sk = item != null ? item['key'].toString() : subjNameOrKey;
    final JsonMap tMap = asJsonMap(_visibilityMap[trackKey]);
    return tMap[sk] != false;
  }

  Future<void> _toggleCourseVis(String trackKey, String subjNameOrKey, bool nextOpen) async {
    if (!isDoctorActionAllowed(_permissions, 'ACT_TOGGLE_VISIBILITY')) {
      _showToast('Course visibility switching is disabled.', isError: true);
      return;
    }
    final JsonMap? item = findSubjectByNameOrKey(subjNameOrKey);
    final String sk = item != null ? item['key'].toString() : subjNameOrKey;
    widget.onLoadingChanged(true, 'Updating Course Visibility...');
    final dynamic res = await PortalApiService.callAction(
      'toggleSingleSubjectVisibility',
      <dynamic>[_username, _password, trackKey, sk, nextOpen],
    );
    widget.onLoadingChanged(false);
    final JsonMap m = asJsonMap(res);
    if (m['success'] == true) {
      setState(() => _visibilityMap = asJsonMap(m['visibility']));
      _showToast(m['message']?.toString() ?? 'Visibility updated.');
    } else {
      _showToast(m['message']?.toString() ?? 'Error updating visibility.', isError: true);
    }
  }

  Future<void> _loadDoctorAppeals() async {
    widget.onLoadingChanged(true, 'Loading Grade Appeals...');
    final dynamic res = await PortalApiService.callAction(
      'getAppealsForDoctor',
      <dynamic>[_username, _password, _grdUni, _grdProg, _grdSubj],
    );
    widget.onLoadingChanged(false);
    final JsonMap m = asJsonMap(res);
    if (m['success'] == true) {
      setState(() => _appealsList = asJsonMapList(m['appeals']));
    } else {
      _showToast(m['message']?.toString() ?? 'Failed to load appeals.', isError: true);
    }
  }

  Future<void> _openAppealDecisionModal(JsonMap a) async {
    if (!isDoctorActionAllowed(_permissions, 'ACT_REVIEW_APPEALS')) {
      _showToast('Reviewing grade appeals is disabled.', isError: true);
      return;
    }
    String decision = (a['status']?.toString() == 'Rejected') ? 'Rejected' : 'Approved';
    final TextEditingController bPerCtrl = TextEditingController(text: a['bonusPeriodical']?.toString() ?? '0');
    final TextEditingController bPracCtrl = TextEditingController(text: a['bonusPractical']?.toString() ?? '0');
    final TextEditingController noteCtrl = TextEditingController(text: a['resultText']?.toString() ?? '');

    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext ctx, void Function(void Function()) setDlg) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.gold, width: 1.5),
              ),
              title: Text(
                '⚖️ Appeal • ${a['name']} (#${a['studentId']})',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Scope: ${a['appealType']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                    Text('Original: Per [${a['origPeriodical']}] | Prac [${a['origPractical']}]', style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                    Text('Current: Per [${a['currentPeriodical']}] | Prac [${a['currentPractical']}]', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.emeraldDark)),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Approve (+Bonus)', style: TextStyle(fontSize: 10)),
                            selected: decision == 'Approved',
                            onSelected: (_) => setDlg(() => decision = 'Approved'),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Reject', style: TextStyle(fontSize: 10)),
                            selected: decision == 'Rejected',
                            onSelected: (_) => setDlg(() => decision = 'Rejected'),
                          ),
                        ),
                      ],
                    ),
                    if (decision == 'Approved') ...<Widget>[
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: bPerCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(fontSize: 11),
                              decoration: const InputDecoration(labelText: '+Bonus Periodical'),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextField(
                              controller: bPracCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(fontSize: 11),
                              decoration: const InputDecoration(labelText: '+Bonus Practical'),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    TextField(
                      controller: noteCtrl,
                      style: const TextStyle(fontSize: 11),
                      decoration: const InputDecoration(labelText: 'Doctor Note / Result Message'),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(fontSize: 11))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldDark, foregroundColor: Colors.white),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    widget.onLoadingChanged(true, 'Syncing Appeal Decision...');
                    final dynamic res = await PortalApiService.callAction(
                      'processDoctorAppealDecision',
                      <dynamic>[
                        <String, dynamic>{
                          'username': _username,
                          'password': _password,
                          'university': _grdUni,
                          'program': _grdProg,
                          'subject': _grdSubj,
                          'row': a['row'],
                          'studentId': a['studentId'],
                          'decision': decision,
                          'bonusPeriodical': double.tryParse(bPerCtrl.text.trim()) ?? 0,
                          'bonusPractical': double.tryParse(bPracCtrl.text.trim()) ?? 0,
                          'doctorNote': noteCtrl.text.trim(),
                        },
                      ],
                    );
                    widget.onLoadingChanged(false);
                    final JsonMap m = asJsonMap(res);
                    if (m['success'] == true) {
                      _showToast('✅ Appeal reviewed & synced to grades sheet!');
                      await _loadDoctorAppeals();
                    } else {
                      _showToast(m['message']?.toString() ?? 'Failed to save appeal.', isError: true);
                    }
                  },
                  child: const Text('Save & Sync', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _loadCourseGradesSheet() async {
    widget.onLoadingChanged(true, 'Loading Live Grades Sheet...');
    final dynamic res = await PortalApiService.callAction(
      'getCourseGradesSheetForDoctor',
      <dynamic>[_username, _password, _grdUni, _grdProg, _grdSubj],
    );
    widget.onLoadingChanged(false);
    final JsonMap m = asJsonMap(res);
    if (m['success'] == true) {
      setState(() {
        _gradesSheetData = m;
        _gradesDirtyEdits.clear();
      });
    } else {
      _showToast(m['message']?.toString() ?? 'Failed to load grades sheet.', isError: true);
    }
  }

  Future<void> _saveLiveGradesSheetEdits() async {
    if (_gradesDirtyEdits.isEmpty) {
      _showToast('No modified grade rows to save.', isError: true);
      return;
    }
    widget.onLoadingChanged(true, 'Saving ${_gradesDirtyEdits.length} Student Grade(s)...');
    final dynamic res = await PortalApiService.callAction(
      'saveStudentGradesEditsByDoctor',
      <dynamic>[
        <String, dynamic>{
          'username': _username,
          'password': _password,
          'university': _grdUni,
          'program': _grdProg,
          'subject': _grdSubj,
          'edits': _gradesDirtyEdits.values.toList(),
        },
      ],
    );
    widget.onLoadingChanged(false);
    final JsonMap m = asJsonMap(res);
    if (m['success'] == true) {
      setState(() {
        _gradesSheetData = m;
        _gradesDirtyEdits.clear();
      });
      _showToast(m['saveMessage']?.toString() ?? '✅ Grades saved!');
    } else {
      _showToast(m['message']?.toString() ?? 'Error saving grades.', isError: true);
    }
  }

  Future<void> _submitAddNewStudentToGrades() async {
    final String sid = _newStIdCtrl.text.trim();
    final String sname = _newStNameCtrl.text.trim();
    if (sid.isEmpty || sname.isEmpty) {
      _showToast('Enter Student ID and Student Name.', isError: true);
      return;
    }
    widget.onLoadingChanged(true, 'Adding Student Row...');
    final dynamic res = await PortalApiService.callAction(
      'addStudentRowToGradesSheetByDoctor',
      <dynamic>[
        <String, dynamic>{
          'username': _username,
          'password': _password,
          'university': _grdUni,
          'program': _grdProg,
          'subject': _grdSubj,
          'studentId': sid,
          'name': sname,
          'periodical': _newStPerCtrl.text.trim(),
          'practical': _newStPracCtrl.text.trim(),
        },
      ],
    );
    widget.onLoadingChanged(false);
    final JsonMap m = asJsonMap(res);
    if (m['success'] == true) {
      setState(() {
        _gradesSheetData = m;
        _newStIdCtrl.clear();
        _newStNameCtrl.clear();
        _newStPerCtrl.clear();
        _newStPracCtrl.clear();
        _showAddStudentDrawer = false;
      });
      _showToast(m['saveMessage']?.toString() ?? '✅ Student added!');
    } else {
      _showToast(m['message']?.toString() ?? 'Error adding student.', isError: true);
    }
  }

  Future<void> _openEditGradeRowModal(JsonMap st) async {
    final int rowNum = int.tryParse(st['rowNumber']?.toString() ?? '0') ?? 0;
    final JsonMap eff = _gradesDirtyEdits[rowNum] ?? st;
    final bool hasPrac = _gradesSheetData?['hasPractical'] != false;

    final TextEditingController idC = TextEditingController(text: eff['studentId']?.toString() ?? '');
    final TextEditingController nmC = TextEditingController(text: eff['name']?.toString() ?? '');
    final TextEditingController pC = TextEditingController(
      text: eff['periodical']?.toString() == '—' ? '' : (eff['periodical']?.toString() ?? ''),
    );
    final TextEditingController prC = TextEditingController(
      text: eff['practical']?.toString() == '—' ? '' : (eff['practical']?.toString() ?? ''),
    );

    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text('✏️ Edit Row #$rowNum • ${st['name']}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(controller: idC, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'Student ID')),
              const SizedBox(height: 7),
              TextField(controller: nmC, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'Student Name')),
              const SizedBox(height: 7),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: pC,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 11),
                      decoration: const InputDecoration(labelText: 'Periodical'),
                    ),
                  ),
                  if (hasPrac) ...<Widget>[
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: prC,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 11),
                        decoration: const InputDecoration(labelText: 'Practical'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(fontSize: 11))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldDark, foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                _gradesDirtyEdits[rowNum] = <String, dynamic>{
                  'rowNumber': rowNum,
                  'originalStudentId': st['studentId'],
                  'studentId': idC.text.trim(),
                  'name': nmC.text.trim(),
                  'periodical': pC.text.trim(),
                  'practical': hasPrac ? prC.text.trim() : '',
                };
              });
              Navigator.pop(ctx);
            },
            child: const Text('Queue Edit', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // BUILD DOCTOR ADMIN WORKSPACE (STICKY SUBPAGE NAVBAR + FULL DESIGN)
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: <Widget>[
        // Sticky Multi-Subpage Navigation Bar matching admin.html
        Container(
          color: AppColors.navyBar,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                _buildTopSubpageTab('home', '🏠 Staff Home'),
                const SizedBox(width: 5),
                _buildTopSubpageTab('attendance', '📋 Doctor: Attendance (الغياب والأعذار)'),
                const SizedBox(width: 5),
                _buildTopSubpageTab('grades', '📊 Doctor: Grades (الدرجات والتظلمات)'),
                const SizedBox(width: 5),
                _buildTopSubpageTab('superadmin', '🛡️ Super Admin (التحكم الأعلى)'),
              ],
            ),
          ),
        ),
        Expanded(
          child: _buildCurrentSubpageBody(),
        ),
      ],
    );
  }

  Widget _buildTopSubpageTab(String key, String label) {
    final bool active = _staffSubpage == key;
    return InkWell(
      onTap: () => _navigateSubpage(key),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(colors: <Color>[AppColors.gold, Color(0xFFEAB308)])
              : null,
          color: active ? null : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? const Color(0xFFFDE047) : Colors.white12,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: active ? AppColors.navyBar : const Color(0xFFCBD5E1),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentSubpageBody() {
    if (_staffSubpage == 'home') {
      return _buildStaffHomeLandingPage();
    }
    if (!_loggedIn) {
      return _buildSharedDoctorLoginGate();
    }
    if (_staffSubpage == 'grades') {
      return _buildDoctorGradesSubpage();
    }
    return _buildDoctorAttendanceSubpage();
  }

  // ==========================================================================
  // PAGE 1: STAFF HOME LANDING PAGE (HERO + 3 GATEWAY CARDS + 3 OVERVIEW CARDS)
  // ==========================================================================
  Widget _buildStaffHomeLandingPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Hero Header matching admin.html
          Container(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 22),
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.4, -0.5),
                radius: 1.4,
                colors: <Color>[
                  AppColors.emeraldMid,
                  AppColors.navyBar,
                ],
              ),
              border: Border(bottom: BorderSide(color: AppColors.gold, width: 2.5)),
            ),
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.gold.withOpacity(0.35)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      OriginalBadgeLogo(size: 20, borderRadius: 5, showGoldBorder: false),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'OFFICIAL FACULTY & ADMINISTRATION HUB • BSU',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: Color(0xFFFCD34D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Academic Control & Faculty Management Hub',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Dedicated multi-page academic portal for Course Coordinators (Doctors) and Super Admin across Beni-Suef University. Choose your dedicated subpage below:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10.5, color: Color(0xFFCBD5E1), height: 1.35),
                ),
                const SizedBox(height: 14),

                // Gateway Card 1: Doctor Attendance & Excuses
                _buildGatewayHeroCard(
                  emoji: '📋',
                  badge: 'Subpage 1 • غياب وأعذار',
                  title: 'Doctor Attendance & Excuses',
                  arabicSub: 'بوابة الدكاترة لإدارة الغياب العملي والأعذار الطبية',
                  desc: 'Review student medical excuse photos, inspect 12-section attendance records, approve/reject excuses (auto-syncing E/A), and edit course attendance rosters directly.',
                  btnText: 'Open Attendance Subpage (دخول صفحة الغياب) →',
                  borderColor: AppColors.emeraldLight,
                  btnColor: AppColors.emerald,
                  onTap: () => _navigateSubpage('attendance'),
                ),
                const SizedBox(height: 10),

                // Gateway Card 2: Doctor Grades & Appeals Hub
                _buildGatewayHeroCard(
                  emoji: '📊',
                  badge: 'Subpage 2 • درجات وتظلمات',
                  title: 'Doctor Grades & Appeals Hub',
                  arabicSub: 'بوابة الدكاترة لدرجات أعمال السنة والتظلمات وإعلان المقررات',
                  desc: 'Review student grade appeals, add bonus marks synced directly to sheets, explore & edit live coursework grade sheets inline, and toggle course visibility switches.',
                  btnText: 'Open Grades Subpage (دخول صفحة الدرجات) →',
                  borderColor: const Color(0xFF38BDF8),
                  btnColor: const Color(0xFF38BDF8),
                  onTap: () => _navigateSubpage('grades'),
                ),
                const SizedBox(height: 10),

                // Gateway Card 3: Super Admin Master Control
                _buildGatewayHeroCard(
                  emoji: '🛡️',
                  badge: 'Subpage 3 • التحكم الأعلى',
                  title: 'Super Admin Master Control',
                  arabicSub: 'لوحة التحكم العليا (مصفوفة الـ 36 مقرر + الغياب + الأرشفة + Audit Log)',
                  desc: 'Manage doctor accounts & the 36-course permissions matrix, promote doctors to Super Admin, edit section dates (1–12), archive/clear all 8 workbooks, and inspect the Audit Log.',
                  btnText: 'Open Super Admin Subpage (لوحة السوبر أدمن) →',
                  borderColor: AppColors.gold,
                  btnColor: AppColors.gold,
                  onTap: () => _navigateSubpage('superadmin'),
                ),
              ],
            ),
          ),

          // Department Overview 3 Cards below Hero (matching admin.html)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: <Widget>[
                _buildOverviewFeatureCard(
                  emoji: '📋',
                  title: 'Attendance & Excuses Subpage',
                  desc: 'مراجعة الأعذار الطبية المرفوعة من الطلاب بالصور، مع إمكانية التعديل المباشر لغياب أي طالب في الـ 12 سكشن أو تعديل كشف المادة بالكامل.',
                  bgTint: const Color(0xFFD1FAE5),
                ),
                const SizedBox(height: 8),
                _buildOverviewFeatureCard(
                  emoji: '📊',
                  title: 'Grades, Sheets & Appeals Subpage',
                  desc: 'فحص تظلمات درجات أعمال السنة وإضافة درجات الزيادة تلقائياً للشيت، مع مستكشف ومعدل شيت الدرجات المباشر ومفاتيح إعلان وحجب المقررات.',
                  bgTint: const Color(0xFFE0F2FE),
                ),
                const SizedBox(height: 8),
                _buildOverviewFeatureCard(
                  emoji: '🛡️',
                  title: 'Super Admin Master Subpage',
                  desc: 'التحكم المركزي في حسابات الدكاترة وترقية السوبر أدمن ومصفوفة الـ 36 مقرر، تعديل تواريخ السكاشن، أرشفة وتفريغ الشيتات الـ 8، وسجل المراقبة الموحد.',
                  bgTint: const Color(0xFFFEF3C7),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGatewayHeroCard({
    required String emoji,
    required String badge,
    required String title,
    required String arabicSub,
    required String desc,
    required String btnText,
    required Color borderColor,
    required Color btnColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[Color(0xFF0F2925), Color(0xFF0F172A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor.withOpacity(0.55), width: 1.4),
          boxShadow: <BoxShadow>[
            BoxShadow(color: Colors.black.withOpacity(0.22), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: borderColor.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor.withOpacity(0.35)),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 15)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: borderColor.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: borderColor.withOpacity(0.35)),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: borderColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const SizedBox(height: 2),
            Text(
              arabicSub,
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.gold),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: const TextStyle(fontSize: 10, color: Color(0xFFCBD5E1), height: 1.35),
            ),
            const SizedBox(height: 9),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 7),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: btnColor,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                btnText,
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewFeatureCard({
    required String emoji,
    required String title,
    required String desc,
    required Color bgTint,
  }) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: bgTint, borderRadius: BorderRadius.circular(9)),
            child: Text(emoji, style: const TextStyle(fontSize: 15)),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textMain)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 10, color: AppColors.textMuted, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SHARED DOCTOR LOGIN GATE (MATCHING admin.html & main_fixed.dart)
  // ==========================================================================
  Widget _buildSharedDoctorLoginGate() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.gold, width: 1.6),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.navyBar.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const OriginalBadgeLogo(size: 64, borderRadius: 14, showGoldBorder: true),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.emeraldSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _pendingTargetSubpage == 'grades'
                        ? '📊 DOCTOR GRADES, SHEETS & APPEALS SUBPAGE'
                        : '📋 DOCTOR ATTENDANCE & EXCUSES SUBPAGE',
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.emeraldDark,
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Course Coordinator Sign In (تسجيل دخول الدكتور)',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: AppColors.textMain),
                ),
                const SizedBox(height: 4),
                const Text(
                  'سجّل دخولك مرة واحدة لفتح كلٍ من صفحة الغياب والأعذار وصفحة الدرجات والتظلمات للمقررات المخصصة لك.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10.5, color: AppColors.textMuted, height: 1.35),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _userCtrl,
                  style: const TextStyle(fontSize: 11.5),
                  decoration: const InputDecoration(
                    labelText: 'Doctor Username (اسم المستخدم)',
                    prefixIcon: Icon(Icons.person_outline, size: 17),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passCtrl,
                  obscureText: _obscurePass,
                  style: const TextStyle(fontSize: 11.5),
                  onSubmitted: (_) => _doDoctorLogin(),
                  decoration: InputDecoration(
                    labelText: 'Password (كلمة المرور)',
                    prefixIcon: const Icon(Icons.lock_outline, size: 17),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility, size: 16),
                      onPressed: () => setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                ),
                if (_loginError != null) ...<Widget>[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.dangerSoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _loginError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.danger),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton(
                    onPressed: _doDoctorLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emeraldDark,
                      foregroundColor: AppColors.gold,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Sign In to Doctor Portal (دخول بوابة الدكتور) →',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900),
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

  // ==========================================================================
  // SUBPAGE 2: DOCTOR ATTENDANCE & MEDICAL EXCUSES PORTAL (FULL VISUAL DESIGN)
  // ==========================================================================
  Widget _buildDoctorAttendanceSubpage() {
    final List<String> allowedSubjs = _allowedSubjectsFor(_attUni, _attProg);
    if (!allowedSubjs.contains(_attSubj)) _attSubj = allowedSubjs.first;

    return RefreshIndicator(
      color: AppColors.emeraldDark,
      onRefresh: _loadAllExcuses,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Subpage Banner matching admin.html & main_fixed.dart
            _buildDoctorHeroSubpageBanner(
              titleWhite: 'Academic Attendance & Excuses ',
              titleGold: 'Doctor Dashboard',
              subtitle: 'Welcome, $_doctorName — بوابة مراجعة الأعذار الطبية وتعديل غياب الـ 12 سكشن',
              oppositeButtonLabel: '📊 الانتقال لصفحة الدرجات والتظلمات →',
              onOppositeTap: () => _navigateSubpage('grades'),
            ),

            // Overlapping Portal Shell Workspace
            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (_showCredDrawer) _buildCredentialsDrawerCard(),

                    // Filter & Sub-tab Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: AppColors.navyBar.withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _attUni,
                                  isExpanded: true,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMain),
                                  decoration: const InputDecoration(labelText: '1. University (الجامعة)'),
                                  items: const <StringDropItem>[
                                    StringDropItem(value: 'Beni-Suef University', child: Text('BSU (الحكومية)')),
                                    StringDropItem(value: 'Beni-Suef National University', child: Text('BSNU (الأهلية)')),
                                  ],
                                  onChanged: (String? v) {
                                    if (v == null) return;
                                    setState(() => _attUni = v);
                                    _applyExcuseFilters();
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _attProg,
                                  isExpanded: true,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMain),
                                  decoration: const InputDecoration(labelText: '2. Program (البرنامج)'),
                                  items: const <StringDropItem>[
                                    StringDropItem(value: 'Clinical', child: Text('PharmD Clinical')),
                                    StringDropItem(value: 'General', child: Text('PharmD General')),
                                  ],
                                  onChanged: (String? v) {
                                    if (v == null) return;
                                    setState(() => _attProg = v);
                                    _applyExcuseFilters();
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: DropdownButtonFormField<String>(
                                  value: _attSubj,
                                  isExpanded: true,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMain),
                                  decoration: const InputDecoration(labelText: '3. Permitted Subject (المقرر)'),
                                  items: allowedSubjs
                                      .map((String s) => StringDropItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis)))
                                      .toList(),
                                  onChanged: (String? v) {
                                    if (v == null) return;
                                    setState(() => _attSubj = v);
                                    _applyExcuseFilters();
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: _attSearchCtrl,
                                  onChanged: (_) => _applyExcuseFilters(),
                                  style: const TextStyle(fontSize: 11),
                                  decoration: const InputDecoration(
                                    labelText: 'Search ID/Name',
                                    prefixIcon: Icon(Icons.search, size: 15),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Sub-tabs bar matching admin.html
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: _buildSubTabButton(
                                    label: '📩 طلبات الأعذار (${_filteredExcuses.length})',
                                    active: _attInnerTab == 0,
                                    onTap: () => setState(() => _attInnerTab = 0),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: _buildSubTabButton(
                                    label: '✏️ تعديل الغياب المباشر والكشف',
                                    active: _attInnerTab == 1,
                                    onTap: () => setState(() => _attInnerTab = 1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                    if (_attInnerTab == 0)
                      _buildRichExcuseInspectorWorkspace()
                    else
                      _buildDirectAttendanceAndRosterWorkspace(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRichExcuseInspectorWorkspace() {
    if (_filteredExcuses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: <Widget>[
            const Icon(Icons.inbox_rounded, size: 32, color: AppColors.textMuted),
            const SizedBox(height: 6),
            const Text(
              'No medical excuse requests match the selected course filter.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _loadAllExcuses,
              icon: const Icon(Icons.refresh, size: 14),
              label: const Text('Sync All Excuses', style: TextStyle(fontSize: 10.5)),
            ),
          ],
        ),
      );
    }

    if (_selectedExcuseIdx >= _filteredExcuses.length) {
      _selectedExcuseIdx = 0;
    }
    final JsonMap student = _filteredExcuses[_selectedExcuseIdx];
    final List<JsonMap> files = asJsonMapList(student['files']);
    final String currentImageUrl = (files.isNotEmpty && _selectedPhotoIdx < files.length)
        ? (files[_selectedPhotoIdx]['url'] ?? '').toString()
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Horizontal Student Selector Strip (from main_fixed.dart, compact fonts)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
          decoration: const BoxDecoration(
            color: AppColors.emeraldDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Excuse Requests (${_filteredExcuses.length})',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
              ),
              Text(
                'Request ${_selectedExcuseIdx + 1} of ${_filteredExcuses.length}',
                style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800, fontSize: 10.5),
              ),
            ],
          ),
        ),
        Container(
          height: 74,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border.symmetric(vertical: BorderSide(color: AppColors.cardBorder)),
          ),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            itemCount: _filteredExcuses.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (BuildContext context, int idx) {
              final JsonMap item = _filteredExcuses[idx];
              final bool isSel = idx == _selectedExcuseIdx;
              final String stStatus = (item['status'] ?? 'Pending').toString();
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedExcuseIdx = idx;
                    _selectedPhotoIdx = 0;
                    _statusActionMsg = null;
                  });
                  _loadAttendanceForSelectedStudent(item);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 175,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: isSel ? AppColors.emeraldSoft : AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSel ? AppColors.emerald : AppColors.cardBorder,
                      width: isSel ? 1.6 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '${idx + 1}. ${item['name'] ?? ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.textMain),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'ID: ${item['studentId']}',
                            style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted, fontWeight: FontWeight.w700),
                          ),
                          _buildStatusBadge(stStatus),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Main Excuse Image & Student Details Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Medical Excuse Interactive Image Viewer
              Container(
                height: 210,
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    if (currentImageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: InteractiveViewer(
                          child: Image.network(
                            currentImageUrl,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Text('Unable to load medical image', style: TextStyle(fontSize: 11)),
                            ),
                          ),
                        ),
                      )
                    else
                      const Text('No image attached', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    if (files.length > 1) ...<Widget>[
                      Positioned(
                        left: 6,
                        child: IconButton.filled(
                          style: IconButton.styleFrom(backgroundColor: Colors.black54),
                          icon: const Icon(Icons.chevron_left_rounded, size: 18),
                          onPressed: () {
                            setState(() {
                              _selectedPhotoIdx = (_selectedPhotoIdx - 1 + files.length) % files.length;
                            });
                          },
                        ),
                      ),
                      Positioned(
                        right: 6,
                        child: IconButton.filled(
                          style: IconButton.styleFrom(backgroundColor: Colors.black54),
                          icon: const Icon(Icons.chevron_right_rounded, size: 18),
                          onPressed: () {
                            setState(() {
                              _selectedPhotoIdx = (_selectedPhotoIdx + 1) % files.length;
                            });
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Image ${_selectedPhotoIdx + 1} of ${files.length}',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                  ),
                  if (currentImageUrl.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => launchUrl(Uri.parse(currentImageUrl), mode: LaunchMode.externalApplication),
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), minimumSize: Size.zero),
                      icon: const Icon(Icons.open_in_new_rounded, size: 13),
                      label: const Text('Open Full Resolution', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
              const Divider(height: 14),

              // Student Metadata Lines
              Text(
                (student['name'] ?? '').toString(),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textMain),
              ),
              const SizedBox(height: 6),
              _buildInfoLine('University', student['university']),
              _buildInfoLine('Program', student['program']),
              _buildInfoLine('Subject', student['subject']),
              _buildInfoLine('Student ID', student['studentId']),
              _buildInfoLine('Excused Section', student['sectionRaw'], highlight: true),
              _buildInfoLine('Submission Date', student['timestamp']),
              _buildInfoLine('Comment', (student['comment'] ?? '').toString().isEmpty ? '—' : student['comment']),
              _buildInfoLine('Current Status', student['status']),

              const SizedBox(height: 10),

              // Full 12-Section Attendance Record Card
              _buildDoctor12SectionAttendanceCard(student),

              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _changeExcuseStatus('Approved'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Approve (E)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _changeExcuseStatus('Rejected'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: const Text('Reject (A)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5)),
                    ),
                  ),
                ],
              ),
              if (_statusActionMsg != null) ...<Widget>[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _statusActionSuccess ? AppColors.emeraldSoft : AppColors.dangerSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusActionMsg!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      color: _statusActionSuccess ? AppColors.emeraldDark : AppColors.danger,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDoctor12SectionAttendanceCard(JsonMap student) {
    if (_loadingStudentAttRecord) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.emeraldSoft, borderRadius: BorderRadius.circular(11)),
        child: const Center(
          child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.2)),
        ),
      );
    }

    final JsonMap? rec = _selectedStudentAttRecord;
    if (rec == null || rec['found'] != true) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: const Text(
          'Student Attendance Record Not Found in Subject Sheet.',
          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textMuted),
        ),
      );
    }

    final JsonMap stats = asJsonMap(rec['stats']);
    final List<JsonMap> sections = asJsonMapList(rec['sections']);
    final String targetSec = (student['sectionNumber'] ?? '').toString();

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA7F3D0), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'Student Full Attendance (12 Sections)',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF065F46)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(999)),
                child: Text(
                  'Missed: ${stats['totalAbsence'] ?? 0}',
                  style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFF166534)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              _buildMiniStatCard('Unexcused (A)', '${stats['unexcusedAbsence'] ?? 0}', AppColors.danger),
              const SizedBox(width: 6),
              _buildMiniStatCard('Excused (E)', '${stats['excusedAbsence'] ?? 0}', AppColors.emerald),
              const SizedBox(width: 6),
              _buildMiniStatCard('Score', '${stats['attendanceMarks'] ?? 5} / 5', AppColors.goldDark),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sections.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
              childAspectRatio: 1.3,
            ),
            itemBuilder: (BuildContext context, int i) {
              final JsonMap s = sections[i];
              final String secNum = (s['sectionNumber'] ?? '').toString();
              final String raw = (s['rawStatus'] ?? '').toString().toUpperCase();
              final bool isTarget = secNum == targetSec;

              Color badgeBg = AppColors.emeraldSoft;
              Color badgeFg = AppColors.emeraldDark;
              String label = 'P';
              if (raw == 'A') {
                badgeBg = AppColors.dangerSoft;
                badgeFg = AppColors.danger;
                label = 'A';
              } else if (raw == 'E') {
                badgeBg = const Color(0xFFFEF3C7);
                badgeFg = AppColors.goldDark;
                label = 'E';
              }

              return Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isTarget ? const Color(0xFFFEFCE8) : Colors.white,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: isTarget ? AppColors.gold : AppColors.cardBorder,
                    width: isTarget ? 1.6 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Sec $secNum', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800)),
                    Text(
                      (s['sectionDate'] ?? '').toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 7.5, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 1),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0.5),
                      decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(4)),
                      child: Text(label, style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: badgeFg)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDirectAttendanceAndRosterWorkspace() {
    final String q = _rosterSearchCtrl.text.trim().toLowerCase();
    final List<JsonMap> filteredRoster = _rosterStudents.where((JsonMap s) {
      if (q.isEmpty) return true;
      return (s['studentId']?.toString() ?? '').toLowerCase().contains(q) ||
          (s['studentName']?.toString() ?? '').toLowerCase().contains(q);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            '✏️ تعديل الغياب المباشر لطالب أو عرض كشف المادة بالكامل',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textMain),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _dirIdCtrl,
                  style: const TextStyle(fontSize: 11),
                  onSubmitted: (_) => _lookupDirectSingleStudent(),
                  decoration: const InputDecoration(
                    labelText: 'Quick Student ID Lookup',
                    prefixIcon: Icon(Icons.badge_outlined, size: 15),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              ElevatedButton(
                onPressed: _lookupDirectSingleStudent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emeraldDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                child: const Text('🔍 بحث عن طالب', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 6),
              ElevatedButton(
                onPressed: _loadFullRoster,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.navyBar,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                child: const Text('📋 كشف المادة كامل', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900)),
              ),
            ],
          ),

          if (_dirSingleRecord != null) ...<Widget>[
            const Divider(height: 16),
            Text(
              '${_dirSingleRecord!['studentName']} (#${_dirSingleRecord!['studentId']})',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: List<Widget>.generate(12, (int i) {
                final int sec = i + 1;
                final String val = _dirSingleSecEdits[sec] ?? 'P';
                final Color c = val == 'A' ? AppColors.danger : (val == 'E' ? AppColors.goldDark : AppColors.emeraldDark);
                return InkWell(
                  onTap: () {
                    setState(() {
                      _dirSingleSecEdits[sec] = val == 'P' ? 'A' : (val == 'A' ? 'E' : 'P');
                    });
                  },
                  child: Container(
                    width: 60,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: c.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: c),
                    ),
                    child: Column(
                      children: <Widget>[
                        Text('Sec $sec', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
                        Text(val, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: c)),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 110,
                  child: TextField(
                    controller: _dirSingleMarksCtrl,
                    style: const TextStyle(fontSize: 11),
                    decoration: const InputDecoration(labelText: 'Marks (/5)'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveDirectSingleStudent,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldDark, foregroundColor: Colors.white),
                    icon: const Icon(Icons.save, size: 14),
                    label: const Text('💾 حفظ تعديل الطالب', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ],

          if (_rosterStudents.isNotEmpty) ...<Widget>[
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Roster: $_rosterSheetName (${filteredRoster.length})',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
                if (_rosterDirtyMap.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: _saveBulkRoster,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.navyBar),
                    icon: const Icon(Icons.save, size: 13),
                    label: Text('💾 حفظ (${_rosterDirtyMap.length})', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900)),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _rosterSearchCtrl,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 11),
              decoration: const InputDecoration(
                labelText: 'Filter Roster by Name or ID (Tap cell to cycle P/A/E)',
                prefixIcon: Icon(Icons.search, size: 15),
              ),
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 28,
                dataRowMinHeight: 28,
                dataRowMaxHeight: 32,
                headingRowColor: WidgetStateProperty.all(AppColors.navyBar),
                columnSpacing: 8,
                columns: <DataColumn>[
                  const DataColumn(label: Text('ID', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white))),
                  const DataColumn(label: Text('Student Name', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white))),
                  ...List<DataColumn>.generate(
                    12,
                    (int i) => DataColumn(label: Text('S${i + 1}', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.gold))),
                  ),
                ],
                rows: filteredRoster.take(120).map((JsonMap st) {
                  final String sid = st['studentId']?.toString() ?? '';
                  final JsonMap secs = asJsonMap(st['sections']);
                  return DataRow(
                    cells: <DataCell>[
                      DataCell(Text(sid, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700))),
                      DataCell(SizedBox(width: 120, child: Text(st['studentName']?.toString() ?? '', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10)))),
                      ...List<DataCell>.generate(12, (int i) {
                        final int sNum = i + 1;
                        final String k = '$sid|$sNum';
                        final String v = _rosterDirtyMap[k] ?? (secs[sNum.toString()]?.toString() ?? 'P');
                        final Color c = v == 'A' ? AppColors.danger : (v == 'E' ? AppColors.goldDark : AppColors.emeraldDark);
                        return DataCell(
                          InkWell(
                            onTap: () {
                              setState(() {
                                _rosterDirtyMap[k] = v == 'P' ? 'A' : (v == 'A' ? 'E' : 'P');
                              });
                            },
                            child: Container(
                              width: 22,
                              height: 20,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: c.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: c),
                              ),
                              child: Text(v, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: c)),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================================================
  // SUBPAGE 3: DOCTOR COURSEWORK GRADES, SHEETS & APPEALS PORTAL
  // ==========================================================================
  Widget _buildDoctorGradesSubpage() {
    final List<String> allowedSubjs = _allowedSubjectsFor(_grdUni, _grdProg);
    if (!allowedSubjs.contains(_grdSubj)) _grdSubj = allowedSubjs.first;
    final String tk = resolveTrackKey(_grdUni, _grdProg);
    final bool isCourseOpen = _isCourseVisible(tk, _grdSubj);

    return RefreshIndicator(
      color: AppColors.emeraldDark,
      onRefresh: () async {
        if (_grdInnerTab == 0) {
          await _loadDoctorAppeals();
        } else if (_grdInnerTab == 1) {
          await _loadCourseGradesSheet();
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildDoctorHeroSubpageBanner(
              titleWhite: 'Coursework Grades & Appeals ',
              titleGold: 'Doctor Hub',
              subtitle: 'Welcome, $_doctorName — بوابة مراجعة التظلمات وإضافة البونص وتعديل شيت الدرجات وإعلان المقررات',
              oppositeButtonLabel: '← 📋 الانتقال لصفحة الغياب والأعذار',
              onOppositeTap: () => _navigateSubpage('attendance'),
            ),

            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (_showCredDrawer) _buildCredentialsDrawerCard(),

                    // Unified Course Selector + Instant Course Visibility Bar
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _grdUni,
                                  isExpanded: true,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMain),
                                  decoration: const InputDecoration(labelText: '1. University (الجامعة)'),
                                  items: const <StringDropItem>[
                                    StringDropItem(value: 'Beni-Suef University', child: Text('BSU (الحكومية)')),
                                    StringDropItem(value: 'Beni-Suef National University', child: Text('BSNU (الأهلية)')),
                                  ],
                                  onChanged: (String? v) {
                                    if (v != null) setState(() => _grdUni = v);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _grdProg,
                                  isExpanded: true,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMain),
                                  decoration: const InputDecoration(labelText: '2. Program (البرنامج)'),
                                  items: const <StringDropItem>[
                                    StringDropItem(value: 'Clinical', child: Text('PharmD Clinical')),
                                    StringDropItem(value: 'General', child: Text('PharmD General')),
                                  ],
                                  onChanged: (String? v) {
                                    if (v != null) setState(() => _grdProg = v);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _grdSubj,
                                  isExpanded: true,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMain),
                                  decoration: const InputDecoration(labelText: '3. Permitted Course (المقرر)'),
                                  items: allowedSubjs
                                      .map((String s) => StringDropItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis)))
                                      .toList(),
                                  onChanged: (String? v) {
                                    if (v != null) setState(() => _grdSubj = v);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => _toggleCourseVis(tk, _grdSubj, !isCourseOpen),
                                borderRadius: BorderRadius.circular(9),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: isCourseOpen ? AppColors.emeraldSoft : AppColors.dangerSoft,
                                    borderRadius: BorderRadius.circular(9),
                                    border: Border.all(color: isCourseOpen ? AppColors.emerald : AppColors.danger),
                                  ),
                                  child: Text(
                                    isCourseOpen ? '🟢 معلنة (Announced)' : '🔒 محجوبة (Hidden)',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: isCourseOpen ? AppColors.emeraldDark : AppColors.danger,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: _buildSubTabButton(
                                    label: '⚖️ 1. التظلمات (${_appealsList.length})',
                                    active: _grdInnerTab == 0,
                                    onTap: () {
                                      setState(() => _grdInnerTab = 0);
                                      _loadDoctorAppeals();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: _buildSubTabButton(
                                    label: '📊 2. شيت الدرجات',
                                    active: _grdInnerTab == 1,
                                    onTap: () {
                                      setState(() => _grdInnerTab = 1);
                                      _loadCourseGradesSheet();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: _buildSubTabButton(
                                    label: '🔓 3. إعلان وحجب المقررات',
                                    active: _grdInnerTab == 2,
                                    onTap: () => setState(() => _grdInnerTab = 2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                    if (_grdInnerTab == 0)
                      _buildGradesAppealsSection()
                    else if (_grdInnerTab == 1)
                      _buildGradesLiveSheetSection()
                    else
                      _buildGradesVisibilitySwitchesSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradesAppealsSection() {
    final String q = _appealSearchCtrl.text.trim().toLowerCase();
    final List<JsonMap> list = _appealsList.where((JsonMap a) {
      final String st = (a['status'] ?? 'Pending').toString();
      if (_appealFilter != 'All' && st.toLowerCase() != _appealFilter.toLowerCase()) return false;
      if (q.isNotEmpty) {
        return (a['name']?.toString() ?? '').toLowerCase().contains(q) ||
            (a['studentId']?.toString() ?? '').toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _appealSearchCtrl,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(fontSize: 11),
                  decoration: const InputDecoration(
                    labelText: 'Search Appeal by Name / ID',
                    prefixIcon: Icon(Icons.search, size: 15),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              ElevatedButton.icon(
                onPressed: _loadDoctorAppeals,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldDark, foregroundColor: Colors.white),
                icon: const Icon(Icons.sync, size: 14),
                label: const Text('تحميل التظلمات', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                'Tap "تحميل التظلمات" or no grade appeals submitted for this course.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            )
          else
            ...list.map((JsonMap a) {
              final String st = (a['status'] ?? 'Pending').toString();
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            '${a['name']} (#${a['studentId']})',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                          ),
                        ),
                        _buildStatusBadge(st),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text('Appeal Type: ${a['appealType']} • ${a['timestamp']}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    Text(
                      'Orig: Per [${a['origPeriodical']}] / Prac [${a['origPractical']}]  →  Live: Per [${a['currentPeriodical']}] / Prac [${a['currentPractical']}]',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.emeraldDark),
                    ),
                    if ((a['comment']?.toString() ?? '').isNotEmpty)
                      Text('Comment: "${a['comment']}"', style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic)),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      height: 28,
                      child: ElevatedButton.icon(
                        onPressed: () => _openAppealDecisionModal(a),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.navyBar, foregroundColor: AppColors.gold),
                        icon: const Icon(Icons.rate_review_outlined, size: 13),
                        label: const Text('مراجعة التظلم وإضافة درجات البونص', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildGradesLiveSheetSection() {
    final List<JsonMap> students = _gradesSheetData != null ? asJsonMapList(_gradesSheetData!['students']) : <JsonMap>[];
    final JsonMap stats = _gradesSheetData != null ? asJsonMap(_gradesSheetData!['stats']) : <String, dynamic>{};
    final bool hasPrac = _gradesSheetData?['hasPractical'] != false;
    final String q = _gradesSearchCtrl.text.trim().toLowerCase();
    final List<JsonMap> filtered = students.where((JsonMap s) {
      if (q.isEmpty) return true;
      return (s['studentId']?.toString() ?? '').toLowerCase().contains(q) ||
          (s['name']?.toString() ?? '').toLowerCase().contains(q);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: _loadCourseGradesSheet,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldDark, foregroundColor: Colors.white),
                icon: const Icon(Icons.table_view, size: 13),
                label: const Text('📥 تحميل شيت الدرجات', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800)),
              ),
              OutlinedButton.icon(
                onPressed: () => setState(() => _showAddStudentDrawer = !_showAddStudentDrawer),
                icon: const Icon(Icons.person_add_alt_1, size: 13),
                label: const Text('➕ إضافة طالب جديد', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800)),
              ),
              if (_gradesDirtyEdits.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: _saveLiveGradesSheetEdits,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.navyBar),
                  icon: const Icon(Icons.save, size: 13),
                  label: Text('💾 حفظ التعديلات (${_gradesDirtyEdits.length})', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900)),
                ),
            ],
          ),

          if (_showAddStudentDrawer) ...<Widget>[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.goldSoft.withOpacity(0.55),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: AppColors.gold),
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(controller: _newStIdCtrl, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'Student ID')),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 2,
                        child: TextField(controller: _newStNameCtrl, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'Student Name')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(controller: _newStPerCtrl, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'Periodical')),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextField(controller: _newStPracCtrl, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'Practical')),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        onPressed: _submitAddNewStudentToGrades,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldDark, foregroundColor: Colors.white),
                        child: const Text('✔ إضافة وحفظ', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          if (_gradesSheetData != null) ...<Widget>[
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                _buildMiniStatCard('Students', '${stats['totalStudents'] ?? 0}', AppColors.navyBar),
                const SizedBox(width: 5),
                _buildMiniStatCard('Avg Per.', '${stats['avgPeriodical'] ?? 0}', AppColors.emeraldDark),
                const SizedBox(width: 5),
                _buildMiniStatCard('Avg Prac.', '${stats['avgPractical'] ?? 0}', AppColors.sky),
                const SizedBox(width: 5),
                _buildMiniStatCard('Max Tot.', '${stats['maxTotal'] ?? 0}', AppColors.goldDark),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _gradesSearchCtrl,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 11),
              decoration: const InputDecoration(
                labelText: 'Search Student in Live Grades Sheet (Tap row to edit)',
                prefixIcon: Icon(Icons.search, size: 15),
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 28,
                dataRowMinHeight: 28,
                dataRowMaxHeight: 32,
                headingRowColor: WidgetStateProperty.all(AppColors.navyBar),
                columnSpacing: 12,
                columns: <DataColumn>[
                  const DataColumn(label: Text('#', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white))),
                  const DataColumn(label: Text('ID', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.gold))),
                  const DataColumn(label: Text('Student Name', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white))),
                  const DataColumn(label: Text('Periodical', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white))),
                  if (hasPrac)
                    const DataColumn(label: Text('Practical', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white))),
                  const DataColumn(label: Text('Total', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.gold))),
                ],
                rows: filtered.take(150).map((JsonMap st) {
                  final int rNum = int.tryParse(st['rowNumber']?.toString() ?? '0') ?? 0;
                  final JsonMap eff = _gradesDirtyEdits[rNum] ?? st;
                  return DataRow(
                    color: WidgetStateProperty.all(_gradesDirtyEdits.containsKey(rNum) ? AppColors.goldSoft : Colors.transparent),
                    cells: <DataCell>[
                      DataCell(Text('$rNum', style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted))),
                      DataCell(Text('${eff['studentId']}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)), onTap: () => _openEditGradeRowModal(st)),
                      DataCell(SizedBox(width: 135, child: Text('${eff['name']}', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10))), onTap: () => _openEditGradeRowModal(st)),
                      DataCell(Text('${eff['periodical']}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)), onTap: () => _openEditGradeRowModal(st)),
                      if (hasPrac)
                        DataCell(Text('${eff['practical']}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)), onTap: () => _openEditGradeRowModal(st)),
                      DataCell(Text('${st['total']}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.emeraldDark))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGradesVisibilitySwitchesSection() {
    return Column(
      children: kTrackKeys.map((String tk) {
        final List<JsonMap> allowed = kSubjectCatalog
            .where((JsonMap s) => isDoctorCourseAllowed(_permissions, tk, s['name'].toString()))
            .toList();
        if (allowed.isEmpty) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('📍 ${kTrackLabels[tk] ?? tk}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: AppColors.navyBar)),
              const Divider(height: 10),
              ...allowed.map((JsonMap s) {
                final String sk = s['key'].toString();
                final bool open = _isCourseVisible(tk, sk);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(s['name'].toString(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                            Text(
                              open ? '● معلنة للطلاب (Announced)' : '● محجوبة عن الطلاب (Hidden)',
                              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: open ? AppColors.emeraldDark : AppColors.danger),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: open,
                        activeColor: AppColors.emerald,
                        onChanged: (bool v) => _toggleCourseVis(tk, sk, v),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ==========================================================================
  // SHARED DOCTOR BANNER, CREDENTIALS DRAWER & HELPER WIDGETS
  // ==========================================================================
  Widget _buildDoctorHeroSubpageBanner({
    required String titleWhite,
    required String titleGold,
    required String subtitle,
    required String oppositeButtonLabel,
    required VoidCallback onOppositeTap,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 34),
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.6, -0.4),
          radius: 1.4,
          colors: <Color>[AppColors.emeraldMid, AppColors.emeraldDark, AppColors.navyDeep],
        ),
        border: Border(bottom: BorderSide(color: AppColors.gold, width: 2.5)),
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              InkWell(
                onTap: () => _navigateSubpage('home'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Text('← Staff Home', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ),
              Wrap(
                spacing: 5,
                children: <Widget>[
                  InkWell(
                    onTap: onOppositeTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(8)),
                      child: Text(oppositeButtonLabel, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppColors.navyBar)),
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => _showCredDrawer = !_showCredDrawer),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                      ),
                      child: const Text('⚙️ Account', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.gold)),
                    ),
                  ),
                  InkWell(
                    onTap: _logoutDoctor,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('🚪 Sign Out', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
              children: <TextSpan>[
                TextSpan(text: titleWhite),
                TextSpan(text: titleGold, style: const TextStyle(color: AppColors.gold)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Color(0xFFCBD5E1)),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialsDrawerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold, width: 1.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('⚙️ Update Your Doctor Credentials', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(controller: _newUserCtrl, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'New Username')),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(controller: _newPassCtrl, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'New Password')),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton(
              onPressed: _saveOwnCredentials,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldDark, foregroundColor: Colors.white),
              child: const Text('Save Credentials ✔', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTabButton({required String label, required bool active, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.navyBar : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: active ? AppColors.gold : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final Color bg = status == 'Approved'
        ? AppColors.emeraldSoft
        : (status == 'Rejected' ? AppColors.dangerSoft : AppColors.goldSoft);
    final Color fg = status == 'Approved'
        ? AppColors.emeraldDark
        : (status == 'Rejected' ? AppColors.danger : AppColors.goldDark);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: fg)),
    );
  }

  Widget _buildInfoLine(String label, dynamic value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 105,
            child: Text('$label:', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          ),
          Expanded(
            child: Text(
              (value ?? '—').toString(),
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: highlight ? AppColors.emeraldDark : AppColors.textMain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatCard(String label, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: <Widget>[
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
            const SizedBox(height: 1),
            Text(val, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: color)),
          ],
        ),
      ),
    );
  }
}


// ============================================================================
// SUPER ADMIN MASTER WORKSPACE (PRESERVING FULL admin.html DESIGN + PROMOTE
// DOCTOR TO SUPER ADMIN BUTTON + 36-MATRIX + DATES 1-12 + ARCHIVE 8 + AUDIT)
// ============================================================================
class SuperAdminWorkspace extends StatefulWidget {
  final void Function(bool loading, [String? label]) onLoadingChanged;
  final void Function(bool loggedIn, String masterUser) onAuthStateChanged;

  const SuperAdminWorkspace({
    super.key,
    required this.onLoadingChanged,
    required this.onAuthStateChanged,
  });

  @override
  State<SuperAdminWorkspace> createState() => _SuperAdminWorkspaceState();
}

class _SuperAdminWorkspaceState extends State<SuperAdminWorkspace>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _masterUserCtrl = TextEditingController();
  final TextEditingController _masterPassCtrl = TextEditingController();
  bool _obscureMasterPass = true;
  bool _masterLoggedIn = false;
  String? _loginError;
  String _masterUser = '';
  String _masterPass = '';

  // 0 = Doctors & 36-Matrix, 1 = Attendance & Dates 1-12, 2 = Archive 8 Sheets, 3 = Audit Log
  int _masterTab = 0;

  List<JsonMap> _doctorsList = <JsonMap>[];
  List<JsonMap> _sheetsOverview = <JsonMap>[];
  List<JsonMap> _archivesHistory = <JsonMap>[];
  List<JsonMap> _auditLogs = <JsonMap>[];

  // Tab 0: Create / Edit Doctor Account + Make Super Admin Toggle
  final TextEditingController _docNameCtrl = TextEditingController();
  final TextEditingController _docUserCtrl = TextEditingController();
  final TextEditingController _docPassCtrl = TextEditingController();
  bool _docIsSuperAdmin = false;
  final Set<String> _selectedCoursePerms = <String>{...buildAll36CoursePerms()};
  final Set<String> _selectedActionPerms = <String>{...buildDefaultActionPerms()};

  // Tab 1: Direct Attendance & Section Dates 1-12
  String _mAttUni = 'BSNU';
  String _mAttProg = 'Clinical';
  String _mAttSubj = 'Basic Microbiology';
  String _mRosterSheetName = '';
  List<JsonMap> _mRosterStudents = <JsonMap>[];
  final Map<int, TextEditingController> _secDateCtrls = <int, TextEditingController>{
    for (int s = 1; s <= 12; s++) s: TextEditingController(text: kDefaultSectionDates[s] ?? ''),
  };
  final TextEditingController _mRosterSearchCtrl = TextEditingController();
  final Map<String, String> _mRosterDirtyMap = <String, String>{};

  // Tab 2: Archive & Clear 8 Workbooks
  final Set<String> _selectedArchiveKeys = <String>{};

  // Tab 3: Audit Log
  String _auditCatFilter = 'ALL';
  final TextEditingController _auditSearchCtrl = TextEditingController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _masterUserCtrl.dispose();
    _masterPassCtrl.dispose();
    _docNameCtrl.dispose();
    _docUserCtrl.dispose();
    _docPassCtrl.dispose();
    for (final TextEditingController c in _secDateCtrls.values) {
      c.dispose();
    }
    _mRosterSearchCtrl.dispose();
    _auditSearchCtrl.dispose();
    super.dispose();
  }

  void _showToast(String text, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? AppColors.danger : AppColors.navyBar,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(99),
          side: BorderSide(color: isError ? Colors.white24 : AppColors.gold),
        ),
        content: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _handleMasterLogin() async {
    final String u = _masterUserCtrl.text.trim();
    final String p = _masterPassCtrl.text.trim();
    if (u.isEmpty || p.isEmpty) {
      setState(() => _loginError = 'Enter Master Username and Password.');
      return;
    }
    setState(() => _loginError = null);
    widget.onLoadingChanged(true, 'Verifying Master Credentials...');
    final dynamic res = await PortalApiService.callAction('verifySuperAdminLogin', <dynamic>[u, p]);
    widget.onLoadingChanged(false);

    final JsonMap map = asJsonMap(res);
    if (map['success'] == true) {
      setState(() {
        _masterLoggedIn = true;
        _masterUser = u;
        _masterPass = p;
        _doctorsList = asJsonMapList(map['doctors']);
        _auditLogs = asJsonMapList(map['auditLogs']);
        _sheetsOverview = asJsonMapList(map['sheetsOverview']);
        _archivesHistory = asJsonMapList(map['archivesHistory']);
      });
      widget.onAuthStateChanged(true, u);
      _showToast('🛡️ Super Admin Master Control Unlocked!');
    } else {
      setState(() {
        _loginError = map['message']?.toString() ?? 'Access Denied: Invalid Super Admin credentials.';
      });
    }
  }

  void _handleMasterLogout() {
    setState(() {
      _masterLoggedIn = false;
      _masterUser = '';
      _masterPass = '';
      _masterPassCtrl.clear();
      _doctorsList.clear();
      _auditLogs.clear();
    });
    widget.onAuthStateChanged(false, '');
  }

  Future<void> _refreshMasterAllData() async {
    if (!_masterLoggedIn) return;
    widget.onLoadingChanged(true, 'Refreshing Master Data...');
    final dynamic res = await PortalApiService.callAction('verifySuperAdminLogin', <dynamic>[_masterUser, _masterPass]);
    widget.onLoadingChanged(false);
    final JsonMap map = asJsonMap(res);
    if (map['success'] == true) {
      setState(() {
        _doctorsList = asJsonMapList(map['doctors']);
        _auditLogs = asJsonMapList(map['auditLogs']);
        _sheetsOverview = asJsonMapList(map['sheetsOverview']);
        _archivesHistory = asJsonMapList(map['archivesHistory']);
      });
      _showToast('✅ All Master Data Refreshed!');
    }
  }

  void _resetDoctorForm() {
    setState(() {
      _docNameCtrl.clear();
      _docUserCtrl.clear();
      _docPassCtrl.clear();
      _docIsSuperAdmin = false;
      _selectedCoursePerms
        ..clear()
        ..addAll(buildAll36CoursePerms());
      _selectedActionPerms
        ..clear()
        ..addAll(buildDefaultActionPerms());
    });
  }

  void _loadDoctorIntoEditor(JsonMap doc) {
    final List<String> perms = asStringList(doc['permissions']);
    final bool isSuper = doc['isSuperAdmin'] == true || perms.contains('ROLE_SUPER_ADMIN');
    final Set<String> cPerms = <String>{};
    final Set<String> aPerms = <String>{};
    if (perms.contains('ALL') || isSuper) {
      cPerms.addAll(buildAll36CoursePerms());
    }
    for (final String p in perms) {
      if (p.contains('__')) {
        cPerms.add(p);
      } else if (p.startsWith('ACT_')) {
        aPerms.add(p);
      }
    }
    if (aPerms.isEmpty) {
      aPerms.addAll(buildDefaultActionPerms());
    }
    setState(() {
      _docNameCtrl.text = doc['doctorName']?.toString() ?? '';
      _docUserCtrl.text = doc['username']?.toString() ?? '';
      _docPassCtrl.text = doc['password']?.toString() ?? '';
      _docIsSuperAdmin = isSuper;
      _selectedCoursePerms
        ..clear()
        ..addAll(cPerms);
      _selectedActionPerms
        ..clear()
        ..addAll(aPerms);
    });
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(80, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
    _showToast('✏️ Loaded ${doc['doctorName']} into editor above.');
  }

  Future<void> _saveDoctorFromMaster() async {
    final String name = _docNameCtrl.text.trim();
    final String user = _docUserCtrl.text.trim();
    final String pass = _docPassCtrl.text.trim();
    if (user.isEmpty || pass.isEmpty) {
      _showToast('⚠️ Please enter doctor username and password.', isError: true);
      return;
    }
    if (_selectedCoursePerms.isEmpty && !_docIsSuperAdmin) {
      _showToast('⚠️ Select at least one course in the 36-course matrix.', isError: true);
      return;
    }

    final List<String> allPerms = <String>[
      ..._selectedCoursePerms,
      ..._selectedActionPerms,
      if (_docIsSuperAdmin) 'ROLE_SUPER_ADMIN',
    ];

    widget.onLoadingChanged(true, 'Saving Doctor & Matrix...');
    final dynamic res = await PortalApiService.callAction(
      'saveDoctorAccountByMaster',
      <dynamic>[_masterUser, _masterPass, name.isEmpty ? user : name, user, pass, allPerms],
    );
    widget.onLoadingChanged(false);

    final JsonMap m = asJsonMap(res);
    if (m['success'] == true) {
      setState(() {
        _doctorsList = asJsonMapList(m['doctors']);
        _auditLogs = asJsonMapList(m['auditLogs']);
      });
      _showToast(m['message']?.toString() ?? '✅ Doctor account saved!');
    } else {
      _showToast(m['message']?.toString() ?? 'Failed to save doctor.', isError: true);
    }
  }

  Future<void> _quickToggleDoctorSuperAdmin(JsonMap doc, bool makeSuper) async {
    final String targetUser = doc['username']?.toString() ?? '';
    if (targetUser.isEmpty) return;

    widget.onLoadingChanged(
      true,
      makeSuper ? 'Promoting to Super Admin...' : 'Updating Role...',
    );
    final dynamic res = await PortalApiService.callAction(
      'toggleDoctorSuperAdminByMaster',
      <dynamic>[_masterUser, _masterPass, targetUser, makeSuper],
    );
    widget.onLoadingChanged(false);

    final JsonMap m = asJsonMap(res);
    if (m['success'] == true) {
      setState(() {
        _doctorsList = asJsonMapList(m['doctors']);
        _auditLogs = asJsonMapList(m['auditLogs']);
        if (_docUserCtrl.text.trim().toLowerCase() == targetUser.toLowerCase()) {
          _docIsSuperAdmin = makeSuper;
          if (makeSuper) {
            _selectedCoursePerms
              ..clear()
              ..addAll(buildAll36CoursePerms());
            _selectedActionPerms
              ..clear()
              ..addAll(buildDefaultActionPerms());
          }
        }
      });
      _showToast(m['message']?.toString() ?? '✅ Role updated!');
    } else {
      _showToast(m['message']?.toString() ?? 'Failed to update role.', isError: true);
    }
  }

  Future<void> _deleteDoctorByMaster(JsonMap doc) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('⚠️ Delete Doctor Account?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
        content: Text('Delete ${doc['doctorName']} (@${doc['username']})?', style: const TextStyle(fontSize: 11)),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(fontSize: 11))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    widget.onLoadingChanged(true, 'Deleting Doctor Account...');
    final dynamic res = await PortalApiService.callAction(
      'deleteDoctorAccountByMaster',
      <dynamic>[_masterUser, _masterPass, doc['row']],
    );
    widget.onLoadingChanged(false);

    final JsonMap m = asJsonMap(res);
    if (m['success'] == true) {
      setState(() {
        _doctorsList = asJsonMapList(m['doctors']);
        _auditLogs = asJsonMapList(m['auditLogs']);
      });
      _showToast('✅ Doctor account deleted.');
    } else {
      _showToast(m['message']?.toString() ?? 'Failed to delete.', isError: true);
    }
  }

  // Tab 1: Master Attendance Roster & Section Dates
  Future<void> _loadMasterAttendanceRoster() async {
    widget.onLoadingChanged(true, 'Loading Roster & Dates...');
    final dynamic res = await PortalApiService.callAction(
      'getSubjectAttendanceRoster',
      <dynamic>[_masterUser, _masterPass, true, _mAttUni, _mAttProg, _mAttSubj],
    );
    widget.onLoadingChanged(false);
    final JsonMap m = asJsonMap(res);
    if (m['success'] == true) {
      final JsonMap dates = asJsonMap(m['sectionDates']);
      for (int s = 1; s <= 12; s++) {
        _secDateCtrls[s]?.text = dates[s.toString()]?.toString() ?? (kDefaultSectionDates[s] ?? '');
      }
      setState(() {
        _mRosterSheetName = m['sheetName']?.toString() ?? '';
        _mRosterStudents = asJsonMapList(m['students']);
        _mRosterDirtyMap.clear();
      });
      _showToast('✅ Loaded ${_mRosterStudents.length} students.');
    } else {
      _showToast(m['message']?.toString() ?? 'Failed to load roster.', isError: true);
    }
  }

  Future<void> _saveMasterSectionDates() async {
    final Map<String, String> datesMap = <String, String>{};
    for (int s = 1; s <= 12; s++) {
      datesMap[s.toString()] = _secDateCtrls[s]?.text.trim() ?? '';
    }
    widget.onLoadingChanged(true, 'Saving Section Dates 1–12...');
    final dynamic res = await PortalApiService.callAction(
      'updateSubjectSectionDates',
      <dynamic>[
        <String, dynamic>{
          'isMaster': true,
          'actorUsername': _masterUser,
          'actorPassword': _masterPass,
          'university': _mAttUni,
          'program': _mAttProg,
          'subject': _mAttSubj,
          'datesMap': datesMap,
        },
      ],
    );
    widget.onLoadingChanged(false);
    final JsonMap m = asJsonMap(res);
    if (m['success'] == true) {
      setState(() => _auditLogs = asJsonMapList(m['auditLogs']));
      _showToast(m['message']?.toString() ?? '✅ Section dates saved!');
    } else {
      _showToast(m['message']?.toString() ?? 'Failed to save dates.', isError: true);
    }
  }

  Future<void> _saveMasterBulkAttendance() async {
    if (_mRosterDirtyMap.isEmpty) {
      _showToast('No attendance cells modified.', isError: true);
      return;
    }
    final List<JsonMap> changes = <JsonMap>[];
    _mRosterDirtyMap.forEach((String k, String v) {
      final List<String> p = k.split('|');
      if (p.length == 2) {
        changes.add(<String, dynamic>{
          'studentId': p[0],
          'sectionNumber': int.tryParse(p[1]) ?? 1,
          'newValue': v,
        });
      }
    });
    widget.onLoadingChanged(true, 'Saving ${changes.length} updates...');
    final dynamic res = await PortalApiService.callAction(
      'saveBulkAttendanceChanges',
      <dynamic>[
        <String, dynamic>{
          'isMaster': true,
          'actorUsername': _masterUser,
          'actorPassword': _masterPass,
          'university': _mAttUni,
          'program': _mAttProg,
          'subject': _mAttSubj,
          'changes': changes,
        },
      ],
    );
    widget.onLoadingChanged(false);
    final JsonMap m = asJsonMap(res);
    if (m['success'] == true) {
      _showToast(m['message']?.toString() ?? '✅ Bulk changes saved!');
      await _loadMasterAttendanceRoster();
    } else {
      _showToast(m['message']?.toString() ?? 'Error saving changes.', isError: true);
    }
  }

  // Tab 2: Archive & Clear 8 Workbooks
  Future<void> _archiveAndClearSelected() async {
    if (_selectedArchiveKeys.isEmpty) {
      _showToast('Select at least one workbook first.', isError: true);
      return;
    }
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('🗄️ Confirm Archive & Clear?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
        content: Text(
          'Archive full backup copies of (${_selectedArchiveKeys.length}) selected workbook(s) to Google Drive, and clear student rows for the new semester?',
          style: const TextStyle(fontSize: 11),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(fontSize: 11))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm Archive & Clear', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    widget.onLoadingChanged(true, 'Archiving to Drive & Clearing...');
    final dynamic res = await PortalApiService.callAction(
      'archiveAndClearSelectedSheetsByMaster',
      <dynamic>[_masterUser, _masterPass, _selectedArchiveKeys.toList()],
    );
    widget.onLoadingChanged(false);
    final JsonMap m = asJsonMap(res);
    if (m['success'] == true) {
      setState(() {
        _archivesHistory = asJsonMapList(m['archivesHistory']);
        _auditLogs = asJsonMapList(m['auditLogs']);
        _selectedArchiveKeys.clear();
      });
      _showToast(m['message']?.toString() ?? '✅ Archived & cleared!');
    } else {
      _showToast(m['message']?.toString() ?? 'Failed to archive.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_masterLoggedIn) {
      return _buildMasterLoginGate();
    }
    return RefreshIndicator(
      color: AppColors.navyBar,
      onRefresh: _refreshMasterAllData,
      child: SingleChildScrollView(
        controller: _scrollCtrl,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Hero Banner matching admin.html & main_fixed.dart
            Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 34),
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.5, -0.4),
                  radius: 1.4,
                  colors: <Color>[AppColors.emeraldDark, AppColors.navyBar],
                ),
                border: Border(bottom: BorderSide(color: AppColors.gold, width: 2.5)),
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        '🛡️ MASTER CONTROL & AUDIT CENTER',
                        style: TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.w900),
                      ),
                      Row(
                        children: <Widget>[
                          InkWell(
                            onTap: _refreshMasterAllData,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                              ),
                              child: const Text('🔄 Refresh All', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.gold)),
                            ),
                          ),
                          const SizedBox(width: 5),
                          InkWell(
                            onTap: _handleMasterLogout,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.danger.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('🚪 Sign Out', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                      children: <TextSpan>[
                        TextSpan(text: 'Super Admin '),
                        TextSpan(text: 'Master Control & Audit Center', style: TextStyle(color: AppColors.gold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'التحكم المركزي في حسابات الدكاترة وترقية السوبر أدمن ومصفوفة الـ 36 مقرر • تعديل التواريخ • أرشفة الشيتات الـ 8 • Audit Log',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 9.5, color: Color(0xFFCBD5E1)),
                  ),
                ],
              ),
            ),

            // Overlapping 4-Tab Bar & Active Tab Content
            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // 4-Tab Bar matching admin.html
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: AppColors.cardBorder, width: 1.3),
                        boxShadow: <BoxShadow>[
                          BoxShadow(color: AppColors.navyBar.withOpacity(0.08), blurRadius: 16),
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: _buildMasterSubTabBtn(0, '👨‍🏫 1. الدكاترة والصلاحيات (${_doctorsList.length})'),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: _buildMasterSubTabBtn(1, '✏️ 2. الغياب والتواريخ (1–12)'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: _buildMasterSubTabBtn(2, '🗄️ 3. أرشفة الشيتات (8)'),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: _buildMasterSubTabBtn(3, '📋 4. سجل المراقبة (${_auditLogs.length})'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                    if (_masterTab == 0)
                      _buildMasterTab1DoctorsAndMatrix()
                    else if (_masterTab == 1)
                      _buildMasterTab2AttendanceAndDates()
                    else if (_masterTab == 2)
                      _buildMasterTab3Archive8Sheets()
                    else
                      _buildMasterTab4AuditLogs(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMasterSubTabBtn(int index, String label) {
    final bool active = _masterTab == index;
    return InkWell(
      onTap: () => setState(() => _masterTab = index),
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.navyBar : Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: active ? AppColors.gold : AppColors.cardBorder),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: active ? AppColors.gold : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildMasterLoginGate() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.gold, width: 1.8),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.navyBar.withOpacity(0.1),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const OriginalBadgeLogo(size: 64, borderRadius: 14, showGoldBorder: true),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.goldSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    '🛡️ RESTRICTED MASTER ACCESS',
                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppColors.goldDark),
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Super Admin Control',
                  style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900, color: AppColors.textMain),
                ),
                const SizedBox(height: 4),
                const Text(
                  'دخول الـ Super Admin للتحكم في مصفوفة المواد (36 مقرر)، ترقية الدكاترة إلى Super Admin، تعديل الغياب والتواريخ، الأرشفة، والـ Audit Log',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10.5, color: AppColors.textMuted, height: 1.35),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _masterUserCtrl,
                  style: const TextStyle(fontSize: 11.5),
                  decoration: const InputDecoration(
                    labelText: 'Master Username',
                    prefixIcon: Icon(Icons.admin_panel_settings_outlined, size: 17),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _masterPassCtrl,
                  obscureText: _obscureMasterPass,
                  style: const TextStyle(fontSize: 11.5),
                  onSubmitted: (_) => _handleMasterLogin(),
                  decoration: InputDecoration(
                    labelText: 'Master Password',
                    prefixIcon: const Icon(Icons.lock_person_outlined, size: 17),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureMasterPass ? Icons.visibility_off : Icons.visibility, size: 16),
                      onPressed: () => setState(() => _obscureMasterPass = !_obscureMasterPass),
                    ),
                  ),
                ),
                if (_loginError != null) ...<Widget>[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.dangerSoft, borderRadius: BorderRadius.circular(8)),
                    child: Text(_loginError!, style: const TextStyle(color: AppColors.danger, fontSize: 10.5, fontWeight: FontWeight.w700)),
                  ),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton(
                    onPressed: _handleMasterLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navyBar,
                      foregroundColor: AppColors.gold,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Unlock Super Admin (فتح لوحة التحكم العليا) →',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900),
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

  // ==========================================================================
  // MASTER TAB 1: DOCTORS + PROMOTE TO SUPER ADMIN + 36-COURSE MATRIX
  // ==========================================================================
  Widget _buildMasterTab1DoctorsAndMatrix() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Create / Edit Doctor Form Shell
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      '➕ إضافة حساب دكتور أو تعديل صلاحياته (Create / Edit Doctor)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textMain),
                    ),
                  ),
                  InkWell(
                    onTap: _resetDoctorForm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(7)),
                      child: const Text('🔄 Reset Form', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _docNameCtrl,
                style: const TextStyle(fontSize: 11),
                decoration: const InputDecoration(labelText: 'Doctor Full Name (اسم الدكتور — e.g. Dr. Ahmed Hassan)'),
              ),
              const SizedBox(height: 7),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _docUserCtrl,
                      style: const TextStyle(fontSize: 11),
                      decoration: const InputDecoration(labelText: 'Username (اسم المستخدم)'),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: TextField(
                      controller: _docPassCtrl,
                      style: const TextStyle(fontSize: 11),
                      decoration: const InputDecoration(labelText: 'Password (كلمة المرور)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ==============================================================
              // PROMOTE DOCTOR TO SUPER ADMIN BUTTON / CARD (INSIDE EDIT FORM)
              // ==============================================================
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _docIsSuperAdmin
                        ? <Color>[const Color(0xFFFEF3C7), const Color(0xFFFDE68A)]
                        : <Color>[const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gold, width: 1.6),
                ),
                child: Row(
                  children: <Widget>[
                    const Text('👑', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'ترقية هذا الحساب إلى Super Admin (Grant Super Admin Role)',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.navyBar),
                          ),
                          Text(
                            _docIsSuperAdmin
                                ? '✅ هذا الحساب يمتلك حالياً صلاحية Super Admin كاملة (يدخل كبوابة دكتور وكسوبر أدمن)'
                                : 'اضغط على الزر لترقية هذا الدكتور إلى Super Admin كامل الصلاحيات',
                            style: const TextStyle(fontSize: 9.5, color: Color(0xFF475569), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _docIsSuperAdmin = !_docIsSuperAdmin;
                          if (_docIsSuperAdmin) {
                            _selectedCoursePerms
                              ..clear()
                              ..addAll(buildAll36CoursePerms());
                            _selectedActionPerms
                              ..clear()
                              ..addAll(buildDefaultActionPerms());
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _docIsSuperAdmin ? AppColors.emeraldDark : AppColors.navyBar,
                        foregroundColor: _docIsSuperAdmin ? Colors.white : AppColors.gold,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                      ),
                      icon: Icon(_docIsSuperAdmin ? Icons.verified_rounded : Icons.workspace_premium_rounded, size: 14),
                      label: Text(
                        _docIsSuperAdmin ? 'Super Admin مفعل ✔' : 'Make Super Admin',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Allowed Doctor Capabilities (7 Checkboxes)
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Expanded(
                          child: Text(
                            '⚙️ صلاحيات واختيارات الدكتور (Allowed Capabilities):',
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            InkWell(
                              onTap: () => setState(() => _selectedActionPerms.addAll(buildDefaultActionPerms())),
                              child: const Text('تفعيل الكل', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.emeraldDark)),
                            ),
                            const Text(' • ', style: TextStyle(fontSize: 9.5)),
                            InkWell(
                              onTap: () => setState(() => _selectedActionPerms.clear()),
                              child: const Text('إغلاق الكل', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.danger)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...kActionPermDefinitions.map((JsonMap a) {
                      final String k = a['key'].toString();
                      final bool checked = _selectedActionPerms.contains(k);
                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (checked) {
                              _selectedActionPerms.remove(k);
                            } else {
                              _selectedActionPerms.add(k);
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.5),
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: checked,
                                  activeColor: AppColors.emeraldDark,
                                  onChanged: (bool? v) {
                                    setState(() {
                                      if (v == true) {
                                        _selectedActionPerms.add(k);
                                      } else {
                                        _selectedActionPerms.remove(k);
                                      }
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(a['label'].toString(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 36-Course Matrix
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '🎯 مصفوفة الـ 36 مقرر (${_selectedCoursePerms.length}/36):',
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900),
                  ),
                  Wrap(
                    spacing: 4,
                    children: <Widget>[
                      _buildPresetChip('✅ الكل (36)', AppColors.emerald, () {
                        setState(() => _selectedCoursePerms
                          ..clear()
                          ..addAll(buildAll36CoursePerms()));
                      }),
                      _buildPresetChip('✖ إلغاء', AppColors.danger, () {
                        setState(() => _selectedCoursePerms.clear());
                      }),
                      _buildPresetChip('🏛️ BSNU', AppColors.emeraldDark, () {
                        setState(() {
                          _selectedCoursePerms.clear();
                          for (final JsonMap s in kSubjectCatalog) {
                            _selectedCoursePerms.add('BSNU_Clinical__${s['key']}');
                            _selectedCoursePerms.add('BSNU_General__${s['key']}');
                          }
                        });
                      }),
                      _buildPresetChip('🎓 BSU', AppColors.goldDark, () {
                        setState(() {
                          _selectedCoursePerms.clear();
                          for (final JsonMap s in kSubjectCatalog) {
                            _selectedCoursePerms.add('BSU_General__${s['key']}');
                            _selectedCoursePerms.add('BSU_Clinical__${s['key']}');
                          }
                        });
                      }),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowHeight: 28,
                  dataRowMinHeight: 28,
                  dataRowMaxHeight: 32,
                  headingRowColor: WidgetStateProperty.all(AppColors.navyBar),
                  columnSpacing: 10,
                  columns: const <DataColumn>[
                    DataColumn(label: Text('Course / Subject', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white))),
                    DataColumn(label: Text('BSNU Clin', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.gold))),
                    DataColumn(label: Text('BSNU Gen', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.gold))),
                    DataColumn(label: Text('BSU Gen', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white))),
                    DataColumn(label: Text('BSU Clin', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white))),
                    DataColumn(label: Text('Row Toggle', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.gold))),
                  ],
                  rows: kSubjectCatalog.map((JsonMap subj) {
                    final String sk = subj['key'].toString();
                    final String sName = subj['name'].toString();
                    final List<String> rowToks = kTrackKeys.map((String tk) => '${tk}__$sk').toList();
                    return DataRow(
                      cells: <DataCell>[
                        DataCell(Text(sName, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                        ...kTrackKeys.map((String tk) {
                          final String tok = '${tk}__$sk';
                          return DataCell(
                            Checkbox(
                              value: _selectedCoursePerms.contains(tok),
                              activeColor: AppColors.emeraldDark,
                              onChanged: (bool? v) {
                                setState(() {
                                  if (v == true) {
                                    _selectedCoursePerms.add(tok);
                                  } else {
                                    _selectedCoursePerms.remove(tok);
                                  }
                                });
                              },
                            ),
                          );
                        }),
                        DataCell(
                          InkWell(
                            onTap: () {
                              final bool allChecked = rowToks.every(_selectedCoursePerms.contains);
                              setState(() {
                                if (allChecked) {
                                  _selectedCoursePerms.removeAll(rowToks);
                                } else {
                                  _selectedCoursePerms.addAll(rowToks);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(5)),
                              child: const Text('تبديل الصف', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 35,
                child: ElevatedButton(
                  onPressed: _saveDoctorFromMaster,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.navyBar,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    '💾 حفظ بيانات الدكتور والصلاحيات المحددة (Save Doctor & Matrix) ✔',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Registered Doctors Cards List (with 1-click Make Super Admin & Edit Permissions)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '👨‍🏫 حسابات أعضاء هيئة التدريس المسجلة (${_doctorsList.length})',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              ..._doctorsList.map((JsonMap doc) {
                final List<String> perms = asStringList(doc['permissions']);
                final bool isSuper = doc['isSuperAdmin'] == true || perms.contains('ROLE_SUPER_ADMIN');
                final int cCount = perms.where((String p) => p.contains('__')).length;
                final String countLabel = (perms.contains('ALL') || cCount >= 36)
                    ? '✅ جميع المواد (36/36)'
                    : '🎯 مخصص ($cCount/36)';

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSuper ? AppColors.goldSoft.withOpacity(0.45) : AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSuper ? AppColors.gold : AppColors.cardBorder,
                      width: isSuper ? 1.6 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Row(
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    '${isSuper ? "👑" : "👨‍🏫"} ${doc['doctorName']}',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                                  ),
                                ),
                                if (isSuper) ...<Widget>[
                                  const SizedBox(width: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: AppColors.navyBar,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(color: AppColors.gold),
                                    ),
                                    child: const Text(
                                      'SUPER ADMIN',
                                      style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: AppColors.gold),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.goldSoft,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.gold),
                            ),
                            child: Text(countLabel, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.goldDark)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'User: ${doc['username']}  •  Pass: ${doc['password']}',
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.emeraldDark),
                      ),
                      const Divider(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        alignment: WrapAlignment.end,
                        children: <Widget>[
                          // Direct 1-Click Make Super Admin / Revoke Super Admin Button
                          InkWell(
                            onTap: () => _quickToggleDoctorSuperAdmin(doc, !isSuper),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(
                                color: isSuper ? const Color(0xFFFDE68A) : AppColors.gold,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.goldDark.withOpacity(0.4)),
                              ),
                              child: Text(
                                isSuper ? '🔒 إلغاء Super Admin' : '👑 ترقية لـ Super Admin',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.navyBar),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => _loadDoctorIntoEditor(doc),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(color: AppColors.navyBar, borderRadius: BorderRadius.circular(8)),
                              child: const Text(
                                '✏️ Edit Permissions (تعديل الصلاحيات)',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.gold),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => _deleteDoctorByMaster(doc),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(color: AppColors.dangerSoft, borderRadius: BorderRadius.circular(8)),
                              child: const Text('🗑 حذف', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.danger)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // MASTER TAB 2: DIRECT ATTENDANCE & SECTION DATES (1-12)
  // ==========================================================================
  Widget _buildMasterTab2AttendanceAndDates() {
    final String q = _mRosterSearchCtrl.text.trim().toLowerCase();
    final List<JsonMap> filtered = _mRosterStudents.where((JsonMap s) {
      if (q.isEmpty) return true;
      return (s['studentId']?.toString() ?? '').toLowerCase().contains(q) ||
          (s['studentName']?.toString() ?? '').toLowerCase().contains(q);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            '✏️ مركز تعديل الغياب المباشر وتواريخ السكاشن (1–12)',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _mAttUni,
                  isExpanded: true,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMain),
                  decoration: const InputDecoration(labelText: 'University'),
                  items: const <StringDropItem>[
                    StringDropItem(value: 'BSNU', child: Text('BSNU (الأهلية)')),
                    StringDropItem(value: 'BSU', child: Text('BSU (الحكومية)')),
                  ],
                  onChanged: (String? v) => setState(() => _mAttUni = v ?? 'BSNU'),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _mAttProg,
                  isExpanded: true,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMain),
                  decoration: const InputDecoration(labelText: 'Program'),
                  items: const <StringDropItem>[
                    StringDropItem(value: 'Clinical', child: Text('PharmD Clinical')),
                    StringDropItem(value: 'General', child: Text('PharmD General')),
                  ],
                  onChanged: (String? v) => setState(() => _mAttProg = v ?? 'Clinical'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: <Widget>[
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _mAttSubj,
                  isExpanded: true,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMain),
                  decoration: const InputDecoration(labelText: 'Subject'),
                  items: kSubjectCatalog
                      .map((JsonMap s) => StringDropItem(value: s['name'].toString(), child: Text(s['name'].toString())))
                      .toList(),
                  onChanged: (String? v) => setState(() => _mAttSubj = v ?? _mAttSubj),
                ),
              ),
              const SizedBox(width: 7),
              ElevatedButton(
                onPressed: _loadMasterAttendanceRoster,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldDark, foregroundColor: Colors.white),
                child: const Text('📥 تحميل الكشف والتواريخ', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.goldSoft.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text('📅 تواريخ السكاشن (Section Dates 1–12):', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900)),
                    ElevatedButton(
                      onPressed: _saveMasterSectionDates,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navyBar,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        minimumSize: Size.zero,
                      ),
                      child: const Text('💾 حفظ التواريخ ✔', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 12,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                    childAspectRatio: 2.5,
                  ),
                  itemBuilder: (BuildContext context, int i) {
                    final int s = i + 1;
                    return TextField(
                      controller: _secDateCtrls[s],
                      style: const TextStyle(fontSize: 10),
                      decoration: InputDecoration(
                        labelText: 'Sec $s',
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          if (_mRosterStudents.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text('Sheet: $_mRosterSheetName (${filtered.length})', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                ),
                if (_mRosterDirtyMap.isNotEmpty)
                  ElevatedButton(
                    onPressed: _saveMasterBulkAttendance,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldDark, foregroundColor: Colors.white),
                    child: Text('💾 حفظ (${_mRosterDirtyMap.length})', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800)),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _mRosterSearchCtrl,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 11),
              decoration: const InputDecoration(labelText: 'Search Student in Roster', prefixIcon: Icon(Icons.search, size: 15)),
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 28,
                dataRowMinHeight: 28,
                dataRowMaxHeight: 32,
                headingRowColor: WidgetStateProperty.all(AppColors.navyBar),
                columnSpacing: 8,
                columns: <DataColumn>[
                  const DataColumn(label: Text('ID', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white))),
                  const DataColumn(label: Text('Name', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white))),
                  ...List<DataColumn>.generate(
                    12,
                    (int i) => DataColumn(label: Text('S${i + 1}', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.gold))),
                  ),
                ],
                rows: filtered.take(120).map((JsonMap st) {
                  final String sid = st['studentId']?.toString() ?? '';
                  final JsonMap secs = asJsonMap(st['sections']);
                  return DataRow(
                    cells: <DataCell>[
                      DataCell(Text(sid, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700))),
                      DataCell(SizedBox(width: 120, child: Text('${st['studentName']}', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10)))),
                      ...List<DataCell>.generate(12, (int i) {
                        final int sNum = i + 1;
                        final String k = '$sid|$sNum';
                        final String v = _mRosterDirtyMap[k] ?? (secs[sNum.toString()]?.toString() ?? 'P');
                        final Color c = v == 'A' ? AppColors.danger : (v == 'E' ? AppColors.goldDark : AppColors.emeraldDark);
                        return DataCell(
                          InkWell(
                            onTap: () {
                              setState(() {
                                _mRosterDirtyMap[k] = v == 'P' ? 'A' : (v == 'A' ? 'E' : 'P');
                              });
                            },
                            child: Container(
                              width: 22,
                              height: 20,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: c.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: c),
                              ),
                              child: Text(v, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: c)),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================================================
  // MASTER TAB 3: ARCHIVE & CLEAR ALL 8 WORKBOOKS
  // ==========================================================================
  Widget _buildMasterTab3Archive8Sheets() {
    final List<JsonMap> items = _sheetsOverview.isNotEmpty
        ? _sheetsOverview
        : <JsonMap>[
            <String, dynamic>{'key': 'BSNU_ATTENDANCE', 'badge': 'Attendance', 'title': 'غياب الأهلية — BSNU Attendance', 'desc': 'تفريغ الـ 18 شيت غياب مع أرشفة النسخة القديمة في Drive'},
            <String, dynamic>{'key': 'BSU_ATTENDANCE', 'badge': 'Attendance', 'title': 'غياب الحكومية — BSU Attendance', 'desc': 'تفريغ الـ 18 شيت غياب مع أرشفة النسخة القديمة في Drive'},
            <String, dynamic>{'key': 'EXCUSES_DB', 'badge': 'Excuses', 'title': 'قاعدة بيانات الأعذار الطبية — Excuses DB', 'desc': 'تفريغ طلبات الأعذار الطبية للطلاب مع الأرشفة'},
            <String, dynamic>{'key': 'BSNU_Clinical', 'badge': 'Grades', 'title': 'درجات الأهلية كلينيكال — BSNU Clinical', 'desc': 'تفريغ الـ 9 مقررات كاملة + أرشفة النسخة القديمة'},
            <String, dynamic>{'key': 'BSNU_General', 'badge': 'Grades', 'title': 'درجات الأهلية جنرال — BSNU General', 'desc': 'تفريغ الـ 9 مقررات كاملة + أرشفة النسخة القديمة'},
            <String, dynamic>{'key': 'BSU_General', 'badge': 'Grades', 'title': 'درجات الحكومية جنرال — BSU General', 'desc': 'تفريغ الـ 9 مقررات كاملة + أرشفة النسخة القديمة'},
            <String, dynamic>{'key': 'BSU_Clinical', 'badge': 'Grades', 'title': 'درجات الحكومية كلينيكال — BSU Clinical', 'desc': 'تفريغ الـ 9 مقررات كاملة + أرشفة النسخة القديمة'},
            <String, dynamic>{'key': 'APPEALS_DB', 'badge': 'Appeals', 'title': 'قاعدة بيانات التظلمات — Appeals DB', 'desc': 'تفريغ التظلمات مع الحفاظ على حسابات الدكاترة والـ Audit'},
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      '🗄️ جدول تفريغ وأرشفة الشيتات الـ 8 (Archive & Clear)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.danger),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      _buildPresetChip('☑️ الكل (8)', AppColors.navyBar, () {
                        setState(() {
                          for (final JsonMap it in items) {
                            _selectedArchiveKeys.add(it['key'].toString());
                          }
                        });
                      }),
                      const SizedBox(width: 4),
                      _buildPresetChip('✖ إلغاء', AppColors.textMuted, () {
                        setState(() => _selectedArchiveKeys.clear());
                      }),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...items.map((JsonMap wb) {
                final String k = wb['key'].toString();
                final bool sel = _selectedArchiveKeys.contains(k);
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.dangerSoft.withOpacity(0.4) : AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: sel ? AppColors.danger : AppColors.cardBorder),
                  ),
                  child: CheckboxListTile(
                    value: sel,
                    dense: true,
                    activeColor: AppColors.danger,
                    title: Text('${wb['title']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                    subtitle: Text('${wb['desc']}', style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
                    onChanged: (bool? v) {
                      setState(() {
                        if (v == true) {
                          _selectedArchiveKeys.add(k);
                        } else {
                          _selectedArchiveKeys.remove(k);
                        }
                      });
                    },
                  ),
                );
              }),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 35,
                child: ElevatedButton(
                  onPressed: _archiveAndClearSelected,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
                  child: Text(
                    '🗑️ أرشفة القديم في Drive وتفريغ المختار (${_selectedArchiveKeys.length})',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('📂 سجل النسخ المؤرشفة في Google Drive (${_archivesHistory.length})', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              ..._archivesHistory.map((JsonMap h) {
                final String url = h['archiveUrl']?.toString() ?? '';
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text('${h['workbookTitle']} • ${h['timestamp']}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800)),
                  subtitle: Text('${h['archiveName']} (Tabs: ${h['tabsCleared']} | Rows: ${h['rowsCleared']})', style: const TextStyle(fontSize: 9.5)),
                  trailing: url.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.open_in_new, size: 15, color: AppColors.emeraldDark),
                          onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
                        )
                      : null,
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // MASTER TAB 4: UNIFIED AUDIT LOG
  // ==========================================================================
  Widget _buildMasterTab4AuditLogs() {
    final String q = _auditSearchCtrl.text.trim().toLowerCase();
    final List<JsonMap> filtered = _auditLogs.where((JsonMap l) {
      final String act = (l['action']?.toString() ?? '').toLowerCase();
      if (_auditCatFilter == 'ATTENDANCE' && !act.contains('attendance') && !act.contains('excuse') && !act.contains('date')) return false;
      if (_auditCatFilter == 'GRADES' && !act.contains('grade') && !act.contains('appeal') && !act.contains('student')) return false;
      if (_auditCatFilter == 'VISIBILITY' && !act.contains('announced') && !act.contains('hidden')) return false;
      if (_auditCatFilter == 'MASTER' && !act.contains('doctor') && !act.contains('archive') && !act.contains('super')) return false;
      if (q.isNotEmpty) {
        final String hay = '${l['doctorName']} ${l['username']} ${l['action']} ${l['target']} ${l['subjectInfo']} ${l['details']}'.toLowerCase();
        return hay.contains(q);
      }
      return true;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text('📋 سجل المراقبة الموحد (Unified Audit Log)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          TextField(
            controller: _auditSearchCtrl,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 11),
            decoration: const InputDecoration(
              labelText: 'Search by Doctor, Student, Course, or Action',
              prefixIcon: Icon(Icons.search, size: 15),
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <String>['ALL', 'ATTENDANCE', 'GRADES', 'VISIBILITY', 'MASTER'].map((String c) {
                final bool sel = _auditCatFilter == c;
                return Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: ChoiceChip(
                    label: Text(c, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: sel ? AppColors.gold : AppColors.textMain)),
                    selected: sel,
                    selectedColor: AppColors.navyBar,
                    visualDensity: VisualDensity.compact,
                    onSelected: (_) => setState(() => _auditCatFilter = c),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          ...filtered.take(150).map((JsonMap l) {
            return Container(
              margin: const EdgeInsets.only(bottom: 7),
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.navyBar, borderRadius: BorderRadius.circular(6)),
                          child: Text(
                            '${l['action']}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppColors.gold),
                          ),
                        ),
                      ),
                      Text('${l['timestamp']}', style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '👨‍⚕️ ${l['doctorName']} (@${l['username']})  •  🎯 ${l['target']}',
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    '${l['subjectInfo']} — ${l['details']}',
                    style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String text, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
        child: Text(text, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white)),
      ),
    );
  }
}

// ============================================================================
// STUDENT PORTAL MODAL SCREEN (ACCESSIBLE VIA SMALL TOP-RIGHT "Students" BUTTON)
// ============================================================================
class StudentPortalModalScreen extends StatefulWidget {
  const StudentPortalModalScreen({super.key});

  @override
  State<StudentPortalModalScreen> createState() => _StudentPortalModalScreenState();
}

class _StudentPortalModalScreenState extends State<StudentPortalModalScreen> {
  int _portalMode = 0; // 0 = Attendance & Excuses, 1 = Coursework Grades & Appeals
  bool _loading = false;
  String? _loadingLabel;

  String _uni = 'Beni-Suef University';
  String _prog = 'Clinical';
  String _subj = 'Basic Microbiology';
  final TextEditingController _idCtrl = TextEditingController();

  JsonMap? _attRecord;
  int _excSec = 1;
  final TextEditingController _excCommentCtrl = TextEditingController();
  Uint8List? _pickedBytes;
  String _pickedName = '';

  JsonMap? _gradeRecord;
  String _appealScope = 'Periodical only';
  final TextEditingController _appealCommentCtrl = TextEditingController();

  @override
  void dispose() {
    _idCtrl.dispose();
    _excCommentCtrl.dispose();
    _appealCommentCtrl.dispose();
    super.dispose();
  }

  void _showToast(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? AppColors.danger : AppColors.navyBar,
        behavior: SnackBarBehavior.floating,
        content: Text(msg, style: const TextStyle(fontSize: 11, color: Colors.white)),
      ),
    );
  }

  Future<void> _lookupAttendance() async {
    final String sid = _idCtrl.text.trim();
    if (sid.isEmpty) {
      _showToast('Enter your Student ID.', isError: true);
      return;
    }
    setState(() {
      _loading = true;
      _loadingLabel = 'Checking Attendance...';
    });
    final dynamic res = await PortalApiService.callAction(
      'getStudentFullRecord',
      <dynamic>[_uni, _prog, _subj, sid],
    );
    setState(() => _loading = false);
    final JsonMap m = asJsonMap(res);
    if (m['found'] == true) {
      setState(() => _attRecord = m);
    } else {
      _showToast(m['error']?.toString() ?? 'Student ID not found.', isError: true);
    }
  }

  Future<void> _pickExcuseImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? f = await picker.pickImage(source: ImageSource.gallery, imageQuality: 78, maxWidth: 1280);
      if (f == null) return;
      final Uint8List b = await f.readAsBytes();
      setState(() {
        _pickedBytes = b;
        _pickedName = f.name;
      });
    } catch (e) {
      _showToast('Error picking image: $e', isError: true);
    }
  }

  Future<void> _submitMedicalExcuse() async {
    if (_attRecord == null || _pickedBytes == null) {
      _showToast('Attach a medical report image first.', isError: true);
      return;
    }
    setState(() {
      _loading = true;
      _loadingLabel = 'Uploading Medical Excuse...';
    });
    final dynamic res = await PortalApiService.callAction(
      'uploadFile',
      <dynamic>[
        <String, dynamic>{
          'university': _uni,
          'program': _prog,
          'subject': _subj,
          'studentId': _attRecord!['studentId'],
          'name': _attRecord!['studentName'],
          'section': _excSec.toString(),
          'comment': _excCommentCtrl.text.trim(),
          'files': <JsonMap>[
            <String, dynamic>{
              'filename': _pickedName.isEmpty ? 'excuse.jpg' : _pickedName,
              'mimeType': 'image/jpeg',
              'base64': base64Encode(_pickedBytes!),
            },
          ],
        },
      ],
    );
    setState(() => _loading = false);
    final JsonMap m = asJsonMap(res);
    if (m['success'] == true) {
      _showToast(m['message']?.toString() ?? '✅ Excuse submitted!');
      setState(() {
        _pickedBytes = null;
        _excCommentCtrl.clear();
      });
      await _lookupAttendance();
    } else {
      _showToast(m['message']?.toString() ?? 'Failed to submit excuse.', isError: true);
    }
  }

  Future<void> _lookupGrades() async {
    final String sid = _idCtrl.text.trim();
    if (sid.isEmpty) {
      _showToast('Enter your Student ID.', isError: true);
      return;
    }
    setState(() {
      _loading = true;
      _loadingLabel = 'Fetching Coursework Grades...';
    });
    final dynamic res = await PortalApiService.callAction(
      'getStudentGradeRecord',
      <dynamic>[_uni, _prog, _subj, sid],
    );
    setState(() => _loading = false);
    final JsonMap m = asJsonMap(res);
    if (m['found'] == true) {
      setState(() => _gradeRecord = m);
    } else {
      _showToast(m['error']?.toString() ?? 'Grades not found or currently hidden.', isError: true);
    }
  }

  Future<void> _submitAppeal() async {
    if (_gradeRecord == null) return;
    setState(() {
      _loading = true;
      _loadingLabel = 'Submitting Appeal...';
    });
    final dynamic res = await PortalApiService.callAction(
      'submitStudentGradeAppeal',
      <dynamic>[
        <String, dynamic>{
          'university': _uni,
          'program': _prog,
          'subject': _subj,
          'studentId': _gradeRecord!['studentId'],
          'studentName': _gradeRecord!['studentName'],
          'appealType': _appealScope,
          'comment': _appealCommentCtrl.text.trim(),
        },
      ],
    );
    setState(() => _loading = false);
    final JsonMap m = asJsonMap(res);
    if (m['success'] == true) {
      _showToast(m['message']?.toString() ?? '✅ Appeal submitted!');
      await _lookupGrades();
    } else {
      _showToast(m['message']?.toString() ?? 'Could not submit appeal.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(46),
        child: AppBar(
          backgroundColor: AppColors.navyBar,
          foregroundColor: Colors.white,
          titleSpacing: 6,
          title: const Row(
            children: <Widget>[
              OriginalBadgeLogo(size: 28, borderRadius: 6, showGoldBorder: true),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Official Student Portal (Attendance & Grades)',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: AppColors.gold),
              icon: const Icon(Icons.arrow_back, size: 13),
              label: const Text('Admin', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _portalMode = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _portalMode == 0 ? AppColors.emeraldDark : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '📋 1. Attendance & Excuses',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: _portalMode == 0 ? AppColors.gold : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _portalMode = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _portalMode == 1 ? AppColors.emeraldDark : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '🎓 2. Grades & Appeals',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: _portalMode == 1 ? AppColors.gold : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _uni,
                              isExpanded: true,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMain),
                              decoration: const InputDecoration(labelText: 'University'),
                              items: const <StringDropItem>[
                                StringDropItem(value: 'Beni-Suef University', child: Text('BSU (الحكومية)')),
                                StringDropItem(value: 'Beni-Suef National University', child: Text('BSNU (الأهلية)')),
                              ],
                              onChanged: (String? v) => setState(() => _uni = v ?? _uni),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _prog,
                              isExpanded: true,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMain),
                              decoration: const InputDecoration(labelText: 'Program'),
                              items: const <StringDropItem>[
                                StringDropItem(value: 'Clinical', child: Text('PharmD Clinical')),
                                StringDropItem(value: 'General', child: Text('PharmD General')),
                              ],
                              onChanged: (String? v) => setState(() => _prog = v ?? _prog),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _subj,
                        isExpanded: true,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMain),
                        decoration: const InputDecoration(labelText: 'Course / Subject'),
                        items: kSubjectCatalog
                            .map((JsonMap s) => StringDropItem(value: s['name'].toString(), child: Text(s['name'].toString())))
                            .toList(),
                        onChanged: (String? v) => setState(() => _subj = v ?? _subj),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: _idCtrl,
                              style: const TextStyle(fontSize: 11.5),
                              onSubmitted: (_) => _portalMode == 0 ? _lookupAttendance() : _lookupGrades(),
                              decoration: const InputDecoration(
                                labelText: 'Student ID Code',
                                prefixIcon: Icon(Icons.badge_outlined, size: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _portalMode == 0 ? _lookupAttendance : _lookupGrades,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.emeraldDark,
                              foregroundColor: AppColors.gold,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                            ),
                            icon: const Icon(Icons.search, size: 15),
                            label: Text(
                              _portalMode == 0 ? 'Show Attendance' : 'Show Grades',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                if (_portalMode == 0 && _attRecord != null) _buildStudentAttendanceCard(),
                if (_portalMode == 1 && _gradeRecord != null) _buildStudentGradeCard(),
              ],
            ),
          ),
          TopFloatingCircularLoader(isLoading: _loading, label: _loadingLabel),
        ],
      ),
    );
  }

  Widget _buildStudentAttendanceCard() {
    final JsonMap stats = asJsonMap(_attRecord!['stats']);
    final List<JsonMap> secs = asJsonMapList(_attRecord!['sections']);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('${_attRecord!['studentName']} (#${_attRecord!['studentId']})', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(
            'Present: ${stats['presentCount']} | Unexcused (A): ${stats['unexcusedAbsence']} | Excused (E): ${stats['excusedAbsence']} | Score: ${stats['attendanceMarks']}/5',
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.emeraldDark),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: secs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
              childAspectRatio: 1.35,
            ),
            itemBuilder: (BuildContext context, int i) {
              final JsonMap s = secs[i];
              final String raw = (s['rawStatus']?.toString() ?? '').toUpperCase();
              final Color c = raw == 'A' ? AppColors.danger : (raw == 'E' ? AppColors.goldDark : AppColors.emeraldDark);
              return Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: c.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: c.withOpacity(0.45)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Sec ${s['sectionNumber']}', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800)),
                    Text(raw.isEmpty ? 'P' : raw, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: c)),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 16),
          const Text('Submit Medical Excuse:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _excSec,
                  decoration: const InputDecoration(labelText: 'Section (1–12)'),
                  items: List<IntDropItem>.generate(
                    12,
                    (int i) => IntDropItem(value: i + 1, child: Text('Section ${i + 1}', style: const TextStyle(fontSize: 11))),
                  ),
                  onChanged: (int? v) => setState(() => _excSec = v ?? 1),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _pickExcuseImage,
                icon: const Icon(Icons.add_a_photo_outlined, size: 14),
                label: Text(_pickedBytes == null ? 'Attach Report' : 'Attached ✔', style: const TextStyle(fontSize: 10.5)),
              ),
            ],
          ),
          const SizedBox(height: 7),
          TextField(controller: _excCommentCtrl, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'Comment (Optional)')),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 33,
            child: ElevatedButton(
              onPressed: _submitMedicalExcuse,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldDark, foregroundColor: Colors.white),
              child: const Text('Submit Medical Excuse ✔', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentGradeCard() {
    final JsonMap appeal = asJsonMap(_gradeRecord!['appeal']);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('${_gradeRecord!['studentName']} (#${_gradeRecord!['studentId']})', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(
            'Periodical: ${_gradeRecord!['periodicalMark']}  |  Practical: ${_gradeRecord!['practicalMark']}  |  Total: ${_gradeRecord!['totalMark']}',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.emeraldDark),
          ),
          const Divider(height: 16),
          if (appeal['submitted'] == true)
            Text(
              'Appeal Status: ${appeal['decision']} (${appeal['type']}) — ${appeal['result']}',
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.goldDark),
            )
          else ...<Widget>[
            const Text('Submit Electronic Grade Appeal:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _appealScope,
              style: const TextStyle(fontSize: 11, color: AppColors.textMain),
              decoration: const InputDecoration(labelText: 'Appeal Type'),
              items: const <StringDropItem>[
                StringDropItem(value: 'Periodical only', child: Text('Periodical Only')),
                StringDropItem(value: 'Practical only', child: Text('Practical Only')),
                StringDropItem(value: 'Both Periodical & Practical', child: Text('Both Periodical & Practical')),
              ],
              onChanged: (String? v) => setState(() => _appealScope = v ?? 'Periodical only'),
            ),
            const SizedBox(height: 7),
            TextField(controller: _appealCommentCtrl, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'Appeal Comment')),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 33,
              child: ElevatedButton(
                onPressed: _submitAppeal,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.navyBar, foregroundColor: AppColors.gold),
                child: const Text('Submit Grade Appeal ✔', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

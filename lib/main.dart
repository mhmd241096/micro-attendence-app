import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

typedef JsonMap = Map<String, dynamic>;
typedef StringDropItem = DropdownMenuItem<String>;
typedef IntDropItem = DropdownMenuItem<int>;

/// Helper to safely convert any dynamic map to JsonMap without nested generic brackets
JsonMap asJsonMap(dynamic raw) {
  if (raw is Map) {
    return Map<String, dynamic>.from(raw);
  }
  return <String, dynamic>{};
}

/// Safe list of JsonMap converter
List<JsonMap> asJsonMapList(dynamic raw) {
  if (raw is List) {
    return raw.map(( dynamic e) => asJsonMap(e)).toList();
  }
  return <JsonMap>[];
}

/// Safe string list converter
List<String> asStringList(dynamic raw) {
  if (raw is List) {
    return raw.map((dynamic e) => e?.toString() ?? '').where((String s) => s.isNotEmpty).toList();
  }
  return <String>[];
}

/// Default Google Apps Script Web App URL (ends with /exec)
const String kDefaultWebAppUrl =
    'https://script.google.com/macros/s/AKfycbygFGReaYRWp4gZqhjkc7iTbJXhfxC3rq5-w_qhYxcq9UCgfFQlOUOvC7MPf7En-FnG4A/exec';

/// Official Edited BSU Department Logo (Beni-Suef University - BSU, Faculty of Pharmacy)
const String kBsuDeptLogoBase64 = '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';

late final Uint8List kBsuDeptLogoBytes;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  kBsuDeptLogoBytes = base64Decode(kBsuDeptLogoBase64);
  runApp(const BsuMicrobiologyPortalApp());
}

// ============================================================================
// CATALOG, TRACKS & PERMISSIONS CONSTANTS (MATCHING Code.gs 100%)
// ============================================================================
const List<String> kTrackKeys = <String>[
  'BSU_General',
  'BSU_Clinical',
  'BSNU_General',
  'BSNU_Clinical',
];

const Map<String, String> kTrackShortLabels = <String, String>{
  'BSU_General': 'BSU General',
  'BSU_Clinical': 'BSU Clinical',
  'BSNU_General': 'BSNU General',
  'BSNU_Clinical': 'BSNU Clinical',
};

const Map<String, String> kTrackFullLabels = <String, String>{
  'BSU_General': 'BSU — General (الحكومية جنرال)',
  'BSU_Clinical': 'BSU — Clinical (الحكومية كلينيكال)',
  'BSNU_General': 'BSNU — General (الأهلية جنرال)',
  'BSNU_Clinical': 'BSNU — Clinical (الأهلية كلينيكال)',
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
    'title': 'Approve / Reject Excuses',
    'sub': 'قبول أو رفض الأعذار الطبية للطلاب',
  },
  <String, dynamic>{
    'key': 'ACT_EDIT_ATTENDANCE',
    'title': 'Direct Attendance Edit',
    'sub': 'تعديل الغياب والحضور والدرجات مباشرة',
  },
  <String, dynamic>{
    'key': 'ACT_EDIT_DATES',
    'title': 'Edit Section Dates (1-12)',
    'sub': 'تعديل تواريخ السكاشن 1 إلى 12',
  },
  <String, dynamic>{
    'key': 'ACT_REVIEW_APPEALS',
    'title': 'Review Grade Appeals',
    'sub': 'مراجعة تظلمات الدرجات وإضافة درجات الرأفة',
  },
  <String, dynamic>{
    'key': 'ACT_EDIT_GRADES',
    'title': 'Edit Live Grades Sheet',
    'sub': 'تعديل وإضافة وحذف درجات الطلاب في الشيت',
  },
  <String, dynamic>{
    'key': 'ACT_TOGGLE_VISIBILITY',
    'title': 'Announce / Hide Courses',
    'sub': 'إعلان أو حجب نتائج المقررات عن الطلاب',
  },
  <String, dynamic>{
    'key': 'ACT_CHANGE_CRED',
    'title': 'Change Own Password',
    'sub': 'السماح للدكتور بتغيير اسم المستخدم وكلمة المرور',
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
  if (perms.contains('ALL')) return true;
  final JsonMap? item = findSubjectByNameOrKey(subjectNameOrKey);
  final String canonicalKey = item != null ? item['key'].toString() : subjectNameOrKey;
  final String altKey = item != null ? item['altKey'].toString() : subjectNameOrKey;
  return perms.contains('${trackKey}__$canonicalKey') || perms.contains('${trackKey}__$altKey');
}

bool isDoctorActionAllowed(List<String> perms, String actionKey) {
  if (perms.isEmpty) return false;
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
// API SERVICE (CONNECTS DIRECTLY TO Code.gs doPost JSON RPC)
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
        'message': 'Network / Connection error: $err',
      };
    } finally {
      client.close();
    }
  }
}

// ============================================================================
// REUSABLE LOGO & TOP FLOATING FACEBOOK-STYLE SPINNER WIDGETS
// ============================================================================
class BsuDeptLogoWidget extends StatelessWidget {
  final double size;
  final bool showGoldBorder;

  const BsuDeptLogoWidget({
    super.key,
    this.size = 42,
    this.showGoldBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: showGoldBorder
            ? Border.all(color: const Color(0xFFD99B26), width: size > 60 ? 2.2 : 1.4)
            : null,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: size * 0.18,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.memory(
          kBsuDeptLogoBytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}

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
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutBack,
        offset: isLoading ? Offset.zero : const Offset(0, -2.2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isLoading ? 1.0 : 0.0,
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              padding: EdgeInsets.symmetric(
                horizontal: (label != null && label!.isNotEmpty) ? 12 : 9,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.16),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.3,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0B4A40)),
                    ),
                  ),
                  if (label != null && label!.isNotEmpty) ...<Widget>[
                    const SizedBox(width: 8),
                    Text(
                      label!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
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
// ROOT APPLICATION WITH COMPACT MOBILE TYPOGRAPHY SCALE
// ============================================================================
class BsuMicrobiologyPortalApp extends StatefulWidget {
  const BsuMicrobiologyPortalApp({super.key});

  @override
  State<BsuMicrobiologyPortalApp> createState() => _BsuMicrobiologyPortalAppState();
}

class _BsuMicrobiologyPortalAppState extends State<BsuMicrobiologyPortalApp> {
  bool _showIntro = true;

  @override
  void initState() {
    super.initState();
    PortalApiService.initSavedUrl();
  }

  void _finishIntro() {
    if (!mounted) return;
    setState(() {
      _showIntro = false;
    });
  }

  void _replayIntro() {
    if (!mounted) return;
    setState(() {
      _showIntro = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BSU Microbiology & Immunology Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        visualDensity: VisualDensity.compact,
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B4A40),
          primary: const Color(0xFF0B4A40),
          secondary: const Color(0xFFD99B26),
          surface: Colors.white,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          titleMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
          titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
          bodyLarge: TextStyle(fontSize: 12.5, color: Color(0xFF1E293B)),
          bodyMedium: TextStyle(fontSize: 11.5, color: Color(0xFF334155)),
          bodySmall: TextStyle(fontSize: 10.5, color: Color(0xFF475569)),
          labelLarge: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
          labelMedium: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
          labelSmall: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600),
        ),
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          labelStyle: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
          hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF0B4A40), width: 1.4),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
      ),
      builder: (BuildContext context, Widget? child) {
        // Clamp text scale factor so mobile OS large font settings never make fonts huge
        final MediaQueryData mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 550),
        child: _showIntro
            ? IntroVideoSplashScreen(
                key: const ValueKey<String>('intro_video_splash'),
                onCompleted: _finishIntro,
              )
            : MainAdminSuperShell(
                key: const ValueKey<String>('main_admin_shell'),
                onReplayIntro: _replayIntro,
              ),
      ),
    );
  }
}

// ============================================================================
// CINEMATIC ANIMATED VIDEO INTRO SCREEN (SLOGAN -> SPLIT LINES -> DEPT EMERGES)
// ============================================================================
class IntroVideoSplashScreen extends StatefulWidget {
  final VoidCallback onCompleted;

  const IntroVideoSplashScreen({
    super.key,
    required this.onCompleted,
  });

  @override
  State<IntroVideoSplashScreen> createState() => _IntroVideoSplashScreenState();
}

class _IntroVideoSplashScreenState extends State<IntroVideoSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Stage 1 (0.00 -> 0.28): Logo & Center Slogan fade + scale in
  late final Animation<double> _sloganOpacity;
  late final Animation<double> _sloganScale;

  // Stage 2 (0.28 -> 0.64): Top & Bottom lines appear in center and split open vertically,
  // while the department word emerges from between them
  late final Animation<double> _linesAppearOpacity;
  late final Animation<double> _linesSplitProgress;
  late final Animation<double> _wordEmergeScale;

  // Stage 3 (0.60 -> 0.90): Subtitle "Microbiology Department • Faculty of Pharmacy, Beni-Suef University"
  late final Animation<double> _footerOpacity;
  late final Animation<Offset> _footerSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4600),
    );

    _sloganOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.04, 0.26, curve: Curves.easeOut),
    );
    _sloganScale = Tween<double>(begin: 0.86, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.04, 0.28, curve: Curves.easeOutBack),
      ),
    );

    _linesAppearOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.24, 0.34, curve: Curves.easeIn),
    );
    _linesSplitProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.30, 0.66, curve: Curves.easeInOutCubic),
    );
    _wordEmergeScale = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.32, 0.68, curve: Curves.easeOutBack),
      ),
    );

    _footerOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.62, 0.88, curve: Curves.easeOut),
    );
    _footerSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.62, 0.88, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward().whenComplete(() {
      if (mounted) {
        Future<void>.delayed(const Duration(milliseconds: 350), () {
          if (mounted) widget.onCompleted();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061B18),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? _) {
          final double splitGap = _linesSplitProgress.value * 84.0; // Total vertical opening between top & bottom line
          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              // Subtle animated scientific background particles
              CustomPaint(
                painter: _MicrobeCinemaBackdropPainter(progress: _controller.value),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Column(
                    children: <Widget>[
                      // Top Bar with Skip button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: const Color(0xFFD99B26).withOpacity(0.45)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(Icons.play_circle_fill, size: 12, color: Color(0xFFF5B82E)),
                                SizedBox(width: 5),
                                Text(
                                  'BSU OFFICIAL PORTAL INTRO',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.7,
                                    color: Color(0xFFFDE68A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: widget.onCompleted,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white70,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              minimumSize: const Size(0, 28),
                            ),
                            icon: const Text(
                              'Skip Intro',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            label: const Icon(Icons.arrow_forward_ios, size: 11),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Edited BSU Department Logo with golden halo
                      Opacity(
                        opacity: _sloganOpacity.value,
                        child: Transform.scale(
                          scale: _sloganScale.value,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: <Color>[
                                  const Color(0xFFF5B82E).withOpacity(0.42),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: const BsuDeptLogoWidget(size: 106, showGoldBorder: true),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Stage 1: Slogan appearing right in the center of the screen
                      Opacity(
                        opacity: _sloganOpacity.value,
                        child: Transform.scale(
                          scale: _sloganScale.value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B4A40).withOpacity(0.55),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: const Color(0xFFF5B82E).withOpacity(0.55),
                                width: 1.0,
                              ),
                            ),
                            child: const Text(
                              '“Understanding Microbes, Strengthening Health”',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 0.3,
                                color: Color(0xFFFDE68A),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Stage 2: The Top Line & Bottom Line splitting open vertically from the center
                      // and the Department Title emerging from between them!
                      Opacity(
                        opacity: _linesAppearOpacity.value,
                        child: SizedBox(
                          height: 104,
                          width: double.infinity,
                          child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              // Emerging center portal window clipped strictly between Top Line and Bottom Line
                              ClipRect(
                                child: Align(
                                  alignment: Alignment.center,
                                  heightFactor: _linesSplitProgress.value.clamp(0.0, 1.0),
                                  child: Container(
                                    width: double.infinity,
                                    height: 84,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: <Color>[
                                          Colors.transparent,
                                          const Color(0xFF0B4A40).withOpacity(0.65),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                    child: Transform.scale(
                                      scale: _wordEmergeScale.value,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          const Text(
                                            'MICROBIOLOGY & IMMUNOLOGY',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16.5,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.1,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'قسم الميكروبيولوجي والمناعة • جامعة بني سويف',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFFF5B82E).withOpacity(0.95),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // TOP SPLITTING LINE (moves upward from center)
                              Transform.translate(
                                offset: Offset(0, -splitGap / 2),
                                child: _buildGlowingLaserLine(),
                              ),

                              // BOTTOM SPLITTING LINE (moves downward from center)
                              Transform.translate(
                                offset: Offset(0, splitGap / 2),
                                child: _buildGlowingLaserLine(),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Stage 3: Underneath text: "Microbiology Department — Faculty of Pharmacy, Beni-Suef University"
                      SlideTransition(
                        position: _footerSlide,
                        child: Opacity(
                          opacity: _footerOpacity.value,
                          child: Column(
                            children: <Widget>[
                              const Text(
                                'Microbiology Department',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: Color(0xFFF5B82E),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Faculty of Pharmacy, Beni-Suef University (BSU)',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.88),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Progress indicator bar at bottom of intro video
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: _controller.value,
                          minHeight: 3,
                          backgroundColor: Colors.white.withOpacity(0.12),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF5B82E)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGlowingLaserLine() {
    return Container(
      height: 2.2,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(
          colors: <Color>[
            Colors.transparent,
            Color(0xFFD99B26),
            Color(0xFFFFFBEB),
            Color(0xFFD99B26),
            Colors.transparent,
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFFF5B82E).withOpacity(0.65),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class _MicrobeCinemaBackdropPainter extends CustomPainter {
  final double progress;

  _MicrobeCinemaBackdropPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint bgPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0, -0.15),
        radius: 1.05,
        colors: <Color>[
          Color(0xFF0E4D42),
          Color(0xFF07231F),
          Color(0xFF041311),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bgPaint);

    final Paint orbPaint = Paint()..style = PaintingStyle.stroke;
    for (int i = 0; i < 10; i++) {
      final double angle = (progress * 2 * math.pi * 0.35) + (i * 0.65);
      final double radius = 22.0 + (i * 11.0);
      final double cx = (size.width * (0.15 + ((i * 0.19) % 0.72))) + math.cos(angle) * 14;
      final double cy = (size.height * (0.18 + ((i * 0.13) % 0.68))) + math.sin(angle) * 14;
      orbPaint
        ..color = const Color(0xFF34D399).withOpacity(0.07)
        ..strokeWidth = 1.2;
      canvas.drawCircle(Offset(cx, cy), radius, orbPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MicrobeCinemaBackdropPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// ============================================================================
// MAIN ADMIN & SUPER ADMIN SHELL (WITH PRE/POST LOGIN RULES & STUDENT BUTTON)
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

  int _currentPageIndex = 0; // 0 = Doctor Admin, 1 = Super Admin
  bool _isDoctorLoggedIn = false;
  bool _isSuperAdminLoggedIn = false;
  String _loggedDoctorName = '';
  String _loggedDoctorUser = '';
  String _loggedSuperUser = '';

  bool _globalLoading = false;
  String _globalLoadingText = '';

  void _setLoading(bool loading, [String label = '']) {
    if (!mounted) return;
    setState(() {
      _globalLoading = loading;
      _globalLoadingText = label;
    });
  }

  void _switchToPage(int index) {
    if (!mounted) return;
    setState(() {
      _currentPageIndex = index;
    });
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _openStudentPortalModal() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const StudentPortalModalScreen(),
      ),
    );
  }

  void _openServerUrlConfigDialog() {
    final TextEditingController urlCtrl = TextEditingController(text: PortalApiService.webAppUrl);
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Google Apps Script Web App URL', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Ensure this URL ends with /exec from your Google Apps Script deployment:',
                style: TextStyle(fontSize: 11, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: urlCtrl,
                style: const TextStyle(fontSize: 11),
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Web App /exec URL',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                urlCtrl.text = kDefaultWebAppUrl;
              },
              child: const Text('Reset Default', style: TextStyle(fontSize: 11)),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(fontSize: 11)),
            ),
            FilledButton(
              onPressed: () async {
                await PortalApiService.setWebAppUrl(urlCtrl.text);
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Web App URL updated.', style: TextStyle(fontSize: 11.5))),
                  );
                }
              },
              child: const Text('Save URL', style: TextStyle(fontSize: 11)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool anyLoggedIn = _isDoctorLoggedIn || _isSuperAdminLoggedIn;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          backgroundColor: const Color(0xFF0A2E28),
          foregroundColor: Colors.white,
          elevation: 2,
          titleSpacing: 8,
          title: Row(
            children: <Widget>[
              GestureDetector(
                onTap: widget.onReplayIntro,
                onLongPress: _openServerUrlConfigDialog,
                child: const BsuDeptLogoWidget(size: 32, showGoldBorder: true),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'BSU Microbiology & Immunology',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _currentPageIndex == 0
                          ? (_isDoctorLoggedIn
                              ? 'Doctor Hub • $_loggedDoctorName'
                              : 'Faculty of Pharmacy • Doctor Admin')
                          : (_isSuperAdminLoggedIn
                              ? 'Master Hub • @$_loggedSuperUser'
                              : 'Faculty of Pharmacy • Super Admin'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFFFDE68A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            // Post-Login Role Switch Button in Top Bar (switches between Doctor Admin and Super Admin)
            if (anyLoggedIn)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: OutlinedButton.icon(
                  onPressed: () => _switchToPage(_currentPageIndex == 0 ? 1 : 0),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFDE68A),
                    side: BorderSide(color: const Color(0xFFF5B82E).withOpacity(0.6)),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 0),
                    minimumSize: const Size(0, 27),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                  ),
                  icon: Icon(
                    _currentPageIndex == 0 ? Icons.admin_panel_settings : Icons.medical_information,
                    size: 13,
                  ),
                  label: Text(
                    _currentPageIndex == 0 ? 'Super Admin' : 'Doctor Admin',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

            // Small Top-Right Student View Button (always available to enter like a student)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton.icon(
                onPressed: _openStudentPortalModal,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFD99B26),
                  foregroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  minimumSize: const Size(0, 27),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                ),
                icon: const Icon(Icons.school, size: 13),
                label: const Text(
                  'Student',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              // Pre-login swipe indicator pill bar (only shown before login)
              if (!anyLoggedIn)
                Container(
                  width: double.infinity,
                  color: const Color(0xFF0F3B33),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: _buildRoleTopPill(
                          index: 0,
                          icon: Icons.medical_services_outlined,
                          title: 'Doctor Admin Portal',
                          selected: _currentPageIndex == 0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildRoleTopPill(
                          index: 1,
                          icon: Icons.shield_outlined,
                          title: 'Super Admin Master',
                          selected: _currentPageIndex == 1,
                        ),
                      ),
                    ],
                  ),
                ),

              // Main PageView: BouncingScrollPhysics before login, NeverScrollableScrollPhysics after login
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: anyLoggedIn
                      ? const NeverScrollableScrollPhysics()
                      : const BouncingScrollPhysics(),
                  onPageChanged: (int idx) {
                    setState(() {
                      _currentPageIndex = idx;
                    });
                  },
                  children: <Widget>[
                    DoctorAdminWorkspace(
                      onLoadingChanged: _setLoading,
                      onAuthStateChanged: (bool loggedIn, String docName, String docUser) {
                        setState(() {
                          _isDoctorLoggedIn = loggedIn;
                          _loggedDoctorName = docName;
                          _loggedDoctorUser = docUser;
                        });
                      },
                    ),
                    SuperAdminWorkspace(
                      onLoadingChanged: _setLoading,
                      onAuthStateChanged: (bool loggedIn, String masterUser) {
                        setState(() {
                          _isSuperAdminLoggedIn = loggedIn;
                          _loggedSuperUser = masterUser;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Facebook-style floating top circular spinner
          TopFloatingCircularLoader(
            isLoading: _globalLoading,
            label: _globalLoadingText,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleTopPill({
    required int index,
    required IconData icon,
    required String title,
    required bool selected,
  }) {
    return InkWell(
      onTap: () => _switchToPage(index),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFD99B26) : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? const Color(0xFFFDE68A) : Colors.white.withOpacity(0.16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 13,
              color: selected ? const Color(0xFF0F172A) : Colors.white70,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: selected ? const Color(0xFF0F172A) : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ============================================================================
// DOCTOR ADMIN WORKSPACE (ATTENDANCE & EXCUSES + GRADES, SHEETS & APPEALS)
// ============================================================================
class DoctorAdminWorkspace extends StatefulWidget {
  final void Function(bool loading, [String label]) onLoadingChanged;
  final void Function(bool loggedIn, String doctorName, String username) onAuthStateChanged;

  const DoctorAdminWorkspace({
    super.key,
    required this.onLoadingChanged,
    required this.onAuthStateChanged,
  });

  @override
  State<DoctorAdminWorkspace> createState() => _DoctorAdminWorkspaceState();
}

class _DoctorAdminWorkspaceState extends State<DoctorAdminWorkspace>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Login controllers & auth state
  final TextEditingController _userCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _loggedIn = false;
  String _doctorName = '';
  String _username = '';
  String _password = '';
  List<String> _permissions = <String>[];
  JsonMap _visibilityMap = <String, dynamic>{};

  // Top Sub-Portal: 0 = Attendance & Excuses, 1 = Coursework Grades, Sheets & Appeals
  int _activeSubPortal = 0;

  // Sub-Portal 0 (Attendance & Excuses) state
  int _attModeTab = 0; // 0 = Medical Excuses Queue, 1 = Direct Attendance & Full Roster
  String _excUniFilter = 'ALL'; // ALL, BSU, BSNU
  String _excProgFilter = 'ALL'; // ALL, Clinical, General
  String _excSubjFilter = 'ALL';
  String _excStatusFilter = 'All'; // All, Pending, Approved, Rejected
  final TextEditingController _excSearchCtrl = TextEditingController();
  List<JsonMap> _allExcuses = <JsonMap>[];

  // Direct Attendance Single Student & Full Roster state
  String _dirUni = 'Beni-Suef University (BSU)';
  String _dirProg = 'Clinical';
  String _dirSubj = 'Basic Microbiology';
  final TextEditingController _dirStudentIdCtrl = TextEditingController();
  JsonMap? _singleAttRecord;
  final Map<int, String> _singleAttSecEdits = <int, String>{};
  final TextEditingController _singleAttMarksCtrl = TextEditingController();

  List<JsonMap> _rosterStudents = <JsonMap>[];
  Map<String, String> _rosterSectionDates = <String, String>{};
  String _rosterSheetName = '';
  final TextEditingController _rosterSearchCtrl = TextEditingController();
  // key: "$studentId|$secNum" -> "P"/"A"/"E"
  final Map<String, String> _rosterPendingSecChanges = <String, String>{};
  // key: studentId -> marks string
  final Map<String, String> _rosterPendingMarksChanges = <String, String>{};

  // Sub-Portal 1 (Grades, Sheets & Appeals) state
  int _gradesModeTab = 0; // 0 = Student Appeals, 1 = Live Grades Sheet, 2 = Visibility Matrix
  String _grdUni = 'Beni-Suef University (BSU)';
  String _grdProg = 'Clinical';
  String _grdSubj = 'Basic Microbiology';

  // Appeals state
  List<JsonMap> _doctorAppeals = <JsonMap>[];
  String _appealStatusFilter = 'All';
  final TextEditingController _appealSearchCtrl = TextEditingController();

  // Live Grades Sheet state
  JsonMap? _gradesSheetData;
  final TextEditingController _gradesSearchCtrl = TextEditingController();
  // key: rowNumber -> edited JsonMap
  final Map<int, JsonMap> _gradesPendingEdits = <int, JsonMap>{};

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _excSearchCtrl.dispose();
    _dirStudentIdCtrl.dispose();
    _singleAttMarksCtrl.dispose();
    _rosterSearchCtrl.dispose();
    _appealSearchCtrl.dispose();
    _gradesSearchCtrl.dispose();
    super.dispose();
  }

  void _showMsg(String text, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? const Color(0xFFB91C1C) : const Color(0xFF0B4A40),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        content: Text(
          text,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }

  List<String> _permittedSubjectsForTrack(String university, String program) {
    final String tk = resolveTrackKey(university, program);
    final List<String> allowed = <String>[];
    for (final JsonMap s in kSubjectCatalog) {
      final String sName = s['name'].toString();
      if (isDoctorCourseAllowed(_permissions, tk, sName)) {
        allowed.add(sName);
      }
    }
    return allowed;
  }

  List<String> _allPermittedSubjectNamesAnyTrack() {
    final Set<String> names = <String>{};
    for (final String tk in kTrackKeys) {
      for (final JsonMap s in kSubjectCatalog) {
        final String sName = s['name'].toString();
        if (isDoctorCourseAllowed(_permissions, tk, sName)) {
          names.add(sName);
        }
      }
    }
    return names.toList();
  }

  void _syncDefaultPermittedSelections() {
    final List<String> dirAllowed = _permittedSubjectsForTrack(_dirUni, _dirProg);
    if (dirAllowed.isNotEmpty && !dirAllowed.contains(_dirSubj)) {
      _dirSubj = dirAllowed.first;
    }
    final List<String> grdAllowed = _permittedSubjectsForTrack(_grdUni, _grdProg);
    if (grdAllowed.isNotEmpty && !grdAllowed.contains(_grdSubj)) {
      _grdSubj = grdAllowed.first;
    }
  }

  Future<void> _handleDoctorLogin() async {
    final String u = _userCtrl.text.trim();
    final String p = _passCtrl.text.trim();
    if (u.isEmpty || p.isEmpty) {
      _showMsg('Please enter both doctor username and password.', isError: true);
      return;
    }

    widget.onLoadingChanged(true, 'Signing in...');
    final dynamic res = await PortalApiService.callAction('verifyDoctorLogin', <dynamic>[u, p]);
    widget.onLoadingChanged(false);

    final JsonMap map = asJsonMap(res);
    if (map['success'] == true) {
      setState(() {
        _loggedIn = true;
        _username = map['username']?.toString() ?? u;
        _password = p;
        _doctorName = map['doctorName']?.toString() ?? u;
        _permissions = asStringList(map['permissions']);
        _visibilityMap = asJsonMap(map['visibility']);
        _syncDefaultPermittedSelections();
      });
      widget.onAuthStateChanged(true, _doctorName, _username);
      _showMsg('Welcome, $_doctorName');
      await _loadExcusesQueue();
    } else {
      _showMsg(map['message']?.toString() ?? 'Invalid doctor credentials.', isError: true);
    }
  }

  void _handleDoctorLogout() {
    setState(() {
      _loggedIn = false;
      _doctorName = '';
      _username = '';
      _password = '';
      _permissions = <String>[];
      _allExcuses = <JsonMap>[];
      _rosterStudents = <JsonMap>[];
      _doctorAppeals = <JsonMap>[];
      _gradesSheetData = null;
      _passCtrl.clear();
    });
    widget.onAuthStateChanged(false, '', '');
  }

  Future<void> _loadExcusesQueue() async {
    if (!_loggedIn) return;
    widget.onLoadingChanged(true, 'Loading Excuses...');
    final dynamic res = await PortalApiService.callAction('getStudents');
    widget.onLoadingChanged(false);
    if (res is List) {
      setState(() {
        _allExcuses = asJsonMapList(res);
      });
    } else {
      final JsonMap m = asJsonMap(res);
      if (m['message'] != null) {
        _showMsg(m['message'].toString(), isError: true);
      }
    }
  }

  List<JsonMap> _filteredExcuses() {
    final String q = _excSearchCtrl.text.trim().toLowerCase();
    return _allExcuses.where((JsonMap item) {
      final String uni = item['university']?.toString() ?? '';
      final String prog = item['program']?.toString() ?? '';
      final String subj = item['subject']?.toString() ?? '';
      final String status = (item['status']?.toString() ?? 'Pending').trim();
      final String tk = resolveTrackKey(uni, prog);

      // Must be permitted to this doctor
      if (!isDoctorCourseAllowed(_permissions, tk, subj)) {
        return false;
      }

      if (_excUniFilter == 'BSU' && (uni.toLowerCase().contains('national') || uni.toLowerCase().contains('bsnu'))) {
        return false;
      }
      if (_excUniFilter == 'BSNU' && !uni.toLowerCase().contains('national') && !uni.toLowerCase().contains('bsnu')) {
        return false;
      }
      if (_excProgFilter != 'ALL' && !prog.toLowerCase().contains(_excProgFilter.toLowerCase())) {
        return false;
      }
      if (_excSubjFilter != 'ALL' && subj.toLowerCase() != _excSubjFilter.toLowerCase()) {
        return false;
      }
      if (_excStatusFilter != 'All' && status.toLowerCase() != _excStatusFilter.toLowerCase()) {
        return false;
      }
      if (q.isNotEmpty) {
        final String name = (item['name']?.toString() ?? '').toLowerCase();
        final String sid = (item['studentId']?.toString() ?? '').toLowerCase();
        final String sec = (item['sectionRaw']?.toString() ?? '').toLowerCase();
        if (!name.contains(q) && !sid.contains(q) && !sec.contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Future<void> _updateExcuseDecision(JsonMap item, String newStatus) async {
    if (!isDoctorActionAllowed(_permissions, 'ACT_REVIEW_EXCUSES')) {
      _showMsg('You do not have permission to approve/reject medical excuses.', isError: true);
      return;
    }
    final int row = int.tryParse(item['row']?.toString() ?? '0') ?? 0;
    if (row <= 0) return;

    widget.onLoadingChanged(true, '$newStatus Excuse...');
    final dynamic res = await PortalApiService.callAction(
      'updateStatus',
      <dynamic>[row, newStatus, _doctorName, _username],
    );
    widget.onLoadingChanged(false);

    final JsonMap syncMap = asJsonMap(res);
    setState(() {
      item['status'] = newStatus;
      item['actionBy'] = '$_doctorName ($_username)';
    });

    final String syncNote = syncMap['updated'] == true
        ? 'Synced to sheet (${syncMap['sheetName']})'
        : (syncMap['note']?.toString() ?? 'Status updated');
    _showMsg('$newStatus • $syncNote');
  }

  Future<void> _searchSingleStudentAttendance() async {
    final String sid = _dirStudentIdCtrl.text.trim();
    if (sid.isEmpty) {
      _showMsg('Enter a Student ID first.', isError: true);
      return;
    }
    widget.onLoadingChanged(true, 'Looking up student...');
    final dynamic res = await PortalApiService.callAction(
      'getStudentAttendanceForDoctor',
      <dynamic>[_dirUni, _dirProg, _dirSubj, sid],
    );
    widget.onLoadingChanged(false);

    final JsonMap map = asJsonMap(res);
    if (map['found'] == true) {
      final Map<int, String> secMap = <int, String>{};
      final List<JsonMap> secs = asJsonMapList(map['sections']);
      for (final JsonMap s in secs) {
        final int num = int.tryParse(s['sectionNumber']?.toString() ?? '0') ?? 0;
        final String raw = (s['rawStatus']?.toString() ?? '').toUpperCase();
        if (num >= 1 && num <= 12) {
          secMap[num] = (raw == 'A' || raw == 'E') ? raw : 'P';
        }
      }
      final JsonMap stats = asJsonMap(map['stats']);
      setState(() {
        _singleAttRecord = map;
        _singleAttSecEdits
          ..clear()
          ..addAll(secMap);
        _singleAttMarksCtrl.text = stats['attendanceMarks']?.toString() ?? '5';
      });
    } else {
      _showMsg(map['error']?.toString() ?? 'Student ID not found in $_dirSubj.', isError: true);
    }
  }

  Future<void> _saveSingleStudentAttendance() async {
    if (!isDoctorActionAllowed(_permissions, 'ACT_EDIT_ATTENDANCE')) {
      _showMsg('Direct attendance editing is disabled for your account.', isError: true);
      return;
    }
    if (_singleAttRecord == null) return;
    final Map<String, String> secPayload = <String, String>{};
    _singleAttSecEdits.forEach((int k, String v) {
      secPayload[k.toString()] = v;
    });

    widget.onLoadingChanged(true, 'Saving attendance...');
    final dynamic res = await PortalApiService.callAction(
      'updateStudentAttendanceDirect',
      <dynamic>[
        <String, dynamic>{
          'isMaster': false,
          'actorUsername': _username,
          'actorPassword': _password,
          'actorDoctorName': _doctorName,
          'university': _dirUni,
          'program': _dirProg,
          'subject': _dirSubj,
          'studentId': _singleAttRecord!['studentId'],
          'sections': secPayload,
          'attendanceMarks': _singleAttMarksCtrl.text.trim(),
        },
      ],
    );
    widget.onLoadingChanged(false);

    final JsonMap map = asJsonMap(res);
    if (map['success'] == true) {
      if (map['updatedRecord'] != null) {
        setState(() {
          _singleAttRecord = asJsonMap(map['updatedRecord']);
        });
      }
      _showMsg(map['message']?.toString() ?? 'Student attendance saved.');
    } else {
      _showMsg(map['message']?.toString() ?? 'Failed to update attendance.', isError: true);
    }
  }

  Future<void> _loadFullSubjectRoster() async {
    widget.onLoadingChanged(true, 'Loading subject roster...');
    final dynamic res = await PortalApiService.callAction(
      'getSubjectAttendanceRoster',
      <dynamic>[_username, _password, false, _dirUni, _dirProg, _dirSubj],
    );
    widget.onLoadingChanged(false);

    final JsonMap map = asJsonMap(res);
    if (map['success'] == true) {
      final JsonMap rawDates = asJsonMap(map['sectionDates']);
      final Map<String, String> cleanDates = <String, String>{};
      rawDates.forEach((String k, dynamic v) {
        cleanDates[k] = v?.toString() ?? '';
      });
      setState(() {
        _rosterSheetName = map['sheetName']?.toString() ?? '';
        _rosterSectionDates = cleanDates;
        _rosterStudents = asJsonMapList(map['students']);
        _rosterPendingSecChanges.clear();
        _rosterPendingMarksChanges.clear();
      });
      _showMsg('Loaded ${_rosterStudents.length} students from $_rosterSheetName');
    } else {
      _showMsg(map['message']?.toString() ?? 'Failed to load roster.', isError: true);
    }
  }

  Future<void> _saveBulkRosterAttendance() async {
    if (!isDoctorActionAllowed(_permissions, 'ACT_EDIT_ATTENDANCE')) {
      _showMsg('Direct attendance editing is disabled for your account.', isError: true);
      return;
    }
    if (_rosterPendingSecChanges.isEmpty && _rosterPendingMarksChanges.isEmpty) {
      _showMsg('No attendance changes queued.', isError: true);
      return;
    }

    final List<JsonMap> changes = <JsonMap>[];
    _rosterPendingSecChanges.forEach((String key, String val) {
      final List<String> parts = key.split('|');
      if (parts.length == 2) {
        changes.add(<String, dynamic>{
          'studentId': parts[0],
          'sectionNumber': int.tryParse(parts[1]) ?? 1,
          'newValue': val,
        });
      }
    });
    _rosterPendingMarksChanges.forEach((String sid, String marksVal) {
      changes.add(<String, dynamic>{
        'studentId': sid,
        'attendanceMarks': marksVal,
      });
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
          'university': _dirUni,
          'program': _dirProg,
          'subject': _dirSubj,
          'changes': changes,
        },
      ],
    );
    widget.onLoadingChanged(false);

    final JsonMap map = asJsonMap(res);
    if (map['success'] == true) {
      _showMsg(map['message']?.toString() ?? 'Saved bulk attendance changes.');
      await _loadFullSubjectRoster();
    } else {
      _showMsg(map['message']?.toString() ?? 'Failed to save bulk changes.', isError: true);
    }
  }

  // ==========================================================================
  // SUB-PORTAL 1 METHODS: GRADES, APPEALS & VISIBILITY
  // ==========================================================================
  bool _isCourseAnnounced(String trackKey, String subjectNameOrKey) {
    final JsonMap? item = findSubjectByNameOrKey(subjectNameOrKey);
    final String sk = item != null ? item['key'].toString() : subjectNameOrKey;
    final JsonMap trackMap = asJsonMap(_visibilityMap[trackKey]);
    if (trackMap.containsKey(sk)) {
      return trackMap[sk] != false;
    }
    return true;
  }

  Future<void> _toggleCourseVisibility(String trackKey, String subjectNameOrKey, bool nextOpen) async {
    if (!isDoctorActionAllowed(_permissions, 'ACT_TOGGLE_VISIBILITY')) {
      _showMsg('Course visibility switching is disabled for your account.', isError: true);
      return;
    }
    final JsonMap? item = findSubjectByNameOrKey(subjectNameOrKey);
    final String sk = item != null ? item['key'].toString() : subjectNameOrKey;

    widget.onLoadingChanged(true, nextOpen ? 'Announcing course...' : 'Hiding course...');
    final dynamic res = await PortalApiService.callAction(
      'toggleSingleSubjectVisibility',
      <dynamic>[_username, _password, trackKey, sk, nextOpen],
    );
    widget.onLoadingChanged(false);

    final JsonMap map = asJsonMap(res);
    if (map['success'] == true) {
      setState(() {
        _visibilityMap = asJsonMap(map['visibility']);
      });
      _showMsg(map['message']?.toString() ?? 'Visibility updated.');
    } else {
      _showMsg(map['message']?.toString() ?? 'Failed to toggle visibility.', isError: true);
    }
  }

  Future<void> _loadDoctorAppeals() async {
    widget.onLoadingChanged(true, 'Loading grade appeals...');
    final dynamic res = await PortalApiService.callAction(
      'getAppealsForDoctor',
      <dynamic>[_username, _password, _grdUni, _grdProg, _grdSubj],
    );
    widget.onLoadingChanged(false);

    final JsonMap map = asJsonMap(res);
    if (map['success'] == true) {
      setState(() {
        _doctorAppeals = asJsonMapList(map['appeals']);
      });
      _showMsg('Loaded ${_doctorAppeals.length} appeal(s) for $_grdSubj');
    } else {
      _showMsg(map['message']?.toString() ?? 'Failed to load appeals.', isError: true);
    }
  }

  Future<void> _submitAppealReviewDialog(JsonMap appeal) async {
    if (!isDoctorActionAllowed(_permissions, 'ACT_REVIEW_APPEALS')) {
      _showMsg('Appeal review permission is disabled for your account.', isError: true);
      return;
    }

    String decision = (appeal['status']?.toString() == 'Rejected') ? 'Rejected' : 'Approved';
    final TextEditingController bonusPerCtrl = TextEditingController(
      text: (appeal['bonusPeriodical']?.toString() ?? '0'),
    );
    final TextEditingController bonusPracCtrl = TextEditingController(
      text: (appeal['bonusPractical']?.toString() ?? '0'),
    );
    final TextEditingController noteCtrl = TextEditingController(
      text: (appeal['resultText']?.toString() ?? ''),
    );

    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext ctx, void Function(void Function()) setDlgState) {
            return AlertDialog(
              title: Text(
                'Review Appeal • ${appeal['name']} (#${appeal['studentId']})',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Appeal Type: ${appeal['appealType']}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Original Marks: Periodical [${appeal['origPeriodical']}] | Practical [${appeal['origPractical']}]',
                            style: const TextStyle(fontSize: 10.5, color: Color(0xFF475569)),
                          ),
                          Text(
                            'Current Live Marks: Periodical [${appeal['currentPeriodical']}] | Practical [${appeal['currentPractical']}]',
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF0B4A40)),
                          ),
                          if ((appeal['comment']?.toString() ?? '').isNotEmpty) ...<Widget>[
                            const SizedBox(height: 4),
                            Text(
                              'Student Note: "${appeal['comment']}"',
                              style: const TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Decision:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 5),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Approve (+Bonus)', style: TextStyle(fontSize: 10.5)),
                            selected: decision == 'Approved',
                            onSelected: (_) => setDlgState(() => decision = 'Approved'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Reject (No Bonus)', style: TextStyle(fontSize: 10.5)),
                            selected: decision == 'Rejected',
                            onSelected: (_) => setDlgState(() => decision = 'Rejected'),
                          ),
                        ),
                      ],
                    ),
                    if (decision == 'Approved') ...<Widget>[
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: bonusPerCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(fontSize: 11.5),
                              decoration: const InputDecoration(
                                labelText: '+Bonus Periodical',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: bonusPracCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(fontSize: 11.5),
                              decoration: const InputDecoration(
                                labelText: '+Bonus Practical',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 10),
                    TextField(
                      controller: noteCtrl,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 11.5),
                      decoration: const InputDecoration(
                        labelText: 'Doctor Note / Result Message (Optional)',
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel', style: TextStyle(fontSize: 11)),
                ),
                FilledButton(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    widget.onLoadingChanged(true, 'Saving appeal decision...');
                    final dynamic res = await PortalApiService.callAction(
                      'processDoctorAppealDecision',
                      <dynamic>[
                        <String, dynamic>{
                          'username': _username,
                          'password': _password,
                          'university': _grdUni,
                          'program': _grdProg,
                          'subject': _grdSubj,
                          'row': appeal['row'],
                          'studentId': appeal['studentId'],
                          'decision': decision,
                          'bonusPeriodical': double.tryParse(bonusPerCtrl.text.trim()) ?? 0,
                          'bonusPractical': double.tryParse(bonusPracCtrl.text.trim()) ?? 0,
                          'doctorNote': noteCtrl.text.trim(),
                        },
                      ],
                    );
                    widget.onLoadingChanged(false);
                    final JsonMap m = asJsonMap(res);
                    if (m['success'] == true) {
                      _showMsg('Appeal decision saved & synced to grades sheet.');
                      await _loadDoctorAppeals();
                    } else {
                      _showMsg(m['message']?.toString() ?? 'Error saving appeal.', isError: true);
                    }
                  },
                  child: const Text('Save & Sync Sheet', style: TextStyle(fontSize: 11)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _loadCourseGradesSheet() async {
    widget.onLoadingChanged(true, 'Loading live grades sheet...');
    final dynamic res = await PortalApiService.callAction(
      'getCourseGradesSheetForDoctor',
      <dynamic>[_username, _password, _grdUni, _grdProg, _grdSubj],
    );
    widget.onLoadingChanged(false);

    final JsonMap map = asJsonMap(res);
    if (map['success'] == true) {
      setState(() {
        _gradesSheetData = map;
        _gradesPendingEdits.clear();
      });
    } else {
      _showMsg(map['message']?.toString() ?? 'Could not load grades sheet.', isError: true);
    }
  }

  Future<void> _savePendingGradesSheetEdits() async {
    if (!isDoctorActionAllowed(_permissions, 'ACT_EDIT_GRADES')) {
      _showMsg('Editing live grades is disabled for your account.', isError: true);
      return;
    }
    if (_gradesPendingEdits.isEmpty) {
      _showMsg('No student rows modified yet.', isError: true);
      return;
    }

    widget.onLoadingChanged(true, 'Saving ${_gradesPendingEdits.length} grade row(s)...');
    final dynamic res = await PortalApiService.callAction(
      'saveStudentGradesEditsByDoctor',
      <dynamic>[
        <String, dynamic>{
          'username': _username,
          'password': _password,
          'university': _grdUni,
          'program': _grdProg,
          'subject': _grdSubj,
          'edits': _gradesPendingEdits.values.toList(),
        },
      ],
    );
    widget.onLoadingChanged(false);

    final JsonMap map = asJsonMap(res);
    if (map['success'] == true) {
      setState(() {
        _gradesSheetData = map;
        _gradesPendingEdits.clear();
      });
      _showMsg(map['saveMessage']?.toString() ?? 'Grades saved to sheet.');
    } else {
      _showMsg(map['message']?.toString() ?? 'Failed to save grades.', isError: true);
    }
  }

  Future<void> _openEditSingleGradeRowDialog(JsonMap stRow) async {
    if (!isDoctorActionAllowed(_permissions, 'ACT_EDIT_GRADES')) {
      _showMsg('Editing live grades is disabled for your account.', isError: true);
      return;
    }
    final int rowNum = int.tryParse(stRow['rowNumber']?.toString() ?? '0') ?? 0;
    final JsonMap existingEdit = _gradesPendingEdits[rowNum] ?? stRow;
    final bool hasPractical = _gradesSheetData?['hasPractical'] != false;

    final TextEditingController idCtrl = TextEditingController(text: existingEdit['studentId']?.toString() ?? '');
    final TextEditingController nameCtrl = TextEditingController(text: existingEdit['name']?.toString() ?? '');
    final TextEditingController perCtrl = TextEditingController(
      text: (existingEdit['periodical']?.toString() == '—') ? '' : (existingEdit['periodical']?.toString() ?? ''),
    );
    final TextEditingController pracCtrl = TextEditingController(
      text: (existingEdit['practical']?.toString() == '—') ? '' : (existingEdit['practical']?.toString() ?? ''),
    );

    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text('Edit Row #$rowNum • ${stRow['name']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: idCtrl,
                  style: const TextStyle(fontSize: 11.5),
                  decoration: const InputDecoration(labelText: 'Student ID'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(fontSize: 11.5),
                  decoration: const InputDecoration(labelText: 'Student Full Name'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: perCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 11.5),
                        decoration: InputDecoration(
                          labelText: _gradesSheetData?['periodicalTitle']?.toString() ?? 'Periodical',
                        ),
                      ),
                    ),
                    if (hasPractical) ...<Widget>[
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: pracCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(fontSize: 11.5),
                          decoration: InputDecoration(
                            labelText: _gradesSheetData?['practicalTitle']?.toString() ?? 'Practical',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(fontSize: 11)),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  _gradesPendingEdits[rowNum] = <String, dynamic>{
                    'rowNumber': rowNum,
                    'originalStudentId': stRow['studentId'],
                    'studentId': idCtrl.text.trim(),
                    'name': nameCtrl.text.trim(),
                    'periodical': perCtrl.text.trim(),
                    'practical': hasPractical ? pracCtrl.text.trim() : '',
                  };
                });
                Navigator.of(ctx).pop();
                _showMsg('Row #$rowNum queued for save. Tap "Save Sheet Edits" to commit.');
              },
              child: const Text('Queue Edit', style: TextStyle(fontSize: 11)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openAddStudentGradeDialog() async {
    if (!isDoctorActionAllowed(_permissions, 'ACT_EDIT_GRADES')) {
      _showMsg('Adding students is disabled for your account.', isError: true);
      return;
    }
    final TextEditingController idCtrl = TextEditingController();
    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController perCtrl = TextEditingController();
    final TextEditingController pracCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text('Add New Student to $_grdSubj', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: idCtrl,
                  style: const TextStyle(fontSize: 11.5),
                  decoration: const InputDecoration(labelText: 'Student ID *'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(fontSize: 11.5),
                  decoration: const InputDecoration(labelText: 'Student Name *'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: perCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 11.5),
                        decoration: const InputDecoration(labelText: 'Periodical Mark'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: pracCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 11.5),
                        decoration: const InputDecoration(labelText: 'Practical Mark'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(fontSize: 11)),
            ),
            FilledButton(
              onPressed: () async {
                if (idCtrl.text.trim().isEmpty || nameCtrl.text.trim().isEmpty) {
                  _showMsg('Student ID and Name are required.', isError: true);
                  return;
                }
                Navigator.of(ctx).pop();
                widget.onLoadingChanged(true, 'Adding student row...');
                final dynamic res = await PortalApiService.callAction(
                  'addStudentRowToGradesSheetByDoctor',
                  <dynamic>[
                    <String, dynamic>{
                      'username': _username,
                      'password': _password,
                      'university': _grdUni,
                      'program': _grdProg,
                      'subject': _grdSubj,
                      'studentId': idCtrl.text.trim(),
                      'name': nameCtrl.text.trim(),
                      'periodical': perCtrl.text.trim(),
                      'practical': pracCtrl.text.trim(),
                    },
                  ],
                );
                widget.onLoadingChanged(false);
                final JsonMap m = asJsonMap(res);
                if (m['success'] == true) {
                  setState(() {
                    _gradesSheetData = m;
                  });
                  _showMsg(m['saveMessage']?.toString() ?? 'Student added.');
                } else {
                  _showMsg(m['message']?.toString() ?? 'Failed to add student.', isError: true);
                }
              },
              child: const Text('Add to Sheet', style: TextStyle(fontSize: 11)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteStudentGradeRow(JsonMap stRow) async {
    if (!isDoctorActionAllowed(_permissions, 'ACT_EDIT_GRADES')) {
      _showMsg('Deleting rows is disabled for your account.', isError: true);
      return;
    }
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Delete Student Row?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        content: Text(
          'Delete ${stRow['name']} (#${stRow['studentId']}) at Row #${stRow['rowNumber']} from $_grdSubj?',
          style: const TextStyle(fontSize: 11.5),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel', style: TextStyle(fontSize: 11))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB91C1C)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete Row', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    widget.onLoadingChanged(true, 'Deleting row...');
    final dynamic res = await PortalApiService.callAction(
      'deleteStudentRowFromGradesSheetByDoctor',
      <dynamic>[
        <String, dynamic>{
          'username': _username,
          'password': _password,
          'university': _grdUni,
          'program': _grdProg,
          'subject': _grdSubj,
          'rowNumber': stRow['rowNumber'],
          'studentId': stRow['studentId'],
        },
      ],
    );
    widget.onLoadingChanged(false);
    final JsonMap m = asJsonMap(res);
    if (m['success'] == true) {
      setState(() {
        _gradesSheetData = m;
      });
      _showMsg(m['saveMessage']?.toString() ?? 'Row deleted.');
    } else {
      _showMsg(m['message']?.toString() ?? 'Failed to delete row.', isError: true);
    }
  }

  Future<void> _openChangeOwnCredentialsDialog() async {
    if (!isDoctorActionAllowed(_permissions, 'ACT_CHANGE_CRED')) {
      _showMsg('Self-credential changes are disabled for your account.', isError: true);
      return;
    }
    final TextEditingController newU = TextEditingController(text: _username);
    final TextEditingController newP = TextEditingController(text: _password);

    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Update Doctor Credentials', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: newU,
                style: const TextStyle(fontSize: 11.5),
                decoration: const InputDecoration(labelText: 'New Username'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: newP,
                style: const TextStyle(fontSize: 11.5),
                decoration: const InputDecoration(labelText: 'New Password'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel', style: TextStyle(fontSize: 11))),
            FilledButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                widget.onLoadingChanged(true, 'Updating credentials...');
                final dynamic res = await PortalApiService.callAction(
                  'updateOwnDoctorCredentials',
                  <dynamic>[_username, _password, newU.text.trim(), newP.text.trim()],
                );
                widget.onLoadingChanged(false);
                final JsonMap m = asJsonMap(res);
                if (m['success'] == true) {
                  setState(() {
                    _username = m['newUsername']?.toString() ?? newU.text.trim();
                    _password = m['newPassword']?.toString() ?? newP.text.trim();
                  });
                  widget.onAuthStateChanged(true, _doctorName, _username);
                  _showMsg(m['message']?.toString() ?? 'Credentials updated.');
                } else {
                  _showMsg(m['message']?.toString() ?? 'Failed to update credentials.', isError: true);
                }
              },
              child: const Text('Save Changes', style: TextStyle(fontSize: 11)),
            ),
          ],
        );
      },
    );
  }

  void _openExcuseImagePreview(String url, String title) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(12),
          child: Stack(
            children: <Widget>[
               SizedBox(
                width: double.infinity,
                height: MediaQuery.of(ctx).size.height * 0.72,
                child: InteractiveViewer(
                  minScale: 0.6,
                  maxScale: 4.5,
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Text('Unable to load image preview.', style: TextStyle(color: Colors.white70, fontSize: 11.5)),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 10,
                right: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================================
  // UI BUILDERS FOR DOCTOR ADMIN WORKSPACE
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_loggedIn) {
      return _buildDoctorLoginView();
    }

    return Column(
      children: <Widget>[
        _buildDoctorTopIdentityBar(),
        _buildDoctorSubPortalSwitcher(),
        Expanded(
          child: _activeSubPortal == 0
              ? _buildAttendanceAndExcusesPortal()
              : _buildGradesAndAppealsPortal(),
        ),
      ],
    );
  }

  Widget _buildDoctorLoginView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const BsuDeptLogoWidget(size: 68, showGoldBorder: true),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B4A40).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'FACULTY OF PHARMACY • BSU',
                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF0B4A40)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Doctor Admin Portal',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Sign in to manage practical attendance, medical excuses, coursework grades & student appeals.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _userCtrl,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      labelText: 'Doctor Username',
                      prefixIcon: Icon(Icons.person_outline, size: 17),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passCtrl,
                    obscureText: _obscurePass,
                    style: const TextStyle(fontSize: 12),
                    onSubmitted: (_) => _handleDoctorLogin(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline, size: 17),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility, size: 16),
                        onPressed: () => setState(() => _obscurePass = !_obscurePass),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: FilledButton.icon(
                      onPressed: _handleDoctorLogin,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0B4A40),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.login, size: 15),
                      label: const Text(
                        'Sign In to Doctor Hub',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.swipe_left, size: 13, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'Swipe left for Super Admin Master Login',
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorTopIdentityBar() {
    final int courseCount = _permissions.where((String p) => p.contains('__')).length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFF0B4A40).withOpacity(0.1),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(Icons.verified_user, size: 15, color: Color(0xFF0B4A40)),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _doctorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                Text(
                  '@$_username • $courseCount Permitted Course Offerings',
                  style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _openChangeOwnCredentialsDialog,
            tooltip: 'Change Username / Password',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.key, size: 16, color: Color(0xFF0B4A40)),
          ),
          IconButton(
            onPressed: () {
              if (_activeSubPortal == 0) {
                if (_attModeTab == 0) {
                  _loadExcusesQueue();
                } else {
                  _loadFullSubjectRoster();
                }
              } else {
                if (_gradesModeTab == 0) {
                  _loadDoctorAppeals();
                } else if (_gradesModeTab == 1) {
                  _loadCourseGradesSheet();
                }
              }
            },
            tooltip: 'Refresh Data',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.refresh, size: 16, color: Color(0xFF334155)),
          ),
          IconButton(
            onPressed: _handleDoctorLogout,
            tooltip: 'Sign Out',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.logout, size: 16, color: Color(0xFFB91C1C)),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorSubPortalSwitcher() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      color: const Color(0xFFF8FAFC),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _buildSubPortalButton(
              index: 0,
              icon: Icons.fact_check_outlined,
              label: '1. Attendance & Excuses',
              selected: _activeSubPortal == 0,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSubPortalButton(
              index: 1,
              icon: Icons.assessment_outlined,
              label: '2. Grades, Sheets & Appeals',
              selected: _activeSubPortal == 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubPortalButton({
    required int index,
    required IconData icon,
    required String label,
    required bool selected,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _activeSubPortal = index;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0B4A40) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? const Color(0xFF0B4A40) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 13.5, color: selected ? const Color(0xFFFDE68A) : const Color(0xFF475569)),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // SUB-PORTAL 0: ATTENDANCE & MEDICAL EXCUSES
  // ==========================================================================
  Widget _buildAttendanceAndExcusesPortal() {
    return Column(
      children: <Widget>[
        // Mode tabs: Excuses Queue vs Direct Attendance & Roster
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          color: Colors.white,
          child: Row(
            children: <Widget>[
              Expanded(
                child: _buildMiniTabButton(
                  title: '📩 Medical Excuses (${_filteredExcuses().length})',
                  selected: _attModeTab == 0,
                  onTap: () => setState(() => _attModeTab = 0),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildMiniTabButton(
                  title: '✏️ Direct Attendance & Roster',
                  selected: _attModeTab == 1,
                  onTap: () => setState(() => _attModeTab = 1),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _attModeTab == 0
              ? _buildExcusesQueueView()
              : _buildDirectAttendanceAndRosterView(),
        ),
      ],
    );
  }

  Widget _buildExcusesQueueView() {
    final List<JsonMap> list = _filteredExcuses();
    int pendingCnt = 0;
    int approvedCnt = 0;
    int rejectedCnt = 0;
    for (final JsonMap e in list) {
      final String st = (e['status']?.toString() ?? 'Pending');
      if (st == 'Approved') {
        approvedCnt++;
      } else if (st == 'Rejected') {
        rejectedCnt++;
      } else {
        pendingCnt++;
      }
    }

    final List<String> allPermSubjs = <String>['ALL', ..._allPermittedSubjectNamesAnyTrack()];
    if (!allPermSubjs.contains(_excSubjFilter)) {
      _excSubjFilter = 'ALL';
    }

    return ListView(
      padding: const EdgeInsets.all(10),
      children: <Widget>[
        // Compact Filter Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _excUniFilter,
                        isExpanded: true,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF0F172A)),
                        decoration: const InputDecoration(labelText: 'University'),
                        items: const <StringDropItem>[
                          DropdownMenuItem<String>(value: 'ALL', child: Text('All Universities')),
                          DropdownMenuItem<String>(value: 'BSU', child: Text('BSU (الحكومية)')),
                          DropdownMenuItem<String>(value: 'BSNU', child: Text('BSNU (الأهلية)')),
                        ],
                        onChanged: (String? v) => setState(() => _excUniFilter = v ?? 'ALL'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _excProgFilter,
                        isExpanded: true,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF0F172A)),
                        decoration: const InputDecoration(labelText: 'Program'),
                        items: const <StringDropItem>[
                          DropdownMenuItem<String>(value: 'ALL', child: Text('All Programs')),
                          DropdownMenuItem<String>(value: 'Clinical', child: Text('Clinical')),
                          DropdownMenuItem<String>(value: 'General', child: Text('General')),
                        ],
                        onChanged: (String? v) => setState(() => _excProgFilter = v ?? 'ALL'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 5,
                      child: DropdownButtonFormField<String>(
                        value: _excSubjFilter,
                        isExpanded: true,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF0F172A)),
                        decoration: const InputDecoration(labelText: 'Permitted Course'),
                        items: allPermSubjs
                            .map((String s) => DropdownMenuItem<String>(
                                  value: s,
                                  child: Text(s == 'ALL' ? 'All Permitted Courses' : s, overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (String? v) => setState(() => _excSubjFilter = v ?? 'ALL'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: _excSearchCtrl,
                        style: const TextStyle(fontSize: 11),
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Search Name / ID',
                          prefixIcon: Icon(Icons.search, size: 15),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <String>['All', 'Pending', 'Approved', 'Rejected'].map((String st) {
                      final bool sel = _excStatusFilter == st;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(st, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: sel ? Colors.white : const Color(0xFF334155))),
                          selected: sel,
                          selectedColor: const Color(0xFF0B4A40),
                          visualDensity: VisualDensity.compact,
                          onSelected: (_) => setState(() => _excStatusFilter = st),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // KPI Strip
        Row(
          children: <Widget>[
            _buildMiniKpiCard('Total', '${list.length}', const Color(0xFF1E293B)),
            const SizedBox(width: 6),
            _buildMiniKpiCard('Pending', '$pendingCnt', const Color(0xFFD97706)),
            const SizedBox(width: 6),
            _buildMiniKpiCard('Approved (E)', '$approvedCnt', const Color(0xFF059669)),
            const SizedBox(width: 6),
            _buildMiniKpiCard('Rejected (A)', '$rejectedCnt', const Color(0xFFDC2626)),
          ],
        ),

        const SizedBox(height: 8),

        if (list.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  const Icon(Icons.inbox_outlined, size: 28, color: Color(0xFF94A3B8)),
                  const SizedBox(height: 6),
                  const Text('No medical excuse requests match your current filters.', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _loadExcusesQueue,
                    icon: const Icon(Icons.refresh, size: 14),
                    label: const Text('Reload Excuses Queue', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ),
          )
        else
          ...list.map(_buildExcuseItemCard),
      ],
    );
  }

  Widget _buildExcuseItemCard(JsonMap item) {
    final String status = item['status']?.toString() ?? 'Pending';
    final Color statusColor = status == 'Approved'
        ? const Color(0xFF059669)
        : (status == 'Rejected' ? const Color(0xFFDC2626) : const Color(0xFFD97706));
    final List<JsonMap> files = asJsonMapList(item['files']);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${item['name']}  •  ID: ${item['studentId']}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${item['university']} • ${item['program']} • ${item['subject']}',
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF0B4A40)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: statusColor.withOpacity(0.4)),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: statusColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: <Widget>[
                  _buildTagPill(Icons.calendar_today, '${item['sectionRaw']}'),
                  if ((item['timestamp']?.toString() ?? '').isNotEmpty)
                    _buildTagPill(Icons.access_time, '${item['timestamp']}'),
                  if ((item['actionBy']?.toString() ?? '').isNotEmpty)
                    _buildTagPill(Icons.verified_outlined, 'By: ${item['actionBy']}'),
                ],
              ),
              if ((item['comment']?.toString() ?? '').isNotEmpty) ...<Widget>[
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Comment: ${item['comment']}',
                    style: const TextStyle(fontSize: 10.5, color: Color(0xFF334155)),
                  ),
                ),
              ],
              if (files.isNotEmpty) ...<Widget>[
                const SizedBox(height: 7),
                SizedBox(
                  height: 54,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: files.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (BuildContext context, int i) {
                      final String url = files[i]['url']?.toString() ?? '';
                      return InkWell(
                        onTap: () => _openExcuseImagePreview(url, '${item['name']} • ${item['sectionRaw']}'),
                        child: Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, size: 20, color: Color(0xFF64748B)),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: SizedBox(
                      height: 29,
                      child: FilledButton.icon(
                        onPressed: () => _updateExcuseDecision(item, 'Approved'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        icon: const Icon(Icons.check_circle_outline, size: 13),
                        label: const Text('Approve (Sync E)', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 29,
                      child: OutlinedButton.icon(
                        onPressed: () => _updateExcuseDecision(item, 'Rejected'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          side: const BorderSide(color: Color(0xFFDC2626)),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        icon: const Icon(Icons.cancel_outlined, size: 13),
                        label: const Text('Reject (Sync A)', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDirectAttendanceAndRosterView() {
    final List<String> allowedSubjs = _permittedSubjectsForTrack(_dirUni, _dirProg);
    if (allowedSubjs.isNotEmpty && !allowedSubjs.contains(_dirSubj)) {
      _dirSubj = allowedSubjs.first;
    }

    final String q = _rosterSearchCtrl.text.trim().toLowerCase();
    final List<JsonMap> filteredRoster = _rosterStudents.where((JsonMap s) {
      if (q.isEmpty) return true;
      final String sid = (s['studentId']?.toString() ?? '').toLowerCase();
      final String sname = (s['studentName']?.toString() ?? '').toLowerCase();
      return sid.contains(q) || sname.contains(q);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(10),
      children: <Widget>[
        // Course selector card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Select Track & Course for Direct Attendance',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _dirUni,
                        isExpanded: true,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF0F172A)),
                        decoration: const InputDecoration(labelText: 'University'),
                        items: const <StringDropItem>[
                          DropdownMenuItem<String>(value: 'Beni-Suef University (BSU)', child: Text('BSU (الحكومية)')),
                          DropdownMenuItem<String>(value: 'Beni-Suef National University (BSNU)', child: Text('BSNU (الأهلية)')),
                        ],
                        onChanged: (String? v) {
                          if (v == null) return;
                          setState(() {
                            _dirUni = v;
                            _syncDefaultPermittedSelections();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _dirProg,
                        isExpanded: true,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF0F172A)),
                        decoration: const InputDecoration(labelText: 'Program'),
                        items: const <StringDropItem>[
                          DropdownMenuItem<String>(value: 'Clinical', child: Text('Clinical')),
                          DropdownMenuItem<String>(value: 'General', child: Text('General')),
                        ],
                        onChanged: (String? v) {
                          if (v == null) return;
                          setState(() {
                            _dirProg = v;
                            _syncDefaultPermittedSelections();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: allowedSubjs.contains(_dirSubj) ? _dirSubj : (allowedSubjs.isNotEmpty ? allowedSubjs.first : null),
                  isExpanded: true,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF0F172A)),
                  decoration: const InputDecoration(labelText: 'Permitted Subject'),
                  items: allowedSubjs
                      .map((String s) => DropdownMenuItem<String>(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (String? v) {
                    if (v != null) setState(() => _dirSubj = v);
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _dirStudentIdCtrl,
                        style: const TextStyle(fontSize: 11.5),
                        onSubmitted: (_) => _searchSingleStudentAttendance(),
                        decoration: const InputDecoration(
                          labelText: 'Quick Student ID Lookup',
                          prefixIcon: Icon(Icons.badge_outlined, size: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      height: 34,
                      child: FilledButton.icon(
                        onPressed: _searchSingleStudentAttendance,
                        icon: const Icon(Icons.search, size: 14),
                        label: const Text('Find ID', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      height: 34,
                      child: OutlinedButton.icon(
                        onPressed: _loadFullSubjectRoster,
                        icon: const Icon(Icons.table_chart_outlined, size: 14),
                        label: const Text('Full Roster', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Single student direct attendance card (when searched)
        if (_singleAttRecord != null) ...<Widget>[
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          '${_singleAttRecord!['studentName']} (#${_singleAttRecord!['studentId']})',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _singleAttRecord = null),
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.close, size: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: List<Widget>.generate(12, (int i) {
                      final int sec = i + 1;
                      final String val = _singleAttSecEdits[sec] ?? 'P';
                      final Color c = val == 'A'
                          ? const Color(0xFFDC2626)
                          : (val == 'E' ? const Color(0xFFD97706) : const Color(0xFF059669));
                      return InkWell(
                        onTap: () {
                          setState(() {
                            final String next = val == 'P' ? 'A' : (val == 'A' ? 'E' : 'P');
                            _singleAttSecEdits[sec] = next;
                          });
                        },
                        child: Container(
                          width: 68,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                          decoration: BoxDecoration(
                            color: c.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(color: c),
                          ),
                          child: Column(
                            children: <Widget>[
                              Text('Sec $sec', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700)),
                              Text(val, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: c)),
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
                        width: 120,
                        child: TextField(
                          controller: _singleAttMarksCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(fontSize: 11.5),
                          decoration: const InputDecoration(labelText: 'Marks (/5)'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 34,
                          child: FilledButton.icon(
                            onPressed: _saveSingleStudentAttendance,
                            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0B4A40)),
                            icon: const Icon(Icons.save_outlined, size: 14),
                            label: const Text('Save Student Attendance', style: TextStyle(fontSize: 11)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],

        // Full Subject Roster Table (when loaded)
        if (_rosterStudents.isNotEmpty) ...<Widget>[
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Roster: $_rosterSheetName (${filteredRoster.length} students)',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (_rosterPendingSecChanges.isNotEmpty || _rosterPendingMarksChanges.isNotEmpty)
                        SizedBox(
                          height: 29,
                          child: FilledButton.icon(
                            onPressed: _saveBulkRosterAttendance,
                            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD97706)),
                            icon: const Icon(Icons.save, size: 13),
                            label: Text(
                              'Save (${_rosterPendingSecChanges.length + _rosterPendingMarksChanges.length})',
                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _rosterSearchCtrl,
                    style: const TextStyle(fontSize: 11),
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Filter Roster by Name or Student ID (Tap any section cell to cycle P → A → E)',
                      prefixIcon: Icon(Icons.filter_list, size: 15),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowHeight: 30,
                      dataRowMinHeight: 30,
                      dataRowMaxHeight: 34,
                      columnSpacing: 8,
                      horizontalMargin: 6,
                      columns: <DataColumn>[
                        const DataColumn(label: Text('ID', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                        const DataColumn(label: Text('Student Name', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                        ...List<DataColumn>.generate(12, (int i) {
                          final int s = i + 1;
                          return DataColumn(
                            label: Text('S$s', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
                          );
                        }),
                        const DataColumn(label: Text('Marks', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                      ],
                      rows: filteredRoster.take(120).map((JsonMap st) {
                        final String sid = st['studentId']?.toString() ?? '';
                        final JsonMap secs = asJsonMap(st['sections']);
                        return DataRow(
                          cells: <DataCell>[
                            DataCell(Text(sid, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700))),
                            DataCell(
                              SizedBox(
                                width: 130,
                                child: Text(
                                  st['studentName']?.toString() ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 10.5),
                                ),
                              ),
                            ),
                            ...List<DataCell>.generate(12, (int i) {
                              final int secNum = i + 1;
                              final String key = '$sid|$secNum';
                              final String curVal = _rosterPendingSecChanges[key] ??
                                  (secs[secNum.toString()]?.toString() ?? 'P');
                              final Color c = curVal == 'A'
                                  ? const Color(0xFFDC2626)
                                  : (curVal == 'E' ? const Color(0xFFD97706) : const Color(0xFF059669));
                              return DataCell(
                                InkWell(
                                  onTap: () {
                                    final String next = curVal == 'P' ? 'A' : (curVal == 'A' ? 'E' : 'P');
                                    setState(() {
                                      _rosterPendingSecChanges[key] = next;
                                    });
                                  },
                                  child: Container(
                                    width: 24,
                                    height: 22,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: c.withOpacity(0.14),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: _rosterPendingSecChanges.containsKey(key) ? const Color(0xFF0F172A) : c,
                                        width: _rosterPendingSecChanges.containsKey(key) ? 1.4 : 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      curVal,
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: c),
                                    ),
                                  ),
                                ),
                              );
                            }),
                            DataCell(
                              Text(
                                _rosterPendingMarksChanges[sid] ?? (st['attendanceMarks']?.toString() ?? '5'),
                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ==========================================================================
  // SUB-PORTAL 1: COURSEWORK GRADES, SHEETS & APPEALS
  // ==========================================================================
  Widget _buildGradesAndAppealsPortal() {
    final List<String> allowedSubjs = _permittedSubjectsForTrack(_grdUni, _grdProg);
    if (allowedSubjs.isNotEmpty && !allowedSubjs.contains(_grdSubj)) {
      _grdSubj = allowedSubjs.first;
    }
    final String currentTrackKey = resolveTrackKey(_grdUni, _grdProg);
    final bool isAnnounced = _isCourseAnnounced(currentTrackKey, _grdSubj);

    return Column(
      children: <Widget>[
        // Course & Track Selector + Live Visibility Switch
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _grdUni,
                      isExpanded: true,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF0F172A)),
                      decoration: const InputDecoration(labelText: 'University'),
                      items: const <StringDropItem>[
                        DropdownMenuItem<String>(value: 'Beni-Suef University (BSU)', child: Text('BSU (الحكومية)')),
                        DropdownMenuItem<String>(value: 'Beni-Suef National University (BSNU)', child: Text('BSNU (الأهلية)')),
                      ],
                      onChanged: (String? v) {
                        if (v == null) return;
                        setState(() {
                          _grdUni = v;
                          _syncDefaultPermittedSelections();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _grdProg,
                      isExpanded: true,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF0F172A)),
                      decoration: const InputDecoration(labelText: 'Program'),
                      items: const <StringDropItem>[
                        DropdownMenuItem<String>(value: 'Clinical', child: Text('Clinical')),
                        DropdownMenuItem<String>(value: 'General', child: Text('General')),
                      ],
                      onChanged: (String? v) {
                        if (v == null) return;
                        setState(() {
                          _grdProg = v;
                          _syncDefaultPermittedSelections();
                        });
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
                      value: allowedSubjs.contains(_grdSubj) ? _grdSubj : (allowedSubjs.isNotEmpty ? allowedSubjs.first : null),
                      isExpanded: true,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF0F172A)),
                      decoration: const InputDecoration(labelText: 'Permitted Course'),
                      items: allowedSubjs
                          .map((String s) => DropdownMenuItem<String>(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (String? v) {
                        if (v != null) setState(() => _grdSubj = v);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Instant Course Visibility Toggle Button
                  InkWell(
                    onTap: () => _toggleCourseVisibility(currentTrackKey, _grdSubj, !isAnnounced),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                      decoration: BoxDecoration(
                        color: isAnnounced ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isAnnounced ? const Color(0xFF059669) : const Color(0xFFDC2626),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            isAnnounced ? Icons.visibility : Icons.visibility_off,
                            size: 13.5,
                            color: isAnnounced ? const Color(0xFF059669) : const Color(0xFFDC2626),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isAnnounced ? 'Announced' : 'Hidden',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: isAnnounced ? const Color(0xFF059669) : const Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _buildMiniTabButton(
                      title: '⚖️ Appeals (${_doctorAppeals.length})',
                      selected: _gradesModeTab == 0,
                      onTap: () {
                        setState(() => _gradesModeTab = 0);
                        _loadDoctorAppeals();
                      },
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: _buildMiniTabButton(
                      title: '📑 Live Grades Sheet',
                      selected: _gradesModeTab == 1,
                      onTap: () {
                        setState(() => _gradesModeTab = 1);
                        _loadCourseGradesSheet();
                      },
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: _buildMiniTabButton(
                      title: '👁️ Visibility Matrix',
                      selected: _gradesModeTab == 2,
                      onTap: () => setState(() => _gradesModeTab = 2),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: _gradesModeTab == 0
              ? _buildDoctorAppealsTab()
              : (_gradesModeTab == 1 ? _buildDoctorLiveGradesSheetTab() : _buildDoctorVisibilityMatrixTab()),
        ),
      ],
    );
  }

  Widget _buildDoctorAppealsTab() {
    final String q = _appealSearchCtrl.text.trim().toLowerCase();
    final List<JsonMap> filtered = _doctorAppeals.where((JsonMap a) {
      final String st = a['status']?.toString() ?? 'Pending';
      if (_appealStatusFilter != 'All' && st.toLowerCase() != _appealStatusFilter.toLowerCase()) {
        return false;
      }
      if (q.isNotEmpty) {
        final String sid = (a['studentId']?.toString() ?? '').toLowerCase();
        final String sname = (a['name']?.toString() ?? '').toLowerCase();
        return sid.contains(q) || sname.contains(q);
      }
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(10),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _appealSearchCtrl,
                style: const TextStyle(fontSize: 11),
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Search Appeal by Student Name / ID',
                  prefixIcon: Icon(Icons.search, size: 15),
                ),
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              height: 34,
              child: FilledButton.icon(
                onPressed: _loadDoctorAppeals,
                icon: const Icon(Icons.download, size: 14),
                label: const Text('Load Appeals', style: TextStyle(fontSize: 11)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <String>['All', 'Pending', 'Approved', 'Rejected'].map((String st) {
              final bool sel = _appealStatusFilter == st;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(st, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: sel ? Colors.white : const Color(0xFF334155))),
                  selected: sel,
                  selectedColor: const Color(0xFF0B4A40),
                  visualDensity: VisualDensity.compact,
                  onSelected: (_) => setState(() => _appealStatusFilter = st),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        if (filtered.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Center(
                child: Text(
                  'Tap "Load Appeals" above or no student appeals found for this course.',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                ),
              ),
            ),
          )
        else
          ...filtered.map((JsonMap a) {
            final String st = a['status']?.toString() ?? 'Pending';
            final Color c = st == 'Approved'
                ? const Color(0xFF059669)
                : (st == 'Rejected' ? const Color(0xFFDC2626) : const Color(0xFFD97706));
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              '${a['name']} (#${a['studentId']})',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: c.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(st, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: c)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Type: ${a['appealType']} • Submitted: ${a['timestamp']}',
                        style: const TextStyle(fontSize: 10.5, color: Color(0xFF475569)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Original: Per [${a['origPeriodical']}] / Prac [${a['origPractical']}]  →  Current: Per [${a['currentPeriodical']}] / Prac [${a['currentPractical']}]',
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF0B4A40)),
                      ),
                      if ((a['comment']?.toString() ?? '').isNotEmpty) ...<Widget>[
                        const SizedBox(height: 4),
                        Text('Student Note: "${a['comment']}"', style: const TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic)),
                      ],
                      if ((a['resultText']?.toString() ?? '').isNotEmpty) ...<Widget>[
                        const SizedBox(height: 4),
                        Text('Decision Result: ${a['resultText']}', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: c)),
                      ],
                      const SizedBox(height: 7),
                      SizedBox(
                        width: double.infinity,
                        height: 29,
                        child: FilledButton.icon(
                          onPressed: () => _submitAppealReviewDialog(a),
                          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0B4A40)),
                          icon: const Icon(Icons.rate_review_outlined, size: 13),
                          label: const Text('Review & Add Bonus Marks', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildDoctorLiveGradesSheetTab() {
    final List<JsonMap> students = _gradesSheetData != null
        ? asJsonMapList(_gradesSheetData!['students'])
        : <JsonMap>[];
    final JsonMap stats = _gradesSheetData != null
        ? asJsonMap(_gradesSheetData!['stats'])
        : <String, dynamic>{};
    final bool hasPractical = _gradesSheetData?['hasPractical'] != false;

    final String q = _gradesSearchCtrl.text.trim().toLowerCase();
    final List<JsonMap> filtered = students.where((JsonMap s) {
      if (q.isEmpty) return true;
      final String sid = (s['studentId']?.toString() ?? '').toLowerCase();
      final String sname = (s['name']?.toString() ?? '').toLowerCase();
      return sid.contains(q) || sname.contains(q);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(10),
      children: <Widget>[
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: <Widget>[
            SizedBox(
              height: 31,
              child: FilledButton.icon(
                onPressed: _loadCourseGradesSheet,
                icon: const Icon(Icons.cloud_download_outlined, size: 14),
                label: const Text('Load Grades Sheet', style: TextStyle(fontSize: 10.5)),
              ),
            ),
            SizedBox(
              height: 31,
              child: OutlinedButton.icon(
                onPressed: _openAddStudentGradeDialog,
                icon: const Icon(Icons.person_add_alt_1, size: 14),
                label: const Text('Add Student', style: TextStyle(fontSize: 10.5)),
              ),
            ),
            if ((_gradesSheetData?['sheetUrl']?.toString() ?? '').isNotEmpty)
              SizedBox(
                height: 31,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final Uri u = Uri.parse(_gradesSheetData!['sheetUrl'].toString());
                    await launchUrl(u, mode: LaunchMode.externalApplication);
                  },
                  icon: const Icon(Icons.open_in_new, size: 13),
                  label: const Text('Google Sheet', style: TextStyle(fontSize: 10.5)),
                ),
              ),
            if (_gradesPendingEdits.isNotEmpty)
              SizedBox(
                height: 31,
                child: FilledButton.icon(
                  onPressed: _savePendingGradesSheetEdits,
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD97706)),
                  icon: const Icon(Icons.save, size: 14),
                  label: Text(
                    'Save Sheet Edits (${_gradesPendingEdits.length})',
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
          ],
        ),

        if (_gradesSheetData != null) ...<Widget>[
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              _buildMiniKpiCard('Students', '${stats['totalStudents'] ?? 0}', const Color(0xFF0F172A)),
              const SizedBox(width: 5),
              _buildMiniKpiCard('Avg Per.', '${stats['avgPeriodical'] ?? 0}', const Color(0xFF0B4A40)),
              const SizedBox(width: 5),
              _buildMiniKpiCard('Avg Prac.', '${stats['avgPractical'] ?? 0}', const Color(0xFF0369A1)),
              const SizedBox(width: 5),
              _buildMiniKpiCard('Max Tot.', '${stats['maxTotal'] ?? 0}', const Color(0xFFD97706)),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _gradesSearchCtrl,
            style: const TextStyle(fontSize: 11),
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Search Student in Live Sheet (Tap any row to edit marks)',
              prefixIcon: Icon(Icons.search, size: 15),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 30,
                dataRowMinHeight: 30,
                dataRowMaxHeight: 34,
                columnSpacing: 12,
                horizontalMargin: 8,
                columns: <DataColumn>[
                  const DataColumn(label: Text('#', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                  const DataColumn(label: Text('ID', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                  const DataColumn(label: Text('Student Name', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                  DataColumn(label: Text(_gradesSheetData!['periodicalTitle']?.toString() ?? 'Periodical', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                  if (hasPractical)
                    DataColumn(label: Text(_gradesSheetData!['practicalTitle']?.toString() ?? 'Practical', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                  const DataColumn(label: Text('Total', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                  const DataColumn(label: Text('Actions', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                ],
                rows: filtered.take(150).map((JsonMap st) {
                  final int rowNum = int.tryParse(st['rowNumber']?.toString() ?? '0') ?? 0;
                  final JsonMap eff = _gradesPendingEdits[rowNum] ?? st;
                  final bool isEdited = _gradesPendingEdits.containsKey(rowNum);
                  final double? pNum = double.tryParse(eff['periodical']?.toString() ?? '');
                  final double? prNum = double.tryParse(eff['practical']?.toString() ?? '');
                  final String totStr = (pNum != null && hasPractical && prNum != null)
                      ? (pNum + prNum).toStringAsFixed(1)
                      : (st['total']?.toString() ?? '—');

                  return DataRow(
                    color: WidgetStateProperty.all(
                      isEdited ? const Color(0xFFFEF3C7) : Colors.transparent,
                    ),
                    cells: <DataCell>[
                      DataCell(Text('$rowNum', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)))),
                      DataCell(
                        Text(eff['studentId']?.toString() ?? '', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
                        onTap: () => _openEditSingleGradeRowDialog(st),
                      ),
                      DataCell(
                        SizedBox(
                          width: 145,
                          child: Text(
                            eff['name']?.toString() ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10.5),
                          ),
                        ),
                        onTap: () => _openEditSingleGradeRowDialog(st),
                      ),
                      DataCell(
                        Text(eff['periodical']?.toString() ?? '—', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
                        onTap: () => _openEditSingleGradeRowDialog(st),
                      ),
                      if (hasPractical)
                        DataCell(
                          Text(eff['practical']?.toString() ?? '—', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
                          onTap: () => _openEditSingleGradeRowDialog(st),
                        ),
                      DataCell(Text(totStr, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Color(0xFF0B4A40)))),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              onPressed: () => _openEditSingleGradeRowDialog(st),
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.edit_outlined, size: 15, color: Color(0xFF0B4A40)),
                            ),
                            IconButton(
                              onPressed: () => _deleteStudentGradeRow(st),
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.delete_outline, size: 15, color: Color(0xFFDC2626)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ] else
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Center(
                  child: Text(
                    'Tap "Load Grades Sheet" above to view and edit student coursework marks.',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDoctorVisibilityMatrixTab() {
    return ListView(
      padding: const EdgeInsets.all(10),
      children: kTrackKeys.map((String tk) {
        final List<JsonMap> permittedInTrack = kSubjectCatalog
            .where((JsonMap s) => isDoctorCourseAllowed(_permissions, tk, s['name'].toString()))
            .toList();
        if (permittedInTrack.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    kTrackFullLabels[tk] ?? tk,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0B4A40)),
                  ),
                  const Divider(height: 12),
                  ...permittedInTrack.map((JsonMap s) {
                    final String sKey = s['key'].toString();
                    final String sName = s['name'].toString();
                    final bool open = _isCourseAnnounced(tk, sKey);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(sName, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                          ),
                          Switch(
                            value: open,
                            activeColor: const Color(0xFF059669),
                            onChanged: (bool val) => _toggleCourseVisibility(tk, sKey, val),
                          ),
                          SizedBox(
                            width: 68,
                            child: Text(
                              open ? 'Announced' : 'Hidden',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: open ? const Color(0xFF059669) : const Color(0xFFDC2626),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMiniTabButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0B4A40).withOpacity(0.11) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: selected ? const Color(0xFF0B4A40) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: selected ? const Color(0xFF0B4A40) : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniKpiCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: <Widget>[
            Text(
              value,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 11, color: const Color(0xFF475569)),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        ],
      ),
    );
  }
}


// ============================================================================
// SUPER ADMIN MASTER WORKSPACE (DOCTORS 36-MATRIX, DATES, ARCHIVE 8 SHEETS, AUDIT)
// ============================================================================
class SuperAdminWorkspace extends StatefulWidget {
  final void Function(bool loading, [String label]) onLoadingChanged;
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

  final TextEditingController _masterUserCtrl = TextEditingController();
  final TextEditingController _masterPassCtrl = TextEditingController();
  bool _obscureMasterPass = true;
  bool _masterLoggedIn = false;
  String _masterUser = '';
  String _masterPass = '';

  // 0 = Doctors & 36-Matrix, 1 = Attendance & Dates 1-12, 2 = Archive & Clear 8 Workbooks, 3 = Unified Audit Log
  int _masterTab = 0;

  // Data lists
  List<JsonMap> _doctorsList = <JsonMap>[];
  List<JsonMap> _sheetsOverview = <JsonMap>[];
  List<JsonMap> _archivesHistory = <JsonMap>[];
  List<JsonMap> _auditLogs = <JsonMap>[];

  // Tab 0: Create / Edit Doctor Form
  final TextEditingController _docNameCtrl = TextEditingController();
  final TextEditingController _docUserCtrl = TextEditingController();
  final TextEditingController _docPassCtrl = TextEditingController();
  final Set<String> _selectedCoursePerms = <String>{...buildAll36CoursePerms()};
  final Set<String> _selectedActionPerms = <String>{...buildDefaultActionPerms()};

  // Tab 1: Master Direct Attendance & Section Dates 1-12
  String _mAttUni = 'Beni-Suef University (BSU)';
  String _mAttProg = 'Clinical';
  String _mAttSubj = 'Basic Microbiology';
  String _mRosterSheetName = '';
  List<JsonMap> _mRosterStudents = <JsonMap>[];
  final Map<int, TextEditingController> _secDateCtrls = <int, TextEditingController>{
    for (int s = 1; s <= 12; s++) s: TextEditingController(text: kDefaultSectionDates[s] ?? ''),
  };
  final TextEditingController _mRosterSearchCtrl = TextEditingController();
  final Map<String, String> _mPendingSecChanges = <String, String>{};

  // Tab 2: Archive & Clear 8 Workbooks
  final Set<String> _selectedArchiveKeys = <String>{};

  // Tab 3: Audit Log filter
  String _auditCatFilter = 'ALL'; // ALL, ATTENDANCE, GRADES, VISIBILITY, MASTER
  final TextEditingController _auditSearchCtrl = TextEditingController();

  @override
  void dispose() {
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

  void _showMsg(String text, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? const Color(0xFFB91C1C) : const Color(0xFF0B4A40),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        content: Text(
          text,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _handleMasterLogin() async {
    final String u = _masterUserCtrl.text.trim();
    final String p = _masterPassCtrl.text.trim();
    if (u.isEmpty || p.isEmpty) {
      _showMsg('Please enter Super Admin username and password.', isError: true);
      return;
    }

    widget.onLoadingChanged(true, 'Verifying Super Admin...');
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
      _showMsg('Super Admin Master Hub unlocked.');
    } else {
      _showMsg(map['message']?.toString() ?? 'Invalid Super Admin credentials.', isError: true);
    }
  }

  void _handleMasterLogout() {
    setState(() {
      _masterLoggedIn = false;
      _masterUser = '';
      _masterPass = '';
      _masterPassCtrl.clear();
      _doctorsList = <JsonMap>[];
      _auditLogs = <JsonMap>[];
    });
    widget.onAuthStateChanged(false, '');
  }

  Future<void> _refreshMasterData() async {
    if (!_masterLoggedIn) return;
    widget.onLoadingChanged(true, 'Syncing Master Control...');
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
      _showMsg('Master data refreshed.');
    }
  }

  void _loadDoctorIntoEditor(JsonMap doc) {
    final List<String> perms = asStringList(doc['permissions']);
    final Set<String> cPerms = <String>{};
    final Set<String> aPerms = <String>{};
    if (perms.contains('ALL')) {
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
      _selectedCoursePerms
        ..clear()
        ..addAll(cPerms);
      _selectedActionPerms
        ..clear()
        ..addAll(aPerms);
    });
    _showMsg('Loaded ${doc['doctorName']} into editor above.');
  }

  Future<void> _saveDoctorAccount() async {
    final String name = _docNameCtrl.text.trim();
    final String user = _docUserCtrl.text.trim();
    final String pass = _docPassCtrl.text.trim();
    if (user.isEmpty || pass.isEmpty) {
      _showMsg('Please enter doctor username and password.', isError: true);
      return;
    }
    if (_selectedCoursePerms.isEmpty) {
      _showMsg('Select at least one course in the 36-course matrix.', isError: true);
      return;
    }

    final List<String> combinedPerms = <String>[
      ..._selectedCoursePerms,
      ..._selectedActionPerms,
    ];

    widget.onLoadingChanged(true, 'Saving doctor account...');
    final dynamic res = await PortalApiService.callAction(
      'saveDoctorAccountByMaster',
      <dynamic>[_masterUser, _masterPass, name.isEmpty ? user : name, user, pass, combinedPerms],
    );
    widget.onLoadingChanged(false);

    final JsonMap map = asJsonMap(res);
    if (map['success'] == true) {
      setState(() {
        _doctorsList = asJsonMapList(map['doctors']);
        _auditLogs = asJsonMapList(map['auditLogs']);
        _docNameCtrl.clear();
        _docUserCtrl.clear();
        _docPassCtrl.clear();
      });
      _showMsg(map['message']?.toString() ?? 'Doctor account saved.');
    } else {
      _showMsg(map['message']?.toString() ?? 'Failed to save doctor account.', isError: true);
    }
  }

  Future<void> _deleteDoctorAccount(JsonMap doc) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Delete Doctor Account?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        content: Text('Delete ${doc['doctorName']} (@${doc['username']})?', style: const TextStyle(fontSize: 11.5)),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel', style: TextStyle(fontSize: 11))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB91C1C)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    widget.onLoadingChanged(true, 'Deleting doctor account...');
    final dynamic res = await PortalApiService.callAction(
      'deleteDoctorAccountByMaster',
      <dynamic>[_masterUser, _masterPass, doc['row']],
    );
    widget.onLoadingChanged(false);

    final JsonMap map = asJsonMap(res);
    if (map['success'] == true) {
      setState(() {
        _doctorsList = asJsonMapList(map['doctors']);
        _auditLogs = asJsonMapList(map['auditLogs']);
      });
      _showMsg('Doctor account deleted.');
    } else {
      _showMsg(map['message']?.toString() ?? 'Failed to delete doctor.', isError: true);
    }
  }

  // Tab 1: Master Attendance Roster & Section Dates
  Future<void> _loadMasterRosterAndDates() async {
    widget.onLoadingChanged(true, 'Loading sheet & section dates...');
    final dynamic res = await PortalApiService.callAction(
      'getSubjectAttendanceRoster',
      <dynamic>[_masterUser, _masterPass, true, _mAttUni, _mAttProg, _mAttSubj],
    );
    widget.onLoadingChanged(false);

    final JsonMap map = asJsonMap(res);
    if (map['success'] == true) {
      final JsonMap dates = asJsonMap(map['sectionDates']);
      for (int s = 1; s <= 12; s++) {
        _secDateCtrls[s]?.text = dates[s.toString()]?.toString() ?? (kDefaultSectionDates[s] ?? '');
      }
      setState(() {
        _mRosterSheetName = map['sheetName']?.toString() ?? '';
        _mRosterStudents = asJsonMapList(map['students']);
        _mPendingSecChanges.clear();
      });
      _showMsg('Loaded ${_mRosterStudents.length} students & dates from $_mRosterSheetName');
    } else {
      _showMsg(map['message']?.toString() ?? 'Failed to load attendance sheet.', isError: true);
    }
  }

  Future<void> _saveMasterSectionDates() async {
    final Map<String, String> datesMap = <String, String>{};
    for (int s = 1; s <= 12; s++) {
      datesMap[s.toString()] = _secDateCtrls[s]?.text.trim() ?? '';
    }
    widget.onLoadingChanged(true, 'Saving section dates 1-12...');
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

    final JsonMap map = asJsonMap(res);
    if (map['success'] == true) {
      setState(() {
        _auditLogs = asJsonMapList(map['auditLogs']);
      });
      _showMsg(map['message']?.toString() ?? 'Section dates updated.');
    } else {
      _showMsg(map['message']?.toString() ?? 'Failed to update section dates.', isError: true);
    }
  }

  Future<void> _saveMasterBulkAttendance() async {
    if (_mPendingSecChanges.isEmpty) {
      _showMsg('No attendance cells modified.', isError: true);
      return;
    }
    final List<JsonMap> changes = <JsonMap>[];
    _mPendingSecChanges.forEach((String k, String val) {
      final List<String> p = k.split('|');
      if (p.length == 2) {
        changes.add(<String, dynamic>{
          'studentId': p[0],
          'sectionNumber': int.tryParse(p[1]) ?? 1,
          'newValue': val,
        });
      }
    });

    widget.onLoadingChanged(true, 'Saving ${changes.length} changes...');
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

    final JsonMap map = asJsonMap(res);
    if (map['success'] == true) {
      _showMsg(map['message']?.toString() ?? 'Saved bulk attendance.');
      await _loadMasterRosterAndDates();
    } else {
      _showMsg(map['message']?.toString() ?? 'Failed to save changes.', isError: true);
    }
  }

  // Tab 2: Archive & Clear Selected Workbooks
  Future<void> _archiveAndClearSelectedWorkbooks() async {
    if (_selectedArchiveKeys.isEmpty) {
      _showMsg('Please select at least one workbook to archive and clear.', isError: true);
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Archive to Drive & Clear Selected?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        content: Text(
          'This will save a full timestamped backup copy of (${_selectedArchiveKeys.length}) selected workbook(s) to Google Drive, and then clear student rows for the new semester while preserving Doctor Accounts & Audit Logs.',
          style: const TextStyle(fontSize: 11.5),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel', style: TextStyle(fontSize: 11))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB91C1C)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm Archive & Clear', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    widget.onLoadingChanged(true, 'Archiving to Drive & clearing sheets...');
    final dynamic res = await PortalApiService.callAction(
      'archiveAndClearSelectedSheetsByMaster',
      <dynamic>[_masterUser, _masterPass, _selectedArchiveKeys.toList()],
    );
    widget.onLoadingChanged(false);

    final JsonMap map = asJsonMap(res);
    if (map['success'] == true) {
      setState(() {
        _archivesHistory = asJsonMapList(map['archivesHistory']);
        _auditLogs = asJsonMapList(map['auditLogs']);
        _selectedArchiveKeys.clear();
      });
      _showMsg(map['message']?.toString() ?? 'Archived and cleared successfully.');
    } else {
      _showMsg(map['message']?.toString() ?? 'Error during archive & clear.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_masterLoggedIn) {
      return _buildMasterLoginView();
    }

    return Column(
      children: <Widget>[
        _buildMasterHeaderBar(),
        _buildMasterTabsStrip(),
        Expanded(
          child: _masterTab == 0
              ? _buildDoctorsAnd36MatrixTab()
              : (_masterTab == 1
                  ? _buildMasterAttendanceAndDatesTab()
                  : (_masterTab == 2 ? _buildArchiveAndClear8SheetsTab() : _buildUnifiedAuditLogTab())),
        ),
      ],
    );
  }

  Widget _buildMasterLoginView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const BsuDeptLogoWidget(size: 68, showGoldBorder: true),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD99B26).withOpacity(0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'SUPER ADMIN MASTER CONTROL • BSU',
                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF92400E)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Super Admin Master Hub',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Manage doctor accounts, 36-course matrix permissions, section dates (1–12), 8-workbook Drive archiving & unified audit logs.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _masterUserCtrl,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      labelText: 'Super Admin Username',
                      prefixIcon: Icon(Icons.admin_panel_settings_outlined, size: 17),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _masterPassCtrl,
                    obscureText: _obscureMasterPass,
                    style: const TextStyle(fontSize: 12),
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
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: FilledButton.icon(
                      onPressed: _handleMasterLogin,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.shield, size: 15, color: Color(0xFFF5B82E)),
                      label: const Text(
                        'Unlock Super Admin Hub',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMasterHeaderBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(bottom: BorderSide(color: Color(0xFF334155))),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.shield, size: 16, color: Color(0xFFF5B82E)),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              'Super Admin (@$_masterUser) • ${_doctorsList.length} Doctors • ${_auditLogs.length} Audit Logs',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
          IconButton(
            onPressed: _refreshMasterData,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.refresh, size: 16, color: Colors.white70),
          ),
          IconButton(
            onPressed: _handleMasterLogout,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.logout, size: 16, color: Color(0xFFF87171)),
          ),
        ],
      ),
    );
  }

  Widget _buildMasterTabsStrip() {
    final List<JsonMap> tabs = <JsonMap>[
      <String, dynamic>{'idx': 0, 'label': '👨‍⚕️ Doctors & 36-Matrix'},
      <String, dynamic>{'idx': 1, 'label': '📅 Dates & Roster'},
      <String, dynamic>{'idx': 2, 'label': '🗄️ Archive 8 Sheets'},
      <String, dynamic>{'idx': 3, 'label': '🛡️ Audit Log'},
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.map((JsonMap t) {
            final int idx = t['idx'] as int;
            final bool sel = _masterTab == idx;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: InkWell(
                onTap: () => setState(() => _masterTab = idx),
                borderRadius: BorderRadius.circular(7),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? const Color(0xFF0B4A40) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    t['label'].toString(),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: sel ? Colors.white : const Color(0xFF334155),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDoctorsAnd36MatrixTab() {
    return ListView(
      padding: const EdgeInsets.all(10),
      children: <Widget>[
        // Doctor Account Editor + 7 Action Perms + 36-Course Matrix
        Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Create / Update Doctor Account & 36-Course Matrix',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _docNameCtrl,
                  style: const TextStyle(fontSize: 11.5),
                  decoration: const InputDecoration(labelText: 'Doctor Full Display Name (e.g., Dr. Ahmed Ali)'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _docUserCtrl,
                        style: const TextStyle(fontSize: 11.5),
                        decoration: const InputDecoration(labelText: 'Username *'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _docPassCtrl,
                        style: const TextStyle(fontSize: 11.5),
                        decoration: const InputDecoration(labelText: 'Password *'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Functional Action Permissions (7 Capabilities):',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0B4A40)),
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: kActionPermDefinitions.map((JsonMap act) {
                    final String k = act['key'].toString();
                    final bool checked = _selectedActionPerms.contains(k);
                    return FilterChip(
                      label: Text(act['title'].toString(), style: const TextStyle(fontSize: 10)),
                      selected: checked,
                      visualDensity: VisualDensity.compact,
                      selectedColor: const Color(0xFF0B4A40).withOpacity(0.16),
                      onSelected: (bool v) {
                        setState(() {
                          if (v) {
                            _selectedActionPerms.add(k);
                          } else {
                            _selectedActionPerms.remove(k);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '36-Course Matrix (${_selectedCoursePerms.length} / 36 selected):',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0B4A40)),
                    ),
                    Wrap(
                      spacing: 4,
                      children: <Widget>[
                        _buildQuickPresetBtn('All 36', () {
                          setState(() {
                            _selectedCoursePerms
                              ..clear()
                              ..addAll(buildAll36CoursePerms());
                          });
                        }),
                        _buildQuickPresetBtn('BSU Only', () {
                          setState(() {
                            _selectedCoursePerms.clear();
                            for (final JsonMap s in kSubjectCatalog) {
                              _selectedCoursePerms.add('BSU_General__${s['key']}');
                              _selectedCoursePerms.add('BSU_Clinical__${s['key']}');
                            }
                          });
                        }),
                        _buildQuickPresetBtn('BSNU Only', () {
                          setState(() {
                            _selectedCoursePerms.clear();
                            for (final JsonMap s in kSubjectCatalog) {
                              _selectedCoursePerms.add('BSNU_General__${s['key']}');
                              _selectedCoursePerms.add('BSNU_Clinical__${s['key']}');
                            }
                          });
                        }),
                        _buildQuickPresetBtn('Clear', () {
                          setState(() => _selectedCoursePerms.clear());
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
                    columnSpacing: 10,
                    horizontalMargin: 6,
                    columns: const <DataColumn>[
                      DataColumn(label: Text('Course (Tap row to toggle all 4)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('BSU Gen', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('BSU Clin', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('BSNU Gen', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('BSNU Clin', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                    ],
                    rows: kSubjectCatalog.map((JsonMap subj) {
                      final String sk = subj['key'].toString();
                      final String sName = subj['name'].toString();
                      return DataRow(
                        cells: <DataCell>[
                          DataCell(
                            Text(sName, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
                            onTap: () {
                              final List<String> rowTokens = kTrackKeys.map((String tk) => '${tk}__$sk').toList();
                              final bool allChecked = rowTokens.every(_selectedCoursePerms.contains);
                              setState(() {
                                if (allChecked) {
                                  _selectedCoursePerms.removeAll(rowTokens);
                                } else {
                                  _selectedCoursePerms.addAll(rowTokens);
                                }
                              });
                            },
                          ),
                          ...kTrackKeys.map((String tk) {
                            final String tok = '${tk}__$sk';
                            final bool checked = _selectedCoursePerms.contains(tok);
                            return DataCell(
                              Checkbox(
                                value: checked,
                                visualDensity: VisualDensity.compact,
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
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 34,
                  child: FilledButton.icon(
                    onPressed: _saveDoctorAccount,
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0B4A40)),
                    icon: const Icon(Icons.save_outlined, size: 15),
                    label: const Text('Save Doctor Account & Permissions', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),
        Text(
          'Registered Doctor Accounts (${_doctorsList.length})',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 6),
        ..._doctorsList.map((JsonMap d) {
          final List<String> perms = asStringList(d['permissions']);
          final int courseCnt = perms.where((String p) => p.contains('__')).length;
          final int actCnt = perms.where((String p) => p.startsWith('ACT_')).length;
          return Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${d['doctorName']} (@${d['username']})',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Password: ${d['password']}  •  Courses: $courseCnt/36  •  Actions: $actCnt/7',
                            style: const TextStyle(fontSize: 10.5, color: Color(0xFF475569)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _loadDoctorIntoEditor(d),
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Edit Doctor',
                      icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF0B4A40)),
                    ),
                    IconButton(
                      onPressed: () => _deleteDoctorAccount(d),
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Delete Doctor',
                      icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFDC2626)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMasterAttendanceAndDatesTab() {
    final String q = _mRosterSearchCtrl.text.trim().toLowerCase();
    final List<JsonMap> filtered = _mRosterStudents.where((JsonMap s) {
      if (q.isEmpty) return true;
      return (s['studentId']?.toString() ?? '').toLowerCase().contains(q) ||
          (s['studentName']?.toString() ?? '').toLowerCase().contains(q);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(10),
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Select Subject Attendance Sheet & Edit Section Dates (1–12)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _mAttUni,
                        isExpanded: true,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF0F172A)),
                        decoration: const InputDecoration(labelText: 'University'),
                        items: const <StringDropItem>[
                          DropdownMenuItem<String>(value: 'Beni-Suef University (BSU)', child: Text('BSU (الحكومية)')),
                          DropdownMenuItem<String>(value: 'Beni-Suef National University (BSNU)', child: Text('BSNU (الأهلية)')),
                        ],
                        onChanged: (String? v) => setState(() => _mAttUni = v ?? _mAttUni),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _mAttProg,
                        isExpanded: true,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF0F172A)),
                        decoration: const InputDecoration(labelText: 'Program'),
                        items: const <StringDropItem>[
                          DropdownMenuItem<String>(value: 'Clinical', child: Text('Clinical')),
                          DropdownMenuItem<String>(value: 'General', child: Text('General')),
                        ],
                        onChanged: (String? v) => setState(() => _mAttProg = v ?? _mAttProg),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _mAttSubj,
                        isExpanded: true,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF0F172A)),
                        decoration: const InputDecoration(labelText: 'Subject'),
                        items: kSubjectCatalog
                            .map((JsonMap s) => DropdownMenuItem<String>(
                                  value: s['name'].toString(),
                                  child: Text(s['name'].toString()),
                                ))
                            .toList(),
                        onChanged: (String? v) => setState(() => _mAttSubj = v ?? _mAttSubj),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 34,
                      child: FilledButton.icon(
                        onPressed: _loadMasterRosterAndDates,
                        icon: const Icon(Icons.folder_open, size: 14),
                        label: const Text('Load Sheet', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text('Section Dates (1 to 12):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 12,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    childAspectRatio: 2.6,
                  ),
                  itemBuilder: (BuildContext context, int i) {
                    final int s = i + 1;
                    return TextField(
                      controller: _secDateCtrls[s],
                      style: const TextStyle(fontSize: 10.5),
                      decoration: InputDecoration(
                        labelText: 'Sec $s Date',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: FilledButton.icon(
                    onPressed: _saveMasterSectionDates,
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0B4A40)),
                    icon: const Icon(Icons.event_available, size: 14),
                    label: const Text('Save Section Dates (1–12) to Sheet', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (_mRosterStudents.isNotEmpty) ...<Widget>[
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Sheet: $_mRosterSheetName (${filtered.length} students)',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (_mPendingSecChanges.isNotEmpty)
                        SizedBox(
                          height: 28,
                          child: FilledButton.icon(
                            onPressed: _saveMasterBulkAttendance,
                            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD97706)),
                            icon: const Icon(Icons.save, size: 13),
                            label: Text('Save (${_mPendingSecChanges.length})', style: const TextStyle(fontSize: 10.5)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _mRosterSearchCtrl,
                    style: const TextStyle(fontSize: 11),
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Search student by ID or Name',
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
                      columnSpacing: 8,
                      columns: <DataColumn>[
                        const DataColumn(label: Text('ID', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                        const DataColumn(label: Text('Name', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                        ...List<DataColumn>.generate(
                          12,
                          (int i) => DataColumn(label: Text('S${i + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                        ),
                      ],
                      rows: filtered.take(100).map((JsonMap st) {
                        final String sid = st['studentId']?.toString() ?? '';
                        final JsonMap secs = asJsonMap(st['sections']);
                        return DataRow(
                          cells: <DataCell>[
                            DataCell(Text(sid, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700))),
                            DataCell(SizedBox(width: 120, child: Text(st['studentName']?.toString() ?? '', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10.5)))),
                            ...List<DataCell>.generate(12, (int i) {
                              final int sNum = i + 1;
                              final String k = '$sid|$sNum';
                              final String v = _mPendingSecChanges[k] ?? (secs[sNum.toString()]?.toString() ?? 'P');
                              final Color c = v == 'A'
                                  ? const Color(0xFFDC2626)
                                  : (v == 'E' ? const Color(0xFFD97706) : const Color(0xFF059669));
                              return DataCell(
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _mPendingSecChanges[k] = v == 'P' ? 'A' : (v == 'A' ? 'E' : 'P');
                                    });
                                  },
                                  child: Container(
                                    width: 22,
                                    height: 20,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: c.withOpacity(0.14),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: c),
                                    ),
                                    child: Text(v, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: c)),
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
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildArchiveAndClear8SheetsTab() {
    final List<JsonMap> items = _sheetsOverview.isNotEmpty
        ? _sheetsOverview
        : <JsonMap>[
            <String, dynamic>{'key': 'BSNU_ATTENDANCE', 'badge': 'Attendance', 'title': 'BSNU Attendance Workbook', 'desc': 'Archive & clear 18 tabs'},
            <String, dynamic>{'key': 'BSU_ATTENDANCE', 'badge': 'Attendance', 'title': 'BSU Attendance Workbook', 'desc': 'Archive & clear 18 tabs'},
            <String, dynamic>{'key': 'EXCUSES_DB', 'badge': 'Excuses', 'title': 'Medical Excuses Database', 'desc': 'Archive & clear excuse requests'},
            <String, dynamic>{'key': 'BSNU_Clinical', 'badge': 'Grades', 'title': 'BSNU Clinical Grades', 'desc': 'Archive & clear 9 course tabs'},
            <String, dynamic>{'key': 'BSNU_General', 'badge': 'Grades', 'title': 'BSNU General Grades', 'desc': 'Archive & clear 9 course tabs'},
            <String, dynamic>{'key': 'BSU_General', 'badge': 'Grades', 'title': 'BSU General Grades', 'desc': 'Archive & clear 9 course tabs'},
            <String, dynamic>{'key': 'BSU_Clinical', 'badge': 'Grades', 'title': 'BSU Clinical Grades', 'desc': 'Archive & clear 9 course tabs'},
            <String, dynamic>{'key': 'APPEALS_DB', 'badge': 'Appeals', 'title': 'Student Appeals Database', 'desc': 'Archive & clear appeals tabs'},
          ];

    return ListView(
      padding: const EdgeInsets.all(10),
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      'Select Workbooks to Archive to Drive & Clear',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                    Wrap(
                      spacing: 4,
                      children: <Widget>[
                        _buildQuickPresetBtn('All 8', () {
                          setState(() {
                            for (final JsonMap it in items) {
                              _selectedArchiveKeys.add(it['key'].toString());
                            }
                          });
                        }),
                        _buildQuickPresetBtn('Clear', () {
                          setState(() => _selectedArchiveKeys.clear());
                        }),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ...items.map((JsonMap wb) {
                  final String key = wb['key'].toString();
                  final bool sel = _selectedArchiveKeys.contains(key);
                  return CheckboxListTile(
                    value: sel,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(wb['title']?.toString() ?? key, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                    subtitle: Text(wb['desc']?.toString() ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                    onChanged: (bool? v) {
                      setState(() {
                        if (v == true) {
                          _selectedArchiveKeys.add(key);
                        } else {
                          _selectedArchiveKeys.remove(key);
                        }
                      });
                    },
                  );
                }),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 34,
                  child: FilledButton.icon(
                    onPressed: _archiveAndClearSelectedWorkbooks,
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB91C1C)),
                    icon: const Icon(Icons.archive_outlined, size: 15),
                    label: Text(
                      'Archive to Drive & Clear Selected (${_selectedArchiveKeys.length})',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),
        Text(
          'Google Drive Archive History (${_archivesHistory.length})',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        ..._archivesHistory.map((JsonMap h) {
          final String url = h['archiveUrl']?.toString() ?? '';
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Card(
              child: ListTile(
                dense: true,
                title: Text(
                  '${h['workbookTitle']} • ${h['timestamp']}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  '${h['archiveName']}\nCleared Tabs: ${h['tabsCleared']} | Rows: ${h['rowsCleared']}',
                  style: const TextStyle(fontSize: 10),
                ),
                trailing: url.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.open_in_new, size: 16, color: Color(0xFF0B4A40)),
                        onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
                      )
                    : null,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildUnifiedAuditLogTab() {
    final String q = _auditSearchCtrl.text.trim().toLowerCase();
    final List<JsonMap> filtered = _auditLogs.where((JsonMap l) {
      final String act = (l['action']?.toString() ?? '').toLowerCase();
      if (_auditCatFilter == 'ATTENDANCE' && !act.contains('attendance') && !act.contains('excuse') && !act.contains('date')) {
        return false;
      }
      if (_auditCatFilter == 'GRADES' && !act.contains('grade') && !act.contains('appeal') && !act.contains('student')) {
        return false;
      }
      if (_auditCatFilter == 'VISIBILITY' && !act.contains('announced') && !act.contains('hidden')) {
        return false;
      }
      if (_auditCatFilter == 'MASTER' && !act.contains('doctor') && !act.contains('archive')) {
        return false;
      }
      if (q.isNotEmpty) {
        final String full = '${l['doctorName']} ${l['username']} ${l['action']} ${l['target']} ${l['subjectInfo']} ${l['details']}'.toLowerCase();
        return full.contains(q);
      }
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(10),
      children: <Widget>[
        TextField(
          controller: _auditSearchCtrl,
          style: const TextStyle(fontSize: 11),
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: 'Search Audit Log by Doctor, Student, Course, or Action',
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
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(c, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: sel ? Colors.white : const Color(0xFF334155))),
                  selected: sel,
                  selectedColor: const Color(0xFF0B4A40),
                  visualDensity: VisualDensity.compact,
                  onSelected: (_) => setState(() => _auditCatFilter = c),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        ...filtered.take(150).map((JsonMap log) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            '${log['action']}',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0B4A40)),
                          ),
                        ),
                        Text(
                          '${log['timestamp']}',
                          style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Actor: ${log['doctorName']} (@${log['username']})  •  Target: ${log['target']}',
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Course: ${log['subjectInfo']}  •  ${log['details']}',
                      style: const TextStyle(fontSize: 10, color: Color(0xFF475569)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildQuickPresetBtn(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
      ),
    );
  }
}

// ============================================================================
// STUDENT PORTAL MODAL SCREEN (OPENED VIA SMALL TOP-RIGHT "Student" BUTTON)
// ============================================================================
class StudentPortalModalScreen extends StatefulWidget {
  const StudentPortalModalScreen({super.key});

  @override
  State<StudentPortalModalScreen> createState() => _StudentPortalModalScreenState();
}

class _StudentPortalModalScreenState extends State<StudentPortalModalScreen> {
  // 0 = Practical Attendance & Excuses, 1 = Coursework Grades & Electronic Appeals
  int _studentPortalTab = 0;
  bool _loading = false;
  String _loadingLabel = '';

  String _uni = 'Beni-Suef University (BSU)';
  String _prog = 'Clinical';
  String _subj = 'Basic Microbiology';
  final TextEditingController _studentIdCtrl = TextEditingController();

  // Attendance result & medical excuse form
  JsonMap? _attRecord;
  int _excuseSecNum = 1;
  final TextEditingController _excuseCommentCtrl = TextEditingController();
  Uint8List? _pickedImageBytes;
  String _pickedImageName = '';

  // Grades result & appeal form
  JsonMap? _gradeRecord;
  String _appealType = 'Periodical only';
  final TextEditingController _appealCommentCtrl = TextEditingController();

  @override
  void dispose() {
    _studentIdCtrl.dispose();
    _excuseCommentCtrl.dispose();
    _appealCommentCtrl.dispose();
    super.dispose();
  }

  void _showMsg(String text, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? const Color(0xFFB91C1C) : const Color(0xFF0B4A40),
        behavior: SnackBarBehavior.floating,
        content: Text(text, style: const TextStyle(fontSize: 11.5, color: Colors.white)),
      ),
    );
  }

  Future<void> _lookupStudentAttendance() async {
    final String sid = _studentIdCtrl.text.trim();
    if (sid.isEmpty) {
      _showMsg('Please enter your Student ID.', isError: true);
      return;
    }
    setState(() {
      _loading = true;
      _loadingLabel = 'Checking attendance...';
    });
    final dynamic res = await PortalApiService.callAction(
      'getStudentFullRecord',
      <dynamic>[_uni, _prog, _subj, sid],
    );
    setState(() => _loading = false);

    final JsonMap map = asJsonMap(res);
    if (map['found'] == true) {
      setState(() {
        _attRecord = map;
      });
    } else {
      _showMsg(map['error']?.toString() ?? 'Student ID not found in $_subj.', isError: true);
    }
  }

  Future<void> _pickMedicalImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 78, maxWidth: 1280);
      if (file == null) return;
      final Uint8List bytes = await file.readAsBytes();
      setState(() {
        _pickedImageBytes = bytes;
        _pickedImageName = file.name;
      });
    } catch (e) {
      _showMsg('Could not pick image: $e', isError: true);
    }
  }

  Future<void> _submitMedicalExcuse() async {
    if (_attRecord == null) return;
    if (_pickedImageBytes == null) {
      _showMsg('Please attach a medical excuse image first.', isError: true);
      return;
    }

    final JsonMap dates = asJsonMap(_attRecord!['sectionDates']);
    final String secDate = dates[_excuseSecNum.toString()]?.toString() ?? '';

    setState(() {
      _loading = true;
      _loadingLabel = 'Uploading medical excuse...';
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
          'section': _excuseSecNum.toString(),
          'sectionDate': secDate,
          'comment': _excuseCommentCtrl.text.trim(),
          'files': <JsonMap>[
            <String, dynamic>{
              'filename': _pickedImageName.isEmpty ? 'excuse.jpg' : _pickedImageName,
              'mimeType': 'image/jpeg',
              'base64': base64Encode(_pickedImageBytes!),
            },
          ],
        },
      ],
    );
    setState(() => _loading = false);

    final JsonMap map = asJsonMap(res);
    if (map['success'] == true) {
      _showMsg(map['message']?.toString() ?? 'Medical excuse submitted.');
      setState(() {
        _pickedImageBytes = null;
        _pickedImageName = '';
        _excuseCommentCtrl.clear();
      });
      await _lookupStudentAttendance();
    } else {
      _showMsg(map['message']?.toString() ?? 'Failed to submit excuse.', isError: true);
    }
  }

  Future<void> _lookupStudentGrades() async {
    final String sid = _studentIdCtrl.text.trim();
    if (sid.isEmpty) {
      _showMsg('Please enter your Student ID.', isError: true);
      return;
    }
    setState(() {
      _loading = true;
      _loadingLabel = 'Fetching coursework grades...';
    });
    final dynamic res = await PortalApiService.callAction(
      'getStudentGradeRecord',
      <dynamic>[_uni, _prog, _subj, sid],
    );
    setState(() => _loading = false);

    final JsonMap map = asJsonMap(res);
    if (map['found'] == true) {
      setState(() {
        _gradeRecord = map;
      });
    } else {
      _showMsg(map['error']?.toString() ?? 'Grades not found or course is currently hidden.', isError: true);
    }
  }

  Future<void> _submitStudentAppeal() async {
    if (_gradeRecord == null) return;
    setState(() {
      _loading = true;
      _loadingLabel = 'Submitting grade appeal...';
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
          'appealType': _appealType,
          'comment': _appealCommentCtrl.text.trim(),
        },
      ],
    );
    setState(() => _loading = false);

    final JsonMap map = asJsonMap(res);
    if (map['success'] == true) {
      _showMsg(map['message']?.toString() ?? 'Grade appeal submitted.');
      _appealCommentCtrl.clear();
      await _lookupStudentGrades();
    } else {
      _showMsg(map['message']?.toString() ?? 'Could not submit appeal.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: AppBar(
          backgroundColor: const Color(0xFF0B4A40),
          foregroundColor: Colors.white,
          titleSpacing: 6,
          title: const Row(
            children: <Widget>[
              BsuDeptLogoWidget(size: 28, showGoldBorder: true),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Student Portal Preview (Attendance & Grades)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFFDE68A)),
              icon: const Icon(Icons.arrow_back, size: 14),
              label: const Text('Back to Admin', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          ListView(
            padding: const EdgeInsets.all(10),
            children: <Widget>[
              // Switch between Practical Attendance & Coursework Grades
              Row(
                children: <Widget>[
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('📋 Attendance & Excuses', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800)),
                      selected: _studentPortalTab == 0,
                      onSelected: (_) => setState(() => _studentPortalTab = 0),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('🎓 Coursework Grades & Appeals', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800)),
                      selected: _studentPortalTab == 1,
                      onSelected: (_) => setState(() => _studentPortalTab = 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Unified Student Lookup Form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _uni,
                              isExpanded: true,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF0F172A)),
                              decoration: const InputDecoration(labelText: 'University'),
                              items: const <StringDropItem>[
                                DropdownMenuItem<String>(value: 'Beni-Suef University (BSU)', child: Text('BSU (الحكومية)')),
                                DropdownMenuItem<String>(value: 'Beni-Suef National University (BSNU)', child: Text('BSNU (الأهلية)')),
                              ],
                              onChanged: (String? v) => setState(() => _uni = v ?? _uni),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _prog,
                              isExpanded: true,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF0F172A)),
                              decoration: const InputDecoration(labelText: 'Program'),
                              items: const <StringDropItem>[
                                DropdownMenuItem<String>(value: 'Clinical', child: Text('Clinical')),
                                DropdownMenuItem<String>(value: 'General', child: Text('General')),
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
                        style: const TextStyle(fontSize: 11, color: Color(0xFF0F172A)),
                        decoration: const InputDecoration(labelText: 'Course / Subject'),
                        items: kSubjectCatalog
                            .map((JsonMap s) => DropdownMenuItem<String>(
                                  value: s['name'].toString(),
                                  child: Text(s['name'].toString()),
                                ))
                            .toList(),
                        onChanged: (String? v) => setState(() => _subj = v ?? _subj),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: _studentIdCtrl,
                              style: const TextStyle(fontSize: 11.5),
                              onSubmitted: (_) => _studentPortalTab == 0 ? _lookupStudentAttendance() : _lookupStudentGrades(),
                              decoration: const InputDecoration(
                                labelText: 'Enter Student ID Code',
                                prefixIcon: Icon(Icons.badge_outlined, size: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 35,
                            child: FilledButton.icon(
                              onPressed: _studentPortalTab == 0 ? _lookupStudentAttendance : _lookupStudentGrades,
                              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0B4A40)),
                              icon: const Icon(Icons.search, size: 15),
                              label: Text(
                                _studentPortalTab == 0 ? 'Show Attendance' : 'Show Grades',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),
              if (_studentPortalTab == 0 && _attRecord != null) _buildStudentAttendanceResultCard(),
              if (_studentPortalTab == 1 && _gradeRecord != null) _buildStudentGradeResultCard(),
            ],
          ),
          TopFloatingCircularLoader(isLoading: _loading, label: _loadingLabel),
        ],
      ),
    );
  }

  Widget _buildStudentAttendanceResultCard() {
    final JsonMap stats = asJsonMap(_attRecord!['stats']);
    final List<JsonMap> secs = asJsonMapList(_attRecord!['sections']);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${_attRecord!['studentName']}  •  ID: ${_attRecord!['studentId']}',
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Present: ${stats['presentCount']} | Unexcused (A): ${stats['unexcusedAbsence']} | Excused (E): ${stats['excusedAbsence']} | Attendance Marks: ${stats['attendanceMarks']} / 5',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0B4A40)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: secs.map((JsonMap s) {
                final String raw = (s['rawStatus']?.toString() ?? '').toUpperCase();
                final String label = raw == 'A' ? 'Absent (A)' : (raw == 'E' ? 'Excused (E)' : 'Present (P)');
                final Color c = raw == 'A'
                    ? const Color(0xFFDC2626)
                    : (raw == 'E' ? const Color(0xFFD97706) : const Color(0xFF059669));
                return Container(
                  width: 98,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: c.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: c.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Sec ${s['sectionNumber']} • ${s['sectionDate']}', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700)),
                      Text(label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: c)),
                    ],
                  ),
                );
              }).toList(),
            ),
            const Divider(height: 18),
            const Text('Submit Medical Excuse for Absent Section:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Row(
              children: <Widget>[
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _excuseSecNum,
                    decoration: const InputDecoration(labelText: 'Section (1-12)'),
                    items: List<IntDropItem>.generate(
                      12,
                      (int i) => DropdownMenuItem<int>(value: i + 1, child: Text('Section ${i + 1}', style: const TextStyle(fontSize: 11))),
                    ),
                    onChanged: (int? v) => setState(() => _excuseSecNum = v ?? 1),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _pickMedicalImage,
                  icon: const Icon(Icons.add_a_photo_outlined, size: 14),
                  label: Text(
                    _pickedImageBytes == null ? 'Attach Report' : 'Image Ready ✔',
                    style: const TextStyle(fontSize: 10.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _excuseCommentCtrl,
              style: const TextStyle(fontSize: 11),
              decoration: const InputDecoration(labelText: 'Optional Comment / Reason'),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 33,
              child: FilledButton.icon(
                onPressed: _submitMedicalExcuse,
                icon: const Icon(Icons.cloud_upload_outlined, size: 15),
                label: const Text('Submit Medical Excuse', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentGradeResultCard() {
    final JsonMap appeal = asJsonMap(_gradeRecord!['appeal']);
    final bool hasPractical = _gradeRecord!['hasPractical'] != false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${_gradeRecord!['studentName']}  •  ID: ${_gradeRecord!['studentId']}',
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(_gradeRecord!['periodicalTitle']?.toString() ?? 'Periodical', style: const TextStyle(fontSize: 10)),
                        Text('${_gradeRecord!['periodicalMark']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ),
                if (hasPractical) ...<Widget>[
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Column(
                        children: <Widget>[
                          Text(_gradeRecord!['practicalTitle']?.toString() ?? 'Practical', style: const TextStyle(fontSize: 10)),
                          Text('${_gradeRecord!['practicalMark']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF059669)),
                    ),
                    child: Column(
                      children: <Widget>[
                        const Text('Total', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                        Text('${_gradeRecord!['totalMark']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF059669))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 18),
            if (appeal['submitted'] == true)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD97706)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Appeal Status: ${appeal['decision']} (${appeal['type']})',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                    if ((appeal['result']?.toString() ?? '').isNotEmpty)
                      Text('Result: ${appeal['result']}', style: const TextStyle(fontSize: 10.5)),
                  ],
                ),
              )
            else ...<Widget>[
              const Text('Submit Electronic Grade Appeal:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _appealType,
                style: const TextStyle(fontSize: 11, color: Color(0xFF0F172A)),
                decoration: const InputDecoration(labelText: 'Appeal Scope'),
                items: const <StringDropItem>[
                  DropdownMenuItem<String>(value: 'Periodical only', child: Text('Periodical Only')),
                  DropdownMenuItem<String>(value: 'Practical only', child: Text('Practical Only')),
                  DropdownMenuItem<String>(value: 'Both Periodical & Practical', child: Text('Both Periodical & Practical')),
                ],
                onChanged: (String? v) => setState(() => _appealType = v ?? 'Periodical only'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _appealCommentCtrl,
                style: const TextStyle(fontSize: 11),
                decoration: const InputDecoration(labelText: 'Appeal Notes (Optional)'),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 33,
                child: FilledButton.icon(
                  onPressed: _submitStudentAppeal,
                  icon: const Icon(Icons.gavel, size: 14),
                  label: const Text('Submit Grade Appeal', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

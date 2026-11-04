// ============================================================================
// MICROBIOLOGY & IMMUNOLOGY PORTAL - BENI-SUEF UNIVERSITY (LIVE WEBVIEW APP)
// File: lib/main.dart (Flutter 3.24.5 - Live Sync with Google Apps Script)
// ============================================================================
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

typedef JsonMap = Map<String, dynamic>;
typedef WebGestureFactory = Factory<OneSequenceGestureRecognizer>;

const String kGasBaseUrl =
    'https://script.google.com/macros/s/AKfycbywmtPDQI1A84fURzNhLB2Pxg5Th8P5DFxDCprJEtFh1H-_eUDZyowox3KqZxADRn1Crg/exec';
const String kAdminDoctorUrl = '$kGasBaseUrl?page=admin';
const String kAdminSuperUrl = '$kGasBaseUrl?page=admin&subpage=superadmin';
const String kStudentPortalUrl = kGasBaseUrl;

const String kOriginalBadgeJpgBase64 = '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';
late final Uint8List kOriginalBadgeBytes = base64Decode(kOriginalBadgeJpgBase64);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A1324),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MicroAdminPortalApp());
}

class AppColors {
  static const Color navyDark = Color(0xFF0A1324);
  static const Color navyHeader = Color(0xFF0F172A);
  static const Color emeraldDark = Color(0xFF0B4A40);
  static const Color emerald = Color(0xFF10B981);
  static const Color tealAccent = Color(0xFF14B8A6);
  static const Color gold = Color(0xFFF5B82E);
  static const Color goldBright = Color(0xFFFFD54F);
  static const Color goldDark = Color(0xFFB45309);
  static const Color slateBg = Color(0xFFF1F5F9);
}

class MicroAdminPortalApp extends StatelessWidget {
  const MicroAdminPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Microbiology Admin Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.slateBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.emeraldDark,
          primary: AppColors.emeraldDark,
          secondary: AppColors.gold,
        ),
      ),
      builder: (BuildContext context, Widget? child) {
        final MediaQueryData mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(textScaler: const TextScaler.linear(0.95)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: const YouTubeOriginalStyleIntroScreen(),
    );
  }
}

// ============================================================================
// ORIGINAL ROUNDED-SQUARE BADGE WIDGET (ZERO ARABIC, ORIGINAL DESIGN)
// ============================================================================
class OriginalBadgeLogo extends StatelessWidget {
  final double size;
  final double borderRadius;
  final bool showGlow;

  const OriginalBadgeLogo({
    super.key,
    this.size = 44,
    this.borderRadius = 11,
    this.showGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showGlow
            ? <BoxShadow>[
                BoxShadow(
                  color: AppColors.tealAccent.withOpacity(0.38),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.22),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
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
// YOUTUBE ORIGINALS STYLE CINEMATIC INTRO SCREEN
// Golden Yellow Slogan ("Understanding Microbes, Strengthening Health")
// emerges from between the Top & Bottom splitting golden bars!
// ============================================================================
class YouTubeOriginalStyleIntroScreen extends StatefulWidget {
  const YouTubeOriginalStyleIntroScreen({super.key});

  @override
  State<YouTubeOriginalStyleIntroScreen> createState() =>
      _YouTubeOriginalStyleIntroScreenState();
}

class _YouTubeOriginalStyleIntroScreenState
    extends State<YouTubeOriginalStyleIntroScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3900),
    )..forward();

    _ctrl.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _goNext();
      }
    });
  }

  void _goNext() {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 520),
        pageBuilder: (BuildContext context, Animation<double> a1,
                Animation<double> a2) =>
            const MainAdminLiveWebViewShell(),
        transitionsBuilder: (BuildContext context, Animation<double> anim,
            Animation<double> sec, Widget child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double _interval(double begin, double end, Curve curve) {
    final double t = _ctrl.value;
    if (t <= begin) return 0.0;
    if (t >= end) return 1.0;
    return curve.transform((t - begin) / (end - begin));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07111E),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.18),
                  radius: 1.05,
                  colors: <Color>[
                    Color(0xFF102A3F),
                    Color(0xFF091626),
                    Color(0xFF050B14),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (BuildContext context, Widget? _) {
                final double badgePop =
                    _interval(0.0, 0.30, Curves.easeOutBack);
                final double badgeSheen =
                    _interval(0.18, 0.55, Curves.easeInOut);
                final double lineDraw =
                    _interval(0.24, 0.46, Curves.Cubic(0.22, 1.0, 0.36, 1.0));
                final double barSplit =
                    _interval(0.44, 0.72, Curves.Cubic(0.16, 1.0, 0.3, 1.0));
                final double deptReveal =
                    _interval(0.60, 0.88, Curves.easeOutCubic);

                final double maxLineWidth =
                    math.min(MediaQuery.of(context).size.width - 40, 340.0);
                final double currentLineWidth = maxLineWidth * lineDraw;
                final double splitGap = 52.0 * barSplit;

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // 1. Original Rounded-Square Badge with Studio Sheen
                        Opacity(
                          opacity: badgePop.clamp(0.0, 1.0),
                          child: Transform.scale(
                            scale: 0.76 + (0.24 * badgePop),
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                const OriginalBadgeLogo(
                                  size: 168,
                                  borderRadius: 34,
                                  showGlow: true,
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(34),
                                  child: SizedBox(
                                    width: 168,
                                    height: 168,
                                    child: FractionalTranslation(
                                      translation: Offset(
                                          -1.3 + (badgeSheen * 2.6), 0.0),
                                      child: Transform.rotate(
                                        angle: -0.45,
                                        child: Container(
                                          width: 56,
                                          height: 240,
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
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // 2. YouTube Originals Split Bar Revealing Golden Slogan
                        if (lineDraw > 0.01)
                          SizedBox(
                            width: maxLineWidth,
                            height: splitGap + 14,
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                ClipRect(
                                  child: Align(
                                    alignment: Alignment.center,
                                    heightFactor: barSplit.clamp(0.0, 1.0),
                                    child: Opacity(
                                      opacity: barSplit.clamp(0.0, 1.0),
                                      child: Transform.scale(
                                        scale: 0.90 + (0.10 * barSplit),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 6),
                                          child: Text(
                                            'Understanding Microbes, Strengthening Health',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 13.0,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.gold,
                                              letterSpacing: 0.45,
                                              shadows: <Shadow>[
                                                Shadow(
                                                  color: Color(0x80F5B82E),
                                                  blurRadius: 10,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Top Splitting Golden Bar
                                Positioned(
                                  top: (splitGap / 2) - (splitGap / 2),
                                  child: Container(
                                    width: currentLineWidth,
                                    height: 2.5,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      gradient: const LinearGradient(
                                        colors: <Color>[
                                          Color(0x00F5B82E),
                                          AppColors.gold,
                                          AppColors.goldBright,
                                          AppColors.gold,
                                          Color(0x00F5B82E),
                                        ],
                                      ),
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color:
                                              AppColors.gold.withOpacity(0.55),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Bottom Splitting Golden Bar
                                Positioned(
                                  bottom: (splitGap / 2) - (splitGap / 2),
                                  child: Container(
                                    width: currentLineWidth,
                                    height: 2.5,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      gradient: const LinearGradient(
                                        colors: <Color>[
                                          Color(0x00F5B82E),
                                          AppColors.gold,
                                          AppColors.goldBright,
                                          AppColors.gold,
                                          Color(0x00F5B82E),
                                        ],
                                      ),
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color:
                                              AppColors.gold.withOpacity(0.55),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const SizedBox(height: 66),

                        const SizedBox(height: 16),

                        // 3. Department & University Subtitle Below Bottom Bar
                        Opacity(
                          opacity: deptReveal.clamp(0.0, 1.0),
                          child: Transform.translate(
                            offset: Offset(0, (1.0 - deptReveal) * 10),
                            child: Column(
                              children: <Widget>[
                                const Text(
                                  'Microbiology Department',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Faculty of Pharmacy, Beni-Suef University',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11.8,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.76),
                                    letterSpacing: 0.25,
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
          ),
          Positioned(
            bottom: 24,
            right: 20,
            child: TextButton.icon(
              onPressed: _goNext,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white70,
                backgroundColor: Colors.white.withOpacity(0.08),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.white.withOpacity(0.14)),
                ),
              ),
              icon: const Icon(Icons.skip_next_rounded,
                  size: 16, color: AppColors.gold),
              label: const Text(
                'Skip Intro',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// FACEBOOK-STYLE TOP FLOATING CIRCULAR REFRESH INDICATOR
// ============================================================================
class TopFloatingCircularLoader extends StatelessWidget {
  final bool visible;
  const TopFloatingCircularLoader({super.key, required this.visible});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutBack,
        offset: visible ? const Offset(0, 0.0) : const Offset(0, -2.2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: visible ? 1.0 : 0.0,
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 38,
                height: 38,
                padding: const EdgeInsets.all(8.5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withOpacity(0.20),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const CircularProgressIndicator(
                  strokeWidth: 2.8,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.emeraldDark),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// MAIN ADMIN LIVE WEBVIEW SHELL (Connected directly to Google Apps Script)
// - Pre-login: Horizontal swipe + edge handle between Doctor Admin & Super Admin
// - Post-login: Swipe locked; top switch button switches portals cleanly
// - Top-right small "Students" button opens Student Portal WebView
// ============================================================================
class MainAdminLiveWebViewShell extends StatefulWidget {
  const MainAdminLiveWebViewShell({super.key});

  @override
  State<MainAdminLiveWebViewShell> createState() =>
      _MainAdminLiveWebViewShellState();
}

class _MainAdminLiveWebViewShellState extends State<MainAdminLiveWebViewShell> {
  final PageController _pageController = PageController(initialPage: 0);
  int _activeIndex = 0; // 0 = Doctor Admin, 1 = Super Admin
  bool _doctorLoggedIn = false;
  bool _superLoggedIn = false;
  bool _isLoadingDoctor = true;
  bool _isLoadingSuper = true;

  InAppWebViewController? _doctorWebCtrl;
  InAppWebViewController? _superWebCtrl;

  bool get _isCurrentLoading =>
      _activeIndex == 0 ? _isLoadingDoctor : _isLoadingSuper;

  bool get _isAnyLoggedIn => _doctorLoggedIn || _superLoggedIn;

  void _switchToRole(int targetIndex) {
    if (_activeIndex == targetIndex) {
      // Also trigger JS subpage switch inside current WebView just in case
      final InAppWebViewController? ctrl =
          targetIndex == 0 ? _doctorWebCtrl : _superWebCtrl;
      final String sub = targetIndex == 0 ? 'doctor' : 'superadmin';
      ctrl?.evaluateJavascript(
          source:
              "if(typeof switchSubpage==='function'){switchSubpage('$sub');}");
      return;
    }
    setState(() => _activeIndex = targetIndex);
    _pageController.animateToPage(
      targetIndex,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
    final InAppWebViewController? ctrl =
        targetIndex == 0 ? _doctorWebCtrl : _superWebCtrl;
    final String sub = targetIndex == 0 ? 'doctor' : 'superadmin';
    ctrl?.evaluateJavascript(
        source:
            "if(typeof switchSubpage==='function'){switchSubpage('$sub');}");
  }

  Future<void> _refreshActiveWebView() async {
    if (_activeIndex == 0) {
      setState(() => _isLoadingDoctor = true);
      await _doctorWebCtrl?.reload();
    } else {
      setState(() => _isLoadingSuper = true);
      await _superWebCtrl?.reload();
    }
  }

  void _openStudentPortal() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const StudentWebViewPortalScreen(),
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? _) async {
        if (didPop) return;
        final InAppWebViewController? ctrl =
            _activeIndex == 0 ? _doctorWebCtrl : _superWebCtrl;
        if (ctrl != null && await ctrl.canGoBack()) {
          await ctrl.goBack();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.slateBg,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.navyHeader,
              border: Border(
                bottom: BorderSide(color: Color(0xFF1E293B), width: 1),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: <Widget>[
                    const OriginalBadgeLogo(size: 34, borderRadius: 8),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'MICROBIOLOGY PORTAL',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.2,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Text(
                            _activeIndex == 0
                                ? 'Doctor & Course Admin (Live)'
                                : 'Super Admin Portal (Live)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9.8,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Role Switch Pill (Doctor Admin <-> Super Admin)
                    InkWell(
                      onTap: () => _switchToRole(_activeIndex == 0 ? 1 : 0),
                      borderRadius: BorderRadius.circular(9),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: _activeIndex == 1
                              ? AppColors.gold
                              : const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: _activeIndex == 1
                                ? AppColors.gold
                                : AppColors.gold.withOpacity(0.45),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              _activeIndex == 1
                                  ? Icons.medical_services_rounded
                                  : Icons.shield_rounded,
                              size: 13,
                              color: _activeIndex == 1
                                  ? AppColors.navyHeader
                                  : AppColors.gold,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _activeIndex == 1
                                  ? 'Doctor Admin'
                                  : 'Super Admin',
                              style: TextStyle(
                                fontSize: 10.2,
                                fontWeight: FontWeight.w800,
                                color: _activeIndex == 1
                                    ? AppColors.navyHeader
                                    : AppColors.gold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    // Circular Refresh Icon Button
                     SizedBox(
                      width: 30,
                      height: 30,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: _refreshActiveWebView,
                        tooltip: 'Refresh Live Portal',
                        icon: const Icon(
                          Icons.refresh_rounded,
                          size: 17,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Small Top-Right Students Portal Button
                    InkWell(
                      onTap: _openStudentPortal,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.emeraldDark,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.emerald.withOpacity(0.55)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(Icons.school_rounded,
                                size: 12.5, color: Colors.white),
                            SizedBox(width: 3.5),
                            Text(
                              'Students',
                              style: TextStyle(
                                fontSize: 10.0,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
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
                setState(() => _activeIndex = idx);
              },
              children: <Widget>[
                // Page 0: Doctor & Staff Admin Live WebView
                _LiveGasWebViewPane(
                  initialUrl: kAdminDoctorUrl,
                  targetSubpage: 'doctor',
                  onControllerCreated: (InAppWebViewController c) =>
                      _doctorWebCtrl = c,
                  onLoadingChanged: (bool loading) {
                    if (mounted) setState(() => _isLoadingDoctor = loading);
                  },
                  onLoginStateChanged: (bool loggedIn) {
                    if (mounted && _doctorLoggedIn != loggedIn) {
                      setState(() => _doctorLoggedIn = loggedIn);
                    }
                  },
                ),
                // Page 1: Super Admin Live WebView
                _LiveGasWebViewPane(
                  initialUrl: kAdminSuperUrl,
                  targetSubpage: 'superadmin',
                  onControllerCreated: (InAppWebViewController c) =>
                      _superWebCtrl = c,
                  onLoadingChanged: (bool loading) {
                    if (mounted) setState(() => _isLoadingSuper = loading);
                  },
                  onLoginStateChanged: (bool loggedIn) {
                    if (mounted && _superLoggedIn != loggedIn) {
                      setState(() => _superLoggedIn = loggedIn);
                    }
                  },
                ),
              ],
            ),

            // Pre-Login Floating Edge Swipe Handle
            if (!_isAnyLoggedIn)
              Positioned(
                right: _activeIndex == 0 ? 0 : null,
                left: _activeIndex == 1 ? 0 : null,
                top: MediaQuery.of(context).size.height * 0.36,
                child: GestureDetector(
                  onTap: () => _switchToRole(_activeIndex == 0 ? 1 : 0),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.navyHeader.withOpacity(0.88),
                      borderRadius: _activeIndex == 0
                          ? const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            )
                          : const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                      border: Border.all(
                        color: AppColors.gold.withOpacity(0.55),
                        width: 1,
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          _activeIndex == 0
                              ? Icons.chevron_left_rounded
                              : Icons.chevron_right_rounded,
                          color: AppColors.gold,
                          size: 18,
                        ),
                        const SizedBox(height: 2),
                        RotatedBox(
                          quarterTurns: 3,
                          child: Text(
                            _activeIndex == 0 ? 'SUPER ADMIN' : 'DOCTOR ADMIN',
                            style: const TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Top Floating Circular Refresh Indicator (Facebook-style)
            TopFloatingCircularLoader(visible: _isCurrentLoading),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// REUSABLE LIVE GOOGLE APPS SCRIPT WEBVIEW PANE
// Injects CSS to hide GAS banner, enforce clean mobile typography, and
// monitors login state so PageView swipe locks automatically after sign-in.
// ============================================================================
class _LiveGasWebViewPane extends StatefulWidget {
  final String initialUrl;
  final String targetSubpage;
  final ValueChanged<InAppWebViewController> onControllerCreated;
  final ValueChanged<bool> onLoadingChanged;
  final ValueChanged<bool> onLoginStateChanged;

  const _LiveGasWebViewPane({
    required this.initialUrl,
    required this.targetSubpage,
    required this.onControllerCreated,
    required this.onLoadingChanged,
    required this.onLoginStateChanged,
  });

  @override
  State<_LiveGasWebViewPane> createState() => _LiveGasWebViewPaneState();
}

class _LiveGasWebViewPaneState extends State<_LiveGasWebViewPane>
    with AutomaticKeepAliveClientMixin {
  InAppWebViewController? _ctrl;
  Timer? _pollTimer;

  @override
  bool get wantKeepAlive => true;

  static const String _kMobilePolishJs = r"""
(function() {
  try {
    // 1. Hide Google Apps Script top warning frame if present
    var st = document.getElementById('bsu-mobile-webview-polish');
    if (!st) {
      st = document.createElement('style');
      st.id = 'bsu-mobile-webview-polish';
      st.innerHTML = `
        #warning-bar-table, .warning-bar, [id*="warning-bar"] { display: none !important; }
        html, body { overflow-x: hidden !important; -webkit-text-size-adjust: 95% !important; }
      `;
      document.head.appendChild(st);
    }
  } catch (e) {}
})();
""";

  Future<void> _injectPolishAndSubpage(InAppWebViewController controller) async {
    await controller.evaluateJavascript(source: _kMobilePolishJs);
    if (widget.targetSubpage.isNotEmpty) {
      final String sub = widget.targetSubpage;
      await controller.evaluateJavascript(
        source: """
        (function() {
          try {
            if (typeof switchSubpage === 'function') {
              var docUnlocked = document.getElementById('doctorDashboardUnlocked');
              var supUnlocked = document.getElementById('superAdminDashboardUnlocked');
              var isLogged = (docUnlocked && !docUnlocked.classList.contains('hidden')) ||
                             (supUnlocked && !supUnlocked.classList.contains('hidden'));
              if (!isLogged) {
                switchSubpage('$sub');
              }
            }
          } catch (e) {}
        })();
        """,
      );
    }
  }

  void _startLoginStateMonitor() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(milliseconds: 1200), (_) async {
      final InAppWebViewController? c = _ctrl;
      if (c == null || !mounted) return;
      try {
        final Object? res = await c.evaluateJavascript(
          source: """
          (function() {
            var d = document.getElementById('doctorDashboardUnlocked');
            var s = document.getElementById('superAdminDashboardUnlocked');
            var docOpen = d && !d.classList.contains('hidden') && d.offsetParent !== null;
            var supOpen = s && !s.classList.contains('hidden') && s.offsetParent !== null;
            return (docOpen || supOpen) ? '1' : '0';
          })();
          """,
        );
        final bool loggedIn = res?.toString().contains('1') ?? false;
        widget.onLoginStateChanged(loggedIn);
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        domStorageEnabled: true,
        databaseEnabled: true,
        supportZoom: false,
        builtInZoomControls: false,
        displayZoomControls: false,
        useWideViewPort: true,
        loadWithOverviewMode: true,
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
        userAgent:
            'Mozilla/5.0 (Linux; Android 14; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36 BSU_MicroPortal_App/2.0',
      ),
      gestureRecognizers: <WebGestureFactory>{
        WebGestureFactory(() => VerticalDragGestureRecognizer()),
      },
      onWebViewCreated: (InAppWebViewController controller) {
        _ctrl = controller;
        widget.onControllerCreated(controller);
        _startLoginStateMonitor();
      },
      onLoadStart: (InAppWebViewController controller, WebUri? url) {
        widget.onLoadingChanged(true);
      },
      onLoadStop: (InAppWebViewController controller, WebUri? url) async {
        await _injectPolishAndSubpage(controller);
        widget.onLoadingChanged(false);
      },
      onReceivedError: (InAppWebViewController controller,
          WebResourceRequest request, WebResourceError error) {
        if (request.isForMainFrame ?? false) {
          widget.onLoadingChanged(false);
        }
      },
      shouldOverrideUrlLoading: (InAppWebViewController controller,
          NavigationAction navigationAction) async {
        final WebUri? uri = navigationAction.request.url;
        if (uri == null) return NavigationActionPolicy.ALLOW;
        final String urlStr = uri.toString();
        if (urlStr.contains('drive.google.com') ||
            urlStr.contains('docs.google.com/spreadsheets') ||
            urlStr.startsWith('mailto:') ||
            urlStr.startsWith('tel:') ||
            urlStr.contains('wa.me')) {
          final Uri? parsed = Uri.tryParse(urlStr);
          if (parsed != null) {
            await launchUrl(parsed, mode: LaunchMode.externalApplication);
            return NavigationActionPolicy.CANCEL;
          }
        }
        return NavigationActionPolicy.ALLOW;
      },
    );
  }
}

// ============================================================================
// STUDENT PORTAL LIVE WEBVIEW SCREEN (Opened from top-right "Students" button)
// ============================================================================
class StudentWebViewPortalScreen extends StatefulWidget {
  const StudentWebViewPortalScreen({super.key});

  @override
  State<StudentWebViewPortalScreen> createState() =>
      _StudentWebViewPortalScreenState();
}

class _StudentWebViewPortalScreenState
    extends State<StudentWebViewPortalScreen> {
  InAppWebViewController? _webCtrl;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slateBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Container(
          color: AppColors.emeraldDark,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 18, color: Colors.white),
                  ),
                  const OriginalBadgeLogo(size: 30, borderRadius: 7),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'STUDENT ACADEMIC PORTAL',
                          style: TextStyle(
                            fontSize: 11.2,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Microbiology Department • Live WebApp',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() => _isLoading = true);
                      _webCtrl?.reload();
                    },
                    icon: const Icon(Icons.refresh_rounded,
                        size: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(kStudentPortalUrl)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              domStorageEnabled: true,
              databaseEnabled: true,
              useWideViewPort: true,
              loadWithOverviewMode: true,
              allowsInlineMediaPlayback: true,
              mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
            ),
            onWebViewCreated: (InAppWebViewController c) => _webCtrl = c,
            onLoadStart: (InAppWebViewController c, WebUri? u) {
              if (mounted) setState(() => _isLoading = true);
            },
            onLoadStop: (InAppWebViewController c, WebUri? u) async {
              await c.evaluateJavascript(
                source: """
                (function(){
                  var s = document.createElement('style');
                  s.innerHTML = '#warning-bar-table, .warning-bar { display:none !important; }';
                  document.head.appendChild(s);
                })();
                """,
              );
              if (mounted) setState(() => _isLoading = false);
            },
            shouldOverrideUrlLoading: (InAppWebViewController controller,
                NavigationAction navigationAction) async {
              final WebUri? uri = navigationAction.request.url;
              if (uri == null) return NavigationActionPolicy.ALLOW;
              final String urlStr = uri.toString();
              if (urlStr.contains('drive.google.com') ||
                  urlStr.startsWith('mailto:') ||
                  urlStr.startsWith('tel:')) {
                final Uri? parsed = Uri.tryParse(urlStr);
                if (parsed != null) {
                  await launchUrl(parsed, mode: LaunchMode.externalApplication);
                  return NavigationActionPolicy.CANCEL;
                }
              }
              return NavigationActionPolicy.ALLOW;
            },
          ),
          TopFloatingCircularLoader(visible: _isLoading),
        ],
      ),
    );
  }
}

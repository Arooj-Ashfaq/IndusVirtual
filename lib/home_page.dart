import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'auth_service.dart';
import 'auth_sheet.dart';
import 'theme.dart';

const _nav = ['Home', 'Admissions', 'Careers', 'About', 'Blogs', 'Contact'];
const _portals = ['Admin Login', 'Teacher Login', 'Student Login', 'Parent Login'];
const _legal = ['Privacy Policy', 'Terms of Service', 'Account Deletion'];

class _Stat {
  final String value, label, img;
  const _Stat(this.value, this.label, this.img);
}

const _stats = [
  _Stat('66+', 'PCTB BOOKS', 'assets/stat1.png'),
  _Stat('KG-8', 'ALL CLASSES', 'assets/stat2.png'),
  _Stat('SECP', 'REG. (PVT) LTD', 'assets/stat3.png'),
  _Stat('4', 'PORTALS', 'assets/stat4.png'),
  _Stat('100%', 'ONLINE', 'assets/stat5.png'),
];

class _Feature {
  final String icon, title, text;
  final Color tint;
  const _Feature(this.icon, this.title, this.text, this.tint);
}

const _features = [
  _Feature('📊', 'LMS Dashboard', 'One place for classes, homework, results and announcements.', Color(0xFFFDE68A)),
  _Feature('🎥', 'Live Classes', 'Join real-time video classes with certified teachers. Interactive learning with whiteboard and chat.', Color(0xFFE5E7EB)),
  _Feature('📹', 'Recorded Lectures', 'Missed a class? Watch recorded lectures anytime at your own pace.', Color(0xFFFBCFE8)),
  _Feature('📝', 'Online Exams', 'MCQ and subjective exams with timer, auto-grading, and instant results.', Color(0xFFFDE68A)),
  _Feature('🏅', 'Results & Report Cards', 'Subject-wise marks, grades, percentages, and official report cards.', Color(0xFFA7F3D0)),
  _Feature('📚', 'Homework & Classwork', 'View, submit online, and get teacher feedback.', Color(0xFFBAE6FD)),
  _Feature('🗓️', 'Attendance Tracking', 'Daily attendance with instant parent visibility.', Color(0xFFFDE68A)),
  _Feature('📖', 'Study Material', 'PCTB textbooks and notes available digitally.', Color(0xFFFED7AA)),
  _Feature('👨‍👩‍👧', 'Parent Portal', 'Follow your child’s progress, fees and attendance.', Color(0xFFDDD6FE)),
  _Feature('🧑‍🏫', 'Teacher Portal', 'Plan lessons, mark work and manage classes.', Color(0xFFFBCFE8)),
  _Feature('💳', 'Fee Management', 'Simple fee vouchers and payment tracking.', Color(0xFFA7F3D0)),
  _Feature('⏰', 'Timetable', 'Daily class schedule with reminders.', Color(0xFFBAE6FD)),
];

String _first(User u) {
  final n = u.displayName?.trim() ?? '';
  if (n.isNotEmpty) return n.split(' ').first;
  return (u.email ?? 'there').split('@').first;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _featuresKey = GlobalKey();

  void _scrollToFeatures() {
    final c = _featuresKey.currentContext;
    if (c != null) {
      Scrollable.ensureVisible(c, duration: const Duration(milliseconds: 600), curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.user,
      builder: (context, snap) {
        final user = snap.data;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: kDark,
            foregroundColor: Colors.white,
            toolbarHeight: 68,
            titleSpacing: 0,
            title: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.asset('assets/logo.png', width: 38, height: 38),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Indus Virtual School',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    Text('Quality Online Schooling',
                        style: TextStyle(fontSize: 10.5, color: Color(0xFFD6D3D1))),
                  ],
                ),
              ),
            ]),
            actions: [
              IconButton(
                tooltip: 'Toggle theme',
                onPressed: () => themeMode.value = context.isDark ? ThemeMode.light : ThemeMode.dark,
                icon: Icon(context.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
              ),
              const SizedBox(width: 4),
            ],
          ),
          drawer: _NavDrawer(user: user),
          body: SingleChildScrollView(
            child: Column(children: [
              _Hero(user: user, onExplore: _scrollToFeatures),
              const _StatsBand(),
              _FeaturesSection(key: _featuresKey),
              const _Footer(),
            ]),
          ),
        );
      },
    );
  }
}

class _NavDrawer extends StatelessWidget {
  final User? user;
  const _NavDrawer({required this.user});

  @override
  Widget build(BuildContext context) {
    final amber = FilledButton.styleFrom(backgroundColor: kAmber, foregroundColor: kDark);
    return Drawer(
      backgroundColor: kDark,
      child: SafeArea(
        child: ListView(padding: const EdgeInsets.all(16), children: [
          for (var i = 0; i < _nav.length; i++)
            ListTile(
              title: Text(_nav[i],
                  style: TextStyle(
                      color: i == 0 ? kAmber : Colors.white70,
                      fontWeight: i == 0 ? FontWeight.w700 : FontWeight.w500)),
              onTap: () => Navigator.pop(context),
            ),
          const Divider(color: Colors.white24),
          const SizedBox(height: 8),
          if (user != null) ...[
            Text('Hi, ${_first(user!)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                AuthService.signOut();
              },
              child: const Text('Log out'),
            ),
          ] else ...[
            FilledButton(
              style: amber,
              onPressed: () {
                Navigator.pop(context);
                showAuthSheet(context, AuthMode.login);
              },
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: kAmber, side: const BorderSide(color: kAmber)),
              onPressed: () {
                Navigator.pop(context);
                showAuthSheet(context, AuthMode.signup);
              },
              child: const Text('Sign Up'),
            ),
          ],
        ]),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final User? user;
  final VoidCallback onExplore;
  const _Hero({required this.user, required this.onExplore});

  Widget _chip(BuildContext c, String text, Color color, {double size = 12}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(.12),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: color.withOpacity(.45)),
        ),
        child: Text(text, style: TextStyle(color: color, fontSize: size, fontWeight: FontWeight.w700, letterSpacing: .3)),
      );

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final wide = w > 900;
    final fs = wide ? 60.0 : (w * .092).clamp(30.0, 60.0);

    final text = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 8, children: [
        _chip(context, '●  ADMISSIONS OPEN — SESSION 2026', const Color(0xFFC2700A)),
        _chip(context, '🏛  SECP Registered • CUIN: 0366188 ✓', const Color(0xFF047857)),
      ]),
      const SizedBox(height: 12),
      Text.rich(TextSpan(
        style: TextStyle(fontSize: fs, fontWeight: FontWeight.w800, height: 1.05, letterSpacing: -1.2, color: context.ink),
        children: const [
          TextSpan(text: "PAKISTAN'S\nPREMIER\n"),
          TextSpan(text: 'ONLINE SCHOOL', style: TextStyle(color: kAmber)),
        ],
      )),
      const SizedBox(height: 20),
      Text.rich(TextSpan(
        style: TextStyle(fontSize: 16.5, height: 1.6, color: context.muted),
        children: [
          const TextSpan(text: 'Complete KG to 8th grade education following Punjab Board (PCTB 2026). Officially incorporated as '),
          TextSpan(text: 'Indus Virtual School (Private) Limited', style: TextStyle(fontWeight: FontWeight.w700, color: context.ink)),
          const TextSpan(text: ' under SECP.'),
        ],
      )),
      const SizedBox(height: 28),
      Wrap(spacing: 14, runSpacing: 12, children: [
        FilledButton(
          onPressed: () => user == null
              ? showAuthSheet(context, AuthMode.signup)
              : ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('You are signed in. Admission form coming soon.'))),
          style: FilledButton.styleFrom(
            backgroundColor: kAmber,
            foregroundColor: kDark,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          child: const Text('Apply for Admission →'),
        ),
        OutlinedButton(
          onPressed: onExplore,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            side: BorderSide(color: context.line, width: 2),
            foregroundColor: context.ink,
            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          child: const Text('Explore Features ↓'),
        ),
      ]),
    ]);

    final art = Padding(
      padding: const EdgeInsets.only(bottom: 34),
      child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.asset('assets/hero.webp', fit: BoxFit.cover),
        ),
        Positioned(
          right: 8,
          bottom: -30,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2B2724),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(.35), blurRadius: 24, offset: const Offset(0, 10))],
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Text('🎓', style: TextStyle(fontSize: 22)),
              SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text('PCTB 2026 Curriculum',
                    style: TextStyle(color: kAmber, fontWeight: FontWeight.w700, fontSize: 14)),
                Text('KG to 8th Class • Live & Interactive',
                    style: TextStyle(color: Colors.white, fontSize: 11)),
              ]),
            ]),
          ),
        ),
      ]),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-.8, -.3),
          radius: 1.3,
          colors: [kAmber.withOpacity(.16), Colors.transparent],
        ),
      ),
      child: wide
          ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(child: text),
              const SizedBox(width: 32),
              Expanded(child: art),
            ])
          : Column(children: [text, const SizedBox(height: 28), art]),
    );
  }
}

/// Stats cards that scroll continuously to the left.
class _StatsBand extends StatefulWidget {
  const _StatsBand();
  @override
  State<_StatsBand> createState() => _StatsBandState();
}

class _StatsBandState extends State<_StatsBand> with SingleTickerProviderStateMixin {
  final _ctrl = ScrollController();
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((d) {
      if (_ctrl.hasClients) _ctrl.jumpTo(d.inMicroseconds / 1e6 * 45); // 45 px/sec
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: context.band,
        border: Border.symmetric(horizontal: BorderSide(color: context.line)),
      ),
      child: SizedBox(
        height: 78,
        child: ListView.builder(
          controller: _ctrl,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (c, i) {
            final s = _stats[i % _stats.length];
            return Container(
              width: 230,
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.line),
              ),
              child: Row(children: [
                ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset(s.img, width: 44, height: 44)),
                const SizedBox(width: 14),
                Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.1)),
                  Text(s.label,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.4, color: c.muted)),
                ]),
              ]),
            );
          },
        ),
      ),
    );
  }
}

class _FeaturesSection extends StatefulWidget {
  const _FeaturesSection({super.key});
  @override
  State<_FeaturesSection> createState() => _FeaturesSectionState();
}

class _FeaturesSectionState extends State<_FeaturesSection> {
  static const _start = 12 * 1000 + 3; // endless loop, starts on "Online Exams"
  final _pc = PageController(viewportFraction: .82, initialPage: _start);
  Timer? _timer;
  int _page = _start;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _go(_page + 1));
  }

  void _go(int p) {
    if (_pc.hasClients) {
      _pc.animateToPage(p, duration: const Duration(milliseconds: 600), curve: Curves.easeOutCubic);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = _features.length;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text('Platform Features',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -.8)),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 270,
          child: PageView.builder(
            controller: _pc,
            onPageChanged: (p) => setState(() => _page = p),
            itemBuilder: (c, i) => AnimatedBuilder(
              animation: _pc,
              builder: (c, _) {
                var d = 0.0;
                if (_pc.position.haveDimensions) d = (_pc.page! - i).abs().clamp(0.0, 1.0);
                return Transform.scale(
                  scale: 1 - d * .08,
                  child: Opacity(opacity: 1 - d * .45, child: _FeatureCard(i % n, active: i == _page)),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Wrap(spacing: 7, children: [
            for (var i = 0; i < n; i++)
              GestureDetector(
                onTap: () => _go(_page + ((i - _page % n) % n)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: i == _page % n ? 26 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _page % n ? kAmber2 : context.line,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
          ]),
        ),
      ]),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final int index;
  final bool active;
  const _FeatureCard(this.index, {required this.active});

  @override
  Widget build(BuildContext context) {
    final f = _features[index];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: active ? kAmber : context.line, width: active ? 2 : 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: f.tint, borderRadius: BorderRadius.circular(14)),
            child: Text(f.icon, style: const TextStyle(fontSize: 26)),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: kAmber.withOpacity(.2), borderRadius: BorderRadius.circular(99)),
            child: Text('#${(index + 1).toString().padLeft(2, '0')}',
                style: const TextStyle(color: kAmber2, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 14),
        Text(f.title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(f.text, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, height: 1.5, color: context.muted)),
        const Spacer(),
        Divider(color: context.line),
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
            decoration: BoxDecoration(color: kAmber, borderRadius: BorderRadius.circular(99)),
            child: const Text('PCTB 2026', style: TextStyle(color: kDark, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
          const Spacer(),
          Text('KG to 8th Grade', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.muted)),
        ]),
      ]),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  static const _soft = Color(0xFFD6D3D1);

  Widget _col(String title, List<String> items, {VoidCallback? onTap}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),
          for (final i in items)
            InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: Text(i, style: const TextStyle(color: _soft, fontSize: 14)),
              ),
            ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: kDark,
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(9), child: Image.asset('assets/logo.png', width: 42, height: 42)),
          const SizedBox(width: 12),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Indus Virtual School', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
            Text('Quality Online Schooling', style: TextStyle(color: kAmber, fontSize: 12, fontWeight: FontWeight.w500)),
          ]),
        ]),
        const SizedBox(height: 14),
        const Text('Complete online school platform for KG to 8th grade following Punjab Board (PCTB 2026) curriculum.',
            style: TextStyle(color: _soft, height: 1.6, fontSize: 14.5)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: const Color(0xFF3A352F)), borderRadius: BorderRadius.circular(10)),
          child: const Text.rich(TextSpan(style: TextStyle(color: _soft, fontSize: 12, height: 1.5), children: [
            TextSpan(text: '✓ ', style: TextStyle(color: Color(0xFF10B981))),
            TextSpan(text: 'SECP Registered: ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            TextSpan(text: 'Indus Virtual School (Pvt) Ltd • CUIN: 0366188'),
          ])),
        ),
        const SizedBox(height: 14),
        const Text('📍 Office 503, Gulberg empire, Civic Center, Executive Block Koral Town, Islamabad, 44000',
            style: TextStyle(color: _soft, fontSize: 13, height: 1.6)),
        const SizedBox(height: 8),
        const Text('⏰ Monday to Saturday: 9:00 AM - 5:00 PM', style: TextStyle(color: _soft, fontSize: 13)),
        const SizedBox(height: 28),
        Wrap(spacing: 44, runSpacing: 26, children: [
          _col('Quick Links', _nav),
          _col('Portals', _portals, onTap: () => showAuthSheet(context, AuthMode.login)),
          _col('Legal', _legal),
        ]),
        const SizedBox(height: 14),
        const Divider(color: Color(0xFF2E2A26)),
        const SizedBox(height: 8),
        Row(children: [
          const Expanded(
            child: Text('© 2026 Indus Virtual School (Private) Limited. All rights reserved.',
                style: TextStyle(color: _soft, fontSize: 12.5)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF2E2A26),
              border: Border.all(color: const Color(0xFF4A4238)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('v1.0.1', style: TextStyle(color: kAmber, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ]),
      ]),
    );
  }
}

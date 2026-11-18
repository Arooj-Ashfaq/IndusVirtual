import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth_service.dart';
import '../theme.dart';
import 'admission_service.dart';

const _green = Color(0xFF059669);
const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _classes = ['KG', 'Prep', 'Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5', 'Class 6', 'Class 7', 'Class 8'];
final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
final _cnicRe = RegExp(r'^\d{5}-\d{7}-\d$');
final _phoneRe = RegExp(r'^(03\d{9}|\+923\d{9})$');

class AdmissionPage extends StatefulWidget {
  const AdmissionPage({super.key});
  @override
  State<AdmissionPage> createState() => _AdmissionPageState();
}

class _AdmissionPageState extends State<AdmissionPage> {
  static const _keys = [
    'fullName', 'email', 'password', 'confirm', 'dob', 'bForm',
    'guardianName', 'fatherName', 'motherName', 'guardianCnic', 'fatherOccupation',
    'phone1', 'phone2', 'guardianEmail',
    'previousSchool', 'lastClass', 'lastResult', 'reason',
  ];
  late final Map<String, TextEditingController> _c = {for (final k in _keys) k: TextEditingController()};
  final _forms = [GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>()];
  final _scroll = ScrollController();

  int _step = 0;
  bool _busy = false, _agree = false, _cnicMissing = false, _showPass = false, _showConfirm = false;
  String? _error, _gender, _applyClass;
  String _relation = 'Father';
  DateTime? _dob;
  PlatformFile? _cnic;
  User? _user;

  @override
  void initState() {
    super.initState();
    if (firebaseReady) {
      _user = FirebaseAuth.instance.currentUser;
      _c['email']!.text = _user?.email ?? '';
      _c['fullName']!.text = _user?.displayName ?? '';
    }
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    _scroll.dispose();
    super.dispose();
  }

  String _t(String k) => _c[k]!.text.trim();

  InputDecoration _dec(String label, {String? hint, String? helper, Widget? suffix}) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: context.line),
    );
    return InputDecoration(
      labelText: label,
      hintText: hint,
      helperText: helper,
      suffixIcon: suffix,
      filled: true,
      fillColor: context.card,
      border: border,
      enabledBorder: border,
    );
  }

  Widget _gap(Widget w) => Padding(padding: const EdgeInsets.only(bottom: 14), child: w);

  Widget _tf(String key, String label,
      {bool req = false, bool obscure = false, TextInputType? type, String? hint, String? helper,
      Widget? suffix, bool readOnly = false, int lines = 1, String? Function(String?)? validator,
      void Function(String)? onChanged}) {
    return _gap(TextFormField(
      controller: _c[key],
      obscureText: obscure,
      keyboardType: type,
      readOnly: readOnly,
      maxLines: obscure ? 1 : lines,
      onChanged: onChanged,
      decoration: _dec(req ? '$label *' : label, hint: hint, helper: helper, suffix: suffix),
      validator: validator ?? (req ? (v) => (v ?? '').trim().isEmpty ? 'Required' : null : null),
    ));
  }

  Widget _dropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged, {bool req = true}) {
    return _gap(DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: _dec(req ? '$label *' : label),
      items: [for (final i in items) DropdownMenuItem(value: i, child: Text(i))],
      onChanged: onChanged,
      validator: req ? (v) => v == null ? 'Required' : null : null,
    ));
  }

  Widget _section(String title, List<Widget> children) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: context.band,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(title, style: const TextStyle(color: _green, fontWeight: FontWeight.w800, fontSize: 12.5, letterSpacing: .8)),
          ),
          ...children,
        ]),
      );

  // ---------- Step 1: Personal details ----------
  Widget _strength() {
    final p = _c['password']!.text;
    final rules = <(bool, String)>[
      (p.length >= 6, 'At least 6 characters'),
      (RegExp(r'\d').hasMatch(p), 'At least one number (0-9)'),
      (RegExp(r'[^A-Za-z0-9]').hasMatch(p), r'At least one special character (!@#$%^&*)'),
    ];
    final score = rules.where((r) => r.$1).length;
    final color = score == 3 ? _green : (score == 2 ? kAmber2 : Colors.red.shade500);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: context.line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          for (var i = 0; i < 3; i++)
            Expanded(
              child: Container(
                height: 5,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(color: i < score ? color : context.line, borderRadius: BorderRadius.circular(9)),
              ),
            ),
          Text(score == 3 ? '✓ STRONG' : (score == 2 ? 'FAIR' : 'WEAK'),
              style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12)),
        ]),
        const SizedBox(height: 10),
        for (final r in rules)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(children: [
              Icon(r.$1 ? Icons.check_circle : Icons.circle_outlined, size: 18, color: r.$1 ? _green : context.muted),
              const SizedBox(width: 8),
              Expanded(child: Text(r.$2, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: r.$1 ? _green : context.muted))),
            ]),
          ),
      ]),
    );
  }

  Future<void> _pickDob() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(2018, 1, 1),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (d != null) {
      setState(() => _dob = d);
      _c['dob']!.text = '${d.day.toString().padLeft(2, '0')}-${_months[d.month - 1]}-${d.year}';
    }
  }

  Future<void> _pickFile() async {
    final r = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );
    final f = r?.files.single;
    if (f == null) return;
    if (f.bytes == null || f.size > 5 * 1024 * 1024) {
      setState(() => _error = 'File must be a JPG, PNG or PDF under 5 MB.');
      return;
    }
    setState(() {
      _cnic = f;
      _cnicMissing = false;
      _error = null;
    });
  }

  void _preview() {
    final f = _cnic!;
    final isImg = ['jpg', 'jpeg', 'png'].contains((f.extension ?? '').toLowerCase());
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(f.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        content: isImg ? Image.memory(f.bytes!) : const Text('PDF selected. Preview is not available.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  Widget _upload() {
    return _gap(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (_cnic == null)
        OutlinedButton.icon(
          onPressed: _pickFile,
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload CNIC / B-Form *  (JPG, PNG, PDF · max 5 MB)'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            foregroundColor: context.ink,
            side: BorderSide(color: _cnicMissing ? Colors.red.shade600 : context.line),
          ),
        )
      else
        Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
          decoration: BoxDecoration(
            color: _green.withOpacity(.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _green.withOpacity(.4)),
          ),
          child: Row(children: [
            Expanded(
              child: Text('${_cnic!.name} (${(_cnic!.size / 1024).toStringAsFixed(1)} KB)',
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _green, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
            TextButton(onPressed: _preview, child: const Text('Preview')),
            IconButton(onPressed: () => setState(() => _cnic = null), icon: const Icon(Icons.close, size: 18)),
          ]),
        ),
      if (_cnicMissing)
        Padding(
          padding: const EdgeInsets.only(top: 6, left: 12),
          child: Text('Please upload the CNIC / B-Form', style: TextStyle(color: Colors.red.shade600, fontSize: 12)),
        ),
    ]));
  }

  Widget _stepPersonal() {
    final signedIn = _user != null;
    return _section('STUDENT INFORMATION', [
      _tf('fullName', 'Full Name', req: true, hint: "Student's full name"),
      _tf('email', 'Email', req: true, type: TextInputType.emailAddress, readOnly: signedIn,
          validator: (v) => _emailRe.hasMatch((v ?? '').trim()) ? null : 'Enter a valid email'),
      if (!signedIn) ...[
        _tf('password', 'Password', req: true, obscure: !_showPass, onChanged: (_) => setState(() {}),
            suffix: IconButton(
                icon: Icon(_showPass ? Icons.visibility : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _showPass = !_showPass)),
            validator: (v) {
              final p = v ?? '';
              if (p.length < 6 || !RegExp(r'\d').hasMatch(p) || !RegExp(r'[^A-Za-z0-9]').hasMatch(p)) {
                return 'Password does not meet all requirements';
              }
              return null;
            }),
        if (_c['password']!.text.isNotEmpty) _strength(),
        _tf('confirm', 'Confirm Password', req: true, obscure: !_showConfirm,
            suffix: IconButton(
                icon: Icon(_showConfirm ? Icons.visibility : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _showConfirm = !_showConfirm)),
            validator: (v) => v == _c['password']!.text ? null : 'Passwords do not match'),
      ],
      _tf('dob', 'Date of Birth', req: true, readOnly: true, hint: 'Select date',
          suffix: const Icon(Icons.calendar_today_outlined, size: 18),
          validator: (_) => _dob == null ? 'Required' : null),
      _dropdown('Gender', _gender, const ['Male', 'Female'], (v) => setState(() => _gender = v)),
      _tf('bForm', 'B-Form / CNIC Number', req: true, type: TextInputType.number, hint: '00000-0000000-0',
          validator: (v) => _cnicRe.hasMatch((v ?? '').trim()) ? null : 'Format: 00000-0000000-0'),
      _upload(),
    ]);
  }

  // ---------- Step 2: Parents details ----------
  Widget _stepParents() {
    return _section('PARENT / GUARDIAN INFORMATION', [
      _dropdown('Parent / Guardian', _relation, const ['Father', 'Mother', 'Guardian'], (v) => setState(() => _relation = v ?? 'Father')),
      _tf('guardianName', 'Parent / Guardian Name', req: true, hint: "Parent or Guardian's full name"),
      _tf('fatherName', 'Father Name', req: true, hint: "Father's full name"),
      _tf('motherName', 'Mother Name', req: true, hint: "Mother's full name"),
      _tf('guardianCnic', 'Father/Guardian CNIC Number', req: true, type: TextInputType.number,
          hint: '00000-0000000-0', helper: 'Fill this form as per CNIC',
          validator: (v) => _cnicRe.hasMatch((v ?? '').trim()) ? null : 'Format: 00000-0000000-0'),
      _tf('fatherOccupation', 'Father Occupation', hint: 'e.g. Engineer, Business, etc.'),
      _tf('phone1', 'Contact Number 1', req: true, type: TextInputType.phone, hint: '03001234567',
          validator: (v) => _phoneRe.hasMatch((v ?? '').trim()) ? null : 'Enter a valid number, e.g. 03001234567'),
      _tf('phone2', 'Contact Number 2', type: TextInputType.phone, hint: 'Optional',
          validator: (v) => (v ?? '').trim().isEmpty || _phoneRe.hasMatch(v!.trim()) ? null : 'Enter a valid number'),
      _tf('guardianEmail', 'Father/Guardian Email', req: true, type: TextInputType.emailAddress, hint: 'parent@email.com',
          validator: (v) => _emailRe.hasMatch((v ?? '').trim()) ? null : 'Enter a valid email'),
    ]);
  }

  // ---------- Step 3: Education details (fields are a first draft; adjust to the real form) ----------
  bool get _needPrev => _applyClass != null && _applyClass != 'KG' && _applyClass != 'Prep';

  Widget _stepEducation() {
    String? prev(String? v) => _needPrev && (v ?? '').trim().isEmpty ? 'Required' : null;
    return _section('EDUCATION INFORMATION', [
      _dropdown('Applying for Class', _applyClass, _classes, (v) => setState(() => _applyClass = v)),
      _tf('previousSchool', 'Previous School Name', hint: 'Last school attended', validator: prev),
      _tf('lastClass', 'Last Class Passed', hint: 'e.g. Class 3', validator: prev),
      _tf('lastResult', 'Last Result (% or Grade)', hint: 'e.g. 82% or A', validator: prev),
      _tf('reason', 'Reason for Leaving Previous School', lines: 3, hint: 'Optional'),
      CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        value: _agree,
        onChanged: (v) => setState(() => _agree = v ?? false),
        title: const Text('I confirm that the information provided is correct.', style: TextStyle(fontSize: 13.5)),
      ),
    ]);
  }

  // ---------- Navigation / submit ----------
  void _go(int step) {
    setState(() {
      _step = step;
      _error = null;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _next() {
    final ok = _forms[_step].currentState!.validate();
    var fileOk = true;
    if (_step == 0 && _cnic == null) {
      setState(() => _cnicMissing = true);
      fileOk = false;
    }
    if (!ok || !fileOk) return;
    _step < 2 ? _go(_step + 1) : _submit();
  }

  Future<void> _submit() async {
    if (!firebaseReady) {
      setState(() => _error = 'Firebase is not configured yet. Run `flutterfire configure` (see README).');
      return;
    }
    if (!_agree) {
      setState(() => _error = 'Please confirm that the information is correct.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final uid = await AdmissionService.submit(
        email: _t('email'),
        password: _c['password']!.text,
        fullName: _t('fullName'),
        file: _cnic!,
        student: {
          'fullName': _t('fullName'),
          'email': _t('email'),
          'dateOfBirth': '${_dob!.year}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.day.toString().padLeft(2, '0')}',
          'gender': _gender,
          'bFormCnic': _t('bForm'),
        },
        parent: {
          'relation': _relation,
          'guardianName': _t('guardianName'),
          'fatherName': _t('fatherName'),
          'motherName': _t('motherName'),
          'guardianCnic': _t('guardianCnic'),
          'fatherOccupation': _t('fatherOccupation'),
          'phone1': _t('phone1'),
          'phone2': _t('phone2'),
          'guardianEmail': _t('guardianEmail'),
        },
        education: {
          'applyingForClass': _applyClass,
          'previousSchool': _t('previousSchool'),
          'lastClassPassed': _t('lastClass'),
          'lastResult': _t('lastResult'),
          'reasonForLeaving': _t('reason'),
        },
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Application submitted 🎉'),
          content: Text('Your reference number is IVS-${uid.substring(0, 6).toUpperCase()}.\nWe will contact you on the parent contact number.'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))],
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => _error = AdmissionService.message(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _tabs() {
    const labels = ['Personal Details', 'Parents Details', 'Education Details'];
    const icons = [Icons.badge_outlined, Icons.shield_outlined, Icons.account_balance_outlined];
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.line)),
      child: Row(children: [
        for (var i = 0; i < 3; i++)
          Expanded(
            child: GestureDetector(
              onTap: i < _step ? () => _go(i) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: i == _step ? kAmber.withOpacity(.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: i == _step ? kDark : (i < _step ? kAmber : context.band),
                    child: Icon(i < _step ? Icons.check : icons[i], size: 16, color: i == _step ? kAmber : (i < _step ? kDark : context.muted)),
                  ),
                  const SizedBox(height: 5),
                  Text('${i + 1}. ${labels[i]}',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10.5, fontWeight: i == _step ? FontWeight.w800 : FontWeight.w600, color: i == _step ? context.ink : context.muted)),
                ]),
              ),
            ),
          ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_stepPersonal(), _stepParents(), _stepEducation()];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kDark,
        foregroundColor: Colors.white,
        title: const Text('Apply for Admission', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('ADMISSION FORM', style: TextStyle(color: _green, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1)),
          const SizedBox(height: 12),
          _tabs(),
          const SizedBox(height: 16),
          Form(key: _forms[_step], child: pages[_step]),
          if (_error != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red.withOpacity(.12), borderRadius: BorderRadius.circular(10)),
              child: Text(_error!, style: TextStyle(color: Colors.red.shade600, fontSize: 13)),
            ),
        ]),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: BoxDecoration(color: context.card, border: Border(top: BorderSide(color: context.line))),
          child: Row(children: [
            if (_step > 0) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : () => _go(_step - 1),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), foregroundColor: context.ink),
                  child: const Text('← Back'),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: _busy ? null : _next,
                style: FilledButton.styleFrom(
                  backgroundColor: kAmber,
                  foregroundColor: kDark,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5),
                ),
                child: Text(_busy ? 'Submitting…' : (_step < 2 ? 'Next →' : 'Submit Application')),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

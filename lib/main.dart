import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:math';

void main() {
  runApp(const CountMyDaysApp());
}

class CountMyDaysApp extends StatelessWidget {
  const CountMyDaysApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Count My Days',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? _birthdate;
  int _lifespanYears = 70;
  ViewMode _viewMode = ViewMode.daily;
  bool _isAutoMode = true;
  bool _notificationsEnabled = false;
  final Set<int> _manuallyCheckedDays = {};

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final birthdateMillis = prefs.getInt('birthdate');
      if (birthdateMillis != null) {
        _birthdate = DateTime.fromMillisecondsSinceEpoch(birthdateMillis);
      }
      _lifespanYears = prefs.getInt('lifespanYears') ?? 70;
      _viewMode = ViewMode.values[prefs.getInt('viewMode') ?? 0];
      _isAutoMode = prefs.getBool('isAutoMode') ?? true;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? false;

      final checkedDays = prefs.getStringList('manuallyCheckedDays') ?? [];
      _manuallyCheckedDays.addAll(checkedDays.map((e) => int.parse(e)));
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (_birthdate != null) {
      await prefs.setInt('birthdate', _birthdate!.millisecondsSinceEpoch);
    }
    await prefs.setInt('lifespanYears', _lifespanYears);
    await prefs.setInt('viewMode', _viewMode.index);
    await prefs.setBool('isAutoMode', _isAutoMode);
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setStringList('manuallyCheckedDays',
        _manuallyCheckedDays.map((e) => e.toString()).toList());
  }

  void _selectBirthdate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _birthdate ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _birthdate = picked;
        _manuallyCheckedDays.clear();
      });
      _savePreferences();
    }
  }

  int _getDaysLived() {
    if (_birthdate == null) return 0;
    return DateTime.now().difference(_birthdate!).inDays;
  }

  int _getTotalDays() {
    return _lifespanYears * 365;
  }

  int _getUnitsCount() {
    switch (_viewMode) {
      case ViewMode.daily:
        return _getTotalDays();
      case ViewMode.weekly:
        return (_getTotalDays() / 7).ceil();
      case ViewMode.monthly:
        return _lifespanYears * 12;
    }
  }

  int _getUnitsLived() {
    if (_birthdate == null) return 0;
    final daysLived = _getDaysLived();

    switch (_viewMode) {
      case ViewMode.daily:
        return daysLived;
      case ViewMode.weekly:
        return (daysLived / 7).floor();
      case ViewMode.monthly:
        final now = DateTime.now();
        return (now.year - _birthdate!.year) * 12 +
            (now.month - _birthdate!.month);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Count My Days'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(),
          ),
        ],
      ),
      body: _birthdate == null ? _buildWelcomeScreen() : _buildMainScreen(),
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today, size: 80, color: Colors.blue),
          const SizedBox(height: 20),
          const Text(
            'Welcome to Count My Days',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Track your life journey, one day at a time',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: _selectBirthdate,
            icon: const Icon(Icons.cake),
            label: const Text('Set Your Birthdate'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainScreen() {
    final daysLived = _getDaysLived();
    final totalDays = _getTotalDays();
    final daysRemaining = max(0, totalDays - daysLived);
    final progressPercent = (daysLived / totalDays * 100).clamp(0, 100);

    return Column(
      children: [
        _buildStatisticsCard(
            daysLived, daysRemaining, totalDays, progressPercent.toDouble()),
        Expanded(
          child: _buildLifespanGridWithPainter(),
        ),
      ],
    );
  }

  Widget _buildStatisticsCard(
      int daysLived, int daysRemaining, int totalDays, double progressPercent) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                    'Days Lived', daysLived.toString(), Colors.green),
                _buildStatItem(
                    'Days Remaining', daysRemaining.toString(), Colors.orange),
                _buildStatItem('Total Days', totalDays.toString(), Colors.blue),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                Text('Life Progress: ${progressPercent.toStringAsFixed(1)}%'),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progressPercent / 100,
                  minHeight: 10,
                  backgroundColor: Colors.grey[300],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildLifespanGridWithPainter() {
    final totalUnits = _getUnitsCount();
    final livedUnits = _getUnitsLived();
    final screenSize = MediaQuery.of(context).size;
    final spacing = 1.0;
    const padding = 32.0;

    final availableWidth = screenSize.width - padding;
    final availableHeight = screenSize.height - 300;

    final aspectRatio = availableWidth / availableHeight;
    final estimatedCols = sqrt(totalUnits * aspectRatio).floor();
    final estimatedRows = (totalUnits / estimatedCols).ceil();

    final cellWidth =
        (availableWidth - (estimatedCols - 1) * spacing) / estimatedCols;
    final cellHeight =
        (availableHeight - (estimatedRows - 1) * spacing) / estimatedRows;
    final cellSize = cellWidth < cellHeight ? cellWidth : cellHeight;

    final actualWidth = estimatedCols * (cellSize + spacing);
    final actualHeight = estimatedRows * (cellSize + spacing);

    return Padding(
      padding: const EdgeInsets.all(padding / 2),
      child: CustomPaint(
        size: Size(actualWidth, actualHeight),
        painter: LifeGridPainter(
          units: totalUnits,
          lived: livedUnits,
          manual: _manuallyCheckedDays,
          auto: _isAutoMode,
          cellSize: cellSize,
          spacing: spacing,
        ),
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.cake),
                title: const Text('Birthdate'),
                subtitle: Text(_birthdate != null
                    ? DateFormat('MMM dd, yyyy').format(_birthdate!)
                    : 'Not set'),
                onTap: () {
                  Navigator.pop(context);
                  _selectBirthdate();
                },
              ),
              ListTile(
                leading: const Icon(Icons.timeline),
                title: const Text('Lifespan (years)'),
                subtitle: Text('$_lifespanYears years'),
                trailing: SizedBox(
                  width: 100,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    controller:
                        TextEditingController(text: _lifespanYears.toString()),
                    onChanged: (value) {
                      final years = int.tryParse(value);
                      if (years != null && years > 0 && years <= 150) {
                        setModalState(() => _lifespanYears = years);
                        setState(() => _lifespanYears = years);
                        _savePreferences();
                      }
                    },
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.view_module),
                title: const Text('Grid View'),
                subtitle: Text(_viewMode.toString().split('.').last),
                trailing: DropdownButton<ViewMode>(
                  value: _viewMode,
                  onChanged: (value) {
                    if (value != null) {
                      setModalState(() => _viewMode = value);
                      setState(() => _viewMode = value);
                      _savePreferences();
                    }
                  },
                  items: ViewMode.values.map((mode) {
                    return DropdownMenuItem(
                      value: mode,
                      child: Text(mode.toString().split('.').last),
                    );
                  }).toList(),
                ),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.auto_mode),
                title: const Text('Automatic Mode'),
                subtitle: const Text('Days auto-filled based on current date'),
                value: _isAutoMode,
                onChanged: (value) {
                  setModalState(() => _isAutoMode = value);
                  setState(() => _isAutoMode = value);
                  _savePreferences();
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.notifications),
                title: const Text('Daily Reminders'),
                subtitle: const Text('Get notified about your daily progress'),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setModalState(() => _notificationsEnabled = value);
                  setState(() => _notificationsEnabled = value);
                  _savePreferences();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

enum ViewMode { daily, weekly, monthly }

class LifeGridPainter extends CustomPainter {
  final int units;
  final int lived;
  final Set<int> manual;
  final bool auto;
  final double cellSize;
  final double spacing;

  LifeGridPainter({
    required this.units,
    required this.lived,
    required this.manual,
    required this.auto,
    required this.cellSize,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final cols = (size.width / (cellSize + spacing)).floor();
    for (int i = 0; i < units; i++) {
      final row = i ~/ cols;
      final col = i % cols;

      final dx = col * (cellSize + spacing);
      final dy = row * (cellSize + spacing);

      final isPast = i < lived;
      final isChecked = auto ? isPast : manual.contains(i);

      paint.color = isChecked
          ? Colors.green
          : isPast
              ? Colors.grey.shade300
              : Colors.grey.shade100;

      canvas.drawRect(
        Rect.fromLTWH(dx, dy, cellSize, cellSize),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

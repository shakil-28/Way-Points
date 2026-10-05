import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/waypoint_logo.dart';
import '../controllers/settings_controller.dart';
import '../models/settings_model.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsController? controller;

  const SettingsScreen({super.key, this.controller});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _avoidHighways = false;
  bool _speedLimitWarnings = true;
  bool _routeDiscovery = true;
  String _voiceLanguage = 'Bengali (BD - Farhana)';

  SettingsController get _ctrl => widget.controller ?? Provider.of<SettingsController>(context, listen: false);

  void _onThemeChanged(ThemePreference val) => _ctrl.setTheme(val);
  void _onVoiceGuidanceChanged(bool v) => _ctrl.setVoicePrompts(v);
  void _onAvoidTollsChanged(bool v) => _ctrl.setAvoidTolls(v);
  void _onAvoidFerriesChanged(bool v) => _ctrl.setAvoidFerries(v);
  void _onSpeedUnitChanged(SpeedUnit unit) => _ctrl.setSpeedUnit(unit);
  void _onOfflineCacheChanged(bool v) => _ctrl.setOfflineCache(v);
  void _onPreferredFuelChanged(String fuel) => _ctrl.setPreferredFuel(fuel);

  void _resetDefaults() {
    _ctrl.resetDefaults();
    setState(() {
      _avoidHighways = false;
      _speedLimitWarnings = true;
      _routeDiscovery = true;
      _voiceLanguage = 'Bengali (BD - Farhana)';
    });
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Voice Language',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),
            ...['Bengali (BD - Farhana)', 'English (US)', 'Hindi (IN)']
                .map((lang) => ListTile(
                      title: Text(lang),
                      trailing: _voiceLanguage == lang ? const Icon(Symbols.check, color: AppTheme.primaryGreen) : null,
                      onTap: () {
                        setState(() => _voiceLanguage = lang);
                        Navigator.pop(ctx);
                      },
                    )),
          ],
        ),
      ),
    );
  }

  void _showFuelPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Consumer<SettingsController>(
        builder: (context, ctrl, _) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Preferred Fuel Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),
              ...['Octane', 'CNG', 'Diesel', 'Electric']
                  .map((fuel) => ListTile(
                        title: Text(fuel),
                        trailing: ctrl.settings.preferredFuelType == fuel ? const Icon(Symbols.check, color: AppTheme.primaryGreen) : null,
                        onTap: () {
                          _onPreferredFuelChanged(fuel);
                          Navigator.pop(ctx);
                        },
                      )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = _ctrl.settings;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkCanvas : const Color(0xFFF8FAF9),
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSettingsContent(isDark, s),
        ],
      ),
      ),
    );
  }

  // ── Main Content ──────────────────────────────────────────────────────

  Widget _buildSettingsContent(bool isDark, SettingsModel s) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _buildContextHeader(isDark),
          const SizedBox(height: 20),
          _buildAppearanceSection(isDark, s),
          const SizedBox(height: 20),
          _buildNavigationPreferences(isDark, s),
          const SizedBox(height: 20),
          _buildAccountPreferences(isDark, s),
          const SizedBox(height: 20),
          _buildAboutSection(isDark, s),
        ]),
      ),
    );
  }

  // ── Context Header ────────────────────────────────────────────────────

  Widget _buildContextHeader(bool isDark) {
    return Row(
      children: [
        _roundActionBtn(icon: Symbols.arrow_back, onTap: () => Navigator.of(context).maybePop(), isDark: isDark),
        const Expanded(child: Center(child: Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))))),
        _roundActionBtn(icon: Symbols.restart_alt, onTap: _resetDefaults, color: const Color(0xFF64748B), isDark: isDark),
      ],
    );
  }

  Widget _roundActionBtn({required IconData icon, required VoidCallback onTap, Color color = const Color(0xFF0F172A), required bool isDark}) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(side: BorderSide(color: Color(0xFFE2E8F0))),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 40, height: 40, child: Icon(icon, size: 20, color: color)),
      ),
    );
  }

  // ── Appearance Section ────────────────────────────────────────────────

  Widget _buildAppearanceSection(bool isDark, SettingsModel s) {
    return _settingsCard(isDark: isDark, child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _sectionIcon(icon: Symbols.palette, highlighted: true, isDark: isDark),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Appearance', style: TextStyle(fontSize: 18, height: 1.3, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
          const SizedBox(height: 3),
          const Text('Switch between Dark Obsidian and Lite Canvas', style: TextStyle(fontSize: 12, height: 1.35, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
        ])),
        const SizedBox(width: 12),
        _themeSelector(s.themePreference, isDark),
      ],
    ));
  }

  Widget _themeSelector(ThemePreference pref, bool isDark) {
    final isLite = pref == ThemePreference.light || (pref == ThemePreference.system && Theme.of(context).brightness == Brightness.light);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(999), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _segmentButton(icon: Symbols.light_mode, label: 'Lite', selected: isLite, onTap: () => _onThemeChanged(ThemePreference.light)),
        _segmentButton(icon: Symbols.dark_mode, label: 'Dark', selected: !isLite, onTap: () => _onThemeChanged(ThemePreference.dark)),
      ]),
    );
  }

  Widget _segmentButton({required IconData icon, required String label, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4, offset: const Offset(0, 2))] : null,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: selected ? Colors.white : const Color(0xFF64748B)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? Colors.white : const Color(0xFF64748B))),
        ]),
      ),
    );
  }

  // ── Navigation Preferences ────────────────────────────────────────────

  Widget _buildNavigationPreferences(bool isDark, SettingsModel s) {
    return _settingsGroup(title: 'Navigation Preferences', isDark: isDark, child: _settingsCard(isDark: isDark, padding: const EdgeInsets.all(8), child: Column(
      children: [
        _voiceGuidanceRow(s.voicePromptsEnabled, isDark),
        const SizedBox(height: 4),
        _switchSetting(icon: Symbols.toll, title: 'Avoid Toll Roads', subtitle: 'Prefer toll-free expressways', value: s.avoidTolls, onChanged: _onAvoidTollsChanged, highlighted: false, isDark: isDark),
        const SizedBox(height: 4),
        _switchSetting(icon: Symbols.add_road, title: 'Avoid Highways', subtitle: 'Prioritize secondary scenic corridors', value: _avoidHighways, onChanged: (v) => setState(() => _avoidHighways = v), highlighted: false, isDark: isDark),
        const SizedBox(height: 4),
        _switchSetting(icon: Symbols.speed, title: 'Speed Limit Warnings', subtitle: 'Chime when exceeding limit', value: _speedLimitWarnings, onChanged: (v) => setState(() => _speedLimitWarnings = v), highlighted: true, isDark: isDark),
      ],
    )));
  }

  Widget _voiceGuidanceRow(bool value, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Column(children: [
        Row(children: [
          _smallIcon(icon: Symbols.record_voice_over, highlighted: true, isDark: isDark),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Voice Guidance', style: TextStyle(fontSize: 16, height: 1.35, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
            const SizedBox(height: 2),
            const Text('Turn-by-turn spoken directions', style: TextStyle(fontSize: 12, height: 1.3, fontWeight: FontWeight.w500, color: AppTheme.primaryGreen)),
          ])),
          const SizedBox(width: 8),
          _switchControl(value: value, onChanged: _onVoiceGuidanceChanged),
        ]),
        const SizedBox(height: 12),
        Padding(padding: const EdgeInsets.only(left: 44), child: Row(children: [
          const Expanded(child: Text('Accent & Language', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B)))),
          const SizedBox(width: 8),
          _languageSelector(value: _voiceLanguage, onTap: _showLanguagePicker),
        ])),
      ]),
    );
  }

  Widget _switchSetting({required IconData icon, required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged, required bool highlighted, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(children: [
        _smallIcon(icon: icon, highlighted: highlighted, isDark: isDark),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        ])),
        const SizedBox(width: 8),
        _switchControl(value: value, onChanged: onChanged),
      ]),
    );
  }

  // ── Account & Map Preferences ─────────────────────────────────────────

  Widget _buildAccountPreferences(bool isDark, SettingsModel s) {
    return _settingsGroup(title: 'Account & Map Preferences', isDark: isDark, child: _settingsCard(isDark: isDark, padding: const EdgeInsets.all(8), child: Column(
      children: [
        _distanceUnitsRow(s.speedUnit, isDark),
        const SizedBox(height: 4),
        _routeDiscoveryRow(s.autoRerouteScenic, isDark),
        const SizedBox(height: 4),
        _offlineMapsRow(s.offlineCacheEnabled, isDark),
      ],
    )));
  }

  Widget _distanceUnitsRow(SpeedUnit unit, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        _smallIcon(icon: Symbols.straighten, highlighted: false, isDark: isDark),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Distance Units', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
          const SizedBox(height: 2),
          const Text('System metric calibration', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        ])),
        const SizedBox(width: 8),
        _unitSelector(unit, onChanged: _onSpeedUnitChanged),
      ]),
    );
  }

  Widget _routeDiscoveryRow(bool value, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _smallIcon(icon: Symbols.explore_nearby, highlighted: true, isDark: isDark),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Flexible(child: Text('Enable Route Discovery', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)))),
            const SizedBox(width: 8),
            const _ProBadge(),
          ]),
          const SizedBox(height: 4),
          const Text('Automatically suggests historic & scenic places along your journey', style: TextStyle(fontSize: 12, height: 1.35, color: Color(0xFF64748B))),
        ])),
        const SizedBox(width: 8),
        _switchControl(value: value, onChanged: (v) => _ctrl.setAutoRerouteScenic(v)),
      ]),
    );
  }

  Widget _offlineMapsRow(bool enabled, bool isDark) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {},
      child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
        _smallIcon(icon: Symbols.cloud_download, highlighted: false, isDark: isDark),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Offline Maps', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Row(children: [
            _onlineDot(),
            const SizedBox(width: 6),
            Expanded(child: Text(enabled ? 'Dhaka Division (184 MB downloaded)' : 'Not downloaded', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: enabled ? AppTheme.primaryGreen : const Color(0xFF64748B)))),
          ]),
        ])),
        const SizedBox(width: 8),
        const Icon(Symbols.chevron_right, size: 20, color: Color(0xFF94A3B8)),
      ])),
    );
  }

  // ── About & System ────────────────────────────────────────────────────

  Widget _buildAboutSection(bool isDark, SettingsModel s) {
    return _settingsGroup(title: 'About & System', isDark: isDark, child: Column(
      children: [
        _settingsCard(isDark: isDark, padding: const EdgeInsets.all(8), child: Column(children: [
          _simpleActionRow(icon: Symbols.local_gas_station, title: 'Preferred Fuel Type', trailing: s.preferredFuelType, onTap: _showFuelPicker, isDark: isDark),
          _simpleActionRow(icon: Symbols.info, title: 'Version', trailing: '1.0.0', onTap: () {}, isDark: isDark),
        ])),
        const SizedBox(height: 12),
        Center(child: TextButton.icon(icon: const Icon(Symbols.restart_alt, size: 18), label: const Text('Restore Default Settings'), onPressed: _resetDefaults, style: TextButton.styleFrom(foregroundColor: AppTheme.primaryGreen))),
      ],
    ));
  }

  Widget _simpleActionRow({required IconData icon, required String title, required String trailing, required VoidCallback onTap, required bool isDark}) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
        _smallIcon(icon: icon, highlighted: false, isDark: isDark),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)))),
        Text(trailing, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? Colors.white70 : const Color(0xFF374151))),
        const SizedBox(width: 8),
        const Icon(Symbols.chevron_right, size: 20, color: Color(0xFF94A3B8)),
      ])),
    );
  }

  // ── Reusable Components ───────────────────────────────────────────────

  Widget _settingsCard({required Widget child, EdgeInsetsGeometry padding = const EdgeInsets.all(16), required bool isDark}) {
    return Container(
      width: double.infinity, padding: padding,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppTheme.darkBorder : const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.035), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }

  Widget _settingsGroup({required String title, required Widget child, required bool isDark}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(left: 8, bottom: 8), child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, height: 1.25, letterSpacing: 1.0, fontWeight: FontWeight.w600, color: Color(0xFF64748B)))),
      child,
    ]);
  }

  Widget _sectionIcon({required IconData icon, required bool highlighted, required bool isDark}) {
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: highlighted ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5)) : (isDark ? const Color(0xFF363436) : const Color(0xFFF1F5F9)),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: highlighted ? (isDark ? const Color(0xFF059669) : const Color(0xFFD1FAE5)) : (isDark ? AppTheme.darkBorder : const Color(0xFFE2E8F0))),
      ),
      child: Icon(icon, size: 20, color: highlighted ? (isDark ? AppTheme.accentNeon : const Color(0xFF025939)) : (isDark ? Colors.white54 : const Color(0xFF64748B))),
    );
  }

  Widget _smallIcon({required IconData icon, required bool highlighted, required bool isDark}) {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(shape: BoxShape.circle, color: highlighted ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5)) : (isDark ? const Color(0xFF363436) : const Color(0xFFF1F5F9))),
      child: Icon(icon, size: 18, color: highlighted ? (isDark ? AppTheme.accentNeon : const Color(0xFF025939)) : (isDark ? Colors.white70 : const Color(0xFF64748B))),
    );
  }

  Widget _switchControl({required bool value, required ValueChanged<bool> onChanged}) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180), curve: Curves.easeOut,
        width: 48, height: 28, padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? AppTheme.primaryGreen : const Color(0xFFCBD5E1),
          borderRadius: BorderRadius.circular(999),
          boxShadow: value ? [BoxShadow(color: AppTheme.primaryGreen.withValues(alpha: 0.12), blurRadius: 6)] : null,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180), curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(width: 24, height: 24, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 4, offset: const Offset(0, 1))])),
        ),
      ),
    );
  }

  Widget _languageSelector({required String value, required VoidCallback onTap}) {
    return Material(
      color: Colors.white, borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999), onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 190),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(value, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
            const SizedBox(width: 4),
            const Icon(Symbols.expand_more, size: 16, color: Color(0xFF64748B)),
          ]),
        ),
      ),
    );
  }

  Widget _unitSelector(SpeedUnit selected, {required ValueChanged<SpeedUnit> onChanged}) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(999), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _unitButton(text: 'km', selected: selected == SpeedUnit.kmh, onTap: () => onChanged(SpeedUnit.kmh)),
        _unitButton(text: 'mi', selected: selected == SpeedUnit.mph, onTap: () => onChanged(SpeedUnit.mph)),
      ]),
    );
  }

  Widget _unitButton({required String text, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4)] : null,
        ),
        child: Text(text, style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.w600 : FontWeight.w500, color: selected ? Colors.white : const Color(0xFF64748B))),
      ),
    );
  }

  Widget _proBadge() => const _ProBadge();
  Widget _onlineDot() => const _OnlineDot();
}

// ── Small reusable widgets ─────────────────────────────────────────────────────

class _ProBadge extends StatelessWidget {
  const _ProBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(999)),
      child: const Text('PRO', style: TextStyle(fontSize: 10, height: 1.2, letterSpacing: 0.8, fontWeight: FontWeight.w700, color: Color(0xFF025939))),
    );
  }
}

class _OnlineDot extends StatelessWidget {
  const _OnlineDot();
  @override
  Widget build(BuildContext context) {
    return Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.primaryGreen, shape: BoxShape.circle));
  }
}

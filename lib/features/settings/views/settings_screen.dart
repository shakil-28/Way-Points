import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/settings_controller.dart';
import '../models/settings_model.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsController? controller;

  const SettingsScreen({super.key, this.controller});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Single source of truth: injected controller or Provider.
  SettingsController get _ctrl =>
      widget.controller ?? context.read<SettingsController>();

  // ---------------------------------------------------------------------------
  // CALLBACKS — all go through the controller, never local setState
  // ---------------------------------------------------------------------------

  void _onThemeChanged(ThemePreference val) => _ctrl.setTheme(val);
  void _onVoiceGuidanceChanged(bool v) => _ctrl.setVoicePrompts(v);
  void _onAvoidTollsChanged(bool v) => _ctrl.setAvoidTolls(v);
  void _onAvoidHighwaysChanged(bool v) => _ctrl.setAvoidHighways(v);
  void _onSpeedLimitWarningsChanged(bool v) => _ctrl.setSpeedLimitWarnings(v);
  void _onSpeedUnitChanged(SpeedUnit unit) => _ctrl.setSpeedUnit(unit);
  void _onOfflineCacheChanged(bool v) => _ctrl.setOfflineCache(v);
  void _onPreferredFuelChanged(String fuel) => _ctrl.setPreferredFuel(fuel);
  void _onAutoRerouteScenicChanged(bool v) => _ctrl.setAutoRerouteScenic(v);
  void _resetDefaults() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Default Settings',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            'This will reset all preferences to their default values. Continue?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                _ctrl.resetDefaults();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings restored to defaults'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
              child: const Text('Restore')),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LANGUAGE PICKER — works with injected OR provider controller
  // ---------------------------------------------------------------------------

  void _showLanguagePicker(String currentLang) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        final isDark =
            Theme.of(sheetCtx).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Voice Language',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              ...['Bengali (BD - Farhana)', 'English (US)', 'Hindi (IN)']
                  .map((lang) => ListTile(
                        title: Text(
                          lang,
                          style: TextStyle(
                              color: isDark ? Colors.white70 : const Color(0xFF0F172A)),
                        ),
                        trailing: currentLang == lang
                            ? const Icon(Symbols.check,
                                color: AppTheme.primaryGreen)
                            : null,
                        onTap: () {
                          _ctrl.setVoiceLanguage(lang);
                          Navigator.pop(sheetCtx);
                        },
                      )
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // FUEL PICKER — uses the SAME controller instance, no extra Provider lookup
  // ---------------------------------------------------------------------------

  void _showFuelPicker(String currentFuel) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        final isDark =
            Theme.of(sheetCtx).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Preferred Fuel Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              ...['Octane', 'CNG', 'Diesel', 'Electric']
                  .map((fuel) => ListTile(
                        title: Text(
                          fuel,
                          style: TextStyle(
                              color: isDark ? Colors.white70 : const Color(0xFF0F172A)),
                        ),
                        trailing: currentFuel == fuel
                            ? const Icon(Symbols.check,
                                color: AppTheme.primaryGreen)
                            : null,
                        onTap: () {
                          _onPreferredFuelChanged(fuel);
                          Navigator.pop(sheetCtx);
                        },
                      )),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Listen to controller changes so the UI rebuilds automatically.
    final s = _ctrl.settings;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkCanvas : const Color(0xFFF8FAF9),
      extendBodyBehindAppBar: false,
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // ── Fixed header ──────────────────────────────────────────
            _buildContextHeader(isDark),
            // ── Scrollable settings content ───────────────────────────
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildAppearanceSection(isDark, s),
                        const SizedBox(height: 20),
                        _buildNavigationPreferences(isDark, s),
                        const SizedBox(height: 20),
                        _buildAccountPreferences(isDark, s),
                        const SizedBox(height: 20),
                        _buildAboutSection(isDark, s),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Fixed Header ────────────────────────────────────────────────────────────

  Widget _buildContextHeader(bool isDark) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          // Back button — left aligned
          Align(
            alignment: Alignment.centerLeft,
            child: _roundActionBtn(
              icon: Symbols.arrow_back,
              onTap: null,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              isDark: isDark,
            ),
          ),
          // Title — mathematically centered
          Center(
            child: Text(
              'Settings',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A)),
            ),
          ),
          // Reset button — right aligned
          Align(
            alignment: Alignment.centerRight,
            child: _roundActionBtn(
              icon: Symbols.restart_alt,
              onTap: _resetDefaults,
              color: isDark ? Colors.white70 : const Color(0xFF64748B),
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundActionBtn({
    required IconData icon,
    required VoidCallback? onTap,
    required Color color,
    required bool isDark,
  }) {
    final bgColor = isDark ? AppTheme.darkCard : Colors.white;
    final borderColor = isDark ? AppTheme.darkBorder : const Color(0xFFE2E8F0);
    if (onTap == null) {
      return SizedBox(
        width: 40,
        height: 40,
        child: Material(
          color: bgColor,
          shape: CircleBorder(side: BorderSide(color: borderColor)),
          elevation: 1,
          shadowColor: Colors.black.withValues(alpha: 0.06),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.of(context).maybePop(),
            child: SizedBox(width: 40, height: 40, child: Icon(icon, size: 20, color: color)),
          ),
        ),
      );
    }
    return Material(
      color: bgColor,
      shape: CircleBorder(side: BorderSide(color: borderColor)),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 40, height: 40, child: Icon(icon, size: 20, color: color)),
      ),
    );
  }

  // ── Appearance Section ──────────────────────────────────────────────────────

  Widget _buildAppearanceSection(bool isDark, SettingsModel s) {
    return _settingsGroup(
      title: 'Appearance',
      isDark: isDark,
      child: _settingsCard(
        isDark: isDark,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _sectionIcon(icon: Symbols.palette, highlighted: true, isDark: isDark),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Theme',
                      style: TextStyle(
                          fontSize: 16,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF0F172A))),
                  const SizedBox(height: 2),
                  Text('Switch between Lite Canvas and Dark Obsidian',
                      style: TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : const Color(0xFF64748B))),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _themeSelector(s.themePreference, isDark),
          ],
        ),
      ),
    );
  }

  Widget _themeSelector(ThemePreference pref, bool isDark) {
    final bool isLite = pref == ThemePreference.light ||
        (pref == ThemePreference.system &&
            Theme.of(context).brightness == Brightness.light);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segmentButton(
            icon: Symbols.light_mode,
            label: 'Lite',
            selected: isLite,
            onTap: () => _onThemeChanged(ThemePreference.light),
          ),
          _segmentButton(
            icon: Symbols.dark_mode,
            label: 'Dark',
            selected: !isLite,
            onTap: () => _onThemeChanged(ThemePreference.dark),
          ),
        ],
      ),
    );
  }

  Widget _segmentButton({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: selected ? Colors.white : const Color(0xFF64748B)),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? Colors.white : const Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  // ── Navigation Preferences ──────────────────────────────────────────────────

  Widget _buildNavigationPreferences(bool isDark, SettingsModel s) {
    return _settingsGroup(
      title: 'Navigation Preferences',
      isDark: isDark,
      child: _settingsCard(
        isDark: isDark,
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            _voiceGuidanceRow(s.voicePromptsEnabled, s.voiceLanguage, isDark),
            const SizedBox(height: 4),
            _switchSetting(
              icon: Symbols.toll,
              title: 'Avoid Toll Roads',
              subtitle: 'Prefer toll-free expressways',
              value: s.avoidTolls,
              onChanged: _onAvoidTollsChanged,
              highlighted: false,
              isDark: isDark,
            ),
            const SizedBox(height: 4),
            _switchSetting(
              icon: Symbols.add_road,
              title: 'Avoid Highways',
              subtitle: 'Prioritize secondary scenic corridors',
              value: s.avoidHighways,
              onChanged: _onAvoidHighwaysChanged,
              highlighted: false,
              isDark: isDark,
            ),
            const SizedBox(height: 4),
            _switchSetting(
              icon: Symbols.speed,
              title: 'Speed Limit Warnings',
              subtitle: 'Chime when exceeding limit',
              value: s.speedLimitWarnings,
              onChanged: _onSpeedLimitWarningsChanged,
              highlighted: true,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _voiceGuidanceRow(bool value, String currentLang, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1B1D) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? AppTheme.darkBorder : const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _smallIcon(
                  icon: Symbols.record_voice_over,
                  highlighted: true,
                  isDark: isDark),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Voice Guidance',
                        style: TextStyle(
                            fontSize: 15,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    Text(currentLang,
                        style: const TextStyle(
                            fontSize: 12,
                            height: 1.3,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primaryGreen)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _switchControl(value: value, onChanged: _onVoiceGuidanceChanged),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: Row(
              children: [
                Expanded(
                  child: Text('Accent & Language',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : const Color(0xFF64748B))),
                ),
                const SizedBox(width: 8),
                _languageSelector(value: currentLang, onTap: () => _showLanguagePicker(currentLang)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _switchSetting({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool highlighted,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          _smallIcon(icon: icon, highlighted: highlighted, isDark: isDark),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : const Color(0xFF64748B))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _switchControl(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  // ── Account & Map Preferences ───────────────────────────────────────────────

  Widget _buildAccountPreferences(bool isDark, SettingsModel s) {
    return _settingsGroup(
      title: 'Account & Map Preferences',
      isDark: isDark,
      child: _settingsCard(
        isDark: isDark,
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            _distanceUnitsRow(s.speedUnit, isDark),
            const SizedBox(height: 4),
            _routeDiscoveryRow(s.autoRerouteScenic, isDark),
            const SizedBox(height: 4),
            _offlineMapsRow(s.offlineCacheEnabled, isDark),
          ],
        ),
      ),
    );
  }

  Widget _distanceUnitsRow(SpeedUnit unit, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _smallIcon(icon: Symbols.straighten, highlighted: false, isDark: isDark),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Speed Units',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text('Display speed in km/h or mph',
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : const Color(0xFF64748B))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _unitSelector(unit, onChanged: _onSpeedUnitChanged),
        ],
      ),
    );
  }

  Widget _routeDiscoveryRow(bool value, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1B1D) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? AppTheme.darkBorder : const Color(0xFFF1F5F9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _smallIcon(icon: Symbols.explore_nearby, highlighted: true, isDark: isDark),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                        child: Text('Enable Route Discovery',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF0F172A)))),
                    const SizedBox(width: 8),
                    const _ProBadge(),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                    'Automatically suggests historic & scenic places along your journey',
                    style:
                        TextStyle(fontSize: 12, height: 1.35, color: isDark ? Colors.white70 : const Color(0xFF64748B))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _switchControl(value: value, onChanged: _onAutoRerouteScenicChanged),
        ],
      ),
    );
  }

  Widget _offlineMapsRow(bool enabled, bool isDark) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _onOfflineCacheChanged(!enabled),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _smallIcon(icon: Symbols.cloud_download, highlighted: false, isDark: isDark),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Offline Maps',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : const Color(0xFF0F172A))),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _onlineDot(isDark: isDark),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                            enabled ? 'Cache enabled' : 'Cache disabled',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: enabled
                                    ? AppTheme.primaryGreen
                                    : const Color(0xFF64748B))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Symbols.chevron_right, size: 20, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  // ── About & System ──────────────────────────────────────────────────────────

  Widget _buildAboutSection(bool isDark, SettingsModel s) {
    return _settingsGroup(
      title: 'About & System',
      isDark: isDark,
      child: Column(
        children: [
          _settingsCard(
            isDark: isDark,
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                _simpleActionRow(
                  icon: Symbols.local_gas_station,
                  title: 'Preferred Fuel Type',
                  trailing: s.preferredFuelType,
                  onTap: () => _showFuelPicker(s.preferredFuelType),
                  isDark: isDark,
                ),
                _simpleActionRow(
                  icon: Symbols.info,
                  title: 'Version',
                  trailing: '1.0.0',
                  onTap: () {},
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              icon: const Icon(Symbols.restart_alt, size: 18),
              label: const Text('Restore Default Settings'),
              onPressed: _resetDefaults,
              style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _simpleActionRow({
    required IconData icon,
    required String title,
    required String trailing,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _smallIcon(icon: icon, highlighted: false, isDark: isDark),
            const SizedBox(width: 12),
            Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF0F172A)))),
            Text(trailing,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : const Color(0xFF374151))),
            const SizedBox(width: 8),
            const Icon(Symbols.chevron_right,
                size: 20, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  // ── Reusable Components ─────────────────────────────────────────────────────

  Widget _settingsCard(
      {required Widget child,
      EdgeInsetsGeometry padding = const EdgeInsets.all(16),
      required bool isDark}) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? AppTheme.darkBorder : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.035),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }

  Widget _settingsGroup(
      {required String title, required Widget child, required bool isDark}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(title.toUpperCase(),
              style: TextStyle(
                  fontSize: 11,
                  height: 1.25,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : const Color(0xFF64748B))),
        ),
        child,
      ],
    );
  }

  Widget _sectionIcon(
      {required IconData icon,
      required bool highlighted,
      required bool isDark}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: highlighted
            ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5))
            : (isDark ? const Color(0xFF363436) : const Color(0xFFF1F5F9)),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: highlighted
                ? (isDark ? const Color(0xFF059669) : const Color(0xFFD1FAE5))
                : (isDark ? AppTheme.darkBorder : const Color(0xFFE2E8F0))),
      ),
      child: Icon(icon,
          size: 20,
          color: highlighted
              ? (isDark ? AppTheme.accentNeon : const Color(0xFF025939))
              : (isDark ? Colors.white54 : const Color(0xFF64748B))),
    );
  }

  Widget _smallIcon(
      {required IconData icon,
      required bool highlighted,
      required bool isDark}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: highlighted
            ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5))
            : (isDark ? const Color(0xFF363436) : const Color(0xFFF1F5F9)),
      ),
      child: Icon(icon,
          size: 16,
          color: highlighted
              ? (isDark ? AppTheme.accentNeon : const Color(0xFF025939))
              : (isDark ? Colors.white70 : const Color(0xFF64748B))),
    );
  }

  // Accessible toggle switch
  Widget _switchControl(
      {required bool value, required ValueChanged<bool> onChanged}) {
    return Semantics(
      label: value ? 'Enabled' : 'Disabled',
      checked: value,
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: 48,
          height: 28,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: value ? AppTheme.primaryGreen : const Color(0xFFCBD5E1),
            borderRadius: BorderRadius.circular(999),
            boxShadow: value
                ? [
                    BoxShadow(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                        blurRadius: 6)
                  ]
                : null,
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 4,
                      offset: const Offset(0, 1))
                ],
              ),
            ),
          ),
        ),
      );
  }

  Widget _languageSelector(
      {required String value, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? AppTheme.darkCard : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 180),
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(value,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF0F172A))),
              ),
              const SizedBox(width: 4),
              Icon(Symbols.expand_more,
                  size: 16, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _unitSelector(SpeedUnit selected,
      {required ValueChanged<SpeedUnit> onChanged}) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _unitButton(
              text: 'km/h',
              selected: selected == SpeedUnit.kmh,
              onTap: () => onChanged(SpeedUnit.kmh)),
          _unitButton(
              text: 'mi/h',
              selected: selected == SpeedUnit.mph,
              onTap: () => onChanged(SpeedUnit.mph)),
        ],
      ),
    );
  }

  Widget _unitButton(
      {required String text,
      required bool selected,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4)
                ]
              : null,
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? Colors.white : const Color(0xFF64748B))),
      ),
    );
  }

  Widget _proBadge() => const _ProBadge();
  Widget _onlineDot({required bool isDark}) => _OnlineDot(isDark: isDark);
}

// ── Small reusable widgets ───────────────────────────────────────────────────

class _ProBadge extends StatelessWidget {
  const _ProBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration:
          const BoxDecoration(color: Color(0xFFD1FAE5), borderRadius: BorderRadius.all(Radius.circular(999))),
      child: const Text('PRO',
          style: TextStyle(
              fontSize: 9,
              height: 1.2,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
              color: Color(0xFF025939))),
    );
  }
}

class _OnlineDot extends StatelessWidget {
  final bool isDark;
  const _OnlineDot({required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
          color: AppTheme.primaryGreen, shape: BoxShape.circle),
    );
  }
}

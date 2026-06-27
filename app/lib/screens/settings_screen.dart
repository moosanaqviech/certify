import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state.dart';
import '../widgets/app_background.dart';
import '../widgets/toggle_switch.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                child: Row(
                  children: [
                    _BackButton(onTap: () => Navigator.of(context).pop()),
                    const SizedBox(width: 12),
                    Text('Settings', style: AppTheme.display(size: 22)),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(22, 10, 22, 30),
                  children: [
                    // Reading section
                    Text('READING', style: AppTheme.label()),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161822),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.hairline),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(bottom: 13),
                                  decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06))),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Text size', style: AppTheme.body(size: 15.5, weight: FontWeight.w600)),
                                      const SizedBox(height: 13),
                                      Row(
                                        children: [
                                          _FontButton(label: 'A', size: 14, selected: state.fontIdx == 0, onTap: () => state.setFontIdx(0)),
                                          const SizedBox(width: 9),
                                          _FontButton(label: 'A', size: 17, selected: state.fontIdx == 1, onTap: () => state.setFontIdx(1)),
                                          const SizedBox(width: 9),
                                          _FontButton(label: 'A', size: 21, selected: state.fontIdx == 2, onTap: () => state.setFontIdx(2)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 17),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Reduce motion', style: AppTheme.body(size: 15.5, weight: FontWeight.w600)),
                                      const SizedBox(height: 2),
                                      Text('Calmer transitions and fades.', style: AppTheme.body(size: 13, color: AppTheme.inkSoft, height: 1.4)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 14),
                                CertifyToggle(value: state.reduceMotion, onTap: () => state.toggleReduceMotion()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // App section
                    Text('APP', style: AppTheme.label()),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161822),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.hairline),
                      ),
                      child: Column(
                        children: [
                          _NavRow(
                            label: 'Notifications',
                            onTap: () => Navigator.of(context).pushNamed('/notifications'),
                            hasDivider: true,
                          ),
                          _NavRow(
                            label: 'Downloads',
                            trailing: Text('42 MB', style: AppTheme.mono(size: 12, color: AppTheme.inkFaint)),
                            onTap: () => Navigator.of(context).pushNamed('/downloads'),
                            hasDivider: false,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // About section
                    Text('ABOUT', style: AppTheme.label()),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161822),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.hairline),
                      ),
                      child: Column(
                        children: [
                          _NavRow(label: 'About Certify', onTap: () {}, hasDivider: true),
                          _NavRow(
                            label: 'Version',
                            trailing: Text('1.0.0 (12)', style: AppTheme.mono(size: 13, color: AppTheme.inkFaint)),
                            onTap: null,
                            hasDivider: false,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Legal section
                    Text('LEGAL', style: AppTheme.label()),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161822),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.hairline),
                      ),
                      child: Column(
                        children: [
                          _NavRow(label: 'Privacy policy', onTap: () {}, hasDivider: true),
                          _NavRow(label: 'Terms of service', onTap: () {}, hasDivider: false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FontButton extends StatelessWidget {
  final String label;
  final double size;
  final bool selected;
  final VoidCallback onTap;

  const _FontButton({required this.label, required this.size, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: context.read<AppState>().motion(const Duration(milliseconds: 200)),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? AppTheme.ink : const Color(0xFF1E2130),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppTheme.ink : AppTheme.hairline,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTheme.body(
                size: size,
                weight: FontWeight.w700,
                color: selected ? AppTheme.bg : AppTheme.inkSoft,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool hasDivider;

  const _NavRow({required this.label, this.trailing, required this.onTap, required this.hasDivider});

  @override
  Widget build(BuildContext context) {
    final row = Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: hasDivider
          ? BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06))))
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.body(size: 15, weight: FontWeight.w500)),
          trailing ?? const Icon(Icons.chevron_right, size: 17, color: AppTheme.inkFaint),
        ],
      ),
    );

    if (onTap == null) return row;
    return GestureDetector(onTap: onTap, child: row);
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFF161822),
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.hairline),
        ),
        child: const Center(
          child: Text('←', style: TextStyle(color: AppTheme.ink, fontSize: 19, height: 1)),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state.dart';
import '../widgets/app_background.dart';
import '../widgets/toggle_switch.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final h = state.remindAt.hour;
    final m = state.remindAt.minute.toString().padLeft(2, '0');
    final ampm = h >= 12 ? 'PM' : 'AM';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    final timeStr = '$h12:$m $ampm';

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
                    Text('Notifications', style: AppTheme.display(size: 22)),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
                  children: [
                    Text(
                      "Quiet by default. Turn on only what you'll find useful.",
                      style: AppTheme.body(size: 14.5, color: AppTheme.inkSoft, height: 1.5),
                    ),
                    const SizedBox(height: 20),

                    // Toggles card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161822),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.hairline),
                      ),
                      child: Column(
                        children: [
                          _ToggleRow(
                            title: 'Study reminders',
                            subtitle: 'A daily nudge at the time you choose.',
                            value: state.notifStreak,
                            onTap: () => state.toggleNotif('streak'),
                            hasDivider: true,
                          ),
                          _ToggleRow(
                            title: 'New certification alerts',
                            subtitle: 'Hear when a new cert joins the catalog.',
                            value: state.notifNew,
                            onTap: () => state.toggleNotif('new'),
                            hasDivider: true,
                          ),
                          _ToggleRow(
                            title: 'Exam reminders',
                            subtitle: 'A heads-up as a scheduled exam nears.',
                            value: state.notifExam,
                            onTap: () => state.toggleNotif('exam'),
                            hasDivider: false,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    Text('TIMING', style: AppTheme.label()),
                    const SizedBox(height: 8),

                    GestureDetector(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: state.remindAt,
                          builder: (ctx, child) => Theme(
                            data: Theme.of(ctx).copyWith(
                              colorScheme: const ColorScheme.dark(primary: AppTheme.accent, surface: Color(0xFF1E2130)),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) state.setRemindAt(picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(17),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161822),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.hairline),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Remind me at', style: AppTheme.body(size: 15.5, weight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text('Your daily study reminder', style: AppTheme.body(size: 13, color: AppTheme.inkSoft)),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E2130),
                                    borderRadius: BorderRadius.circular(9),
                                    border: Border.all(color: AppTheme.hairline),
                                  ),
                                  child: Text(timeStr, style: AppTheme.mono(size: 14, color: AppTheme.ink)),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right, size: 16, color: AppTheme.inkFaint),
                              ],
                            ),
                          ],
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
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final VoidCallback onTap;
  final bool hasDivider;

  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onTap,
    required this.hasDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 17),
      decoration: hasDivider
          ? BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06))))
          : null,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.body(size: 15.5, weight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTheme.body(size: 13, color: AppTheme.inkSoft, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          CertifyToggle(value: value, onTap: onTap),
        ],
      ),
    );
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state.dart';
import '../widgets/app_background.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

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
                    Text('Downloads', style: AppTheme.display(size: 22)),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
                  children: [
                    Text(
                      state.currentCert == null
                          ? 'Keep units on your device to study offline.'
                          : 'Keep units on your device to study offline. ${state.currentCert!.vendor} · ${state.currentCert!.track}.',
                      style: AppTheme.body(size: 14.5, color: AppTheme.inkSoft, height: 1.5),
                    ),
                    const SizedBox(height: 18),

                    // Storage card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161822),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.hairline),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text('Storage used', style: AppTheme.body(size: 13.5, color: AppTheme.inkSoft)),
                              Text(
                                '${state.usedMb} MB of ${state.totalMb} MB',
                                style: AppTheme.mono(size: 12.5, color: AppTheme.ink),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: SizedBox(
                              height: 7,
                              child: Stack(children: [
                                Container(color: Colors.white.withOpacity(0.08)),
                                LayoutBuilder(
                                  builder: (_, c) => AnimatedContainer(
                                    duration: state.motion(const Duration(milliseconds: 300)),
                                    width: c.maxWidth * (state.totalMb > 0 ? state.usedMb / state.totalMb : 0.0),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accent,
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),
                    Text('UNITS', style: AppTheme.label()),
                    const SizedBox(height: 6),

                    ...state.downloads.map((dl) => _DownloadRow(
                          item: dl,
                          onTap: () => state.toggleDownload(dl.id),
                        )),
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

class _DownloadRow extends StatelessWidget {
  final DownloadItem item;
  final VoidCallback onTap;

  const _DownloadRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final motion = context.read<AppState>().motion;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2130),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: AppTheme.hairline),
            ),
            child: const Center(child: _DocIcon()),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: AppTheme.body(size: 14.5, weight: FontWeight.w600, height: 1.25)),
                if (item.state == DownloadState.downloading) ...[
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: SizedBox(
                            height: 5,
                            child: Stack(children: [
                              Container(color: Colors.white.withOpacity(0.08)),
                              LayoutBuilder(
                                builder: (_, c) => AnimatedContainer(
                                  duration: motion(const Duration(milliseconds: 200)),
                                  width: c.maxWidth * item.progress,
                                  decoration: BoxDecoration(
                                    color: AppTheme.accent,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                            ]),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(item.pct, style: AppTheme.mono(size: 11, color: AppTheme.accent)),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 3),
                  Text(
                    '${item.sizeMb} MB · ${item.statusText}',
                    style: AppTheme.mono(size: 11.5, color: AppTheme.inkFaint),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF1E2130),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.hairline),
              ),
              child: Center(child: _RowIcon(state: item.state)),
            ),
          ),
        ],
      ),
    );
  }
}

class _RowIcon extends StatelessWidget {
  final DownloadState state;
  const _RowIcon({required this.state});

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case DownloadState.done:
        return const Icon(Icons.delete_outline, size: 17, color: AppTheme.inkFaint);
      case DownloadState.downloading:
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: AppTheme.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      case DownloadState.idle:
        return const Icon(Icons.download_outlined, size: 18, color: AppTheme.accent);
    }
  }
}

class _DocIcon extends StatelessWidget {
  const _DocIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.description_outlined, size: 17, color: AppTheme.accent);
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

import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/app_background.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Nav bar
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Certify', style: AppTheme.display(size: 20)),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed('/settings'),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF161822),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.hairline),
                        ),
                        child: const Center(child: _GearIcon()),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
                  children: [
                    Text(
                      'WEDNESDAY · JUNE 20',
                      style: AppTheme.label(size: 11.5, color: AppTheme.inkFaint),
                    ),
                    const SizedBox(height: 6),
                    Text('Your catalog', style: AppTheme.display(size: 30)),
                    const SizedBox(height: 16),

                    // Card: in progress
                    _InProgressCard(
                      onTap: () => Navigator.of(context).pushNamed('/lesson'),
                    ),
                    const SizedBox(height: 16),

                    // Card: new
                    const _NewCertCard(),
                    const SizedBox(height: 16),

                    // Card: locked
                    const _LockedCard(),
                    const SizedBox(height: 12),

                    Center(
                      child: Text(
                        'More certifications are on the way.',
                        style: AppTheme.body(size: 13, color: AppTheme.inkFaint),
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

class _InProgressCard extends StatelessWidget {
  final VoidCallback onTap;
  const _InProgressCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF161822),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.hairline),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: RadialGradient(
                    center: const Alignment(-1.0, -1.0),
                    radius: 1.2,
                    colors: [AppTheme.databricksAccent.withOpacity(0.18), Colors.transparent],
                    stops: const [0, 0.7],
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.databricksAccent.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.databricksAccent.withOpacity(0.35)),
                      ),
                      child: Center(child: Text('D', style: AppTheme.display(size: 24, color: AppTheme.databricksInk))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Databricks', style: AppTheme.display(size: 21)),
                          const SizedBox(height: 2),
                          Text('Data Engineer Associate', style: AppTheme.body(size: 13.5, color: AppTheme.inkSoft)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.databricksAccent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: AppTheme.databricksAccent.withOpacity(0.28)),
                      ),
                      child: Text(
                        'IN PROGRESS',
                        style: AppTheme.body(size: 10.5, weight: FontWeight.w600, color: AppTheme.databricksInk, letterSpacing: 0.06 * 10.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 6,
                    child: Stack(children: [
                      Container(color: Colors.white.withOpacity(0.08)),
                      FractionallySizedBox(
                        widthFactor: 0.42,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.databricksAccent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 9),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('11 of 26 lessons · 42%', style: AppTheme.body(size: 12, color: AppTheme.inkFaint, letterSpacing: 0.03 * 12)),
                    Row(
                      children: [
                        Text('Continue', style: AppTheme.body(size: 13.5, weight: FontWeight.w600)),
                        const SizedBox(width: 5),
                        const Icon(Icons.chevron_right, size: 15, color: AppTheme.ink),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NewCertCard extends StatelessWidget {
  const _NewCertCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161822),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.snowflakeAccent.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.snowflakeAccent.withOpacity(0.35)),
                ),
                child: Center(child: Text('S', style: AppTheme.display(size: 24, color: AppTheme.snowflakeInk))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Snowflake', style: AppTheme.display(size: 21)),
                    const SizedBox(height: 2),
                    Text('SnowPro Core', style: AppTheme.body(size: 13.5, color: AppTheme.inkSoft)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.snowflakeAccent,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text('New', style: AppTheme.body(size: 10.5, weight: FontWeight.w700, color: AppTheme.bg)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 6,
              child: Container(color: Colors.white.withOpacity(0.08)),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0 of 22 lessons · not started', style: AppTheme.body(size: 12, color: AppTheme.inkFaint)),
              Row(
                children: [
                  Text('Start', style: AppTheme.body(size: 13.5, weight: FontWeight.w600)),
                  const SizedBox(width: 5),
                  const Icon(Icons.chevron_right, size: 15, color: AppTheme.ink),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LockedCard extends StatelessWidget {
  const _LockedCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF13141F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: 0.62,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.hairline),
                  ),
                  child: Center(child: Text('d', style: AppTheme.display(size: 24, color: AppTheme.inkFaint))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('dbt', style: AppTheme.display(size: 21, color: AppTheme.inkSoft)),
                      const SizedBox(height: 2),
                      Text('Analytics Engineer', style: AppTheme.body(size: 13.5, color: AppTheme.inkFaint)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppTheme.hairline),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline, size: 11, color: AppTheme.inkFaint),
                      const SizedBox(width: 4),
                      Text('LOCKED', style: AppTheme.body(size: 10.5, weight: FontWeight.w600, color: AppTheme.inkFaint, letterSpacing: 0.06 * 10.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.only(top: 13),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('22 lessons · available later', style: AppTheme.body(size: 12.5, color: AppTheme.inkFaint)),
                Text('Certify Pro', style: AppTheme.body(size: 13, weight: FontWeight.w600, color: AppTheme.dbtInk)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GearIcon extends StatelessWidget {
  const _GearIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.settings_outlined, size: 20, color: AppTheme.inkSoft);
  }
}

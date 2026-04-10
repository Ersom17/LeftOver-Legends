// lib/screens/learn_screen.dart

import 'package:flutter/material.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F1C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F1C),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF8A9E90)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Learn',
          style: TextStyle(
            color: Color(0xFFF5EFE0),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          // ── CONTENT GOES HERE ──────────────────────────────────────────
          // Paste your sections below using the helpers at the bottom of
          // this file. Example structure:
          //
          // _LearnHero(
          //   emoji: '🌍',
          //   title: 'Why Food Waste Matters',
          //   subtitle: 'Every year, 1/3 of all food produced is lost or wasted.',
          // ),
          // SizedBox(height: 24),
          // _LearnSection(
          //   label: 'The Problem',
          //   title: 'A global crisis on our plates',
          //   body: 'Your paragraph text here...',
          //   emoji: '📊',
          // ),
          // SizedBox(height: 16),
          // _StatRow(stats: [
          //   _Stat(value: '1.3B', label: 'tonnes wasted yearly'),
          //   _Stat(value: '8%', label: 'of global emissions'),
          //   _Stat(value: 'CHF 600', label: 'lost per Swiss household'),
          // ]),
          // SizedBox(height: 24),
          // _LearnSection(
          //   label: 'Tips',
          //   title: 'What you can do',
          //   body: 'Your paragraph text here...',
          //   emoji: '💡',
          // ),
          // _TipList(tips: [
          //   'Plan your meals before shopping.',
          //   'Store food correctly to extend shelf life.',
          //   'Use the FIFO method — first in, first out.',
          // ]),
          // ──────────────────────────────────────────────────────────────

          _PlaceholderBanner(),
        ],
      ),
    );
  }
}

// ─── Placeholder shown until real content is added ───────────────────────────

class _PlaceholderBanner extends StatelessWidget {
  const _PlaceholderBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 40),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF232B25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E3830)),
      ),
      child: const Column(
        children: [
          Text('📖', style: TextStyle(fontSize: 48)),
          SizedBox(height: 16),
          Text(
            'Content coming soon',
            style: TextStyle(
              color: Color(0xFFF5EFE0),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Stay Tuned!!!',
            style: TextStyle(color: Color(0xFF8A9E90), fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Reusable content widgets ─────────────────────────────────────────────────

/// Full-width hero block at the top of the page
class _LearnHero extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const _LearnHero({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A4A35), Color(0xFF1A3028)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3D7A56).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFF5EFE0),
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF8A9E90),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Labelled section with a title, body text and an emoji accent
class _LearnSection extends StatelessWidget {
  final String label;
  final String title;
  final String body;
  final String emoji;

  const _LearnSection({
    required this.label,
    required this.title,
    required this.body,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF232B25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E3830)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF5C9E6E),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              Text(emoji, style: const TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFF5EFE0),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: Color(0xFF8A9E90),
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// A row of 2–3 highlighted stats
class _StatRow extends StatelessWidget {
  final List<_Stat> stats;

  const _StatRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: stats
          .map(
            (s) => Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: s == stats.last ? 0 : 8,
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2D24),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF3D7A56).withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      s.value,
                      style: const TextStyle(
                        color: Color(0xFF5C9E6E),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.label,
                      style: const TextStyle(
                        color: Color(0xFF8A9E90),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _Stat {
  final String value;
  final String label;

  const _Stat({required this.value, required this.label});
}

/// A bulleted list of tips
class _TipList extends StatelessWidget {
  final List<String> tips;

  const _TipList({required this.tips});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: tips
          .map(
            (tip) => Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.eco,
                        color: Color(0xFF5C9E6E), size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(
                        color: Color(0xFFF5EFE0),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

/// A highlighted callout / quote block
class _Callout extends StatelessWidget {
  final String text;
  final String? source;

  const _Callout({required this.text, this.source});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF5C9E6E).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: const Color(0xFF5C9E6E),
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFFF5EFE0),
              fontSize: 14,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
          if (source != null) ...[
            const SizedBox(height: 6),
            Text(
              '— $source',
              style: const TextStyle(
                color: Color(0xFF5C9E6E),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

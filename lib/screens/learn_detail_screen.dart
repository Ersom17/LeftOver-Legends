// lib/screens/learn_detail_screen.dart
//
// Reads a [LearnTopic] and renders its list of [LearnBlock]s. Supports
// headings, paragraphs, bullet lists, callouts, and two-column comparison
// tables — enough to cover every topic in learn_content.dart.

import 'package:flutter/material.dart';
import '../i18n/learn_content.dart';
import '../theme/app_theme.dart';

class LearnDetailScreen extends StatelessWidget {
  final LearnTopic topic;

  const LearnDetailScreen({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBeige,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          topic.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(topic.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    topic.title,
                    style: const TextStyle(
                      color: AppColors.darkGreen,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              topic.blurb,
              style: const TextStyle(
                color: AppColors.softGrayText,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ...topic.blocks.map(_renderBlock),
          ],
        ),
      ),
    );
  }

  Widget _renderBlock(LearnBlock block) {
    return switch (block) {
      LearnHeading() => Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 10),
          child: Text(
            block.text.toUpperCase(),
            style: const TextStyle(
              color: AppColors.mutedOlive,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
        ),
      LearnParagraph() => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            block.text,
            style: const TextStyle(
              color: AppColors.darkGreen,
              fontSize: 14,
              height: 1.55,
            ),
          ),
        ),
      LearnBullets() => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: block.items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Icon(Icons.circle,
                              size: 6, color: AppColors.mutedOlive),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(
                              color: AppColors.darkGreen,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      LearnCallout() => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warmGold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.warmGold.withOpacity(0.35),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(block.emoji,
                    style: const TextStyle(fontSize: 20, height: 1.2)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    block.text,
                    style: const TextStyle(
                      color: AppColors.darkGreen,
                      fontSize: 13.5,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      LearnTable() => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.darkGreen.withOpacity(0.12)),
            ),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(1),
              },
              children: [
                if (block.leftHeader != null && block.rightHeader != null)
                  TableRow(
                    decoration: BoxDecoration(
                      color: AppColors.darkGreen.withOpacity(0.08),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    children: [
                      _cell(block.leftHeader!, header: true),
                      _cell(block.rightHeader!, header: true),
                    ],
                  ),
                ...block.rows.map(
                  (row) => TableRow(
                    children: [
                      _cell(row.$1),
                      _cell(row.$2),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    };
  }

  Widget _cell(String text, {bool header = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.darkGreen,
          fontSize: 12.5,
          height: 1.4,
          fontWeight: header ? FontWeight.w900 : FontWeight.w500,
        ),
      ),
    );
  }
}

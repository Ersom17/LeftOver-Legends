// lib/screens/learn_screen.dart
//
// Entry point for the Learn section. Shows a region banner and a list of
// topic cards; each card pushes [LearnDetailScreen] with the selected topic.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../i18n/learn_content.dart';
import '../providers/locale_provider.dart';
import '../providers/region_provider.dart';
import '../theme/app_theme.dart';
import 'learn_detail_screen.dart';

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final region = ref.watch(regionProvider);
    final strings = ref.watch(appStringsProvider);
    final lang = ref.watch(localeProvider);
    final topics = LearnContent.forLanguageAndRegion(lang, region);
    final regionLabel = region == AppRegion.us
        ? strings.learnRegionUS
        : strings.learnRegionEU;

    return Scaffold(
      backgroundColor: AppColors.lightBeige,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(strings.learnTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.warmGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.warmGold.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.public,
                    color: AppColors.warmGold, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${strings.learnRegionPrefix}$regionLabel',
                  style: const TextStyle(
                    color: AppColors.warmGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            strings.learnIntro,
            style: const TextStyle(
              color: AppColors.softGrayText,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ...topics.map(
            (topic) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TopicCard(
                topic: topic,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LearnDetailScreen(topic: topic),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final LearnTopic topic;
  final VoidCallback onTap;

  const _TopicCard({required this.topic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: AppColors.darkGreen.withOpacity(0.12), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.darkGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(topic.emoji,
                      style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.title,
                      style: const TextStyle(
                        color: AppColors.darkGreen,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      topic.blurb,
                      style: const TextStyle(
                        color: AppColors.softGrayText,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: AppColors.softGrayText, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

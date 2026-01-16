import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lifebox/l10n/app_localizations.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/risk_badge.dart'; // RiskBadge + RiskLevel
import '../../../app/theme/colors.dart';

import '../state/local_inbox_providers.dart';
import '../domain/local_inbox_record.dart';

class InboxDetailPage extends ConsumerWidget {
  final String id;
  const InboxDetailPage({super.key, required this.id});

  RiskLevel _mapRisk(String v) {
    switch (v) {
      case 'high':
        return RiskLevel.high;
      case 'mid':
        return RiskLevel.mid;
      case 'low':
      default:
        return RiskLevel.low;
    }
  }

  DateTime? _parseDueAt(String? v) {
    if (v == null) return null;
    final s = v.trim();
    if (s.isEmpty) return null;
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncList = ref.watch(localInboxListProvider);

    return AppScaffold(
      title: l10n.inboxDetailTitle,
      body: asyncList.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
        data: (list) {
          final LocalInboxRecord? r = list.cast<LocalInboxRecord?>().firstWhere(
                (e) => e?.id == id,
                orElse: () => null,
              );

          if (r == null) {
            return EmptyState(
              title: l10n.inboxEmptyTitle,
              subtitle: '未找到该记录（id=$id）',
            );
          }

          final due = _parseDueAt(r.dueAt);
          final dueText = due == null ? l10n.noDueDate : DateFormat('yyyy/MM/dd').format(due);

          final riskLevel = _mapRisk(r.risk);
          final amountText = r.amount == null
              ? '-'
              : (r.currency == null ? '${r.amount}' : '${r.amount} ${r.currency}');

          final sourceText = (r.sourceHint == null || r.sourceHint!.trim().isEmpty)
              ? '-'
              : r.sourceHint!.trim();

          final localeText = (r.locale == null || r.locale!.trim().isEmpty) ? '-' : r.locale!.trim();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ====== 基本信息 ======
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              r.title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          const SizedBox(width: 10),
                          RiskBadge(risk: riskLevel),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.inboxDetailSource(sourceText),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.subtext),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'locale: $localeText',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.subtext),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ====== 结构化字段 ======
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.inboxDetailStructuredFields,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      _kvRow('期限', dueText),
                      const SizedBox(height: 6),
                      _kvRow('金额', amountText),
                      const SizedBox(height: 6),
                      _kvRow('状态', r.status),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => context.push('/action?type=calendar&id=$id'),
                        child: Text(l10n.inboxDetailPrimaryActionAddCalendar),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('TODO：标记为已完成（后续接本地DB更新）')),
                          );
                        },
                        child: Text(l10n.inboxDetailMarkDoneTodo),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ====== 摘要 / 内容 ======
              if (r.summary.trim().isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '摘要',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          r.summary,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // ====== 证据（OCR/语音原文） ======
              ExpansionTile(
                title: Text(l10n.inboxDetailEvidenceTitle),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  SelectableText(
                    r.rawText.trim().isEmpty ? l10n.inboxDetailOcrPlaceholder : r.rawText,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(height: 1.35),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _kvRow extends StatelessWidget {
  const _kvRow(this.k, this.v);

  final String k;
  final String v;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(
            k,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.subtext),
          ),
        ),
        Expanded(
          child: Text(
            v,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/primary_button.dart';
import '../state/import_controller.dart';

class ImportPage extends ConsumerWidget {
  const ImportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: '导入截图',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            PrimaryButton(
              label: '从截图相册选择（模拟）',
              onPressed: () => _start(context, ref, ['screenshot_001.png', 'screenshot_002.png']),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: '从相册选择（可多选，模拟）',
              onPressed: () => _start(context, ref, ['photo_101.jpg', 'photo_102.jpg', 'photo_103.jpg']),
            ),
            const SizedBox(height: 12),
            const Text('默认只分析你选择的图片（MVP：不做全量相册扫描）'),
          ],
        ),
      ),
    );
  }

  void _start(BuildContext context, WidgetRef ref, List<String> files) async {
    // 打开队列 BottomSheet（强建议：不阻塞 UI）
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _ImportQueueSheet(),
    );

    // 模拟处理
    await ref.read(importControllerProvider.notifier).simulateImport(files);
  }
}

class _ImportQueueSheet extends ConsumerWidget {
  const _ImportQueueSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(importControllerProvider);

    String label(ImportJobStatus s) => switch (s) {
          ImportJobStatus.queued => '排队中',
          ImportJobStatus.ocr => 'OCR 中',
          ImportJobStatus.uploading => '上传中',
          ImportJobStatus.parsing => '解析中',
          ImportJobStatus.done => '完成',
          ImportJobStatus.failed => '失败',
        };

    final doneCount = jobs.where((e) => e.status == ImportJobStatus.done).length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('处理中', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Text('$doneCount / ${jobs.length}'),
              ],
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: jobs.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final j = jobs[i];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.image_outlined),
                    title: Text(j.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Text(label(j.status)),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('后台继续'),
              ),
            ),
            if (jobs.isNotEmpty && doneCount == jobs.length) ...[
              const SizedBox(height: 8),
              const Text('已生成事务（TODO：把解析结果写入 Inbox 列表）'),
            ],
          ],
        ),
      ),
    );
  }
}

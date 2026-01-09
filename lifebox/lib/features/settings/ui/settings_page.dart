import 'package:flutter/material.dart';
import '../../../../core/widgets/app_scaffold.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '设置',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              value: true,
              onChanged: (v) {},
              title: const Text('仅上传 OCR 文本（默认开）'),
              subtitle: const Text('隐私友好：默认不上传原图（后续可配置）'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: const Text('本地缓存'),
              subtitle: const Text('保留 7/30/永久（TODO）'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: const Text('清除数据'),
              subtitle: const Text('本地清除 / 云端清除（接口预留）'),
              trailing: const Icon(Icons.delete_outline),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

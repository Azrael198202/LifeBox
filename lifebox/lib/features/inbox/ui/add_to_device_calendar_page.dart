import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../state/local_inbox_providers.dart';

class AddToDeviceCalendarPage extends ConsumerStatefulWidget {
  const AddToDeviceCalendarPage({super.key, required this.recordId});
  final String recordId;

  @override
  ConsumerState<AddToDeviceCalendarPage> createState() =>
      _AddToDeviceCalendarPageState();
}

class _AddToDeviceCalendarPageState
    extends ConsumerState<AddToDeviceCalendarPage> {
  final _plugin = DeviceCalendarPlugin();
  List<Calendar> _cals = const [];
  String? _selectedCalId;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _initTimezone() async {
    tz.initializeTimeZones();
    final String name = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(name));
  }

  Future<void> _init() async {
    await _initTimezone();

    setState(() {
      _loading = true;
      _error = null;
    });

    final perm = await _plugin.requestPermissions();
    if (!(perm.isSuccess == true && perm.data == true)) {
      setState(() {
        _loading = false;
        _error = 'カレンダー権限が許可されていません';
      });
      return;
    }

    final res = await _plugin.retrieveCalendars();
    if (!(res.isSuccess == true)) {
      setState(() {
        _loading = false;
        _error = res.errors?.join(',');
      });
      return;
    }

    final calendars = (res.data ?? <Calendar>[]).cast<Calendar>();

    final writable =
        calendars.where((c) => (c.isReadOnly ?? false) == false).toList();

    setState(() {
      _cals = writable;
      _selectedCalId = writable.isNotEmpty ? writable.first.id : null;
      _loading = false;
    });
  }

  DateTime? _parseDue(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    try {
      return DateTime.parse(v.trim());
    } catch (_) {
      return null;
    }
  }

  Future<void> _add() async {
    final list = await ref.read(localInboxListProvider.future);
    final r = list.firstWhere((e) => e.id == widget.recordId);

    final due = _parseDue(r.dueAt);
    if (due == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('期限（dueAt）がないため追加できません')),
      );
      return;
    }
    if (_selectedCalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('書き込み可能なカレンダーが見つかりません')),
      );
      return;
    }

    // 期限日：終日イベントとして登録（必要なら時間も付けられる）
    final start = tz.TZDateTime(
      tz.local,
      due.year,
      due.month,
      due.day,
      9,
      0,
    );
    final end = start.add(const Duration(hours: 1));

    final groupLabel = (r.groupId == null) ? '個人' : 'Group';
    final colorHex = r.colorValue == null
        ? ''
        : ' color=0x${r.colorValue!.toRadixString(16)}';

    final event = Event(
      _selectedCalId!,
      title: r.title,
      description: '${r.summary}\n\n[$groupLabel]$colorHex',
      start: start,
      end: end,
    );

    final created = await _plugin.createOrUpdateEvent(event);
    if (created?.isSuccess == true && (created?.data?.isNotEmpty ?? false)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('カレンダーに追加しました')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('追加失敗: ${created?.errors?.join(',') ?? 'unknown'}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('カレンダーに追加')),
        body: Center(child: Text(_error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('カレンダーに追加')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCalId,
              decoration: const InputDecoration(
                labelText: '書き込み先カレンダー',
                border: OutlineInputBorder(),
              ),
              items: _cals
                  .map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name ?? 'Calendar'),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCalId = v),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _add,
                icon: const Icon(Icons.event_available),
                label: const Text('追加する'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

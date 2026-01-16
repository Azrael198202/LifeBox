import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifebox/core/services/cloud_inbox_service.dart';

final cloudInboxServiceProvider = Provider<CloudInboxService>((ref) {
  return CloudInboxService();
});

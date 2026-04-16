import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:landlord_os/app.dart';
import 'package:landlord_os/core/constants/supabase_keys.dart';
import 'package:landlord_os/core/services/notification_service.dart';
import 'package:landlord_os/core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final supabaseUrl = SupabaseKeys.url;
  final supabaseKey = SupabaseKeys.anonKey;

  if (supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty) {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  } else {
    AppLogger.warning(
      'Supabase credentials not set — running without backend.',
    );
  }

  await NotificationService.instance.init();
  await NotificationService.instance.requestPermission();

  runApp(const ProviderScope(child: LandlordOSApp()));
}

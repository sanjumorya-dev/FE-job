import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../core/network/dio_client.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/storage/cache_manager.dart';
import '../../core/storage/local_storage_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/user_service.dart';
import '../../data/services/requirement_service.dart';
import '../../data/services/chat_service.dart';
import '../../data/services/dashboard_service.dart';
import '../../data/services/work_type_service.dart';
import '../../data/services/application_request_service.dart';
import '../../data/services/rating_service.dart';
import '../../data/services/common_service.dart';
import '../../data/services/config_service.dart';
import '../../data/services/dispute_service.dart';
import '../../data/services/location_service.dart';
import '../../data/services/preference_service.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── Local Storage ───────────────────────────────────────────
  await localStorageService.init();
  sl.registerSingleton<LocalStorageService>(localStorageService);
  sl.registerSingleton<CacheManager>(cacheManager);

  // ── Dio base instance ─────────────────────────────────────
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://dihaadi-0lje.onrender.com/api/v1',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    PrettyDioLogger(
      requestBody: true,
      responseBody: true,
      error: true,
      compact: true,
    ),
  );

  // ── DioClient (with interceptors) ─────────────────────────
  sl.registerLazySingleton<DioClient>(() => DioClient(dio));

  // ── Services ──────────────────────────────────────────────
  sl.registerLazySingleton<AuthService>(() => AuthService());
  sl.registerLazySingleton<UserService>(() => UserService());
  sl.registerLazySingleton<RequirementService>(() => RequirementService());
  sl.registerLazySingleton<ChatService>(() => ChatService());
  sl.registerLazySingleton<DashboardService>(() => DashboardService());
  sl.registerLazySingleton<NotificationService>(() => NotificationService());
  sl.registerLazySingleton<WorkTypeService>(() => WorkTypeService());
  sl.registerLazySingleton<ApplicationRequestService>(() => ApplicationRequestService());
  sl.registerLazySingleton<RatingService>(() => RatingService());
  sl.registerLazySingleton<CommonService>(() => CommonService());
  sl.registerLazySingleton<ConfigService>(() => ConfigService());
  sl.registerLazySingleton<DisputeService>(() => DisputeService());
  sl.registerLazySingleton<LocationService>(() => LocationService());
  sl.registerLazySingleton<PreferenceService>(() => PreferenceService());
}

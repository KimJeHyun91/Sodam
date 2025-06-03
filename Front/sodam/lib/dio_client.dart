import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.50.56:8080', // 실제 핸드폰에서 접속 가능한 서버 IP
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  )
  // 로그 출력용 Interceptor
    ..interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      logPrint: (log) => print('📦 DioLog: $log'),
    ))

  // JWT 토큰 자동 삽입용 Interceptor
    ..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            print("🔐 Authorization 헤더 추가됨: Bearer $token");
          } else {
            print("⚠️ 토큰 없음. Authorization 헤더 생략됨");
          }
        } catch (e) {
          print("❌ SharedPreferences 오류: $e");
        }

        print("➡️ Dio 요청 준비됨: [${options.method}] ${options.uri}");
        return handler.next(options);
      },

      onResponse: (response, handler) {
        print("✅ Dio 응답 수신: ${response.statusCode} ${response.data}");
        return handler.next(response);
      },

      onError: (DioException e, handler) {
        print("❌ Dio 요청 실패: ${e.message}");
        if (e.response != null) {
          print("❗ 서버 오류 응답: ${e.response?.statusCode} ${e.response?.data}");
        } else {
          print("❗ 서버 응답 없음 (네트워크 문제일 가능성 높음)");
        }
        return handler.next(e);
      },
    ));

  // 외부에서 Dio 인스턴스 접근
  static Dio get dio => _dio;
}

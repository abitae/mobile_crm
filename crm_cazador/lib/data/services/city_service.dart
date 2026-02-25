import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/city_model.dart';
import '../../core/exceptions/api_exception.dart';

/// Servicio para listado de ciudades (Cazador).
/// GET /cazador/cities con query search, per_page (max 500).
class CityService {
  static const int _defaultPerPage = 100;
  static const int _maxPerPage = 500;

  /// Obtener lista de ciudades (paginada, búsqueda).
  /// Respuesta: data.cities (array de { id, name }), data.pagination.
  static Future<List<CityModel>> getCities({
    String? search,
    int perPage = _defaultPerPage,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'per_page': perPage.clamp(1, _maxPerPage),
      };
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await ApiService.get(
        '/cazador/cities',
        queryParameters: queryParams,
      );

      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null) {
        throw ApiException('Respuesta vacía del servidor');
      }

      if (responseData['success'] == false) {
        final message =
            responseData['message'] as String? ?? 'Error al obtener ciudades';
        throw ApiException(message);
      }

      final dataObj = responseData['data'] as Map<String, dynamic>?;
      final citiesList = dataObj?['cities'] as List<dynamic>? ?? [];
      return citiesList
          .map((e) => CityModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final responseData = e.response?.data;
      String? message;
      if (responseData is Map<String, dynamic>) {
        message = responseData['message'] as String?;
      }
      if (e.response?.statusCode == 401) {
        throw ApiException(message ?? 'Usuario no autenticado');
      }
      throw ApiException(message ?? 'Error al obtener ciudades: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }
}

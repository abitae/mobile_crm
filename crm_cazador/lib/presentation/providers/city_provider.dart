import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/city_model.dart';
import '../../../data/services/city_service.dart';

/// Listado de ciudades para formularios (clientes, dateros).
/// Carga hasta 500 ciudades; cache implícito vía FutureProvider.
final citiesProvider = FutureProvider<List<CityModel>>((ref) async {
  return CityService.getCities(perPage: 500);
});

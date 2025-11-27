import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import '../../../data/services/project_service.dart';
import '../../../data/models/project_model.dart';
import '../../../data/models/unit_model.dart';
import '../../../core/exceptions/api_exception.dart';

/// Estado del listado de proyectos
class ProjectsState {
  final List<ProjectModel> projects;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final String? search;
  final String? projectTypeFilter;
  final String? loteTypeFilter;
  final String? stageFilter;
  final String? legalStatusFilter;
  final String? statusFilter;
  final String? districtFilter;
  final String? provinceFilter;
  final String? regionFilter;
  final bool? hasAvailableUnitsFilter;

  ProjectsState({
    List<ProjectModel>? projects,
    bool? isLoading,
    bool? isLoadingMore,
    this.error,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    this.search,
    this.projectTypeFilter,
    this.loteTypeFilter,
    this.stageFilter,
    this.legalStatusFilter,
    this.statusFilter,
    this.districtFilter,
    this.provinceFilter,
    this.regionFilter,
    this.hasAvailableUnitsFilter,
  })  : projects = projects ?? const [],
        isLoading = isLoading ?? false,
        isLoadingMore = isLoadingMore ?? false,
        currentPage = currentPage ?? 1,
        totalPages = totalPages ?? 1,
        hasMore = hasMore ?? false;

  ProjectsState copyWith({
    List<ProjectModel>? projects,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    String? search,
    String? projectTypeFilter,
    String? loteTypeFilter,
    String? stageFilter,
    String? legalStatusFilter,
    String? statusFilter,
    String? districtFilter,
    String? provinceFilter,
    String? regionFilter,
    bool? hasAvailableUnitsFilter,
  }) {
    return ProjectsState(
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      search: search ?? this.search,
      projectTypeFilter: projectTypeFilter ?? this.projectTypeFilter,
      loteTypeFilter: loteTypeFilter ?? this.loteTypeFilter,
      stageFilter: stageFilter ?? this.stageFilter,
      legalStatusFilter: legalStatusFilter ?? this.legalStatusFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      districtFilter: districtFilter ?? this.districtFilter,
      provinceFilter: provinceFilter ?? this.provinceFilter,
      regionFilter: regionFilter ?? this.regionFilter,
      hasAvailableUnitsFilter: hasAvailableUnitsFilter ?? this.hasAvailableUnitsFilter,
    );
  }
}

/// Provider de proyectos
class ProjectsNotifier extends StateNotifier<ProjectsState> {
  ProjectsNotifier() : super(ProjectsState()) {
    loadProjects();
  }

  /// Getter público para acceder al estado
  ProjectsState get currentState => state;

  /// Cargar proyectos
  Future<void> loadProjects({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(isLoading: true, error: null, currentPage: 1);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final response = await ProjectService.getProjects(
        page: refresh ? 1 : state.currentPage,
        perPage: 15,
        search: state.search,
        projectType: state.projectTypeFilter,
        loteType: state.loteTypeFilter,
        stage: state.stageFilter,
        legalStatus: state.legalStatusFilter,
        status: state.statusFilter,
        district: state.districtFilter,
        province: state.provinceFilter,
        region: state.regionFilter,
        hasAvailableUnits: state.hasAvailableUnitsFilter,
      );

      state = state.copyWith(
        projects: refresh ? response.data : [...state.projects, ...response.data],
        currentPage: response.currentPage,
        totalPages: response.totalPages,
        hasMore: response.currentPage < response.totalPages,
        isLoading: false,
        error: null,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Cargar más proyectos (paginación)
  Future<void> loadMoreProjects() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final response = await ProjectService.getProjects(
        page: nextPage,
        perPage: 15,
        search: state.search,
        projectType: state.projectTypeFilter,
        loteType: state.loteTypeFilter,
        stage: state.stageFilter,
        legalStatus: state.legalStatusFilter,
        status: state.statusFilter,
        district: state.districtFilter,
        province: state.provinceFilter,
        region: state.regionFilter,
        hasAvailableUnits: state.hasAvailableUnitsFilter,
      );

      state = state.copyWith(
        projects: [...state.projects, ...response.data],
        currentPage: response.currentPage,
        totalPages: response.totalPages,
        hasMore: response.currentPage < response.totalPages,
        isLoadingMore: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Aplicar búsqueda
  void setSearch(String? search) {
    state = state.copyWith(search: search, currentPage: 1);
    loadProjects(refresh: true);
  }

  /// Aplicar filtros
  void setFilters({
    String? projectType,
    String? loteType,
    String? stage,
    String? legalStatus,
    String? status,
    String? district,
    String? province,
    String? region,
    bool? hasAvailableUnits,
  }) {
    state = state.copyWith(
      projectTypeFilter: projectType,
      loteTypeFilter: loteType,
      stageFilter: stage,
      legalStatusFilter: legalStatus,
      statusFilter: status,
      districtFilter: district,
      provinceFilter: province,
      regionFilter: region,
      hasAvailableUnitsFilter: hasAvailableUnits,
      currentPage: 1,
    );
    loadProjects(refresh: true);
  }

  /// Limpiar filtros
  void clearFilters() {
    state = state.copyWith(
      search: null,
      projectTypeFilter: null,
      loteTypeFilter: null,
      stageFilter: null,
      legalStatusFilter: null,
      statusFilter: null,
      districtFilter: null,
      provinceFilter: null,
      regionFilter: null,
      hasAvailableUnitsFilter: null,
      currentPage: 1,
    );
    loadProjects(refresh: true);
  }

  /// Limpiar error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider global del notifier de proyectos
final projectsNotifierProvider = Provider<ProjectsNotifier>((ref) {
  final notifier = ProjectsNotifier();
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

/// Provider global de proyectos (estado) - reactivo
/// Observa el notifier y accede al estado actual
/// Nota: Para que sea completamente reactivo, los widgets deben observar
/// directamente projectsNotifierProvider y acceder a currentState
final projectsProvider = Provider<ProjectsState>((ref) {
  // Observar el notifier para que el provider se actualice cuando cambie
  ref.watch(projectsNotifierProvider);
  // Retornar el estado actual
  return ref.read(projectsNotifierProvider).currentState;
});

/// Provider para un proyecto específico
/// 
/// Según la documentación, acepta parámetros opcionales:
/// - `unitsPerPage`: Unidades por página (máximo 100, por defecto 15)
/// - `includeUnits`: Incluir unidades en la respuesta (por defecto true)
final projectProvider = FutureProvider.family<ProjectModel, int>((ref, id) async {
  return await ProjectService.getProject(id);
});

/// Provider para un proyecto específico con opciones
final projectWithOptionsProvider = FutureProvider.family<ProjectModel, ({int id, int? unitsPerPage, bool? includeUnits})>((ref, params) async {
  return await ProjectService.getProject(
    params.id,
    unitsPerPage: params.unitsPerPage,
    includeUnits: params.includeUnits,
  );
});

/// Estado de unidades de un proyecto
/// 
/// Según la documentación:
/// - Solo se muestran unidades con estado "disponible"
/// - Solo acepta parámetros de paginación (per_page, page)
class ProjectUnitsState {
  final List<UnitModel> units;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  ProjectUnitsState({
    List<UnitModel>? units,
    bool? isLoading,
    bool? isLoadingMore,
    this.error,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
  })  : units = units ?? const [],
        isLoading = isLoading ?? false,
        isLoadingMore = isLoadingMore ?? false,
        currentPage = currentPage ?? 1,
        totalPages = totalPages ?? 1,
        hasMore = hasMore ?? false;

  ProjectUnitsState copyWith({
    List<UnitModel>? units,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
  }) {
    return ProjectUnitsState(
      units: units ?? this.units,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Provider de unidades de proyecto
class ProjectUnitsNotifier extends StateNotifier<ProjectUnitsState> {
  final int projectId;

  ProjectUnitsNotifier(this.projectId) : super(ProjectUnitsState()) {
    // Cargar unidades después de que el widget esté construido
    Future.microtask(() => loadUnits());
  }

  /// Getter público para acceder al estado
  ProjectUnitsState get currentState => state;

  /// Cargar unidades disponibles
  /// 
  /// Según la documentación, solo se muestran unidades con estado "disponible"
  /// y se ordenan por manzana y número de unidad
  Future<void> loadUnits({bool refresh = false}) async {
    // Evitar múltiples cargas simultáneas
    if (state.isLoading && !refresh) return;
    
    if (refresh) {
      // Invalidar caché al hacer refresh
      ProjectService.invalidateUnitsCache(projectId);
      state = state.copyWith(isLoading: true, error: null, currentPage: 1, units: []);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final pageToLoad = refresh ? 1 : state.currentPage;
      final response = await ProjectService.getProjectUnits(
        projectId: projectId,
        page: pageToLoad,
        perPage: 15,
        useCache: !refresh, // Usar caché solo si no es refresh
      );

      final newState = state.copyWith(
        units: refresh ? response.data : [...state.units, ...response.data],
        currentPage: response.currentPage,
        totalPages: response.totalPages,
        hasMore: response.currentPage < response.totalPages,
        isLoading: false,
        error: null,
      );
      
      // Actualizar el estado - esto debería notificar a los listeners
      state = newState;
      
      // Debug: verificar que el estado se actualizó
      print('✅ [ProjectUnitsNotifier] Estado actualizado: ${state.units.length} unidades');
    } on ApiException catch (e) {
      // Debug: error de API
      // print('API Error loading units: ${e.message}');
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      // Debug: error inesperado
      // print('Unexpected error loading units: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Cargar más unidades (paginación)
  Future<void> loadMoreUnits() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final response = await ProjectService.getProjectUnits(
        projectId: projectId,
        page: nextPage,
        perPage: 15,
      );

      state = state.copyWith(
        units: [...state.units, ...response.data],
        currentPage: response.currentPage,
        totalPages: response.totalPages,
        hasMore: response.currentPage < response.totalPages,
        isLoadingMore: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: 'Error inesperado: ${e.toString()}',
      );
    }
  }
}

/// Provider de unidades por proyecto
final projectUnitsNotifierProvider = Provider.family<ProjectUnitsNotifier, int>((ref, projectId) {
  final notifier = ProjectUnitsNotifier(projectId);
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

/// Provider de estado de unidades (reactivo)
/// Observa el notifier y accede al estado actual
/// Nota: En Riverpod 3.0 con StateNotifier, el provider se actualiza
/// cuando el notifier cambia, pero necesitamos observar el estado directamente
final projectUnitsProvider = Provider.family<ProjectUnitsState, int>((ref, projectId) {
  // Observar el notifier
  final notifier = ref.watch(projectUnitsNotifierProvider(projectId));
  // Retornar el estado actual
  // Para que sea reactivo, el widget debe observar este provider
  // y el notifier debe notificar cambios cuando actualice el estado
  return notifier.currentState;
});


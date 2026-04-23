library;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/usecases/get_nearby_garages_usecase.dart';
import '../../domain/errors/service_locator_failure.dart';
import 'service_locator_event.dart';
import 'service_locator_state.dart';

class ServiceLocatorBloc
    extends Bloc<ServiceLocatorEvent, ServiceLocatorState> {
  ServiceLocatorBloc(this._getNearbyGarages)
    : super(ServiceLocatorState.initial()) {
    on<InitializeServiceLocator>(_onInitialize);
    on<LoadNearbyGarages>(_onLoadNearbyGarages);
    on<SelectServiceCenter>(_onSelectCenter);
    on<ClearSelectedCenter>(_onClearSelectedCenter);
    on<UpdateVisibleCenters>(_onUpdateVisibleCenters);
    on<RefreshNearbyGaragesRequested>(_onRefreshNearbyGaragesRequested);
  }

  final GetNearbyGaragesUseCase _getNearbyGarages;

  Future<void> _onInitialize(
    InitializeServiceLocator event,
    Emitter<ServiceLocatorState> emit,
  ) async {
    await _loadNearby(emit, null, null);
  }

  Future<void> _onLoadNearbyGarages(
    LoadNearbyGarages event,
    Emitter<ServiceLocatorState> emit,
  ) async {
    await _loadNearby(emit, event.latitude, event.longitude);
  }

  Future<void> _loadNearby(
    Emitter<ServiceLocatorState> emit,
    double? lat,
    double? lng,
  ) async {
    emit(state.copyWith(isLoading: true, failureMessage: null));
    try {
      final centers = await _getNearbyGarages(latitude: lat, longitude: lng);
      emit(
        state.copyWith(
          centers: centers,
          visibleCenterIds: centers.map((c) => c.id).toList(),
          selectedCenterId: centers.isNotEmpty ? centers.first.id : null,
          isLoading: false,
          lastLatitude: lat,
          lastLongitude: lng,
          failureMessage: null,
        ),
      );
    } on ServiceLocatorException catch (e) {
      emit(state.copyWith(isLoading: false, failureMessage: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          failureMessage: 'Unable to load nearby garages.',
        ),
      );
    }
  }

  void _onSelectCenter(
    SelectServiceCenter event,
    Emitter<ServiceLocatorState> emit,
  ) {
    emit(state.copyWith(selectedCenterId: event.centerId));
  }

  void _onClearSelectedCenter(
    ClearSelectedCenter event,
    Emitter<ServiceLocatorState> emit,
  ) {
    emit(state.copyWith(clearSelectedCenter: true));
  }

  void _onUpdateVisibleCenters(
    UpdateVisibleCenters event,
    Emitter<ServiceLocatorState> emit,
  ) {
    emit(state.copyWith(visibleCenterIds: event.visibleCenterIds));
  }

  Future<void> _onRefreshNearbyGaragesRequested(
    RefreshNearbyGaragesRequested event,
    Emitter<ServiceLocatorState> emit,
  ) async {
    await _loadNearby(emit, state.lastLatitude, state.lastLongitude);
  }
}

import { Location } from '../../../gps/domain/entities/location.entity';

/**
 * Repositorio de ubicaciones de viajes
 * Define los métodos de acceso a datos para las ubicaciones GPS de los viajes
 */
export abstract class TripLocationRepository {
  /**
   * Agrega una nueva ubicación a un viaje
   */
  abstract addLocation(tripId: string, location: Location): Promise<Location>;

  /**
   * Obtiene todas las ubicaciones de un viaje
   * @param tripId - ID del viaje
   * @returns Array de ubicaciones ordenadas por timestamp
   */
  abstract getLocationsByTripId(tripId: string): Promise<Location[]>;

  /**
   * Obtiene la última ubicación registrada de un viaje
   * @param tripId - ID del viaje
   * @returns La última ubicación o null si no hay ubicaciones
   */
  abstract getLatestLocation(tripId: string): Promise<Location | null>;

  /**
   * Cuenta las ubicaciones de un viaje
   * @param tripId - ID del viaje
   * @returns Número de ubicaciones
   */
  abstract countLocations(tripId: string): Promise<number>;
}

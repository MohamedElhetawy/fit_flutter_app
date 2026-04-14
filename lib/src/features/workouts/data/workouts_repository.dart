import 'workout.dart';
import 'workouts_local_data_source.dart';

class WorkoutsRepository {
  WorkoutsRepository(this._localDataSource);

  final WorkoutsLocalDataSource _localDataSource;

  Stream<List<Workout>> watchWorkouts() {
    return _localDataSource.watchAllWorkouts().map((localWorkouts) {
      return localWorkouts.map((local) {
        return Workout(
          id: local.originalId,
          title: local.title,
          coach: local.coach,
          image: local.image,
          price: local.price,
          discountPercent: local.discountPercent,
        );
      }).toList();
    });
  }
}

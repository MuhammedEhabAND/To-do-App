part of 'app_cubit.dart';

@immutable
abstract class AppState {}

class AppInitial extends AppState {}
class AppNavBarChange extends AppState {}
class AppBottomSheetState extends AppState {}
class AppCreateDatabase extends AppState {}
class AppGetDatabase extends AppState {}
class AppUpdateDatabase extends AppState {}
class AppDeleteFromDatabase extends AppState {}
class AppGetDatabaseLoading extends AppState {}
class AppInsertToDatabase extends AppState {}


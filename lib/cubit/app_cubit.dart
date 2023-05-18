import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';

import '../screens/archived_tasks.dart';
import '../screens/done_tasks.dart';
import '../screens/tasks_screen.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppInitial());

  IconData fabIcon = Icons.edit;
  bool isBottomSheetOpen = false;
void ChangeBottomSheet(bool isShown , IconData icon){
  isBottomSheetOpen = isShown;
  fabIcon= icon;
  emit(AppBottomSheetState());

}

  List<Widget> screens = const [
    TasksScreen(),
    DoneTasks(),
    ArchivedTasks(),
  ];
  List<String> titles = [
    'Tasks',
    'Done Tasks',
    'Archived Tasks'
  ];
  int currentIndex = 0 ;

  static AppCubit get(context) => BlocProvider.of(context);
  void ChangeScreen(int index){
    currentIndex = index;
    emit(AppNavBarChange());
  }

  late Database database;
  List<Map> tasks =[];
  List<Map> doneTasks =[];
  List<Map> archivedTasks =[];



  void createDB()  {
     openDatabase('todo.db', version: 1,
        onCreate: (database, version) {
          print('Database Created');
          database.execute(
              'CREATE TABLE tasks (id INTEGER PRIMARY KEY , title TEXT , date TEXT , time TEXT , status TEXT)')
              .then((value) {
            print('Table Created');
          }).catchError((onError) {
            print('The error is ${onError.toString()}');
          });
        },
        onOpen: (database) {
          getDataFromDB(database);
          print('Database Opened');
        }

    ).then((value){
      database = value;
      emit(AppCreateDatabase());
     });
  }

  insertToDB(String title, String time, String date) async {
    await database.transaction((txn) async {
      txn
          .rawInsert(
          'INSERT INTO tasks(title , date , time ,status) VALUES("$title" ,"$date","$time","New")')
          .then((value) {
        print('$value inserted successfully ');
        emit(AppInsertToDatabase());
        getDataFromDB(database);

          }).catchError((onError) {
        print('Error is ${onError.toString()}');
      });
    });
  }

  void getDataFromDB(Database database) {
    tasks = [];
    archivedTasks = [];
    doneTasks = [];
    emit(AppGetDatabaseLoading());
    database.rawQuery('SELECT * FROM tasks').then((value) {
      print(value);
      value.forEach((element) {
        if(element['status'] == 'New'){
          tasks.add(element);
        }else if(element['status'] == 'done'){
          doneTasks.add(element);
        }else {
          archivedTasks.add(element);
        }
      });
      emit(AppGetDatabase());
    });
  }
   updateDB(String status , int id )async{
     database.rawUpdate('UPDATE tasks set status = ? WHERE id = ?' ,
          ['$status' , id],).then((value){
            getDataFromDB(database);
            emit(AppUpdateDatabase());


          });
  }
   deleteDB(int id ){
     database
        .rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value){
          getDataFromDB(database);
          emit(AppDeleteFromDatabase());
     });

  }

}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/layout/cubit/app_states.dart';
import 'package:todo_app/modules/archive_tasks_screen.dart';
import 'package:todo_app/modules/done_tasks_screen.dart';
import 'package:todo_app/modules/new_tasks_screen.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialStates());

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;
  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchiveTasksScreen()
  ];

  late List<String> titles = ['New Tasks', 'Done Tasks', 'Archived Tasks'];

  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeButtonNavBarStates());
  }

  late Database database;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archiveTasks = [];

  void createDatabase() {
    openDatabase('todo.db', version: 1, onCreate: (database, version) async {
      await database
          .execute(
              "CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT,status TEXT)")
          .then((value) {
        print('Table Created');
      }).catchError((error) {
        print(error.toString());
      });
    }, onOpen: (database) {
      getDataFromDatabase(database);
    }).then((value) {
      database = value;
      emit(AppCreateDataBaseStates());
    });
  }

  Future insertToDatabase(
      {required String title,
      required String time,
      required String date,
      status}) async {
    await database.transaction((txn) async {
      txn
          .rawInsert(
              'INSERT INTO tasks(title, time,date ,status) VALUES("${title}","${time}","${date}","status")')
          .then((value) {
        emit(AppInsertDataBaseStates());

        getDataFromDatabase(database);
      }).catchError((error) {
        print(error.toString());
      });
      // return null;
    });
  }

  void getDataFromDatabase(database) {
    newTasks = [];
    doneTasks = [];
    archiveTasks = [];

    database.rawQuery('SELECT * FROM tasks').then((value) {
      newTasks = value;
      value.forEach((element) {
        if (element['status'] == 'new')
          newTasks.add(element);
        else if (element['status'] == 'done') {
          doneTasks.add(element);
        } else if (element['status'] == 'archive') {
          archiveTasks.add(element);
        }
      });
      emit(AppGetDataBaseStates());
    });
  }

  void updateData({required String status, required int id}) {
    database.rawUpdate(
      'UPDATE tasks SET status = ? WHERE id = ?',
      [status, id],
    ).then((value) {
      print(value.toString());
      getDataFromDatabase(database);
      emit(AppUpdateDataBaseStates());
    });
  }

  void deleteData({required int id}) {
    database.rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      getDataFromDatabase(database);
      emit(AppDeleteDatabaseStates());
    });
  }

  bool isButtonSheetShown = false;
  IconData fabIcon = Icons.edit;
  void changeButtonSheetState({required bool isShow, required IconData icon}) {
    isButtonSheetShown = isShow;
    fabIcon = icon;
    emit(AppChangeButtonSheetState());
  }
}

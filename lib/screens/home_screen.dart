import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/cubit/app_cubit.dart';
import 'package:todo/screens/tasks_screen.dart';
import 'package:todo/shared/components/components.dart';
import 'package:todo/shared/components/constants.dart';

import 'archived_tasks.dart';
import 'done_tasks.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit()..createDB(),
      child: BlocConsumer<AppCubit, AppState>(
        listener: (context, state) {
          if(state is AppInsertToDatabase){
            Navigator.pop(context);
          }
        },
        builder: (context, state) {

          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(cubit.titles[cubit.currentIndex]),

            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (cubit.isBottomSheetOpen) {
                  if (formKey.currentState!.validate()) {
                    cubit.insertToDB(titleController.text, timeController.text, dateController.text);
                    titleController.text ='';
                    timeController.text ='';
                    dateController.text ='';
                    cubit.ChangeBottomSheet(false,Icons.edit);
                  }
                } else {
                  scaffoldKey.currentState?.showBottomSheet(
                          elevation: 50,
                          (context) =>
                      Form(
                        key: formKey,
                        child: Container(
                          padding: const EdgeInsets.all(20),

                          child: Column(
                            mainAxisSize: MainAxisSize.min,


                            children: [
                              defaultFormField(controller: titleController,
                                  text: 'Task Title',
                                  type: TextInputType.text,
                                  icon: Icons.title,
                                  validate: (value) {
                                    if (value!.isEmpty) {
                                      return 'title cannot be empty!';
                                    } else {
                                      return null;
                                    }
                                  }),
                              SizedBox(height: 15,),
                              defaultFormField(controller: timeController,
                                  text: 'Task Time',
                                  type: TextInputType.datetime,
                                  icon: Icons.watch_later_outlined,
                                  onTap: () {
                                    showTimePicker(context: context,
                                      initialTime: TimeOfDay.now(),)
                                        .then((value) {
                                      timeController.text =
                                          value!.format(context).toString();
                                    }).catchError((onError) {
                                      print('error is ${onError.toString()}');
                                    });
                                  },
                                  validate: (value) {
                                    if (value!.isEmpty) {
                                      return 'Time cannot be empty!';
                                    } else {
                                      return null;
                                    }
                                  }),
                              SizedBox(height: 15,),
                              defaultFormField(controller: dateController,
                                  text: 'Task Date',
                                  type: TextInputType.datetime,
                                  icon: Icons.date_range,
                                  onTap: () {
                                    showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.parse('2023-12-30'))
                                        .then((value) =>
                                    {
                                      dateController.text = DateFormat.yMMMd()
                                          .format(value!)
                                          .toString(),
                                    }).catchError((onError) {
                                      print('Error is ${onError.toString()}');
                                    });
                                  },
                                  validate: (value) {
                                    if (value!.isEmpty) {
                                      return 'date cannot be empty!';
                                    } else {
                                      return null;
                                    }
                                  })
                            ],
                          ),
                        ),
                      )).closed.then((value) {
                    cubit.ChangeBottomSheet(false, Icons.edit);
                  });
                  cubit.ChangeBottomSheet(true, Icons.add);
                }
              },

              child: Icon(cubit.fabIcon),

            ),
            body:state is AppGetDatabaseLoading ? Center(child: CircularProgressIndicator(),) : cubit.screens[cubit.currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                cubit.ChangeScreen(index);
                  },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Tasks'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.check_box), label: 'Done Tasks'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.archive_rounded), label: 'Archived Tasks'),
              ],

            ),

          );
        },
      ),
    );
  }

}
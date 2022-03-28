import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/layout/cubit/app_cubit.dart';
import 'package:todo_app/layout/cubit/app_states.dart';
import 'package:todo_app/shared/componants/componants.dart';

class HomeLayout extends StatelessWidget {

  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {
          if (state is AppInsertDataBaseStates) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          AppCubit cubit = AppCubit.get(context);

          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(title: Text(cubit.titles[cubit.currentIndex])),
            body: ConditionalBuilder(
              condition: true,
              builder: (context) => cubit.screens[cubit.currentIndex],
              fallback: (context) => Center(child: CircularProgressIndicator()),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (cubit.isButtonSheetShown) {
                  if (formKey.currentState!.validate()) {
                    cubit.insertToDatabase(
                      title: titleController.text,
                      time: timeController.text,
                      date: dateController.text,
                    );
                  }
                } else {
                  scaffoldKey.currentState!
                      .showBottomSheet(
                        (context) => Container(
                          color: Colors.grey[100],
                          padding: EdgeInsets.all(20.0),
                          child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                defaultFormField(
                                    controller: titleController,
                                    label: 'Task Title',
                                    type: TextInputType.text,
                                    validate: (String? value) {
                                      if (value!.isEmpty) {
                                        return 'title must not be empty';
                                      } else
                                        return null;
                                    },
                                    prefix: Icons.title),
                                SizedBox(
                                  height: 15.0,
                                ),
                                defaultFormField(
                                    controller: timeController,
                                    onTap: () {
                                      showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now())
                                          .then((value) {
                                        timeController.text =
                                            value!.format(context);
                                      });
                                    },
                                    label: 'Task Time',
                                    type: TextInputType.datetime,
                                    validate: (String? value) {
                                      if (value!.isEmpty) {
                                        return 'time must not be empty';
                                      } else
                                        return null;
                                    },
                                    prefix: Icons.watch_later_outlined),
                                SizedBox(
                                  height: 15.0,
                                ),
                                defaultFormField(
                                    controller: dateController,
                                    onTap: () {
                                      showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime.now(),
                                              lastDate:
                                                  DateTime.parse('2024-05-03'))
                                          .then((value) {
                                        dateController.text =
                                            DateFormat.yMMMd().format(value!);
                                      });
                                    },
                                    label: 'Task Date',
                                    type: TextInputType.datetime,
                                    validate: (String? value) {
                                      if (value!.isEmpty) {
                                        return 'date must not be empty';
                                      } else
                                        return null;
                                    },
                                    prefix: Icons.calendar_today)
                              ],
                            ),
                          ),
                        ),
                        elevation: 20.0,
                      ).closed
                      .then((value) {
                    cubit.changeButtonSheetState(
                        isShow: false, icon: Icons.edit);
                  });
                  cubit.changeButtonSheetState(isShow: true, icon: Icons.add);
                }
              },
              child: Icon(cubit.fabIcon),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                cubit.changeIndex(index);
              },
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Tasks'),
                BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: 'done'),
                BottomNavigationBarItem(icon: Icon(Icons.archive_outlined), label: 'Archived'),
              ],
            ),
          );
        },
      ),
    );
  }
}

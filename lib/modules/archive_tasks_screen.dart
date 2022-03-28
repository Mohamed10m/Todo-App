import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/layout/cubit/app_cubit.dart';
import 'package:todo_app/layout/cubit/app_states.dart';
import 'package:todo_app/shared/componants/componants.dart';

class ArchiveTasksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var tasks = AppCubit.get(context).archiveTasks;
        return TasksBuilder(tasks: tasks);
      },
    );
  }
}

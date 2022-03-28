import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/layout/cubit/app_cubit.dart';

Widget defaultFormField({
  required TextEditingController controller,
  required String label,
  required TextInputType type,
  required FormFieldValidator<String> validate,
  GestureTapCallback? onTap,
  required IconData prefix,
  bool obSecureText = false,
  IconData? suffix,
}) =>
    TextFormField(
      onTap: onTap,
      controller: controller,
      keyboardType: type,
      validator: validate,
      obscureText: obSecureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        prefixIcon: Icon(prefix),
        suffixIcon: Icon(suffix),
      ),
    );

Widget TasksBuilder({
  required List<Map> tasks
}) => ConditionalBuilder(condition:tasks.length > 0 ,
    builder:(context) => ListView.separated(itemBuilder: (context ,index)=> buildTaskItem(tasks[index],context),
        separatorBuilder:(context,index) => Container(
          width: double.infinity,
          height: 1,
          color: Colors.grey[300],
        ),
        itemCount:tasks.length
    ),
    fallback: (context)=>Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu,size: 100,color: Colors.grey,),
          Text("No Tasks Yet, Please Add Some Tasks ",style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.bold
          ),)
        ],),
    ));

Widget buildTaskItem(Map model, context) => Dismissible(
      key: Key(model['id'].toString()),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              child: Text(
                '${model['time']}',
                style: TextStyle(fontSize: 14.0),
              ),
            ),
            SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${model['title']}',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${model['date']} ',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 20.0,
            ),
            IconButton(
                onPressed: () {
                  AppCubit.get(context)
                      .updateData(status: 'done', id: model['id']);
                },
                icon: Icon(
                  Icons.check_box,
                  color: Colors.green,
                )),
            IconButton(
                onPressed: () {
                  AppCubit.get(context)
                      .updateData(status: 'archive', id: model['id']);
                },
                icon: Icon(
                  Icons.archive,
                  color: Colors.black26,
                ))
          ],
        ),
      ),
  onDismissed: (direction)
  {
    AppCubit.get(context).deleteData(id:model['id']);
  },
    );

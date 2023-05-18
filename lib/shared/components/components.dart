import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';

import '../../cubit/app_cubit.dart';

Widget defaultButton({
  double width = double.infinity,
  Color color = Colors.blue,
  required void Function() function,
  required String text,
  bool isUpperCase = true,
}) =>
    Container(
      width: width,
      color: color,
      child: MaterialButton(
        onPressed: function,
        child: Text(
          isUpperCase ? text.toUpperCase() : text,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
Widget defaultFormField({
  required TextEditingController controller,
  required String text,
  required TextInputType type,
  bool isNotPass = true,
  // Function? validate,
  String? Function(String?)? validate,
  void Function()? onpressed,
  void Function()? onTap,
  required IconData icon,
  IconData? suffixIcon,
}) =>
    TextFormField(
      controller: controller,
      keyboardType: type,
      validator: validate,
      obscureText: isNotPass ? false : true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: text,
        border: OutlineInputBorder(),
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon != null
            ? IconButton(onPressed: onpressed, icon: Icon(suffixIcon))
            : null,
      ),
    );
Widget buildTaskItem(Map model ,context) => Dismissible(
  key: Key(model['id'].toString()),

  background: Container(
    color: Colors.red,

    padding: const EdgeInsets.symmetric(horizontal: 16),
    child:  Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:const [

            Icon(Icons.delete , color: Colors.white,),
            Icon(Icons.delete , color: Colors.white,),
      ],
    ),
  ),
  onDismissed: (direction){
    final String title = model['title'] ;
    final String time = model['time'] ;
    final String date = model['date'] ;

    AppCubit.get(context).deleteDB(model['id']);
    ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Task deleted') ,
           ));

  },
  child:   Padding(

        padding: const EdgeInsets.all(20.0),

        child: Row(

          children: [

            CircleAvatar(

              radius: 40.0,

              child: Text(

                '${model['time']}',

                style: TextStyle(

                  color: Colors.white,

                ),

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

                    '${model['date']}',

                    style: TextStyle(

                      color: Colors.grey,

                    ),

                  ),

                ],

              ),

            ),

            SizedBox(

              width: 20.0,

            ),

            IconButton(onPressed: (){

              AppCubit.get(context).updateDB('done', model['id']);

            }, icon: Icon(Icons.check_box , color: Colors.green,)),

            IconButton(onPressed: (){



              AppCubit.get(context).updateDB('archived', model['id']);

            }, icon: Icon(Icons.archive_rounded , color: Colors.black45,)),



          ],

        ),

      ),
);
Widget TasksBuilder(List<Map> tasks) => ConditionalBuilder(
condition: tasks.length > 0,
builder: (BuildContext context)=>ListView.separated(
itemBuilder: (context, index) => buildTaskItem(tasks[index], context),
separatorBuilder: (context, index) =>
Container(
width: double.infinity,
height: 1.0,
color: Colors.grey[300],
), itemCount: tasks.length),
fallback: (BuildContext context)=>Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
crossAxisAlignment: CrossAxisAlignment.center,
mainAxisSize: MainAxisSize.max,
children: [
Icon(Icons.menu,size: 100,color: Colors.black26,),
Text('No Tasks Yet , Please Add Some Tasks ' , style: TextStyle(
fontSize: 16 ,
fontWeight: FontWeight.bold ,
color: Colors.black26
),)
],
),
),

);


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sedeek/shared/components/components.dart';
import 'package:sqflite/sqflite.dart';
import '../modules/archived_tasks/archived_tasks_screen.dart';
import '../modules/done_tasks/done_tasks_screen.dart';
import '../modules/new_tasks/new_tasks_screen.dart';


class HomeLayout extends StatefulWidget {





  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}


class _HomeLayoutState extends State<HomeLayout> {
   late int? currentIndex = 0;

   List <Widget> screens =
  [
    NewTaskScreen(),
    DoneTaskScreen(),
    ArchivedTaskScreen(),
  ];

   late Database database;
    var scaffoldKey = GlobalKey<ScaffoldState>();
    var formKey = GlobalKey<FormState>();
    bool isBottomSheetShown = false;
    IconData fabIcon = Icons.edit;
    var titleController = TextEditingController();
    var timeController = TextEditingController();
    var dateController = TextEditingController();




  @override
  void initState() {
    super.initState();
    createDatabase();
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Todo App'),
        centerTitle: true,

      ),
      body: screens[currentIndex!],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isBottomSheetShown) {
            if (formKey.currentState!.validate()) {
              insertToDatabase(
                date: dateController.text,
                title: titleController.text,
                time: timeController.text,
              ).then((value) {
                Navigator.pop(context);
                isBottomSheetShown = false;
                setState(() {
                  fabIcon = Icons.edit;
                });
                return null;
              });
            }
          } else {
            scaffoldKey.currentState
                ?.showBottomSheet(
                  (context) =>
                  Container(
                    color: Colors.grey[100],
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          defaultTextFormField(
                            controller: titleController,
                            type: TextInputType.text,
                            validate: (String value) {
                              if (value.isEmpty) {
                                return 'title is not be empty';
                              }
                              return null;

                            },
                            label: 'New task',
                            prefix: Icons.title,
                          ),
                          const SizedBox(height: 15,),
                          defaultTextFormField(
                            controller: timeController,
                            type: TextInputType.datetime,
                            onTap: () {
                              showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              ).then((value) {
                                timeController.text =
                                    value!.format(context).toString();
                              }
                              );
                            },
                            validate: (String value) {
                              if (value.isEmpty) {
                                return 'time is not be empty';
                              }
                              return null;
                            },
                            label: 'task time',
                            prefix: Icons.watch_later_outlined,
                          ),
                          const SizedBox(height: 10,),
                          defaultTextFormField(

                            controller: dateController,
                            type: TextInputType.datetime,
                            onTap: () {
                              showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.parse('2022-10-10'),
                              ).then((value) {
                                dateController.text =
                                    DateFormat.yMMMd().format(value!);
                              }
                              );
                            },
                            validate: (String value) {
                              if (value.isEmpty) {
                                return 'date is not be empty';
                              }
                              return null;
                            },
                            label: 'task date',
                            prefix: Icons.date_range,
                          )
                        ],
                      ),
                    ),
                  ),
            )
                .closed
                .then((value) {
              isBottomSheetShown = false;
              setState(() {
                fabIcon = Icons.edit;
              });
            });
            isBottomSheetShown = true;
            setState(() {
              fabIcon = Icons.add;
            });
          }
        },
        child: Icon(
            fabIcon
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex!,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            currentIndex = index;
            print(index);
          }
          );
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.task_outlined),
            label: 'tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.done_all),
            label: 'Done',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.archive),
            label: 'Archived',
          ),

        ],
      ),
    );
  }


  void createDatabase() async
  {
    database = await openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) {
        print('database created');

        database.execute(
            'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
            .then((value) {
          print('table created');
        }).catchError((error) {
          print('Error when creating table ${error.toString()}');
        });
      },
      onOpen: (database) {
        //getDataFromDatabase(database);
        print('database opened');
      },
    );
  }

  Future insertToDatabase({
    required String title,
    required String time,
    required String date,
  })
  {
    return  database.transaction((txn) {
    return  txn.rawInsert(

              'INSERT INTO tasks (title, date, time, status) VALUES( "$title", "$date", "$time", "new",)'
      ).then((value) {
        print('$value inserted');
      });

    });



  }
}

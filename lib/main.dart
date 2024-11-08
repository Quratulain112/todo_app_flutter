import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController createtaskcontroller = TextEditingController();
  List<bool> marklist = [];
  List<String> todotasks = [];
  Future<void> loadtasks() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var storetask = await pref.getStringList("todotask");
    if (!pref.containsKey("todotask")) {
      return;
    }
    setState(() {
      todotasks = storetask!;
      for (var task in todotasks) {
        List<String> value = task.split(', ');
        bool mark = (value[1] == '1') ? true : false;
        marklist.add(mark);
      }
    });
  }

  Future<void> save() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setStringList("todotask", todotasks);
  }

  @override
  void initState() {
    loadtasks();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purple, brightness: Brightness.dark),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("My TO-DO App"),
        ),
        body: Padding(
          padding: EdgeInsets.all(15),
          child: Column(children: [
            Padding(
                padding: EdgeInsets.all(15),
                child: Card(
                  child: ListTile(
                    title: TextField(
                      controller: createtaskcontroller,
                      decoration: InputDecoration.collapsed(
                          hintText: "Type Task Here "),
                    ),
                    trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            todotasks.add(createtaskcontroller.text + ", 0");
                            marklist.add(false);
                            createtaskcontroller.clear();
                            save();
                          });
                        },
                        icon: Icon(Icons.send)),
                  ),
                )),
            Expanded(
              child: ListView.builder(
                itemCount: todotasks.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(todotasks[index].split(', ')[0]),
                      leading: Checkbox(
                        value: marklist[index],
                        onChanged: (value) {
                          setState(() {
                            marklist[index] = value!;
                            String task = todotasks[index];
                            String markvalue = (value == true) ? "1" : "0";
                            todotasks[index] =
                                task.replaceFirst(RegExp(r'0|1'), markvalue);
                            save();
                          });
                        },
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            todotasks.removeAt(index);
                            marklist.removeAt(index);
                            save();
                          });
                        },
                        icon: Icon(Icons.delete),
                      ),
                    ),
                  );
                },
              ),
            )
          ]),
        ),
      ),
    );
  }
}

// Import MaterialApp and other widgets which we can use to quickly create a material app
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Code written in Dart starts exectuting from the main function. runApp is part of
// Flutter, and requires the component which will be our app's container. In Flutter,
// every component is known as a "widget".
void main() => runApp(new TodoApp());

// Every component in Flutter is a widget, even the whole app itself
class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Lista della spesa',
        home: new TodoList()
    );
  }

}

class TodoList extends StatefulWidget {
  @override
  createState() => new TodoListState();
}

class TodoListState extends State<TodoList> {
  List<String> _todoItems = [];

  @override
  void initState() {
    _leggiLista();
    super.initState();
  }

  void _addTodoItem(String task) {
    // Only add the task if the user actually entered something
    if(task.length > 0) {
      // Putting our code inside "setState" tells the app that our state has changed, and
      // it will automatically re-render the list
      setState(() => _todoItems.add(task));
      _salvaLista();
    }
  }

  void _removeTodoItem(int index) {
    // setState(() => _todoItems.removeAt(index));
    String valore = _todoItems.elementAt(index);
    setState(() => _todoItems.removeAt(index));
    setState(() => _todoItems.add("OK - "+valore));
    _salvaLista();
  }

  void _clearLista() {
    setState(() => _todoItems.clear());
    _cancellaSalvataggioLista();
  }

  void _promptRemoveTodoItem(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              title: new Text('Hai preso "${_todoItems[index]}"?'),
              actions: <Widget>[
                new FlatButton(
                    child: new Text('NO'),
                    // The alert is actually part of the navigation stack, so to close it, we
                    // need to pop it.
                    onPressed: () => Navigator.of(context).pop()
                ),
                new FlatButton(
                    child: new Text('PRESO'),
                    onPressed: () {
                      _removeTodoItem(index);
                      Navigator.of(context).pop();
                    }
                )
              ]
          );
        }
    );
  }

  void _promptClearLista() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              title: new Text('Nuova lista?'),
              actions: <Widget>[
                new FlatButton(
                    child: new Text('NO'),
                    // The alert is actually part of the navigation stack, so to close it, we
                    // need to pop it.
                    onPressed: () => Navigator.of(context).pop()
                ),
                new FlatButton(
                    child: new Text('SI'),
                    onPressed: () {
                      _clearLista();
                      Navigator.of(context).pop();
                    }
                )
              ]
          );
        }
    );
  }

  // Build the whole list of todo items
  Widget _buildTodoList() {
    return new ListView.builder(
      itemBuilder: (context, index) {
        // itemBuilder will be automatically be called as many times as it takes for the
        // list to fill up its available space, which is most likely more than the
        // number of todo items we have. So, we need to check the index is OK.
        if(index < _todoItems.length) {
          return _buildTodoItem(_todoItems[index], index);
        }
        return null;
      }
    );
  }

  // Build a single todo item
  Widget _buildTodoItem(String todoText, int index) {
    return new ListTile(
        title: new Text(todoText, style: TextStyle(fontSize: 50.0)),

        onLongPress: (){
          if(!_todoItems[index].startsWith("OK")){
            _promptRemoveTodoItem(index);
            _salvaLista();
          }
        },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text('Lista della spesa')
      ),
      body: _buildTodoList(),
        floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                child: Icon(
                    Icons.add
                ),
                onPressed: () {
                  _pushAddTodoScreen();
                },
                heroTag: null,
              ),
              SizedBox(
                height: 40,
              ),
              FloatingActionButton(
                child: Icon(
                    Icons.delete
                ),
                onPressed: () {
                  _promptClearLista();
                },
                heroTag: null,
              )
            ]
        )
    );
  }

  _cancellaSalvataggioLista() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('lista_della_spesa');
  }

  _leggiLista() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _todoItems = prefs.getStringList('lista_della_spesa') ?? []);
  }

  _salvaLista() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList("lista_della_spesa", _todoItems);
  }

  void _pushAddTodoScreen() {
    // Push this page onto the stack
    Navigator.of(context).push(
      // MaterialPageRoute will automatically animate the screen entry, as well as adding
      // a back button to close it
        new MaterialPageRoute(
            builder: (context) {
              return new Scaffold(
                  appBar: new AppBar(
                      title: new Text('Aggiungi elemento')
                  ),
                  body: new TextField(
                    autofocus: true,
                    onSubmitted: (val) {
                      _addTodoItem(val);
                      Navigator.pop(context); // Close the add todo screen
                    },
                    decoration: new InputDecoration(
                        hintText: 'Descrizione...',
                        contentPadding: const EdgeInsets.all(16.0)
                    ),
                  )
              );
            }
        )
    );
  }
}
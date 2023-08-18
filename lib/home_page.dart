import 'package:flutter/material.dart';
import 'package:sqf_lite/sqlhelper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _datas = [];
  bool _isLoading = true;

  void _refreshdata() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _datas = data;
      _isLoading = false;
    });
  }

  void initStata() {
    super.initState();
    _refreshdata();
  }

  final TextEditingController _titlecontroller = TextEditingController();
  final TextEditingController _descriptioncontroller = TextEditingController();

  void _showForm(int? id) async {
    if (id != null) {
      final existingData = _datas.firstWhere((element) => element['id'] == id);
      _titlecontroller.text = existingData['title'];
      _descriptioncontroller.text = existingData['description'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                  top: 15,
                  left: 15,
                  right: 15,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 120),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _titlecontroller,
                    decoration: const InputDecoration(hintText: 'Title',border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))
                    )),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _descriptioncontroller,
                    decoration: const InputDecoration(hintText: 'Description',border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (id == null) {
                          await _addItem();
                        }
                        if (id != null) {
                          await _updateItem(id);
                        }
                        _titlecontroller.text = '';
                        _descriptioncontroller.text = '';
                        Navigator.of(context).pop();
                      },
                      child: Text(id == null ? 'Create New' : 'Update'))
                ],
              ),
            ));
  }

  Future<void> _addItem() async {
    await SQLHelper.createItem(
        _titlecontroller.text, _descriptioncontroller.text);
    _refreshdata();
  }

  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id, _titlecontroller.text, _descriptioncontroller.text);
    _refreshdata();
  }

  Future<void> _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Sucessfully deleted a journal'),
    ));
    _refreshdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('sqlHelper'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _datas.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.orange,
                  margin: const EdgeInsets.all(15),
                  child: ListTile(
                    title: Text(_datas[index]['title']),
                    subtitle: Text(_datas[index]['description']),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () => _showForm(_datas[index]['id']),
                              icon: const Icon(Icons.edit)),
                          IconButton(
                              onPressed: () => _deleteItem(_datas[index]['id']),
                              icon: const Icon(Icons.delete))
                        ],
                      ),
                    ),
                  ),
                );
              }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}

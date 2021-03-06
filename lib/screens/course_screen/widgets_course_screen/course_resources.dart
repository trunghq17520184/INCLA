import 'package:document/models/course.dart';
import 'package:document/models/resource.dart';
import 'package:document/models/user.dart';
import 'package:document/screens/shared_widgets/confirm_dialog.dart';
import 'package:document/services/collection_firestore.dart';
import 'package:document/services/firestore_helper.dart';
import 'package:document/utils/WebViewContainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class CourseResources extends StatefulWidget {
  CourseResources();

  @override
  _CourseResourcesState createState() => _CourseResourcesState();
}

class _CourseResourcesState extends State<CourseResources> {
  Stream<List<Resource>> resourceStream;
  Course course;

  void initState() {
    course = Provider.of<Course>(context, listen: false);
    resourceStream =
        Collection<Resource>(path: 'course/${course.courseID}/resource')
            .streamData();
    super.initState();
  }

  showAddResourceDialog(BuildContext context, Course course) async {
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          TextEditingController _nameEditingController =
              TextEditingController();
          TextEditingController _linkEditingController =
              TextEditingController();
          return AlertDialog(
            content: Column(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _nameEditingController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Thông tin tài liệu',
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _linkEditingController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Link tài liệu (PDF)',
                    ),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                  child: const Text('Hủy'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              FlatButton(
                  child: const Text('Lưu'),
                  onPressed: () {
                    FireStoreHelper().createResource(
                        course,
                        _nameEditingController.text,
                        _linkEditingController.text);
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }

  showEditResourceDialog(BuildContext context, Course course, String name,
      String link, String resourceID) async {
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          TextEditingController _nameEditingController =
              TextEditingController(text: name);
          TextEditingController _linkEditingController =
              TextEditingController(text: link);
          return AlertDialog(
            content: Column(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _nameEditingController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Thông tin tài liệu',
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _linkEditingController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Link tài liệu (PDF)',
                    ),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                  child: const Text('Hủy'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              FlatButton(
                  child: const Text('Cập nhật'),
                  onPressed: () {
                    FireStoreHelper().updateResource(
                        course,
                        _nameEditingController.text,
                        _linkEditingController.text,
                        resourceID);
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    Course course = Provider.of<Course>(context);
    User user = Provider.of<User>(context, listen: false);
    return StreamBuilder<List<Resource>>(
      stream: resourceStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final SlidableController slidableController = SlidableController();
          snapshot.data.sort((a, b) => a.time.compareTo(b.time));
          return Scaffold(
              floatingActionButton: user.type == UserType.Teacher
                  ? FloatingActionButton.extended(
                      onPressed: () {
                        showAddResourceDialog(context, course);
                      },
                      label: Text('Tài liệu'),
                      icon: Icon(Icons.add),
                    )
                  : null,
              body: ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) => Card(
                  child: Slidable(
                    key: Key(snapshot.data[index].uid),
                    controller: slidableController,
                    closeOnScroll: true,
                    actionExtentRatio: 0.13,
                    actionPane: SlidableDrawerActionPane(),
                    child: ListTile(
                        leading: Icon(Icons.insert_drive_file),
                        title: Text(snapshot.data[index].name),
                        onTap: () =>
                            //View document
                            _handleURLView(context, snapshot.data[index].link)),
                    actions: user.type == UserType.Teacher
                        ? <Widget>[
                            IconSlideAction(
                                icon: Icons.delete_outline,
                                onTap: () {
                                  confirmDialog(
                                      context, 'Xác nhận xóa tài liệu', () {
                                    FireStoreHelper().deleteResource(
                                        course, snapshot.data[index].uid);
                                  });
                                }),
                            IconSlideAction(
                              icon: Icons.edit,
                              onTap: () {
                                showEditResourceDialog(
                                  context,
                                  course,
                                  snapshot.data[index].name,
                                  snapshot.data[index].link,
                                  snapshot.data[index].uid,
                                );
                              },
                            ),
                          ]
                        : null,
                  ),
                ),
              ));
        } else
          return Center(child: CircularProgressIndicator());
      },
    );
  }

  void _handleURLView(BuildContext context, String url) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => WebViewContainer(url)));
  }
}

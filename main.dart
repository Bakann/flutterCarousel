import 'dart:async';
import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:firebase/firestore.dart' as fs;

void main() {
  fb.initializeApp(
      apiKey: "AIzaSyDlgPhKyTsSqcpHolH0SeewQ_TDXlHqOHc",
      authDomain: "signin-736b4.firebaseapp.com",
      databaseURL: "https://signin-736b4.firebaseio.com",
      projectId: "signin-736b4",
      storageBucket: "signin-736b4.appspot.com",
      messagingSenderId: "417536075109",
      appId: "1:417536075109:web:888c24a71f1257d6fe6d8c",
      measurementId: "G-RYGSHTBJJ1");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Bakann Shopping'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ScrollController _controller;
  ScrollPhysics _physics;
  double _currentPage = 1;

  // In your screen (stateful) widget

// Before your build method, create an UploadTask instance
  fb.UploadTask _uploadTask;

  /// Upload file to firebase storage and updates [_uploadTask] to the latest
  /// file upload
  uploadToFirebase(File imageFile) async {
    final filePath = 'images/${DateTime.now()}.png';
    setState(() {
      _uploadTask = fb
          .storage()
          .refFromURL('gs://signin-736b4.appspot.com')
          .child(filePath)
          .put(imageFile);


    });
    Uri downloadUrl = await (await _uploadTask.future).ref.getDownloadURL();
    debugPrint("toto : "+downloadUrl.toString());
  }

  /// A "select file/folder" window will appear. User will have to choose a file.
  /// This file will be then read, and uploaded to firebase storage;
  uploadImage() async {
    // HTML input element
    InputElement uploadInput = FileUploadInputElement();
    uploadInput.click();

    uploadInput.onChange.listen(
      (changeEvent) {
        final file = uploadInput.files.first;
        final reader = FileReader();
        // The FileReader object lets web applications asynchronously read the
        // contents of files (or raw data buffers) stored on the user's computer,
        // using File or Blob objects to specify the file or data to read.
        // Source: https://developer.mozilla.org/en-US/docs/Web/API/FileReader

        reader.readAsDataUrl(file);
        // The readAsDataURL method is used to read the contents of the specified Blob or File.
        //  When the read operation is finished, the readyState becomes DONE, and the loadend is
        // triggered. At that time, the result attribute contains the data as a data: URL representing
        // the file's data as a base64 encoded string.
        // Source: https://developer.mozilla.org/en-US/docs/Web/API/FileReader/readAsDataURL

        reader.onLoadEnd.listen(
          // After file finiesh reading and loading, it will be uploaded to firebase storage
          (loadEndEvent) async {
            uploadToFirebase(file);
          },
        );
      },
    );
  }

  @override
  void initState() {
    _controller = ScrollController();
    super.initState();

    Timer.periodic(Duration(seconds: 6), (Timer timer) {
      var unit = _controller.position.maxScrollExtent / 3;

      _currentPage = (_controller.offset + unit) / unit;

      if (_currentPage < 4) {
        _controller.animateTo(
          _currentPage * _controller.position.maxScrollExtent / 3,
          duration: Duration(milliseconds: 700),
          curve: Curves.easeIn,
        );
        setState(() {
          _currentPage++;
        });
      } else {
        setState(() {
          _currentPage = 1;
        });
        _controller.animateTo(
          0,
          duration: Duration(milliseconds: 700),
          curve: Curves.easeIn,
        );
      }
    });
  }

  bool onNotification(ScrollNotification scrollNotification) {
    if (scrollNotification is UserScrollNotification) {
      var unit = _controller.position.maxScrollExtent / 3;
      setState(() {
        _currentPage = (_controller.offset + unit) / unit;
      });
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    var listener = () {
      if (_controller.position.haveDimensions && _physics == null) {
        setState(() {
          _physics = CustomScrollPhysics(
              itemDimension: _controller.position.maxScrollExtent / 3);
        });
      }
    };

    _controller.addListener(listener);

    return Scaffold(
      appBar: AppBar(
        title: Container(
          alignment: Alignment.center,
          color: Colors.white,
          child: TextField(
            decoration: InputDecoration(
                icon: Icon(Icons.search),
                hintText: "Size ${media.width} * ${media.height}"),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Flexible(
              flex: 1,
              child: Container(
                  margin: EdgeInsets.symmetric(vertical: 0),
                  height: media.height / 2,
                  child: Stack(
                    children: [
                      NotificationListener<ScrollNotification>(
                          onNotification: onNotification,
                          child: ListView.builder(
                            physics: _physics,
                            controller: _controller,
                            scrollDirection: Axis.horizontal,
                            itemCount: 4,
                            itemBuilder: (context, index) => Stack(
                              children: <Widget>[
                                Container(
                                  width: media.width,
                                  decoration: BoxDecoration(
                                    color: const Color(0xff7c94b6),
                                    image: const DecorationImage(
                                      image: NetworkImage(
                                          'https://images-na.ssl-images-amazon.com/images/I/714fnZBj1IL._AC_UX679_.jpg'),
                                      fit: BoxFit.cover,
                                    ),
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 0,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: new FloatingActionButton(
                                      child:
                                          const Icon(Icons.add_shopping_cart),
                                      backgroundColor: Colors.green.shade800,
                                      onPressed: () => uploadImage(),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )),
                      new Positioned(
                        bottom: 0.0,
                        left: 25.0,
                        right: 25.0,
                        top: 375.0,
                        child: new Container(
                          color: Colors.grey[800].withOpacity(1.0),
                          padding: const EdgeInsets.all(20.0),
                          child: Center(
                            child: DotsIndicator(
                                numberOfDots: 4, currentPage: _currentPage),
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
            StreamBuilder<fb.UploadTaskSnapshot>(
                stream: _uploadTask?.onStateChanged,
                builder: (context, snapshot) {
                  final event = snapshot?.data;
                  double progressPercent = event != null
                      ? event.bytesTransferred / event.totalBytes * 100
                      : 0;

                  debugPrint(progressPercent.toString());

                  if (progressPercent == 100) {
                    return Text('Successfully uploaded file 🎊');
                  } else if (progressPercent == 0) {
                    return SizedBox();
                  } else {
                    return LinearProgressIndicator(
                      value: progressPercent,
                    );
                  }
                }),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: <Widget>[
          new SizedBox(
            height: 80.0,
            child: DrawerHeader(
              child: Text('Bakann Shopping',
                  style: TextStyle(
                    fontSize: 20,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 6
                      ..color = Colors.blue[700],
                  )),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
            ),
          ),
          ListTile(
            title: Text('Accueil'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Rayons'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
        ]),
      ),

      floatingActionButton: FloatingActionButton(
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class DotsIndicator extends StatelessWidget {
  final int numberOfDots;
  final double currentPage;

  DotsIndicator({this.numberOfDots, this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: buildDots(),
      ),
    );
    throw UnimplementedError();
  }

  Widget _inactiveDot() {
    return new Container(
        child: new Padding(
      padding: const EdgeInsets.only(left: 3.0, right: 3.0),
      child: Container(
        height: 8.0,
        width: 8.0,
        decoration: BoxDecoration(
            color: Colors.grey, borderRadius: BorderRadius.circular(4.0)),
      ),
    ));
  }

  Widget _activeDot() {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(left: 3.0, right: 3.0),
        child: Container(
          height: 10.0,
          width: 10.0,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey, spreadRadius: 0.0, blurRadius: 2.0)
              ]),
        ),
      ),
    );
  }

  List<Widget> buildDots() {
    List<Widget> dots = [];
    for (int i = 1; i <= numberOfDots; i++) {
      dots.add(
          i == currentPage.floorToDouble() ? _activeDot() : _inactiveDot());
    }
    return dots;
  }
}

class CustomScrollPhysics extends ScrollPhysics {
  final double itemDimension;

  CustomScrollPhysics({this.itemDimension, ScrollPhysics parent})
      : super(parent: parent);

  @override
  CustomScrollPhysics applyTo(ScrollPhysics ancestor) {
    return CustomScrollPhysics(
        itemDimension: itemDimension, parent: buildParent(ancestor));
  }

  double _getPage(ScrollPosition position) {
    return position.pixels / itemDimension;
  }

  double _getPixels(double page) {
    return page * itemDimension;
  }

  double _getTargetPixels(
      ScrollPosition position, Tolerance tolerance, double velocity) {
    double page = _getPage(position);
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    return _getPixels(page.roundToDouble());
  }

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // If we're out of range and not headed back in range, defer to the parent
    // ballistics, which should put us back in range at a page boundary.
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent))
      return super.createBallisticSimulation(position, velocity);
    final Tolerance tolerance = this.tolerance;
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels)
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}

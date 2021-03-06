import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:med_alarm/models/user.dart';
import 'package:med_alarm/utilities/user_provider.dart';
import 'package:med_alarm/utilities/firebase_provider.dart';
import 'package:med_alarm/custom_widgets/custom_widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as Auth;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:med_alarm/screens/user_profile/user_profile.dart';

class ChatRoom extends StatefulWidget {
  static const String id = 'CHAT_ROOM';
  final Auth.FirebaseAuth auth = FirebaseProvider.instance.auth;
  final User currentUser = UserProvider.instance.currentUser;
  final User otherUser;

  ChatRoom({Key key, this.otherUser})
      : super(key: key);

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final FirebaseProvider fbPro = FirebaseProvider.instance;
  String name = '';
  String messagesPath;
  File image;

  MessageBox msgBox = MessageBox();
  ScrollController scrollController = ScrollController();

  Future<void> sendMessage({String url}) async {
    String msg = '';
    String type = '';
    if (msgBox.messagesController.text.length > 0) {
      msg = msgBox.messagesController.text.trim();
      type = 'text';
    } else
      try {
        if (url != null && url.isNotEmpty) {
          msg = url;
          type = 'image';
        }
      } catch (e) {}
    if (msg.isNotEmpty) {
      msgBox.text = '';
      msgBox.messagesController.clear();
      setState(() {
        msgBox.textFieldHeight = 50;
      });

      await fbPro.sendMessage(
        messagesPath,
        widget.currentUser.uid,
        widget.otherUser.uid,
        type,
        msg,
        url
      );

      scrollController.animateTo(scrollController.position.minScrollExtent,
          duration: Duration(milliseconds: 1), curve: Curves.easeOut);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.auth.currentUser.uid.compareTo(widget.otherUser.uid) < 0) {
      messagesPath = widget.auth.currentUser.uid + widget.otherUser.uid;
    } else {
      messagesPath = widget.otherUser.uid + widget.auth.currentUser.uid;
    }
    if(widget.otherUser.type == 'Doctor')
      name = 'Dr/';
    name += widget.otherUser.firstname + ' ' + widget.otherUser.lastname;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        elevation: 5,
        titleSpacing: 0,
        title: InkWell(
          borderRadius: BorderRadius.circular(30.0),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (BuildContext context) {
                return UserProfile(widget.otherUser, false);
              }),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: 'profPic-${widget.otherUser.uid}',
                  child: (widget.otherUser.profPicURL == '') ?
                  Container(
                    child: Icon(
                      Icons.account_circle,
                      color: Colors.white,
                      size: AppBar().preferredSize.height-10,
                    ),
                  ) :
                  Container(
                    padding: EdgeInsets.all(3),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        widget.otherUser.profPicURL,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      widget.otherUser.phoneNumber,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: fbPro.getChat(messagesPath),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if(snapshot.data.docs.isEmpty)
                    return Center();

                  List<DocumentSnapshot> docs = snapshot.data.docs;
                  String prevDate;
                  List<Widget> messages = [];
                  docs.forEach((doc) {
                    if(messages.isNotEmpty)
                      if(prevDate != doc.get('date').toString().substring(0, 10))
                          messages.add(dateExtractor(prevDate));

                    doc.get('type') == 'text'?
                    messages.add(MessageBubble(
                            // from: doc.get('from'),
                            text: doc.get('text'),
                            date: doc.get('date'),
                            type: doc.get('type'),
                            me: widget.currentUser.uid == doc.get('from')
                                ? true
                                : false)):
                    messages.add(MessageBubble(
                            // from: doc.get('from'),
                            url: doc.get('url'),
                            date: doc.get('date'),
                            type: doc.get('type'),
                            me: widget.currentUser.uid == doc.get('from')
                                ? true
                                : false));
                    prevDate = doc.get('date').toString().substring(0, 10);
                  });

                  messages.add(dateExtractor(prevDate));

                  return ListView(
                    controller: scrollController,
                    children: [...messages],
                    reverse: true,
                  );
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 5),
              child: Material(
                color: Colors.white10,
                child: Container(
                  height: msgBox.textFieldHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Center(
                          child: msgBox,
                        ),
                      ),
                      SizedBox(
                        width: 1,
                      ),
                      Container(
                        height: 50,
                        width: 30,
                        child: IconButton(
                          padding: EdgeInsets.all(0),
                          onPressed: chooseImage,
                          icon: Icon(
                            Icons.attach_file,
                            color: Colors.grey,
                            size: 30,
                          ),
                          // shape: RoundedRectangleBorder(
                          //   borderRadius: BorderRadius.circular(10),
                          // ),
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 50,
                        child: FlatButton(
                          padding: EdgeInsets.all(0),
                          onPressed: sendMessage,
                          child: Icon(
                            Icons.send,
                            color: Theme.of(context).accentColor,
                            size: 30,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget dateExtractor(date) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,

        // mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Divider(
              color: Colors.grey,
              height: 1,
            ),
          ),
          Container(
            margin: EdgeInsets.all(10),
            child: Text(
              date,
              style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: Colors.grey,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  void chooseImage() async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);

    if (image == null) return;
    File file = File(image.path);

    sendMessage(url: await fbPro.uploadImage(messagesPath, file));
  }
}

class MessageBubble extends StatelessWidget {
  // final String from;
  final String text;
  final String url;
  final String type;
  final String date;
  final bool me;


  MessageBubble({
    this.text,
    this.url,
    this.type,
    this.date,
    this.me
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Column(
        crossAxisAlignment:
            me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Material(
            color: me ? Theme.of(context).accentColor : Colors.grey,
            borderRadius: BorderRadius.circular(20),
            // elevation: 6,
            child: type == 'text'
                ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                        padding: EdgeInsets.fromLTRB(10, 7, 10, 3),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 3 / 5,
                          ),
                          child: Text(
                            text,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(13, 0, 13, 5),
                          child: Text(
                            timeExtractor(date),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
                : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                        padding: EdgeInsets.fromLTRB(10, 7, 10, 3),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height,
                            maxWidth: MediaQuery.of(context).size.width * 3 / 5,
                            // minHeight: 25.0,
                            // minWidth: 25.0,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ImageViewer(url),
                                  ));
                            },
                            child: Image.network(
                              url,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(13, 0, 13, 5),
                          child: Text(
                            timeExtractor(date),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),),
                        ),
                      ],
                    ),
                  ],
                ),
          ),
        ],
      ),
    );
  }

  String timeExtractor(String str) {
    return str.substring(11, 16);
  }
}

class ImageViewer extends StatelessWidget {
  final String url;

  ImageViewer(this.url);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
      ),
      child: Image.network(
        url,
      ),
    );
  }
}

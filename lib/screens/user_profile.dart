import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/screens/suggestions.dart';
import 'package:hello_me/user_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:snapping_sheet/snapping_sheet.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final _email = CurrentUser.instance().user!.email;
  String? _profilePictureURL;

  final noFilePickedSnackBar = const SnackBar(
      content: Text('No image selected')
  );

  @override
  initState() {
    super.initState();
    getProfilePicture();
  }

  @override
  Widget build(BuildContext context) {
    //getProfilePicture();
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey,
                backgroundImage: _profilePictureURL == null ? null : NetworkImage(_profilePictureURL!),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _email!,
                    style: const TextStyle(
                        fontSize: 20
                    ),
                  ),
                  TextButton(
                    onPressed: () async{
                      FilePickerResult? pickerResult = await FilePicker.platform.pickFiles();
                      if (pickerResult != null) {
                        final picture = File(pickerResult.files.single.path!);
                        final fileName = pickerResult.files.single.name;
                        UploadTask pictureUpload = FirebaseStorage.instance.ref().child('profilePictures/${_email!}/$fileName').putFile(picture);
                        String url = await (await pictureUpload).ref.getDownloadURL();
                        await FirebaseFirestore.instance.collection('usersData').doc(_email).set({"picture": url}, SetOptions(merge: true));
                        setState(() {
                          _profilePictureURL = url;
                        });
                      }
                      else {
                        ScaffoldMessenger.of(context).showSnackBar(noFilePickedSnackBar);
                      }
                    },
                    child: Text(
                      'Change avatar',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      )
    );
  }

  Future getProfilePicture() async{
    await FirebaseFirestore.instance.collection('usersData').doc(_email).get().then((snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data();
        if (data != null) {
          setState(() {
            _profilePictureURL = data['picture'];
          });
        }
      }
    });
  }
}
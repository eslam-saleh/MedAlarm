import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as Auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:med_alarm/models/doctor.dart';
import 'package:med_alarm/models/medicine2.dart';
import 'package:med_alarm/models/patient.dart';
import 'package:med_alarm/models/sign_up_model.dart';
import 'package:med_alarm/models/user.dart';
import 'package:med_alarm/providers/user_provider.dart';
import 'package:med_alarm/utilities/sql_helper.dart';

class FirebaseProvider with ChangeNotifier {
  FirebaseProvider._privateConstructor();
  static final FirebaseProvider instance = FirebaseProvider._privateConstructor();

  final Auth.FirebaseAuth auth = Auth.FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Stream getLatestMsgStream(String msgPath) {
    return firestore
        .collection('Messages/$msgPath/$msgPath')
        .orderBy('date', descending: true)
        .limit(1)
        .snapshots();

  }

  Future getLatestMsg(String msgPath) {
    return firestore
        .collection('Messages/$msgPath/$msgPath')
        .orderBy('date', descending: true)
        .limit(1)
        .get();
  }

  Stream getChat(String msgPath) {
    return firestore
        .collection('Messages/$msgPath/$msgPath')
        .orderBy('date', descending: true)
        .snapshots();
  }

  deleteContact(String uid1, String uid2) async {
    await firestore
        .collection(
        'Users/$uid1/Contacts')
        .doc(uid2)
        .delete();
    await firestore
        .collection('Users/$uid2/Contacts')
        .doc(uid1)
        .delete();
  }

  addContact(String uid1, String uid2) async {
    await firestore
        .collection('Users/$uid1/Contacts')
        .doc(uid2)
        .set({
      'uid': uid2,
    });
    await firestore
        .collection('Users/$uid2/Contacts')
        .doc(uid1)
        .set({
      'uid': uid1,
    });
  }

  Future searchEmailExcept(String email, String excEmail) {
    return firestore
        .collection('Users')
        .where('email', isEqualTo: email)
        .where('email', isNotEqualTo: excEmail)
        .get();
  }

  Stream getContactFromUser(String userUid, String uid) {
    return firestore
        .collection('Users/$userUid/Contacts')
        .doc(uid)
        .snapshots();
  }

  Stream getContactsStream(String userUid) {
    return firestore.collection("Users/$userUid/Contacts").snapshots();
  }

  Future getContacts() {
    return firestore.collection("Users/${auth.currentUser.uid}/Contacts").get();
  }

  sendMessage(
      String msgPath,
      String from,
      String to,
      String type,
      String msg,
      String url,
  ) async {
    type == 'text'?
    await firestore.collection('Messages/$msgPath/$msgPath').add({
      'from': from,
      'to': to,
      'type': type,
      'text': msg,
      'date': DateTime.now().toIso8601String().toString()
    }):
    await firestore.collection('Messages/$msgPath/$msgPath').add({
      'from': from,
      'to': to,
      'type': type,
      'url': url,
      'date': DateTime.now().toIso8601String().toString()
    });
  }

  insertUserFromSUModel(String uid, SignUpModel model) async {
    await insertUser(
      uid,
      model.email.trim(),
      model.type.trim(),
      model.firstname.trim(),
      model.lastname.trim(),
      model.phoneNumber.trim(),
      model.address.trim(),
      model.dob,
      speciality: model.speciality,
    );
  }

  insertUser(
      String uid,
      String email,
      String type,
      String firstname,
      String lastname,
      String phoneNumber,
      String address,
      DateTime date,
  {String speciality}
  ) async {
    if(type == 'Patient')
      await firestore
          .collection('Users')
          .doc(uid)
          .set({
        'email': email,
        'type': type,
        'firstname': firstname,
        'lastname': lastname,
        'profPicURL': '',
        'phoneNumber': phoneNumber,
        'address': address,
        'dob': Timestamp.fromDate(date),
      });
    else if(type == 'Doctor')
      await firestore
          .collection('Users')
          .doc(uid)
          .set({
        'email': email,
        'type': type,
        'speciality': speciality,
        'firstname': firstname,
        'lastname': lastname,
        'profPicURL': '',
        'phoneNumber': phoneNumber,
        'address': address,
        'dob': Timestamp.fromDate(date),
      });
    initNewUserContacts(uid);
  }

  Future<bool> updateUser(User user) async {
    try {
      if (user.type == 'Patient')
        await firestore
            .collection('Users')
            .doc(user.uid)
            .update({
          'firstname': user.firstname,
          'lastname': user.lastname,
          'profPicURL': user.profPicURL,
          'phoneNumber': user.phoneNumber,
          'address': user.address,
          'dob': user.dob,
        });
      else if (user.type == 'Doctor')
        await firestore
            .collection('Users')
            .doc(user.uid)
            .update({
          'speciality': (user as Doctor).speciality,
          'firstname': user.firstname,
          'lastname': user.lastname,
          'profPicURL': user.profPicURL,
          'phoneNumber': user.phoneNumber,
          'address': user.address,
          'dob': user.dob,
        });
      return true;
    } catch (e) {return false;}
  }

  Future getUser(String userUid) async {
    return await firestore.collection('Users').doc(userUid).get();
  }

  Future getDoctor(String userUid) async {
    var doc = await firestore.collection('Users').doc(userUid).get();
    return doc.get('type') == 'Doctor' ? doc : null;
  }

  initNewUserContacts(String uid) async {
    await firestore
        .collection('Users')
        .doc(uid)
        .collection('Contacts')
        .doc('_init')
        .set({});
  }

  Future<String> uploadImage(messagesPath, image) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instanceFor(
        bucket: 'gs://medalarm-fcai2021.appspot.com',
      );
      Reference ref =
      storage.ref('media/$messagesPath/${DateTime.now()}');
      UploadTask storageUploadTask = ref.putFile(image);
      TaskSnapshot storageTaskSnapshot =
      await storageUploadTask.whenComplete(() => null);
      String url = await storageTaskSnapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      return '';
    }
  }

  Future<String> uploadProfPic(image) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instanceFor(
        bucket: 'gs://medalarm-fcai2021.appspot.com',
      );

      Reference ref =
      storage.ref('profPic/${auth.currentUser.uid}');
      UploadTask storageUploadTask = ref.putFile(image);
      TaskSnapshot storageTaskSnapshot =
      await storageUploadTask.whenComplete(() => null);
      String url = await storageTaskSnapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      return '';
    }
  }

  uploadMedicinesMerge() async {
    try {

    } catch (e) {

    }
  }

  uploadMedicinesReplace() async {
    try {
      List<Medicine> medicines = await SQLHelper.getInstant().getAllMedicines();
      if(medicines.isNotEmpty) {
        await firestore.collection('Medicines')
            .doc(auth.currentUser.uid).delete();
        for(var med in medicines) {
          await firestore.collection('Medicines/${auth.currentUser.uid}/Medicines')
              .doc(med.medName)
              .set(med.toMap());
        }
      }
    } catch (e) {

    }
  }

  getMedicines() async {
    try {

    } catch (e) {

    }
  }

  logout() async {
    try{
      if(!await SQLHelper.getInstant().deleteUser()) throw '';
      await removeDeviceToken();
      auth.signOut();
    } catch(e) {
      print(e);
    }
  }

  getLoggedUserInfo() async {
    try {
      var value = await firestore
          .collection("Users")
          .doc(auth.currentUser.uid)
          .get();
      if (value.get('type') == 'Patient')
        UserProvider.instance.currentUser =
            Patient.fromDoc(auth.currentUser.uid, value);
      else if (value.get('type') == 'Doctor')
        UserProvider.instance.currentUser =
            Doctor.fromDoc(auth.currentUser.uid, value);
    } catch (e) {
      throw 'Can\'t get user data';
    }
  }

  Future<String> getDeviceToken() async {
    return await firebaseMessaging.getToken();
  }

  registerDeviceToken() async {
    try {
      String token = await getDeviceToken();
      await firestore
          .collection('Users/${auth.currentUser.uid}/Tokens')
          .doc('$token')
          .set({'token': token});
    } catch (e) {
      throw 'Can\'t register device token';
    }
  }

  Future<void> removeDeviceToken() async {
    String token = await getDeviceToken();
    await firestore
        .collection('Users/${auth.currentUser.uid}/Tokens')
        .doc('$token')
        .delete();
  }
}
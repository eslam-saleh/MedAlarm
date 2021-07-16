import 'package:med_alarm/models/user.dart';

class Doctor extends User {
  String speciality;

  Doctor({
    firstname,
    lastname,
    email,
    uid,
    profPicURL,
    address,
    type,
    phoneNumber,
    dob,
    this.speciality
  }) : super(
    firstname: firstname,
    lastname: lastname,
    email: email,
    uid: uid,
    profPicURL: profPicURL,
    address: address,
    type: type,
    phoneNumber: phoneNumber,
    dob: dob,
  );

  Doctor.fromDoc(uid, doc) {
    this.uid = uid;
    email = doc.get('email');
    type = doc.get('type');
    firstname = doc.get('firstname');
    lastname = doc.get('lastname');
    profPicURL = doc.get('profPicURL');
    phoneNumber = doc.get('phoneNumber');
    address = doc.get('address');
    dob = doc.get('dob');
    speciality = doc.get('speciality');
    print('+++++++++++++++++++ From User Constructor +++++++++++++++++++');
    print(uid);
    print(email);
    print(type);
    print(speciality);
    print(firstname);
    print(lastname);
    print(profPicURL);
    print(phoneNumber);
    print(address);
    print(dob);
    print('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
  }
}
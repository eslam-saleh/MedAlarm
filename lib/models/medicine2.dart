import 'dose.dart';

class Medicine {
  String medName;
  String medType;
  DateTime startDate;
  DateTime endDate;
  int amountOfMed;
  String interval;
  int intervalTime;
  DateTime startTime;
  int numOfDoses;
  List<Dose> doses;

  Medicine({
    this.medName,
    this.medType,
    this.startDate,
    this.endDate,
    this.amountOfMed,
    this.startTime,
    this.interval,
    this.numOfDoses,
    this.doses,
    this.intervalTime,
  });

  // String get getName => medicineName;
  // int get getDosage => dosage;
  // String get getType => medicineType;
  // int get getInterval => interval;
  // String get getStartTime => startTime;
  // List<dynamic> get getIDs => notificationIDs;

  Map<String, dynamic> toMap() {
    return {
      "name": this.medName,
      "type": this.medType,
      "start": this.startDate,
      "end": this.endDate,
      "amount": this.amountOfMed,
      "numOfDoses": this.numOfDoses,
      "doses": this.doses,
      "startTime" : this.startTime,
      "interval" : this.interval,
      "intervalTime" : this.intervalTime,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> parsedJson) {
    return Medicine(
      medName: parsedJson['name'],
      medType: parsedJson['type'],
      startDate: parsedJson['start'],
      endDate: parsedJson['end'],
      amountOfMed: parsedJson['amount'],
      numOfDoses: parsedJson['numOfDoses'],
      doses: parsedJson['doses'],
      interval: parsedJson['interval'],
      startTime : parsedJson['startTime'],
      intervalTime : parsedJson['intervalTime'],
    );
  }
}
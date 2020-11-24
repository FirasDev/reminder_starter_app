class AlarmInfo {
  int id;
  String title;
  String occurence;
  DateTime alarmDateTime;
  int isEnabled;
  int gradientColorIndex;

  AlarmInfo(
      {this.id,
      this.title,
      this.occurence,
      this.alarmDateTime,
      this.isEnabled,
      this.gradientColorIndex});

  factory AlarmInfo.fromMap(Map<String, dynamic> json) => AlarmInfo(
        id: json["id"],
        title: json["title"],
        occurence: json["occurence"],
        alarmDateTime: DateTime.parse(json["alarmDateTime"]),
        isEnabled: json["isEnabled"],
        gradientColorIndex: json["gradientColorIndex"],
      );
  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "occurence": occurence,
        "alarmDateTime": alarmDateTime.toIso8601String(),
        "isEnabled": isEnabled,
        "gradientColorIndex": gradientColorIndex,
      };
}

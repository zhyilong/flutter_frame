/*
 * Created by zhyilong on 2026/5/22
 */

import 'dart:math';

void main() {
  Map<String, Map<String, Object>> students = {
    "001": {"id": "001", "name": "stu001", "age": 18},
    "002": {"id": "002", "name": "stu002", "age": 19},
    "003": {"id": "003", "name": "stu003", "age": 20},
    "004": {"id": "004", "name": "stu004", "age": 18},
    "005": {"id": "005", "name": "stu005", "age": 19},
  };

  Map<String, Map<String, double>> scores = {
    "001": {"语文": 95.5, "数学": 94.5, "英语": 96.5},
    "002": {"语文": 96.5, "数学": 95.5, "英语": 96.5},
    "003": {"语文": 94.5, "数学": 97.5, "英语": 95.5},
    "004": {"语文": 98.5, "数学": 95.5, "英语": 94.5},
    "005": {"语文": 95.5, "数学": 96.5, "英语": 97.5},
  };

  print("平均分最高的学生：${findAvgMaxStudent(students, scores)}");

  print("英语平均成绩：${scores.values.map((value) => value["英语"]).reduce((a, b) => a! + b!)! / scores.length}");

  print("学号003的成绩：${scores["003"]}");

  print("年龄大于18的学生：${students.values.where(((value) => value["age"] as int > 18))}");

  print("语文成绩都上97吗：${scores.values.every((value) => value["语文"]! > 97) ? "是" : "否"}");
}

String findAvgMaxStudent(Map<String, Map<String, Object>> students, Map<String, Map<String, double>> scores) {
  return students[findAvgMax(scores)]!["id"] as String;
}

String findAvgMax(Map<String, Map<String, double>> socres) {
  double avg = 0;
  double maxAvg = 0;
  String id = "";
  socres.forEach((key, value) {
    avg = max(avg, value.values.reduce((a, b) => a + b) / value.values.length);
    if (maxAvg < avg) {
      id = key;
    }
  });
  return id;
}

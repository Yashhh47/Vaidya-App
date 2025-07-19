import 'package:crypto/crypto.dart';
import 'dart:convert';

String getPatientID(String name, String dob, String bloodGroup) {
  String input =
      "${name.trim().toLowerCase()}|${dob.trim()}|${bloodGroup.trim().toUpperCase()}";
  var bytesOfString = utf8.encode(input);
  var digest = sha1.convert(bytesOfString);
  String pateintCode =
      "SJVK${digest.toString().substring(0, 6).toUpperCase()}";

  return pateintCode;
}

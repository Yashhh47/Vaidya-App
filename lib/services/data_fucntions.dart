import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'dart:convert';

String getPatientID(String name, String dob, String blood_group) {
  String input =
      "${name.trim().toLowerCase()}|${dob.trim()}|${blood_group.trim().toUpperCase()}";
  var bytes_of_string = utf8.encode(input);
  var digest = sha1.convert(bytes_of_string);
  String pateint_code =
      "SJVK" + digest.toString().substring(0, 6).toUpperCase();

  return pateint_code;
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Datacontroller extends GetxController {
  double size = 0;

  var patient_name = ''.obs;
  var patient_dob = ''.obs;
  var patient_age = ''.obs;
  var patient_phonenumber = ''.obs;
  var patient_email = ''.obs;
  var patient_blood_group = ''.obs;
  var patient_ID = ''.obs;
  var getstartedclicked = true.obs;

  void set_patient_name(String name) {
    patient_name.value = name;
  }

  void set_patient_email(String name) {
    patient_email.value = name;
  }

  void gegstartedclickstatechange() {
    getstartedclicked.value = true;
  }

  void sidebarclicked() {
    getstartedclicked.value = false;
  }

  void set_patient_ID(String name) {
    patient_ID.value = name;
  }

  void set_patient_dob(String dob) {
    patient_dob.value = dob;
  }

  void set_patient_age(String age) {
    patient_age.value = age;
  }

  void set_patient_phonenumber(String phonenumber) {
    patient_phonenumber.value = phonenumber;
  }

  void set_patient_blood_group(String blood_group) {
    patient_blood_group.value = blood_group;
  }

  void Setsize(double size) {
    this.size = size;
    update();
  }
}

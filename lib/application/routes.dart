import 'package:flutter/material.dart';
import 'package:flutter_firebase_login/application/app_bloc.dart';
import 'package:flutter_firebase_login/application/home_page.dart';
import 'package:flutter_firebase_login/login/login_page.dart';

List<Page> onGenerateAppViewPages(AppStatus state, List<Page<dynamic>> pages) {
  switch (state) {
    case AppStatus.authenticated:
      return [HomePage.page()];
    case AppStatus.unauthenticated:
    default:
      return [LoginPage.page()];
  }
}

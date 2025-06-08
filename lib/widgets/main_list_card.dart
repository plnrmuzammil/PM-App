import 'package:flutter/material.dart';

class MainListCard extends StatelessWidget {

  final String title;
  final String inv;
  final String createDate;
  final String Amount;
  final Status;
  final String Attachment;
  void Function() onPressed;


  MainListCard({super.key,
    required this.title,
    required this.inv,
    required this.Amount,
    required this.createDate,
    required this.Status, required this.Attachment,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    bool istrue = false;
    final h = MediaQuery
        .of(context)
        .size
        .height;
    final w = MediaQuery
        .of(context)
        .size
        .width;

    return Container();
  }
}

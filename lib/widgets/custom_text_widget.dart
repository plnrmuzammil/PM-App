import 'package:flutter/material.dart';
import 'package:pm_app/constant.dart';

class CustomTextWidget extends StatelessWidget {
  final String? text1;
  final String? text2;
  final String? text3;
  final String? text4;
  final String? text5;
  final String? text6;
  final String? text7;
  final String? text8;
  final String? text9;

  const CustomTextWidget({this.text1, this.text2, this.text3,this.text4,this.text5,this.text6,this.text7,this.text8,this.text9, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: text1,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: GreyColorWriting,
          fontFamily: "Times New Roman",
          fontSize: 17,
        ),
        children: [
          TextSpan(
            text: text2,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.black,
              fontFamily: "Times New Roman",
              fontSize: 16,
            ),
          ),
          TextSpan(
            text: text3,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.blue,
              fontFamily: "Times New Roman",
              fontSize: 18,
            ),
          ),
          TextSpan(
            text: text4,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.green,
              fontFamily: "Times New Roman",
              fontSize: 19,
            ),
          ),
          TextSpan(
            text: text5,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.brown,
              fontFamily: "Times New Roman",
              fontSize: 19,
            ),
          ),
          TextSpan(
            text: text6,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.purple,
              fontFamily: "Times New Roman",
              fontSize: 19,
            ),
          ),
          TextSpan(
            text: text7,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.red,
              fontFamily: "Times New Roman",
              fontSize: 19,
            ),
          ),
          TextSpan(
            text: text8,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.black,
              fontFamily: "Times New Roman",
              fontSize: 20,
            ),
          ),
          TextSpan(
            text: text9,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.black,
              fontFamily: "Times New Roman",
              fontSize: 22,
            ),
          ),

        ],
      ),
    );
  }
}

import "package:flutter/material.dart";
import 'package:reale/stepper_steps/selectProvince.dart';

class addListing extends StatefulWidget {
  const addListing({super.key});

  @override
  _addListingState createState() => _addListingState();
}

class _addListingState extends State<addListing> {

  @override
  Widget build(BuildContext context) {
    return const selectProvince();
  }
}

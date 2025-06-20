import "package:flutter/material.dart";
import "package:pm_app/stepper_steps/selectProvince.dart";

class addListing extends StatefulWidget {
  @override
  _addListingState createState() => _addListingState();
}

class _addListingState extends State<addListing> {

  @override
  Widget build(BuildContext context) {
    return selectProvince();
  }
}

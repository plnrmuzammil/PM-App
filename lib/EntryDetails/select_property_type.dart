import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown/flutter_dropdown.dart';
import 'package:hive/hive.dart';
import 'package:pm_app/EntryDetails/selectTypeDetails.dart';
import 'package:pm_app/EntryDetails/select_property_sub_type.dart';

class SelectPropertyType extends StatefulWidget {
  const SelectPropertyType({Key? key, required this.isScheme, required this.provinceId, required this.districtId, required this.typeId}) : super(key: key);

  final String provinceId;
  final String districtId;
  final String typeId;
  final bool isScheme;

  @override
  _SelectPropertyTypeState createState() => _SelectPropertyTypeState();
}

class _SelectPropertyTypeState extends State<SelectPropertyType> {

  Box box = Hive.box<dynamic>('userData');

  String selectPropertyType = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Entry Details"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),

      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropDown<dynamic>(
              hint: Text("select property type"),
        items: ["Commercial", "Land / Plot", "Residential"],
            onChanged: (val)
        {
          setState((){
            selectPropertyType = val;
          });
        },
      ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MaterialButton(
                  color: Colors.green,
                  onPressed: (){
                    box.delete('propertyType');
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>
                        SelectTypeDetails(
                          provinceId: widget.provinceId ,
                          districtId: widget.districtId,
                          isScheme: widget.isScheme,
                    )));
                  }, child: Text("Back"),),
                MaterialButton(
                  color: Colors.green,
                  onPressed:selectPropertyType == "" ? null : (){
                    box.put('propertyType', selectPropertyType);
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) =>
                                SelectPropertySubType(
                                  propertyType: selectPropertyType,
                                  provinceId: widget.provinceId,
                                  districtId: widget.districtId,
                                  typeId: widget.typeId,
                                  isScheme: widget.isScheme,
                                ),
                        ));
                  },
                  child: Text("Continue"),),

              ],
            ),
          ],
        ),
      ),
    );
  }
}

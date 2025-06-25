import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown/flutter_dropdown.dart';
import 'package:hive/hive.dart';
import 'package:pm_app/EntryDetails/selectProvinceDetails.dart';
import 'package:pm_app/EntryDetails/selectSchemeDetails.dart';
import 'package:pm_app/EntryDetails/selectStepper.dart';

class SelectDistrictDetails extends StatefulWidget {
  const SelectDistrictDetails({Key? key, required this.provinceId, }) : super(key: key);

  final String provinceId;

  @override
  _SelectDistrictDetailsState createState() => _SelectDistrictDetailsState();
}

class _SelectDistrictDetailsState extends State<SelectDistrictDetails> {

  var district = [];
  var districtId = [];
  Box box = Hive.box<dynamic>('userData');

  String selectDistrict = "";
  String selectDistrictId = "";


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
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('districts').orderBy('name', descending: false).snapshots(),
              builder: (BuildContext context, AsyncSnapshot snapshot)
              {
                if(snapshot.hasData)
                {
                  var el = snapshot.data.docs;
                  district = [];
                  districtId = [];
                  for(var e in el)
                  {
                    if(e.data() != null)
                    {
                      if(e.data()['provinceID'] == widget.provinceId)
                      {
                        districtId.add(e.data()['id']);
                        district.add(e.data()['name']);
                      }
                    }
                  }

                  return DropDown<dynamic>(
                    hint: Text('select district'),
                    items: district,
                    onChanged: (val){
                      setState(() {
                        selectDistrict = val;
                        selectDistrictId = districtId[district.indexOf(val)];
                      });
                    },
                  );
                }
                else
                {
                  return CircularProgressIndicator();
                }
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MaterialButton(
                  color: Colors.green,
                  onPressed: (){
                    box.delete('district');
                    box.delete('districtId');
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => StepperForm()));
                  }, child: Text("Back"),),
                MaterialButton(
                  color: Colors.green,
                  onPressed:(selectDistrict == "" && selectDistrictId == "") ? null : (){
                    box.put('district', selectDistrict);
                    box.put('districtId', selectDistrictId);
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SelectSchemeDetails(
                      provinceId: widget.provinceId,
                      districtId: selectDistrictId,
                    )));
                    //Navigator.of(context).push(MaterialPageRoute(builder: (context) => SelectProvinceDetails()));
                  }, child: Text("Continue"),),

              ],
            ),
          ],
        ),
      ),
    );
  }
}

import "dart:developer" as dev;

import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter_dropdown/flutter_dropdown.dart";
import "package:pm_app/main.dart";
import "package:pm_app/stepper_steps/select_scheme_route.dart";
import "package:pm_app/widgets/TextContainer.dart";
import "package:pm_app/widgets/setting_stepper.dart";

import "package:simple_database/simple_database.dart";

var districts = [];
var districtIds = [];
var selectedDistrict = "";
var districtId;

class selectDistrict extends StatefulWidget{

  final province;
  final provinceName;

  selectDistrict({this.province, this.provinceName});

  @override
  _selectDistrictState createState() => _selectDistrictState();
}

class _selectDistrictState extends State<selectDistrict> {
  // bool _isCityDropDownEnable;
  //
  // _selectCityState(): _isCityDropDownEnable = true;

  @override
  void initState() {
    super.initState();
    print('district init()');
  }

  @override
  void dispose() {
    print('district dispose()');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("districts")
              .orderBy("name", descending: false)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              //InformationStepper.refresh(isShowLoader: false);
              var el = snapshot.data.docs;
              districts = [];
              districtIds = [];
              for (var e in el) {
                if (e.data() != null) {
                  if (e.data()["provinceID"] == widget.province) {
                    districts.add(e.data()["name"]);
                    districtIds.add(e.data()["id"]);
                  }
                }
              }
              //print(cities);
              //print(cityIds);
              dev.log(
                  'district outside the onChange: content: $districts \ndistricts id: $districtIds');
              return Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IgnorePointer(
                      ignoring: !stepperStateModel.isDistrictDropDownEnable,
                      child: DropDown<dynamic>(
                        items: districts,
                        // items: houseModel.cityName.length > 0
                        //     ? [houseModel.cityName]
                        //     : cities,
                        initialValue: houseModel.districtName.isNotEmpty
                            ? houseModel.districtName
                            : null,
                        hint: Text("select district"),
                        onChanged: (val) async {
                          dev.log(
                              'district outside the onChange: content: $districts \ndistricts id: $districtIds');
                          var previousStep1 =
                              InformationStepper.allSteps[0]; // for province
                          var previousStep2 =
                              InformationStepper.allSteps[1]; // for district
                          InformationStepper.allSteps.clear();
                          InformationStepper.allSteps = [
                            previousStep1,
                            previousStep2
                          ];

                          SimpleDatabase district = SimpleDatabase(name: 'district');
                          await district.clear();
                          await district.add('${val}');

                          setState(() {
                            selectedDistrict = val.toString();

                            print(selectedDistrict);
                            // districtID is the index of district in district list
                            districtId = districtIds[districts.indexOf(selectedDistrict)];
                            houseModel.districtName = selectedDistrict;
                            houseModel.district = districtId;
                            print(districtId);
                            stepperStateModel.isDistrictDropDownEnable = false;
                          });

                          InformationStepper.refresh(isShowLoader: true);
                          InformationStepper.allSteps.add({
                            'color': Colors.white,
                            'background': Colors.green,
                            'label': '3',
                            'content': Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Select Scheme/ Non-Scheme',
                                  style: TextStyle(fontSize: 18.0),
                                ),
                                // new code
                                SchemeType(
                                  province: widget.province,
                                  provinceName: widget.provinceName,
                                  district: districtId,
                                  districtName: selectedDistrict,
                                ),
                              ],
                            ),
                          });
                          InformationStepper.refresh(isShowLoader: false);
                        },
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return TextContainer();
            }
          }),
    );
  }
}

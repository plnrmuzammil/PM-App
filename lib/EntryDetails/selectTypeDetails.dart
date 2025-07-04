import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown/flutter_dropdown.dart';
import 'package:hive/hive.dart';
import 'package:pm_app/EntryDetails/selectSchemeDetails.dart';
import 'package:pm_app/EntryDetails/select_property_type.dart';

class SelectTypeDetails extends StatefulWidget {
  const SelectTypeDetails({Key? key, required this.provinceId,  required this.districtId, required this.isScheme}) : super(key: key);


  final String provinceId;
  final String districtId;
  final bool isScheme;
  
  @override
  _SelectTypeDetailsState createState() => _SelectTypeDetailsState();
}

class _SelectTypeDetailsState extends State<SelectTypeDetails> {

  Box box = Hive.box<dynamic>('userData');

  var type = [];
  var typeId = [];
  String typeSelected = "";
  String typeIdSelected = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.isScheme);
  }

  @override
  Widget build(BuildContext context){
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
              stream: FirebaseFirestore.instance.collection(widget.isScheme ? 'Scheme' : 'Non Scheme').orderBy('name', descending: false).snapshots(),
              builder: (BuildContext context, AsyncSnapshot snapshot)
              {
                if(snapshot.hasData)
                  {
                    var myData = snapshot.data.docs;
                    type = [];
                    typeId = [];

                    for(var el in myData)
                      {
                        if(el.data() != null)
                          {
                            if(widget.provinceId == el.data()['provinceID'] && widget.districtId == el.data()['districtID'])
                              {
                                type.add(el.data()['name']);
                                typeId.add(el.data()['id']);
                              }
                          }
                      }

                    return DropDown<dynamic>(
                      hint: Text("select type"),
                      items: type,
                      onChanged: (val)
                      {
                        setState((){
                          typeSelected = val;
                          typeIdSelected = typeId[type.indexOf(val)];
                        });
                      },
                    );
                  }
                else
                  {
                    return const CircularProgressIndicator();
                  }
              },
            ),


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                MaterialButton(
                  color: Colors.green,
                  onPressed: (){
                    box.delete('type');
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SelectSchemeDetails(provinceId: widget.provinceId, districtId: widget.districtId,)));
                  },
                  child: Text("Back"),
                ),
                MaterialButton(
                  color: Colors.green,
                  onPressed: (typeSelected == "" && typeIdSelected == "") ? null : (){
                    box.put('type', typeSelected);
                    box.put('typeId', typeIdSelected);
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) =>
                         SelectPropertyType(isScheme: widget.isScheme, provinceId: widget.provinceId, districtId: widget.districtId, typeId: typeIdSelected,),
                        ));
                  }, child:const Text("Continue"),),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

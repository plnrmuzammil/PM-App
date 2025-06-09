import "package:flutter/material.dart";
import "package:flutter_dropdown/flutter_dropdown.dart";
import 'package:reale/main.dart';
import "package:reale/stepper_steps/selectAdress.dart";
import "package:simple_database/simple_database.dart";
import 'package:reale/widgets/custom_text_widget.dart';

class SelectArea extends StatefulWidget {
  static bool isStartSubmittingData = false;

  final dynamic scheme;
  final dynamic province;
  final dynamic city;
  final dynamic phase;
  final dynamic block;
  final dynamic subBlock;

  final String? provinceName;
  final String? cityName;
  final String? phaseName;
  final String? schemeName;
  final String? blockName;
  final String? subBlockName;

  final String? adress;
  final String? propertyType;
  final String? propertySubType;
  final dynamic floors;
  final dynamic rooms;
  final dynamic kitchens;
  final dynamic basements;
  final dynamic washrooms;
  final dynamic parkings;
  final String? purpose;

  const SelectArea({
    super.key,
    this.scheme,
    this.province,
    this.city,
    this.phase,
    this.block,
    this.subBlock,
    this.adress,
    this.propertyType,
    this.propertySubType,
    this.floors,
    this.rooms,
    this.kitchens,
    this.basements,
    this.washrooms,
    this.parkings,
    this.subBlockName,
    this.blockName,
    this.phaseName,
    this.cityName,
    this.schemeName,
    this.provinceName,
    this.purpose,
  });

  @override
  State<SelectArea> createState() => _SelectAreaState();
}

class _SelectAreaState extends State<SelectArea> {
  final TextEditingController areaController = TextEditingController();
  final TextEditingController demandController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  final TextEditingController plotNumberController = TextEditingController();

  String? selectedUnit;
  bool isShowPlotInfoToUser = false;

  String? provinceName;
  String? cityName;
  String? phaseName;
  String? schemeName;
  String? blockName;
  String? subBlockName;

  SimpleDatabase? _province;
  SimpleDatabase? _city;
  SimpleDatabase? _phase;
  SimpleDatabase? _block;
  SimpleDatabase? _subBlock;
  SimpleDatabase? _scheme;

  void checkIfFieldsAreEmpty() {
    final isEmpty = areaController.text.trim().isEmpty ||
        demandController.text.trim().isEmpty ||
        detailsController.text.trim().isEmpty;

    SelectArea.isStartSubmittingData = !isEmpty;
  }

  Future<void> getValueFromDatabase() async {
    _province = SimpleDatabase(name: 'province');
    _city = SimpleDatabase(name: 'city');
    _phase = SimpleDatabase(name: 'phase');
    _block = SimpleDatabase(name: 'block');
    _subBlock = SimpleDatabase(name: 'subBlock');
    _scheme = SimpleDatabase(name: 'scheme');

    provinceName = await _province?.getAt(0) as String?;
    cityName = await _city?.getAt(0) as String?;
    schemeName = await _scheme?.getAt(0) as String?;
    phaseName = await _phase?.getAt(0) as String?;
    blockName = await _block?.getAt(0) as String?;
    subBlockName = await _subBlock?.getAt(0) as String?;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getValueFromDatabase();
  }

  @override
  void dispose() {
    areaController.dispose();
    demandController.dispose();
    detailsController.dispose();
    plotNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(height: 15),
        TextField(
          controller: areaController,
          keyboardType: TextInputType.phone,
          onChanged: (value) {
            houseModel.area = value;
            checkIfFieldsAreEmpty();
          },
          decoration: InputDecoration(
            labelText: "Enter Area*",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            isDense: true,
          ),
        ),
        const SizedBox(height: 10),
        DropDown<String>(
          items: const ["Squareft", "Marla"],
          hint: const Text("Units"),
          initialValue: houseModel.areaUnit.isNotEmpty ? houseModel.areaUnit : null,
          onChanged: (val) {
            setState(() {
              selectedUnit = val;
              houseModel.areaUnit = val!;
            });
          },
        ),
        const SizedBox(height: 10),
        TextField(
          controller: demandController,
          keyboardType: TextInputType.phone,
          onChanged: (value) {
            houseModel.demand = value;
            checkIfFieldsAreEmpty();
          },
          decoration: InputDecoration(
            labelText: "Enter Demand*",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            isDense: true,
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: detailsController,
          keyboardType: TextInputType.multiline,
          maxLines: 3,
          onChanged: (value) {
            houseModel.description = value;
          },
          decoration: InputDecoration(
            labelText: "Enter Details",
            hintText:
                "No of Rooms/ Basement/ Car Parking/ Washroom/ Kitchen/ No of Floors",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            isDense: true,
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: plotNumberController,
          keyboardType: TextInputType.phone,
          onChanged: (value) {
            houseModel.plotNumber = value;
            checkIfFieldsAreEmpty();
          },
          decoration: InputDecoration(
            labelText: "Plot / Flat / Khasra*",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            isDense: true,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            const CustomTextWidget(text1: 'Show'),
            Radio<bool>(
              value: true,
              groupValue: isShowPlotInfoToUser,
              onChanged: (value) {
                setState(() {
                  isShowPlotInfoToUser = value!;
                });
              },
            ),
            const CustomTextWidget(text1: 'Hide'),
            Radio<bool>(
              value: false,
              groupValue: isShowPlotInfoToUser,
              onChanged: (value) {
                setState(() {
                  isShowPlotInfoToUser = value!;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 15),
        SelectAddress(
          showPlotToUser: isShowPlotInfoToUser,
          plotNumber: plotNumberController.text,
          province: widget.province,
          scheme: widget.scheme,
          provinceName: provinceName,
          cityName: cityName,
          schemeName: schemeName,
          phaseName: phaseName,
          blockName: blockName,
          subBlockName: subBlockName,
          city: widget.city,
          phase: widget.phase,
          block: widget.block,
          subBlock: widget.subBlock,
          propertyType: widget.propertyType,
          propertySubType: widget.propertySubType,
          area: areaController.text,
          areaUnit: selectedUnit,
          demand: demandController.text,
          description: detailsController.text,
        ),
      ],
    );
  }
}

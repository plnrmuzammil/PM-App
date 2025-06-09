import 'package:flutter/material.dart';
import 'package:reale/stepper_steps/selectAdress.dart';
import 'package:reale/stepper_steps/selectArea.dart';
import 'package:reale/stepper_steps/selectBlock.dart';
import 'package:reale/stepper_steps/selectPhase.dart';
import 'package:reale/main.dart';
import 'package:reale/stepper_steps/selectCity.dart';
import 'package:reale/stepper_steps/selectPropertyPurpose.dart';
import 'package:reale/stepper_steps/selectPropertySubType.dart';
import 'package:reale/stepper_steps/selectPropertyType.dart';
import 'package:reale/stepper_steps/selectScheme.dart';
import 'package:reale/stepper_steps/selectSubblocks.dart';
import 'package:reale/stepper_steps/select_scheme_route.dart';
import '../stepper_steps/selectProvince.dart';

// Global values (replace with your own controller data or refactor to class variables)
bool? isShowPlotInfoToUser = false;
String? plotNumber = '';
String? schemeName = '';
String? phaseName = '';
String? blockName = '';
String? subBlockName = '';
TextEditingController? area = TextEditingController();
String? unit = '';
TextEditingController? demand = TextEditingController();
TextEditingController? details = TextEditingController();
dynamic block;
dynamic subBlock;

int index = 0;

class InformationStepper extends StatefulWidget {
  static List<dynamic> allSteps = <dynamic>[];
  static bool isLoading = false;
  static _InformationStepperState? _stateInstance;

  static void refresh({bool isShowLoader = false}) {
    _stateInstance?._refreshState(isShowLoader: isShowLoader);
  }

  const InformationStepper({super.key});

  @override
  _InformationStepperState createState() {
    _stateInstance = _InformationStepperState();
    return _stateInstance!;
  }
}

class _InformationStepperState extends State<InformationStepper> {
  void _refreshState({bool isShowLoader = false}) {
    setState(() {
      InformationStepper.isLoading = isShowLoader;
    });
  }

  @override
  void initState() {
    super.initState();
    InformationStepper.allSteps.add({
      'color': Colors.white,
      'background': Colors.green,
      'label': '1',
      'content': const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Province', style: TextStyle(fontSize: 18)),
          selectProvince(),
        ],
      ),
    });
  }

  @override
  void dispose() {
    InformationStepper.allSteps.clear();
    houseModel.resetValue();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Enter Details'),
      ),
      body: InformationStepper.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Theme(
                data: ThemeData(
                    primarySwatch: Colors.green,
                    colorScheme: const ColorScheme.light(primary: Colors.green)),
                child: Stepper(
                  physics: const ClampingScrollPhysics(),
                  currentStep: index,
                  onStepContinue: () {
                    if (index < 10) {
                      setState(() {
                        index += 1;
                      });
                    }
                  },
                  onStepTapped: (int i) {
                    setState(() {
                      index = i;
                    });
                  },
                  steps: <Step>[
                    const Step(
                      isActive: true,
                      title: Text('Select Province'),
                      content: selectProvince(),
                    ),
                    Step(
                      isActive: true,
                      title: const Text('Select District'),
                      content: selectCity(
                        province: currentId,
                        provinceName: selectedProvince,
                      ),
                    ),
                    Step(
                      isActive: true,
                      title: const Text('Select Scheme/ Non-Scheme'),
                      content: SchemeType(
                        province: currentId,
                        provinceName: selectedProvince,
                        city: cityId,
                        cityName: selectedCity,
                      ),
                    ),
                    Step(
                      isActive: true,
                      title: const Text('Select Type'),
                      content: boolSelectScheme
                          ? selectScheme(
                              province: currentId,
                              provinceName: selectedProvince,
                              city: cityId,
                              cityName: selectedCity,
                              isNonScheme: false,
                            )
                          : selectScheme(
                              province: currentId,
                              provinceName: selectedProvince,
                              city: cityId,
                              cityName: selectedCity,
                              isNonScheme: true,
                            ),
                    ),
                    Step(
                      isActive: true,
                      title: Text(boolSelectScheme
                          ? "Select Phase"
                          : 'Select Sub Zone/ Sub Phase/ Sector/ Block'),
                      content: boolSelectScheme
                          ? selectPhase(
                              province: currentId,
                              provinceName: selectedProvince,
                              city: cityId,
                              cityName: selectedCity,
                              scheme: schemeId,
                              schemeName: selectedScheme,
                            )
                          : selectPropertyType(
                              province: currentId,
                              provinceName: selectedProvince,
                              schemeName: selectedScheme,
                              scheme: schemeId,
                              city: cityId,
                              cityName: selectedCity,
                              phaseName: null,
                              phase: null,
                              block: null,
                              blockName: null,
                              subBlock: subblockIds,
                              subBlockName: null,
                            ),
                    ),
                    Step(
                      isActive: true,
                      title: Text(boolSelectScheme
                          ? "Select Block"
                          : 'Select Sub Zone/ Sub Phase/ Sector/ Block'),
                      content: boolSelectScheme
                          ? selectBlock(
                              scheme: schemeId,
                              schemeName: selectedScheme,
                              phase: phaseId,
                              phaseName: selectedPhase,
                              province: currentId,
                              provinceName: selectedProvince,
                              city: cityId,
                              cityName: selectedCity)
                          : selectPropertySubType(
                              province: currentId,
                              provinceName: selectedProvince,
                              schemeName: selectedScheme,
                              scheme: schemeId,
                              city: cityId,
                              cityName: selectedCity,
                              phaseName: null,
                              phase: null,
                              block: null,
                              blockName: null,
                              subBlock: subblockIds,
                              subBlockName: null,
                              adress: null,
                              propertyType: propertyType,
                            ),
                    ),
                    Step(
                      isActive: true,
                      title: Text(boolSelectScheme
                          ? "Select Subblocks"
                          : 'Select Property Purpose'),
                      content: boolSelectScheme
                          ? selectSubblocks(
                              province: currentId,
                              provinceName: selectedProvince,
                              schemeName: selectedScheme,
                              scheme: schemeId,
                              city: cityId,
                              cityName: selectedCity,
                              phase: null,
                              phaseName: null,
                              block: blockId,
                              blockName: null,
                            )
                          : selectPropertyPurpose(
                              province: currentId,
                              scheme: schemeId,
                              city: cityId,
                              phase: null,
                              block: null,
                              subBlock: subblockIds,
                              subBlockName: null,
                              adress: null,
                              propertyType: propertyType,
                              propertySubType: propertySubType,
                            ),
                    ),
                    Step(
                      isActive: true,
                      title: Text(boolSelectScheme
                          ? "Select Proper Type"
                          : 'Select Area'),
                      content: boolSelectScheme
                          ? selectPropertyType(
                              province: currentId,
                              provinceName: selectedProvince,
                              schemeName: selectedScheme,
                              scheme: schemeId,
                              city: cityId,
                              cityName: selectedCity,
                              phaseName: null,
                              phase: null,
                              block: null,
                              blockName: null,
                              subBlock: subblockIds,
                              subBlockName: null,
                            )
                          : SelectArea(
                              province: currentId,
                              scheme: schemeId,
                              city: cityId,
                              phase: null,
                              block: null,
                              subBlock: subblockIds,
                              subBlockName: null,
                              adress: null,
                              propertyType: propertyType,
                              propertySubType: propertySubType,
                              washrooms: washrooms,
                              kitchens: kitchens,
                              basements: basements,
                              floors: floors,
                              parkings: parkings,
                              rooms: rooms,
                              purpose: purpose,
                            ),
                    ),
                    Step(
                      isActive: true,
                      title: Text(boolSelectScheme
                          ? "Select Property Sub Type"
                          : 'Select Address'),
                      content: boolSelectScheme
                          ? selectPropertySubType(
                              province: currentId,
                              provinceName: selectedProvince,
                              schemeName: selectedScheme,
                              scheme: schemeId,
                              city: cityId,
                              cityName: selectedCity,
                              phaseName: null,
                              phase: null,
                              block: null,
                              blockName: null,
                              subBlock: subblockIds,
                              subBlockName: null,
                              adress: null,
                              propertyType: propertyType,
                            )
                          : SelectAddress(
                              showPlotToUser: isShowPlotInfoToUser,
                              plotNumber: plotNumber,
                              province: currentId,
                              scheme: schemeId,
                              provinceName: selectedProvince,
                              cityName: selectedCity,
                              schemeName: schemeName,
                              phaseName: phaseName,
                              blockName: blockName,
                              subBlockName: subBlockName,
                              city: cityId,
                              phase: null,
                              block: block,
                              subBlock: subBlock,
                              propertyType: propertyType,
                              propertySubType: propertySubType,
                              area: area?.text,
                              areaUnit: unit,
                              demand: demand?.text,
                              description: details?.text,
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

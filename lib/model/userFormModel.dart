class UserForm {
  static UserForm? _instance;
  UserForm._internal();
  factory UserForm() {
    if (_instance == null) {
      _instance = UserForm._internal();
      return _instance!;
    } else {
      return _instance!;
    }
  }

  @override
  String toString() {
    return 'UserForm{name: $name, phone: $phone, businessName: $businessName, businessOwner: $businessOwner, officeAddress: $officeAddress, idCardNumber: $idCardNumber, registrationNumber: $registrationNumber, cardFrontImage: $cardFrontImage, cardBackImage: $cardBackImage, documentFrontImage: $documentFrontImage, documentBackImage: $documentBackImage, province: $province, city: $city, lat: $lat, long: $long}';
  }

  String name='';
  String phone='';
  String businessName='';
  String businessOwner='';
  String officeAddress='';
  String idCardNumber='';
  String registrationNumber='';
  String cardFrontImage='';
  String cardBackImage='';
  String documentFrontImage='';
  String documentBackImage='';
  String province='';
  String city='';
  String lat='';
  String long='';

  bool isProvidedAllFields() {
    if (!(name.isNotEmpty) ||
        !(businessName.isNotEmpty) ||
        !(businessOwner.isNotEmpty) ||
        !(officeAddress.isNotEmpty) ||
        !(idCardNumber.isNotEmpty) ||
        !(registrationNumber.isNotEmpty) ||
        //!(cardFrontImage.length > 0) ||
        //!(cardBackImage.length > 0) ||
        //!(documentFrontImage.length > 0) ||
        //!(documentBackImage.length > 0) ||
        !(province.isNotEmpty) ||
        !(city.isNotEmpty)) {
      return false;
    } else {
      return true;
    }
  }

  // document already contain pone number so need to use it here
  Map<String, dynamic> createNewDocumentFromProvidedDocument(
      Map<String, dynamic> document) {
    document['name'] = name;
    document['businessName'] = businessName;
    document['businessOwner'] = businessOwner;
    document['officeAddress'] = officeAddress;
    document['idCardNumber'] = idCardNumber;
    document['registrationNumber'] = registrationNumber;
    document['idCardFrontPic'] = cardFrontImage;
    document['idCardBackPic'] = cardBackImage;
    document['registrationDocumentFrontPic'] = documentFrontImage;
    document['registrationDocumentBackPic'] = documentBackImage;

    document['province'] = province;
    document['city'] = city;
    document['lat'] = lat;
    document['long'] = long;
    return document;
  }

  UserForm.defaultValue({
    this.name = '',
    this.phone = '',
    this.businessName = '',
    this.businessOwner = '',
    this.officeAddress = '',
    this.idCardNumber = '',
    this.registrationNumber = '',
    this.cardFrontImage = '',
    this.cardBackImage = '',
    this.documentFrontImage = '',
    this.documentBackImage = '',
    this.province = '',
    this.city= '',
    this.lat= '',
    this.long= '',
  });
}

// import 'package:carousel_images/carousel_images.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import "package:flutter/material.dart";
// import 'package:pm_app/chat.dart';
// import './widgets/custom_text_widget.dart';
// import "./image_preview.dart";
// import 'constant.dart';
// import 'image_screen.dart';
//
// class PropertyDetailsNew extends StatefulWidget {
//   final Map<String, dynamic> data;
//   final String? currentListingDocumentID;
//
//   const PropertyDetailsNew(this.data, {this.currentListingDocumentID, Key? key}) : super(key: key);
//
//   @override
//   _PropertyDetailsState createState() => _PropertyDetailsState();
// }
//
// class _PropertyDetailsState extends State<PropertyDetailsNew> {
//   List<String> _allPropertyImages = [];
//   bool _isPropertyImagesLoading = false;
//   String dealerName = "";
//   final db = FirebaseFirestore.instance;
//
//   Future<void> getAllImages() async {
//     setState(() {
//       _isPropertyImagesLoading = true;
//       _allPropertyImages.clear();
//     });
//
//     try {
//       DocumentSnapshot _snapshot = await FirebaseFirestore.instance
//           .collection("plots_images")
//           .doc(widget.currentListingDocumentID)
//           .get();
//
//       if (_snapshot.exists) {
//         final data = _snapshot.data() as Map<String, dynamic>?;
//         if (data != null) {
//           setState(() {
//             _allPropertyImages = data.values
//                 .whereType<String>()
//                 .where((url) => url.isNotEmpty)
//                 .toList();
//           });
//         }
//       }
//     } catch (e) {
//       print('Error fetching images: $e');
//     } finally {
//       setState(() {
//         _isPropertyImagesLoading = false;
//       });
//     }
//   }
//
//   Future<void> getBusinessName() async {
//     try {
//       final sellerId = widget.data['seller']?.toString();
//       if (sellerId == null || sellerId.isEmpty) return;
//
//       final doc = await db.collection("users").doc(sellerId).get();
//       if (doc.exists) {
//         setState(() {
//           dealerName = doc['businessName']?.toString() ?? '';
//         });
//       }
//     } catch (e) {
//       print('Error fetching business name: $e');
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     getAllImages();
//     getBusinessName();
//   }
//
//   String _formatTimestamp(Timestamp timestamp) {
//     try {
//       final time = timestamp.toDate();
//       var timeHours = time.hour;
//       var timeMinutes = time.minute;
//       var timeCode = "am";
//       if (timeHours >= 12) {
//         timeHours = timeHours - 12;
//         timeCode = "pm";
//       }
//       return "${time.year}-${time.month}-${time.day} $timeHours:$timeMinutes $timeCode";
//     } catch (e) {
//       return "Date not available";
//     }
//   }
//
//   String _safeGetString(dynamic value) {
//     if (value == null) return 'N/A';
//     if (value is List) return value.join(", ");
//     return value.toString();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.green,
//         elevation: 10,
//         onPressed: () {
//           final sellerId = widget.data["seller"]?.toString();
//           if (sellerId != null && sellerId.isNotEmpty) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => chatScreen(sellerId)),
//             );
//           }
//         },
//         child: const Icon(Icons.message),
//       ),
//       appBar: AppBar(
//         backgroundColor: Colors.green,
//         title: const Text('Detail'),
//       ),
//       body: FutureBuilder<DocumentSnapshot>(
//         future: FirebaseFirestore.instance
//             .collection('users')
//             .doc(FirebaseAuth.instance.currentUser?.uid)
//             .get(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           return SingleChildScrollView(
//             child: Column(
//               children: [
//                 // Main Image
//                 InkWell(
//                   onTap: () {
//                     final imageUrl = widget.data['propertyImagesURL']?.toString();
//                     if (imageUrl != null && imageUrl.isNotEmpty) {
//                       Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder: (context) => ImageScreen(url: imageUrl),
//                         ),
//                       );
//                     }
//                   },
//                   child: Container(
//                     color: Colors.white,
//                     padding: const EdgeInsets.all(7),
//                     height: 200,
//                     width: MediaQuery.of(context).size.width,
//                     child: widget.data['propertyImagesURL']?.toString()?.isEmpty ?? true
//                         ? Image.network(
//                       "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT5V0xbLGXgCE5b9LrnrrawNIaYO6qsZxBxRxkOI9yKtA&s",
//                       fit: BoxFit.contain,
//                     )
//                         : Image.network(
//                       widget.data['propertyImagesURL'].toString(),
//                       fit: BoxFit.cover,
//                     ),
//
//
//                   ),
//                 ),
//
//                 // Property Details
//                 Container(
//                   padding: const EdgeInsets.all(15),
//                   child: Column(
//                     children: [
//                       Card(
//                         elevation: 12.0,
//                         child: Container(
//                           padding: const EdgeInsets.all(10),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   const Icon(Icons.access_time),
//                                   CustomTextWidget(
//                                     text1: ' ${_formatTimestamp(widget.data["time"] as Timestamp? ?? Timestamp.now())}',
//                                     text2: '',
//                                   ),
//                                 ],
//                               ),
//                               CustomTextWidget(
//                                 text1: 'Demand: ',
//                                 text2: _safeGetString(widget.data["demand"]),
//                               ),
//                               CustomTextWidget(
//                                 text1: 'Sold: ',
//                                 text2: _safeGetString(widget.data["sold"]),
//                               ),
//                               CustomTextWidget(
//                                 text1: 'Posted By: ',
//                                 text2: _safeGetString(widget.data["name"]),
//                               ),
//                               CustomTextWidget(
//                                 text1: 'Dealer: ',
//                                 text2: dealerName.isNotEmpty ? dealerName : 'N/A',
//                               ),
//                               if (widget.data["isShowPlotInfoToUser"] == true)
//                                 CustomTextWidget(
//                                   text1: 'Plot no: ',
//                                   text2: _safeGetString(widget.data["plotInfo"]),
//                                 ),
//                               CustomTextWidget(
//                                 text1: 'Property Type: ',
//                                 text2: '${_safeGetString(widget.data["type"])} ${_safeGetString(widget.data["subType"])}',
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//
//                       Card(
//                         margin: const EdgeInsets.all(2.0),
//                         elevation: 8.0,
//                         child: Container(
//                           padding: const EdgeInsets.all(10),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               CustomTextWidget(
//                                 text1: 'Listing For: ',
//                                 text2: _safeGetString(widget.data["sale"]),
//                               ),
//                               CustomTextWidget(
//                                 text1: 'Province: ',
//                                 text2: _safeGetString(widget.data["provinceName"]),
//                               ),
//                               CustomTextWidget(
//                                 text1: 'District: ',
//                                 text2: _safeGetString(widget.data["districtName"]),
//                               ),
//                               CustomTextWidget(
//                                 text1: 'Block: ',
//                                 text2: _safeGetString(widget.data["blockName"]),
//                               ),
//                               CustomTextWidget(
//                                 text1: 'Sub Block: ',
//                                 text2: _safeGetString(widget.data["subBlockName"]),
//                               ),
//                               CustomTextWidget(
//                                 text1: 'Phase: ',
//                                 text2: _safeGetString(widget.data["phaseName"]),
//                               ),
//                               CustomTextWidget(
//                                 text1: 'Scheme: ',
//                                 text2: _safeGetString(widget.data["schemeName"]),
//                               ),
//                               CustomTextWidget(
//                                 text1: 'Address: ',
//                                 text2: _safeGetString(widget.data["adress"]),
//                               ),
//                               CustomTextWidget(
//                                 text1: 'Total Area: ',
//                                 text2: '${_safeGetString(widget.data["area"])} ${_safeGetString(widget.data["areaUnit"])}',
//                               ),
//                               if (widget.data['isShowPlotInfoToUser'] == false)
//                                 CustomTextWidget(
//                                   text1: 'plot/house/room no: ',
//                                   text2: _safeGetString(widget.data["plotInfo"]),
//                                 ),
//                               const SizedBox(height: 30),
//                               const CustomTextWidget(
//                                 text1: 'Description: ',
//                               ),
//                               CustomTextWidget(
//                                 text1: '',
//                                 text2: _safeGetString(widget.data["description"]),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // Image Gallery
//                 if (_isPropertyImagesLoading)
//                   const Center(child: CircularProgressIndicator())
//                 else if (_allPropertyImages.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Padding(
//                           padding: EdgeInsets.all(8.0),
//                           child: Text(
//                             'Gallery:',
//                             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 200,
//                           child: ListView.builder(
//                             scrollDirection: Axis.horizontal,
//                             itemCount: _allPropertyImages.length,
//                             itemBuilder: (context, index) {
//                               return Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: InkWell(
//                                   onTap: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => ImageScreen(url: _allPropertyImages[index]),
//                                       ),
//                                     );
//                                   },
//                                   child: Image.network(
//                                     _allPropertyImages[index],
//                                     width: 200,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//

 //plnr



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:pm_app/chat.dart';
import './widgets/custom_text_widget.dart';

class FullScreenGallery extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenGallery({
    Key? key,
    required this.imageUrls,
    required this.initialIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = PageController(initialPage: initialIndex);
    return Scaffold(
      appBar: AppBar(title: const Text('Images')),
      body: PhotoViewGallery.builder(
        pageController: controller,
        itemCount: imageUrls.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(imageUrls[index]),
            minScale: PhotoViewComputedScale.contained * 1,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        scrollPhysics: const BouncingScrollPhysics(),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
      ),
    );
  }
}

class PropertyDetailsNew extends StatefulWidget {
  final Map<String, dynamic> data;
  final String? currentListingDocumentID;

  const PropertyDetailsNew(this.data, {this.currentListingDocumentID, Key? key}) : super(key: key);

  @override
  _PropertyDetailsState createState() => _PropertyDetailsState();
}

class _PropertyDetailsState extends State<PropertyDetailsNew> {
  List<String> _allPropertyImages = [];
  String dealerName = "";
  final db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    loadImagesFromURLField();
    getBusinessName();
  }

  void loadImagesFromURLField() {
    final imagesData = widget.data['propertyImagesURL'];
    if (imagesData is List) {
      _allPropertyImages = imagesData.whereType<String>().where((url) => url.isNotEmpty).toList();
    } else if (imagesData is String && imagesData.isNotEmpty) {
      _allPropertyImages = [imagesData];
    }
  }

  Future<void> getBusinessName() async {
    try {
      final sellerId = widget.data['seller']?.toString();
      if (sellerId == null || sellerId.isEmpty) return;

      final doc = await db.collection("users").doc(sellerId).get();
      if (doc.exists) {
        setState(() {
          dealerName = doc['businessName']?.toString() ?? '';
        });
      }
    } catch (e) {
      print('Error fetching business name: $e');
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    try {
      final time = timestamp.toDate();
      var timeHours = time.hour;
      var timeMinutes = time.minute.toString().padLeft(2, '0');
      var timeCode = "am";
      if (time.hour >= 12) {
        timeHours = time.hour == 12 ? 12 : time.hour - 12;
        timeCode = "pm";
      }
      return "${time.year}-${time.month}-${time.day} $timeHours:$timeMinutes $timeCode";
    } catch (e) {
      return "Date not available";
    }
  }

  String _safeGetString(dynamic value) {
    if (value == null) return 'N/A';
    if (value is List) return value.join(", ");
    return value.toString();
  }

  bool _isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  @override
  Widget build(BuildContext context) {
    final mainImage = _allPropertyImages.isNotEmpty ? _allPropertyImages[0] : null;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        elevation: 10,
        onPressed: () {
          final sellerId = widget.data["seller"]?.toString();
          if (sellerId != null && sellerId.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => chatScreen(sellerId)),
            );
          }
        },
        child: const Icon(Icons.message),
      ),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Detail'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Main Image
                InkWell(
                  onTap: () {
                    if (_isValidUrl(mainImage ?? '')) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenGallery(
                            imageUrls: _allPropertyImages,
                            initialIndex: 0,
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(7),
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    child: _isValidUrl(mainImage ?? '')
                        ? Image.network(mainImage!, fit: BoxFit.cover)
                        : Image.network(
                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT5V0xbLGXgCE5b9LrnrrawNIaYO6qsZxBxRxkOI9yKtA&s",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      _buildMainCard(),
                      _buildProvinceDistrictSchemeOrNonSchemeCard(),

                      _buildAddressCard(),
                    ],
                  ),
                ),
                if (_allPropertyImages.length > 1) _buildGridGallery(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainCard() {
    return Card(
      elevation: 12.0,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time),
                CustomTextWidget(
                  text1: ' ${_formatTimestamp(widget.data["time"] as Timestamp? ?? Timestamp.now())}',
                  text2: '',
                ),
              ],
            ),
            CustomTextWidget(
              text1: 'Property Type: ',
              text2: '${_safeGetString(widget.data["type"])} ${_safeGetString(widget.data["subType"])}',
            ),
            SizedBox(height: 5),
            CustomTextWidget(text1: 'Demand: ', text9: _safeGetString(widget.data["demand"])),
            SizedBox(height: 6),

            CustomTextWidget(text1: 'Sold: ', text2: _safeGetString(widget.data["sold"])),
            SizedBox(height: 5),

            CustomTextWidget(text1: 'Posted By: ', text6: _safeGetString(widget.data["name"])),
            CustomTextWidget(text1: 'Property Dealer: ', text4: dealerName.isNotEmpty ? dealerName : 'N/A'),
            SizedBox(height: 10),

            if (widget.data["isShowPlotInfoToUser"] == true)
              CustomTextWidget(text1: 'Plot no: ', text8: _safeGetString(widget.data["plotInfo"])),
            SizedBox(height: 10),

          ],
        ),
      ),
    );
  }

  //--------------
  Widget _buildProvinceDistrictSchemeOrNonSchemeCard() {
    return Card(
      margin: const EdgeInsets.all(2.0),
      elevation: 8.0,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextWidget(text1: 'Property For: ', text7: _safeGetString(widget.data["sale"])),
            SizedBox(height: 10),
            CustomTextWidget(text1: 'Province: ', text5: _safeGetString(widget.data["provinceName"])),
            CustomTextWidget(text1: 'District: ', text5: _safeGetString(widget.data["districtName"])),
            SizedBox(height: 10),

            CustomTextWidget(text1: 'Housing Scheme or Non H-Scheme): ', text2: _safeGetString(widget.data["schemeName"])),

          ],
        ),
      ),
    );
  }
//--------------


  Widget _buildAddressCard() {
    return Card(
      margin: const EdgeInsets.all(2.0),
      elevation: 8.0,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextWidget(text1: 'Location: ', text3: _safeGetString(widget.data["typeName"])),

            CustomTextWidget(text1: 'Phase: ', text2: _safeGetString(widget.data["phaseName"])),
            CustomTextWidget(text1: 'Block: ', text2: _safeGetString(widget.data["blockName"])),
            CustomTextWidget(text1: 'Sub Block: ', text2: _safeGetString(widget.data["subBlockName"])),
            CustomTextWidget(text1: 'Address: ', text2: _safeGetString(widget.data["address"])),
            CustomTextWidget(
              text1: 'Total Area: ',
              text2: '${_safeGetString(widget.data["area"])} ${_safeGetString(widget.data["areaUnit"])}',
            ),
            if (widget.data['isShowPlotInfoToUser'] == false)
              CustomTextWidget(text1: 'plot/house/room no: ', text2: _safeGetString(widget.data["plotInfo"])),
            const SizedBox(height: 30),
            const CustomTextWidget(text1: 'Description: '),
            CustomTextWidget(text1: '', text2: _safeGetString(widget.data["description"])),
          ],
        ),
      ),
    );
  }



  Widget _buildGridGallery() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Gallery:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _allPropertyImages.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final url = _allPropertyImages[index];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullScreenGallery(
                      imageUrls: _allPropertyImages,
                      initialIndex: index,
                    ),
                  ),
                ),
                child: Image.network(url, fit: BoxFit.cover),
              );
            },
          ),
        ],
      ),
    );
  }
}

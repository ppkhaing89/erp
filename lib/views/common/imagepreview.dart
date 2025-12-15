import 'package:erp/common/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class ImagePreview extends StatefulWidget {
  final String imageurl;
  final int type;
  const ImagePreview({super.key, required this.imageurl, required this.type});

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  Api api = Api();
  bool isLoading = true;
  bool isImageLoad = true;
  Image? imageWidget;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await Future.wait([
      getImage(),
    ]);

    setState(() {
      isLoading = false;
    });
  }

  Future<void> getImage() async {
    try {
      String baseUrl =
          'https://erp.dlink.com.sg/api/HomeApi/DownloadFile'; // Replace with your API endpoint base URL
      String filePath = '$baseUrl?FilePath=${widget.imageurl}';

      final response = await http.post(Uri.parse(filePath));
      if (response.statusCode == 200) {
        imageWidget = Image.memory(
          response.bodyBytes,
        );
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        imageWidget = null;
        isLoading = false;
        isImageLoad = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return CupertinoApp(
        home: CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous page
          },
          child: const Icon(CupertinoIcons.back),
        ),
        middle: const Text('Image Preview'),
      ),
      child: Center(
        child: isLoading
            ? const CupertinoActivityIndicator()
            : CupertinoApp(
                home: CupertinoPageScaffold(
                  child: SizedBox(
                    width: screenWidth, // Set the width to screen width
                    height: screenHeight, // Set the height to screen height
                    child: imageWidget ?? const Text('Preview not available.'),
                  ),
                ),
              ), // Show the image or an empty container if imageWidget is null
      ),
    ));
  }
}

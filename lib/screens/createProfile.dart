import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class CreateProfilePage extends StatefulWidget {
  @override
  _UpdatedProfilePageState createState() => _UpdatedProfilePageState();
}

class _UpdatedProfilePageState extends State<CreateProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Basic fields
  TextEditingController nameController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  // Location fields
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController latController = TextEditingController();
  TextEditingController lngController = TextEditingController();

  // Price Level
  String? selectedPriceLevel;
  List<String> priceLevels = ["budget", "midrange", "premium"];

  // Lists
  List<String> selectedServices = [];
  List<String> selectedLanguages = [];
  List<String> selectedTags = [];

  List<File> selectedImages = [];

  Future<void> pickImages() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        selectedImages = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<void> submitForm() async {
    var uri = Uri.parse("http://192.168.64.36:5000/api/vendor/create-profile");
    var request = http.MultipartRequest('POST', uri);

    request.fields['name'] = nameController.text;
    request.fields['type'] = typeController.text;
    request.fields['description'] = descriptionController.text;
    request.fields['contactNumber'] = contactNumberController.text;
    request.fields['email'] = emailController.text;

    // Convert complex objects to JSON strings
    request.fields['location'] = jsonEncode({
      'address': addressController.text,
      'city': cityController.text,
      'state': stateController.text,
      'country': countryController.text,
      'pincode': pincodeController.text,
      'coordinates': {
        'lat': double.tryParse(latController.text) ?? 0,
        'lng': double.tryParse(lngController.text) ?? 0,
      },
    });

    request.fields['priceLevel'] = selectedPriceLevel ?? 'budget';
    request.fields['servicesOffered'] = jsonEncode(selectedServices);
    request.fields['languagesSpoken'] = jsonEncode(selectedLanguages);
    request.fields['tags'] = jsonEncode(selectedTags);

    for (var image in selectedImages) {
      request.files.add(
        await http.MultipartFile.fromPath('images', image.path),
      );
    }

    try {
      var response = await request.send();

      if (response.statusCode == 201) {
        print("Vendor profile created successfully");
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(content: Text("Profile submitted successfully")),
        );
      } else {
        print("Error: ${response.statusCode}");
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("Upload failed: $e");
    }
  }

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: inputType,
    );
  }

  Widget buildChipInput(
    String label,
    List<String> items,
    Function(String) onAdd,
  ) {
    final controller = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Wrap(
          spacing: 6,
          children:
              items.map((item) {
                return Chip(
                  label: Text(item),
                  onDeleted: () => setState(() => items.remove(item)),
                );
              }).toList(),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(hintText: 'Add $label'),
              ),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    onAdd(controller.text.trim());
                    controller.clear();
                  });
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vendor Profile")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildTextField("Name", nameController),
              buildTextField("Type", typeController),
              buildTextField("Description", descriptionController),
              buildTextField("Contact Number", contactNumberController),
              buildTextField("Email", emailController),
              const SizedBox(height: 10),

              const Text(
                "Location",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              buildTextField("Address", addressController),
              buildTextField("City", cityController),
              buildTextField("State", stateController),
              buildTextField("Country", countryController),
              buildTextField(
                "Pincode",
                pincodeController,
                inputType: TextInputType.number,
              ),
              buildTextField(
                "Latitude",
                latController,
                inputType: TextInputType.number,
              ),
              buildTextField(
                "Longitude",
                lngController,
                inputType: TextInputType.number,
              ),

              DropdownButtonFormField<String>(
                value: selectedPriceLevel,
                items:
                    priceLevels.map((level) {
                      return DropdownMenuItem(value: level, child: Text(level));
                    }).toList(),
                onChanged:
                    (value) => setState(() => selectedPriceLevel = value),
                decoration: InputDecoration(labelText: "Price Level"),
              ),

              const SizedBox(height: 10),
              buildChipInput(
                "Services Offered",
                selectedServices,
                (value) => selectedServices.add(value),
              ),
              buildChipInput(
                "Languages Spoken",
                selectedLanguages,
                (value) => selectedLanguages.add(value),
              ),
              buildChipInput(
                "Tags",
                selectedTags,
                (value) => selectedTags.add(value),
              ),

              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: pickImages,
                icon: Icon(Icons.image),
                label: Text("Pick Images"),
              ),
              Wrap(
                children:
                    selectedImages
                        .map(
                          (img) => Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.file(
                              img,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                        .toList(),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitForm,
                child: Text("Submit Profile"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

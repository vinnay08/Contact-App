import 'package:contact_app/Database/dbhelper.dart';
import 'package:flutter/material.dart';
import '../Models/contact_model.dart';

class AddContact extends StatefulWidget {
  const AddContact({super.key});

  @override
  State<AddContact> createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {};

  void _saveContact() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Create a Contact object
      final newContact = Contact(
        firstName: _formData['First Name'] ?? '',
        lastName: _formData['Last Name'] ?? '',
        phone: _formData['Phone Number'] ?? '',
        email: _formData['Email'] ?? '',
        company: _formData['Company'] ?? '',
        state: _formData['State'] ?? '',
        city: _formData['City'] ?? '',
        street: _formData['Street'] ?? '',
      );

      // Save the contact to the database
      final dbHelper = Dbhelper.instance;
      await dbHelper.insertContact(newContact);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contact saved successfully!")),
      );

      // Navigate back
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Add Contact")),
        actions: [
          InkWell(
            onTap: _saveContact,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.save_outlined,
                size: 29,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                const SizedBox(height: 7),
                Center(
                  child: Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(60),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.asset(
                        "assets/images/p1.png",
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                ..._buildFormFields(size),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFormFields(Size size) {
    final fields = [
      {"icon": Icons.person, "label": "First Name"},
      {"icon": null, "label": "Last Name"},
      {"icon": Icons.phone, "label": "Phone Number"},
      {"icon": Icons.email, "label": "Email"},
      {"icon": Icons.apartment_rounded, "label": "Company"},
      {"icon": Icons.location_on, "label": "State"},
      {"icon": null, "label": "City"},
      {"icon": null, "label": "Street"},
    ];

    return fields
        .map((field) => Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (field['icon'] == null) ...[
                    const SizedBox(width: 35),
                  ],
                  if (field['icon'] != null) ...[
                    Icon(field['icon'] as IconData, color: Colors.black),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: fieldContent(size, field['label'] as String),
                  ),
                ],
              ),
            ))
        .toList();
  }

  Container fieldContent(Size size, String text) {
    return Container(
      // width: size.width * 0.84,
      height: size.height * 0.07,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 7.0, bottom: 5.0, top: 8.0),
        child: TextFormField(
          onChanged: (value) {
            _formData[text] = value;
          },
          validator: (value) {
            // Validation for phone number
            if (text == "Phone Number") {
              if (value == null || value.isEmpty) {
                return "Phone number is required";
              }
              final phoneRegExp = RegExp(r'^\+?[0-9]{10,13}$');
              if (!phoneRegExp.hasMatch(value)) {
                return "Enter a valid phone number";
              }
            }
            return null;
          },
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: text,
          ),
        ),
      ),
    );
  }
}

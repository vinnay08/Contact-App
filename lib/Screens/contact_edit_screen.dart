import 'package:flutter/material.dart';
import 'package:contact_app/Database/dbhelper.dart';
import 'package:contact_app/Models/contact_model.dart';

class EditContactPage extends StatefulWidget {
  final Contact contact;
  final Function onUpdate; // Callback to refresh the main screen

  const EditContactPage(
      {super.key, required this.contact, required this.onUpdate});

  @override
  State<EditContactPage> createState() => _EditContactPageState();
}

class _EditContactPageState extends State<EditContactPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {};

  @override
  void initState() {
    super.initState();
    _formData['First Name'] = widget.contact.firstName;
    _formData['Last Name'] = widget.contact.lastName;
    _formData['Phone Number'] = widget.contact.phone;
    _formData['Email'] = widget.contact.email;
    _formData['Company'] = widget.contact.company;
    _formData['State'] = widget.contact.state;
    _formData['City'] = widget.contact.city;
    _formData['Street'] = widget.contact.street;
  }

  void _saveContact() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Create a Contact object
      final updatedContact = Contact(
        id: widget.contact.id,
        firstName: _formData['First Name'] ?? '',
        lastName: _formData['Last Name'] ?? '',
        phone: _formData['Phone Number'] ?? '',
        email: _formData['Email'] ?? '',
        company: _formData['Company'] ?? '',
        state: _formData['State'] ?? '',
        city: _formData['City'] ?? '',
        street: _formData['Street'] ?? '',
      );

      // Save the updated contact to the database
      final dbHelper = Dbhelper.instance;
      await dbHelper.updateContact(updatedContact);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contact updated successfully!")),
      );

      // Call the onUpdate callback to refresh the main screen
      widget.onUpdate(); // Trigger the refresh

      // Navigate back
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text("Edit Contact")),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: _saveContact,
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
      width: size.width * 0.84,
      height: size.height * 0.07,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 7.0, bottom: 5.0, top: 8.0),
        child: TextFormField(
          initialValue: _formData[text],
          onChanged: (value) {
            _formData[text] = value;
          },
          validator: (value) {
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

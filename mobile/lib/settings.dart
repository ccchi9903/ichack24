import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ichack24/auth.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isEditing = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final db = FirebaseFirestore.instance;

  Widget _buildProfileField(String label, TextEditingController controller) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _isEditing
            ? [
                Expanded(child: _buildEditableTextField(label, controller)),
              ]
            : [
                Expanded(
                  child: Text(
                    '$label: ',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: _buildReadOnlyTextField(controller),
                )
              ]);
  }

  Widget _buildEditableTextField(
      String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: label == 'Name' || label == 'Gender' ? 
                              TextInputType.text : TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Enter your $label',
        border: const OutlineInputBorder(),
      ),
      style: const TextStyle(fontSize: 15),
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _buildReadOnlyTextField(TextEditingController controller) {
    FontWeight weight =
        controller.text.isEmpty ? FontWeight.w100 : FontWeight.normal;
    return Text(
      controller.text.isEmpty ? 'Empty' : controller.text,
      style: TextStyle(fontSize: 20, fontWeight: weight),
    );
  }

  Future<void> _fetchUserData() async {
    User user = Auth().currentUser!;
    final userRef = db.collection("users").doc(user.uid);
    final doc = await userRef.get();
    final data = doc.data() as Map<String, dynamic>;

    setState(() {
      for (final entry in data.entries) {
        switch (entry.key) {
          case "name":
            _nameController.text = entry.value;
            break;
          case "age":
            _ageController.text = entry.value.toString();
            break;
          case "weight":
            _weightController.text = entry.value.toString();
            break;
          case "gender":
            _genderController.text = entry.value.toString();
            break;
        }
      }
    });
  }

  Future<void> _setUserData() async {
    User user = Auth().currentUser!;
    final userRef = db.collection("users").doc(user.uid);
    final data = {
      "name": _nameController.text,
      "age": int.parse(_ageController.text),
      "weight": double.parse(_weightController.text),
      "gender": _genderController.text
    };
    userRef.set(data, SetOptions(merge: true));
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileField("Name", _nameController),
          const SizedBox(height: 24),
          _buildProfileField("Age", _ageController),
          const SizedBox(height: 24),
          _buildProfileField("Gender", _genderController),
          const SizedBox(height: 24),
          _buildProfileField("Weight", _weightController),
          const SizedBox(height: 24),
          Center(child: ElevatedButton(
            onPressed: () {
              _setUserData();
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            child: Text(
              _isEditing ? 'Save Profile' : 'Edit Profile',
              style: const TextStyle(color: Colors.black, 
                                    fontSize: 20),
            ),
          )),
          SizedBox(height: 12),
          Center(child: ElevatedButton(
              onPressed: () async {
                await Auth().signOut();
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.black, 
                                  fontSize: 20),
              ))
          ),
        ],
      ),
    );
  }
}

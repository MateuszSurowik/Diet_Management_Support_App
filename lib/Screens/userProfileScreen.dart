import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String name = 'Jan Kowalski';
  String age = '25';
  String height = '180';
  String weight = '75';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inicjalizacja kontrolerów
    nameController.text = name;
    ageController.text = age;
    heightController.text = height;
    weightController.text = weight;
  }

  void _editProfile() {
    setState(() {
      name = nameController.text;
      age = ageController.text;
      height = heightController.text;
      weight = weightController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Użytkownika'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Profilowe zdjęcie
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    NetworkImage('https://example.com/profile.jpg'),
              ),
            ),
            const SizedBox(height: 16),
            // Imię i nazwisko
            Center(
              child: Text(
                name,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            // Wiek, wzrost i waga
            EditableInfoCard(
              label: 'Age:',
              controller: ageController,
            ),
            EditableInfoCard(
              label: 'Height:',
              controller: heightController,
            ),
            EditableInfoCard(
              label: 'Weight:',
              controller: weightController,
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _editProfile,
                child: const Text('Zapisz zmiany'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditableInfoCard extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const EditableInfoCard(
      {super.key, required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Wprowadź $label',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

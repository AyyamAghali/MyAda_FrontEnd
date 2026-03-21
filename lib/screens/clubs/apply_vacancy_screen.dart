import 'package:flutter/material.dart';
import '../../models/club_vacancy.dart';
import '../../utils/constants.dart';

class ApplyVacancyScreen extends StatefulWidget {
  final ClubVacancy vacancy;

  const ApplyVacancyScreen({super.key, required this.vacancy});

  @override
  State<ApplyVacancyScreen> createState() => _ApplyVacancyScreenState();
}

class _ApplyVacancyScreenState extends State<ApplyVacancyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _motivation = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _motivation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClubUiColors.pageBg,
      appBar: AppBar(
        title: const Text('Apply'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.vacancy.position,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              Text(widget.vacancy.clubName, style: const TextStyle(color: Color(0xFF64748B))),
              const SizedBox(height: 24),
              TextFormField(
                controller: _name,
                decoration: _decoration('Full name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _email,
                decoration: _decoration('University email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _motivation,
                decoration: _decoration('Why are you a good fit?'),
                maxLines: 5,
                validator: (v) => (v == null || v.trim().length < 20) ? 'Please write at least 20 characters' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Application submitted (prototype).')),
                    );
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: ClubUiColors.ctaBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Submit application'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

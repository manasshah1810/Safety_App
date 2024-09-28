import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ReviewPage extends StatefulWidget {
  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _otherIncidentController = TextEditingController();
  String? incidentType;
  String? severity;
  bool showOtherField = false;
  bool otherFieldEmpty = true; // New flag to track if "Other" field is empty

  bool isUnsafeForWalking = false;
  bool isUnsafeForDriving = false;
  bool isUnsafeForPublicTransport = false;

  final List<String> incidentOptions = [
    'Theft',
    'Harassment',
    'Accidents',
    'Physical Assault',
    'Sexual Assault',
    'Other',
  ];

  final List<String> severityOptions = ['1', '2', '3'];

  // Variable to hold the image
  XFile? _image;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  void _submitReview(BuildContext context) {
    // Show incident selection dialog after submitting review
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('What incident did you face?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: incidentOptions.map((String incident) {
                      return RadioListTile<String>(
                        title: Text(incident),
                        value: incident,
                        groupValue: incidentType,
                        onChanged: (String? value) {
                          setState(() {
                            incidentType = value;
                            showOtherField = (incidentType == 'Other');
                            // Clear the other field text if it's not selected
                            if (!showOtherField) {
                              _otherIncidentController.clear();
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  if (showOtherField)
                    TextField(
                      controller: _otherIncidentController,
                      decoration: InputDecoration(
                        labelText: 'Please specify the incident',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (text) {
                        setState(() {
                          otherFieldEmpty = text.isEmpty;
                        });
                      },
                    ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Next'),
                  onPressed: () {
                    if (incidentType == 'Other' && _otherIncidentController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter a description for the "Other" incident.')),
                      );
                    } else {
                      Navigator.of(context).pop();
                      _askWhoAreaIsUnsafeFor(context); // Move to next question
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _askWhoAreaIsUnsafeFor(BuildContext context) {
    // Ask for who the area is unsafe for
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Who do you think this area is unsafe for?'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  title: Text('People who are walking'),
                  value: isUnsafeForWalking,
                  onChanged: (bool? value) {
                    setState(() {
                      isUnsafeForWalking = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('People who are driving'),
                  value: isUnsafeForDriving,
                  onChanged: (bool? value) {
                    setState(() {
                      isUnsafeForDriving = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('People in public transport'),
                  value: isUnsafeForPublicTransport,
                  onChanged: (bool? value) {
                    setState(() {
                      isUnsafeForPublicTransport = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Next'),
              onPressed: () {
                Navigator.of(context).pop();
                _askForSeverity(context); // Move to severity selection
              },
            ),
          ],
        );
      },
    );
  }

  void _askForSeverity(BuildContext context) {
    // Ask for severity on a scale of 1-3
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('What was the severity of the incident? (1-3)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: severityOptions.map((String severityLevel) {
              return RadioListTile<String>(
                title: Text(severityLevel),
                value: severityLevel,
                groupValue: severity,
                onChanged: (String? value) {
                  setState(() {
                    severity = value;
                  });
                  Navigator.of(context).pop();
                  _showConfirmation(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showConfirmation(BuildContext context) {
    // Show final confirmation dialog
    String otherIncidentText = showOtherField ? _otherIncidentController.text : '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Review Submitted'),
          content: Text(
            'Thank you for your review!\n\n'
            'Incident Type: ${incidentType == 'Other' ? otherIncidentText : incidentType}\n'
            'Unsafe for: ${_getUnsafeForText()}\n'
            'Severity: $severity\n'
            'Uploaded Photo: ${_image?.path ?? "No photo uploaded"}',
          ),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _resetForm(); // Reset the form after submission
              },
            ),
          ],
        );
      },
    );
  }

  String _getUnsafeForText() {
    List<String> unsafeFor = [];
    if (isUnsafeForWalking) unsafeFor.add('People who are walking');
    if (isUnsafeForDriving) unsafeFor.add('People who are driving');
    if (isUnsafeForPublicTransport) unsafeFor.add('People in public transport');
    return unsafeFor.join(', ');
  }

  void _resetForm() {
    setState(() {
      _reviewController.clear();
      _otherIncidentController.clear();
      incidentType = null;
      severity = null;
      showOtherField = false;
      isUnsafeForWalking = false;
      isUnsafeForDriving = false;
      isUnsafeForPublicTransport = false;
      _image = null; // Clear the selected image
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a Review'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _reviewController,
                  decoration: InputDecoration(
                    labelText: 'Write your review here',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Upload Photo'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_reviewController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please write a review before submitting')),
                      );
                    } else {
                      _submitReview(context);
                    }
                  },
                  child: Text('Submit Review'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

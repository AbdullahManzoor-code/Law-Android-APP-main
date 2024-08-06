import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:law_app/Hire%20Services/pay_now_page.dart';
import 'package:law_app/components/Email/send_email_emailjs.dart';
import 'package:dotted_border/dotted_border.dart';

class FormPage extends StatefulWidget {
  final String selectedCategory;
  final String selectedCategoryOption;
  final String selectedCategorySubOption;
  final String selectedCategorySubOptionName;
  final double price;
  List<String> selectedCategorySubOptionAllName;

  FormPage({
    Key? key,
    required this.selectedCategory,
    required this.selectedCategoryOption,
    required this.selectedCategorySubOption,
    required this.selectedCategorySubOptionName,
    required this.price,
    this.selectedCategorySubOptionAllName = const [],
  }) : super(key: key);

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  final currentUser = FirebaseAuth.instance.currentUser;

  List<String> allOptions = []; // List of all options
  List<String> selectedOptions = []; // List of selected options
  String? selectedOption; // Currently selected option
  double totalPrice = 0.0;

  bool loading = false;

  List<PlatformFile> pickedFiles = [];
  List<UploadTask?> uploadTasks = [];
  List<String> fileUrls = [];

  final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];

  Future selectFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result == null) return;

    setState(() {
      for (var file in result.files) {
        if (!pickedFiles
            .any((existingFile) => existingFile.name == file.name)) {
          pickedFiles.add(file);
        }
      }
    });
  }

  Future uploadFiles() async {
    if (pickedFiles.isEmpty) return;

    List<String> urls = [];

    for (var file in pickedFiles) {
      final path = 'files/${file.name}';
      final fileToUpload = File(file.path!);
      final ref = FirebaseStorage.instance.ref().child(path);

      final uploadTask = ref.putFile(fileToUpload);

      setState(() {
        uploadTasks.add(uploadTask);
      });

      final snapshot = await uploadTask.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();

      print('Download Link: $urlDownload');
      urls.add(urlDownload);
    }

    setState(() {
      fileUrls = urls;
      uploadTasks = [];
    });
  }

  @override
  void initState() {
    _whatsappController.text = currentUser?.phoneNumber ?? '';
    _emailController.text = currentUser?.email ?? '';
    totalPrice = widget.price;

    // Initialize options
    // allOptions = widget.selectedCategorySubOptionAllName;
    // disabledOptions = [];
    // selectedOption = null; // Initially no option is selected

    allOptions = widget.selectedCategorySubOptionAllName
        .where((option) => option != widget.selectedCategorySubOptionName)
        .toList();
    // Initially disable the option matching selectedCategorySubOptionName
    if (allOptions.contains(widget.selectedCategorySubOptionName)) {
      selectedOptions.add(widget.selectedCategorySubOptionName);
    }
    super.initState();
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        loading = true;
      });

      // Create a map of the data to store
      final orderData = {
        'name': _nameController.text.trim(),
        'whatsapp': _whatsappController.text.trim(),
        'email': _emailController.text.trim(),
        'message': _messageController.text.trim(),
        'selectedCategory': widget.selectedCategory,
        'selectedCategoryOption': widget.selectedCategoryOption,
        'selectedCategorySubOption': widget.selectedCategorySubOption,
        'selectedCategorySubOptionName': widget.selectedCategorySubOptionName,
        'userId': currentUser?.uid,
        'status': 'in progress',
        'fileUrl': fileUrls,
        'extraOption': selectedOptions,
        'totalPrice': selectedOptions.isNotEmpty
            ? totalPrice * (selectedOptions.length + 1)
            : totalPrice,
        'timestamp':
            FieldValue.serverTimestamp(), // Adds a server-side timestamp
      };

      try {
        // Store the data in Firestore
        await FirebaseFirestore.instance.collection('orders').add(orderData);

        // Show a success message or navigate
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Submitted successfully!')),
        );

        // combine services and sub services
        String services =
            '${widget.selectedCategory} - ${widget.selectedCategoryOption} - ${widget.selectedCategorySubOption} - ${widget.selectedCategorySubOptionName}';

        // send email

        sendEmailUsingEmailjs(
            name: _nameController.text,
            email: _emailController.text,
            subject: services,
            message: _messageController.text,
            services: widget.selectedCategorySubOptionName);

        // Clear the form
        _nameController.clear();
        _whatsappController.clear();
        _messageController.clear();

        // Navigate to the pay now page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PayNowPage(
              heading: widget.selectedCategory,
              title: widget.selectedCategoryOption,
              subTitle: widget.selectedCategorySubOption,
              option: widget.selectedCategorySubOptionName,
              totalPrice: selectedOptions.isNotEmpty
                  ? totalPrice * (selectedOptions.length + 1)
                  : totalPrice,
              extraOption: selectedOptions,
            ),
          ),
        );
      } catch (e) {
        // Handle errors, e.g., show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting: $e')),
        );
      } finally {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Services'),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                    widget.selectedCategory,
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const Text(
                    ' > ',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    widget.selectedCategoryOption,
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const Text(
                    ' > ',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    widget.selectedCategorySubOption,
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const Text(
                    ' > ',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    widget.selectedCategorySubOptionName,
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF11CEC4))),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF11CEC4))),
                        labelText: 'Name',
                        labelStyle: TextStyle(color: Color(0xFF11CEC4)),
                        hintText: 'Enter your name',
                        prefixIcon: Icon(
                          Icons.person,
                          color: Color(0xFF11CEC4),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _whatsappController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF11CEC4))),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF11CEC4))),
                        labelText: 'Phone',
                        labelStyle: TextStyle(color: Color(0xFF11CEC4)),
                        hintText: 'Enter your WhatsApp number',
                        prefixIcon: Icon(
                          Icons.phone,
                          color: Color(0xFF11CEC4),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your WhatsApp number';
                        }
                        if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
                          return 'Please enter a valid WhatsApp number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF11CEC4))),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF11CEC4))),
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Color(0xFF11CEC4)),
                        hintText: 'Enter your email address',
                        prefixIcon: Icon(
                          Icons.email,
                          color: Color(0xFF11CEC4),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email address';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // const SizedBox(height: 16),
                    // Display selected options with remove button
                    if (selectedOptions.isNotEmpty)
                      Wrap(
                        spacing: 8.0,
                        children: selectedOptions.map((option) {
                          return Chip(
                            label: Text(option),
                            onDeleted: () {
                              setState(() {
                                selectedOptions.remove(option);
                                if (option !=
                                    widget.selectedCategorySubOptionName) {
                                  allOptions.add(option);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 16),
                    const Text(
                      'Add another Service',
                      style: TextStyle(
                        color: Color(0xFF11CEC4),
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: selectedOption,
                      isExpanded: true,
                      hint: const Text('Select another Service'),
                      items: allOptions.map((option) {
                        final isSelectedSubOption =
                            option == widget.selectedCategorySubOptionName;
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(
                            option,
                            style: TextStyle(
                              color: isSelectedSubOption ||
                                      selectedOptions.contains(option)
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                          enabled: !(isSelectedSubOption ||
                              selectedOptions.contains(option)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null && !selectedOptions.contains(value)) {
                          setState(() {
                            selectedOptions.add(value);
                            allOptions.remove(value);
                            selectedOption = null;
                          });
                        }
                      },
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 16),
                    // ElevatedButton(
                    //   onPressed: selectFiles,
                    //   child: Text(
                    //     pickedFiles.isNotEmpty
                    //         ? 'Select Another File'
                    //         : 'Select Files',
                    //   ),
                    // ),
                    GestureDetector(
                      onTap: selectFiles,
                      child: DottedBorder(
                        color: const Color(0xFF11CEC4),
                        radius: const Radius.circular(8),
                        strokeWidth: 2,
                        child: const SizedBox(
                          height: 50,
                          child: Center(
                            child: Icon(
                              Icons.upload_file,
                              color: Color(0xFF11CEC4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (pickedFiles.isNotEmpty)
                      Column(
                        children: pickedFiles.map((file) {
                          final fileExtension = file.extension?.toLowerCase();
                          final isImage =
                              imageExtensions.contains(fileExtension);

                          return ListTile(
                            leading: isImage
                                ? Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: FileImage(File(file.path!)),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.insert_drive_file,
                                    size: 50, color: Colors.grey),
                            title: Text(file.name),
                            subtitle: Text(
                                '${(file.size / 1024).toStringAsFixed(2)} KB'),
                            trailing: IconButton(
                              color: Colors.black,
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  pickedFiles.remove(file);
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF11CEC4),
                          ),
                          onPressed: uploadFiles,
                          child: const Text(
                            'Attach Files',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    buildProgress(),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _messageController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF11CEC4))),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF11CEC4))),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF11CEC4))),
                        hintText: 'Enter your message',
                        labelText: 'Message',
                        labelStyle: TextStyle(color: Color(0xFF11CEC4)),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        prefixIcon: Icon(
                          Icons.message,
                          color: Color(0xFF11CEC4),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a message';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    loading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF11CEC4)),
                          )
                        : Center(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  // _formKey.currentState?.save();
                                  _submitForm();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF11CEC4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 110, vertical: 15),
                              ),
                              child: const Text(
                                'Generate Order',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget buildProgress() => Column(
        children: uploadTasks.map((task) {
          return StreamBuilder<TaskSnapshot>(
            stream: task?.snapshotEvents,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final snap = snapshot.data!;
                final progress = snap.bytesTransferred / snap.totalBytes;
                final percentage = (progress * 100).toStringAsFixed(2);

                return SizedBox(
                  height: 50,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey,
                        color: Colors.green,
                      ),
                      Center(
                        child: Text(
                          '$percentage %',
                          style: const TextStyle(
                              fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Container();
              }
            },
          );
        }).toList(),
      );
}

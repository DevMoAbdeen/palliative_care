import 'dart:developer';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:palliative_care/components/main_widgets.dart';
import 'package:palliative_care/models/user.dart';
import '../../components/display_files.dart';
import '../../constants.dart';
import '../../firebase/fb_activity.dart';
import '../../firebase/fb_authentication.dart';
import '../../firebase/fb_files.dart';
import '../../models/file.dart';

class AddDoctorScreen extends StatefulWidget {
  static const String id = "AddDoctorScreen";

  const AddDoctorScreen({Key? key}) : super(key: key);

  @override
  State<AddDoctorScreen> createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends State<AddDoctorScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController specialtyController = TextEditingController();
  TextEditingController birthdateController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  SelectedFile? selectedImage;
  String? _imageUrl;
  String _name = "";
  String _email = "";
  String _address = "";
  String _mobileNumber = "";
  String _specialty = "";
  String _birthdate = "";
  String _password = "";

  bool nameValidate = false;
  bool emailValidate = false;
  bool addressValidate = false;
  bool mobileValidate = false;
  bool specialityValidate = false;
  bool birthdateValidate = false;
  bool passwordValidate = false;
  bool isVisible = false;

  bool showProgress = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    addressController.dispose();
    mobileController.dispose();
    specialtyController.dispose();
    birthdateController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> selectImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (file != null) {
      setState(() {
        String imageName = DateTime.now().millisecondsSinceEpoch.toString();
        selectedImage = SelectedFile(file, imageName);
      });
    }
  }

  Future<void> _submitForm() async {
    _name = nameController.text.trim().toString();
    _email = emailController.text.trim().toString();
    _address = addressController.text.trim().toString();
    _mobileNumber = mobileController.text.trim().toString();
    _specialty = specialtyController.text.trim().toString();
    _birthdate = birthdateController.text.trim().toString();
    _password = passwordController.text.trim().toString();

    if (_name.isNotEmpty && _name.contains(" ") && _email.isNotEmpty && _email.contains("@") &&
        _specialty.isNotEmpty && _address.isNotEmpty && _mobileNumber.isNotEmpty &&
        _mobileNumber.length > 8 && _birthdate.isNotEmpty && _password.isNotEmpty) {
      setState(() {
        showProgress = true;
      });
      if (selectedImage != null) {
        _imageUrl = await FbFiles.uploadImage(context, selectedImage!.file, selectedImage!.name);
      }

      try {
        final newDoctor = await FbAuthentication.signUpWithEmailAndPassword(_email, _password);
        if (newDoctor.user != null && mounted) {
          DoctorModel doctor = DoctorModel(imageUrl: _imageUrl, name: _name, email: _email,
            specialty: _specialty, address: _address, birthdate: _birthdate,
            mobileNumber: _mobileNumber, token: "", subscribedTopics: []
          );

          bool isCreated = await FbAuthentication.addNewDoctor(context, doctor);
          if (isCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Doctor account has been created')),
            );
            FbActivitiesFunctions.createUserActivity(context, _email);
            nameController.clear();
            emailController.clear();
            addressController.clear();
            mobileController.clear();
            specialtyController.clear();
            birthdateController.clear();
            passwordController.clear();
          }
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error create account, ${error.toString()}")),
        );
      }
      setState(() {
        showProgress = false;
      });
    } else {
      setState(() {
        nameValidate = _name.isEmpty || !_name.contains(" ");
        emailValidate = _email.isEmpty || !_email.contains("@");
        specialityValidate = _specialty.isEmpty;
        addressValidate = _address.isEmpty;
        mobileValidate = _mobileNumber.isEmpty || _mobileNumber.length <= 8;
        birthdateValidate = _birthdate.isEmpty;
        passwordValidate = _password.isEmpty || _password.length < 5;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  selectedImage != null
                      ? Stack(
                          children: [
                            InkWell(
                              onTap: () {
                                DetailScreen(imagePath: selectedImage!.file.path);
                              },
                              child: Hero(
                                tag: selectedImage!.file.path,
                                child: CircleAvatar(
                                  radius: 80,
                                  backgroundImage: FileImage(File(selectedImage!.file.path)),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: () {
                                  selectImage();
                                },
                                child: const CircleAvatar(
                                  backgroundColor: kMainColorDark,
                                  child: Center(
                                    child: Icon(
                                      Icons.change_circle_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      : InkWell(
                          onTap: () async {
                            selectImage();
                          },
                          child: const SizedBox(
                            height: 100,
                            width: 100,
                            child: Icon(
                              Icons.image,
                              size: 100,
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      labelText: 'Doctor name',
                      errorText: nameValidate
                          ? _name.isEmpty
                              ? 'Name can\'t be empty'
                              : "Write doctor full name"
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _name = value.toString().trim();
                        _name.isNotEmpty ? nameValidate = false : null;
                      });
                    },
                  ),
                  kSizeBoxH8,
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Doctor email',
                      errorText: emailValidate
                          ? _email.isEmpty
                              ? 'Email can\'t be empty'
                              : "This email not valid !"
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _email = value.toString().trim();
                        _email.isNotEmpty ? emailValidate = false : null;
                      });
                    },
                  ),
                  kSizeBoxH8,
                  TextFormField(
                    controller: specialtyController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'Doctor specialty',
                      errorText: specialityValidate ? 'Write doctor specialty!' : null,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _specialty = value.toString().trim();
                        _specialty.isNotEmpty
                            ? specialityValidate = false
                            : null;
                      });
                    },
                  ),
                  kSizeBoxH8,
                  TextFormField(
                    controller: addressController,
                    keyboardType: TextInputType.streetAddress,
                    decoration: InputDecoration(
                      labelText: 'Doctor address',
                      errorText: addressValidate ? 'Write doctor address' : null,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _address = value.toString().trim();
                        _address.isNotEmpty ? addressValidate = false : null;
                      });
                    },
                  ),
                  kSizeBoxH8,
                  TextFormField(
                    controller: mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      errorText: mobileValidate
                          ? _mobileNumber.isEmpty
                              ? 'Enter doctor mobile'
                              : "This number is not valid"
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _mobileNumber = value.toString().trim();
                        _mobileNumber.isNotEmpty
                            ? mobileValidate = false
                            : null;
                      });
                    },
                  ),
                  kSizeBoxH8,
                  TextFormField(
                    controller: birthdateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Doctor birthdate',
                      errorText: birthdateValidate ? "Enter doctor birthdate!" : null,
                      border: const OutlineInputBorder(),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1930),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                        setState(() {
                          birthdateController.text = formattedDate;
                          birthdateValidate = false;
                        });
                      }
                    },
                  ),
                  kSizeBoxH8,
                  TextFormField(
                    controller: passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: !isVisible,
                    decoration: InputDecoration(
                      hintText: 'Doctor password',
                      errorText: passwordValidate
                          ? _password.isEmpty
                              ? 'Enter doctor password'
                              : "The password must be at least 6 characters."
                          : null,
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isVisible = !isVisible;
                          });
                        },
                        icon: isVisible
                            ? const Icon(
                                Icons.visibility,
                                color: Colors.grey,
                              )
                            : const Icon(
                                Icons.visibility_off,
                                color: Colors.grey,
                              ),
                      ),
                    ),
                    onChanged: (value) {
                      _password = value.toString().trim();
                      _password.isNotEmpty ? passwordValidate = false : null;
                    },
                  ),
                  kSizeBoxH24,
                  MainBtn(
                    text: "Add doctor",
                    showProgress: showProgress,
                    onPressed: () {
                      _submitForm();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

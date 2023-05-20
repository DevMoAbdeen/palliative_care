import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palliative_care/constants.dart';
import 'package:palliative_care/firebase/fb_articles.dart';
import 'package:palliative_care/firebase/fb_authentication.dart';
import 'package:palliative_care/firebase/fb_comments.dart';
import 'package:palliative_care/firebase/fb_files.dart';
import 'package:palliative_care/functions.dart';
import 'package:intl/intl.dart';
import '../../components/display_files.dart';
import '../../models/file.dart';

class EditDataScreen extends StatefulWidget {
  final String name;
  final String email;
  final String? specialty;
  final String address;
  final String mobileNumber;
  final String birthdate;
  final String? imageUrl;

  const EditDataScreen({super.key,
    required this.name,
    required this.email,
    required this.specialty,
    required this.address,
    required this.mobileNumber,
    required this.birthdate,
    required this.imageUrl,
  });

  @override
  _EditDataScreenState createState() => _EditDataScreenState();
}

class _EditDataScreenState extends State<EditDataScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController birthdateController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  SelectedFile? selectedImage;
  bool isUpdatingData = false;

  bool nameValidate = false;
  bool specialityValidate = false;
  bool addressValidate = false;
  bool mobileValidate = false;
  String? passwordValidation = "Write new password !";

  bool isWantChangePassword = false;
  bool isVisibleSignup = false;

  late String _name;
  late String _email;
  late String? _specialty;
  late String _address;
  late String _mobileNumber;
  late String? _imageUrl;


  @override
  void initState() {
    super.initState();
    _name = widget.name;
    _email = widget.email;
    _specialty = widget.specialty;
    _address = widget.address;
    _mobileNumber = widget.mobileNumber;
    _imageUrl = widget.imageUrl;
    birthdateController.text = widget.birthdate;
  }

  @override
  void dispose() {
    birthdateController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (isWantChangePassword || _name != widget.name || _specialty != widget.specialty ||
          _address != widget.address || _mobileNumber != widget.mobileNumber ||
          birthdateController.text != widget.birthdate || selectedImage != null) {

        if(!nameValidate && !specialityValidate && !addressValidate && !mobileValidate){
          if((isWantChangePassword && passwordValidation == null) || !isWantChangePassword){

            setState(() {
              isUpdatingData = true;
            });
            if(selectedImage != null){
              _imageUrl = await FbFiles.uploadImage(context, selectedImage!.file, selectedImage!.name);
            }

            await FbAuthentication.updateUserData(context, _name, _email, _address, _mobileNumber, birthdateController.text, _imageUrl, _specialty);
            if(isWantChangePassword && passwordValidation == null){
              await FbAuthentication.updatePassword(newPasswordController.text.toString().trim());
            }

            if(_specialty != null) {
              FbArticlesFunctions.updateDoctorDataInArticles(context, _email, _name, _imageUrl, _specialty!);
            }
            FbCommentsFunctions.updateUserDataInComments(context, _email, _name, _imageUrl);

            setState(() {
              isUpdatingData = false;
            });
            Navigator.pop(context, 'Update data');
          }
        }
      }else{
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isUpdatingData
          ? null
          : AppBar(
              title: const Text('Edit Data'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _submitForm,
                ),
              ],
            ),
      body: isUpdatingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          selectedImage != null
                              ? InkWell(
                                  onTap: () {
                                    DetailScreen(
                                        imagePath: selectedImage!.file.path);
                                  },
                                  child: Hero(
                                    tag: selectedImage!.file.path,
                                    child: CircleAvatar(
                                      radius: 80,
                                      backgroundImage: FileImage(File(selectedImage!.file.path)),
                                    ),
                                  ),
                                )
                              : _imageUrl != null
                                  ? InkWell(
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) =>
                                            ShowImageScreen(uri: _imageUrl!, isWantDownload: false),
                                        ));
                                      },
                                      child: Hero(
                                        tag: _imageUrl!,
                                        child: CircleAvatar(
                                          radius: 80,
                                          backgroundImage: NetworkImage(_imageUrl!),
                                        ),
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: 80,
                                      backgroundColor: kMainColorLight,
                                      child: Text(
                                        AllFunctions.getFirstLetter(widget.name),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 30,
                                        ),
                                      ),
                                    ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: () async {
                                ImagePicker imagePicker = ImagePicker();
                                XFile? file = await imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 50);

                                if (file != null) {
                                  setState(() {
                                    String imageName = DateTime.now().millisecondsSinceEpoch.toString();
                                    selectedImage = SelectedFile(file, imageName);
                                  });
                                }
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
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        initialValue: _name,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          // labelText: 'الإسم',
                          errorText: nameValidate
                              ? _name.isEmpty
                                  ? 'Write your name'
                                  : "Write your full name"
                                  // ? 'أكتب إسمك'
                                  // : "أكتب إسمك كامل"
                              : null,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _name = value.toString().trim();
                            nameValidate =
                                _name.isEmpty || !_name.contains(" ");
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        readOnly: true,
                        initialValue: _email,
                        decoration: const InputDecoration(
                          labelText: 'Email (doesn\'t change)',
                          // labelText: 'الإيميل (لا يمكن تغييره)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      _specialty != null ? kSizeBoxH16 : kSizeBoxEmpty,
                      _specialty != null
                          ? TextFormField(
                              initialValue: _specialty,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                labelText: 'Specialty',
                                // labelText: 'التخصص',
                                errorText: specialityValidate
                                    ? 'Specialty can\'t be empty'
                                    // ? 'أكتب تخصصك !!'
                                    : null,
                                border: const OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _specialty = value.toString().trim();
                                  specialityValidate = _specialty!.isEmpty;
                                });
                              },
                            )
                          : kSizeBoxEmpty,
                      kSizeBoxH16,
                      TextFormField(
                        initialValue: _address,
                        keyboardType: TextInputType.streetAddress,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          // labelText: 'العنوان',
                          errorText: addressValidate
                              ? 'Please enter your address'
                              // ? 'أدخل عنوانك من فضلك'
                              : null,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _address = value.toString().trim();
                            addressValidate = _address.isEmpty;
                          });
                        },
                      ),
                      kSizeBoxH16,
                      TextFormField(
                        initialValue: _mobileNumber,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Mobile Number',
                          // labelText: 'رقم الجوال',
                          errorText: mobileValidate
                              ? _mobileNumber.isEmpty
                                  ? 'Please enter your mobile number'
                                  : "The mobile number is not valid"
                                  // ? 'أدخل رقم جوالك من فضلك'
                                  // : "هذا الرقم غير صالح !"
                              : null,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _mobileNumber = value.toString().trim();
                            mobileValidate = _mobileNumber.isEmpty || _mobileNumber.length <= 8;
                          });
                        },
                      ),
                      kSizeBoxH16,
                      TextFormField(
                        controller: birthdateController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Birthdate',
                          // labelText: 'تاريخ ميلادك',
                          border: OutlineInputBorder(),
                        ),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1930),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            String formattedDate =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                            setState(() {
                              birthdateController.text = formattedDate;
                              log(birthdateController.text);
                            });
                          }
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: isWantChangePassword,
                            onChanged: (v) {
                              setState(() {
                                newPasswordController.clear();
                                isWantChangePassword = !isWantChangePassword;
                              });
                            },
                          ),
                          const Text("Do you want change password ?"),
                          // const Text("هل تريد تغيير كلمة المرور ؟"),
                        ],
                      ),
                      kSizeBoxH8,
                      isWantChangePassword
                          ? TextFormField(
                              controller: newPasswordController,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: !isVisibleSignup,
                              decoration: InputDecoration(
                                labelText: 'New password',
                                // labelText: 'كلمة المرور الجديدة',
                                errorText: passwordValidation,
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isVisibleSignup = !isVisibleSignup;
                                    });
                                  },
                                  icon: isVisibleSignup
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
                                setState(() {
                                  if (value.toString().trim().isEmpty) {
                                    passwordValidation = "Write new password!";
                                    // passwordValidation = "أكتب كلمة المرور الجديدة!";
                                  } else if (value.toString().trim().length <
                                      6) {
                                    passwordValidation = "The password is short, it must be longer than 5 characters";
                                    // passwordValidation = "لا يمكن أن تكون كلمة المرور أقل من 5 حروف !";
                                  } else {
                                    passwordValidation = null;
                                  }
                                });
                              },
                            )
                          : kSizeBoxEmpty,
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

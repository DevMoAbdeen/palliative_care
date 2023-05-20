import 'package:flutter/foundation.dart';
import 'package:palliative_care/models/user.dart';


class UserProvider with ChangeNotifier{

  UserModel? _currentUser;
  DoctorModel? _currentDoctor;

  UserModel? get getCurrentUser => _currentUser;
  DoctorModel? get getCurrentDoctor => _currentDoctor;

  void setDataCurrentUser(UserModel user){
    _currentUser = user;
    notifyListeners();
  }

  void setDataCurrentDoctor(DoctorModel doctor){
    _currentDoctor = doctor;
    notifyListeners();
  }

  void resetData(){
    _currentUser = null;
    _currentDoctor = null;
    notifyListeners();
  }

}
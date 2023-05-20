import 'package:flutter/foundation.dart';
import 'package:palliative_care/models/topic.dart';


class TopicsProvider with ChangeNotifier{
  List<Topic> _allTopics = [];

  int get allTopicsLength => _allTopics.length;

  List<Topic> get getAllTopics => _allTopics;

  void setDataTopics(List<Topic> allTopics){
    _allTopics = allTopics;
    notifyListeners();
  }

  void addTopic(Topic topic){
    _allTopics.add(topic);
    notifyListeners();
  }

  void updateTopic(Topic topic, String newName, String newDescription, String date){
    topic.title = newName;
    topic.description = newDescription;
    topic.updatedAt = date;
    notifyListeners();
  }

  void deleteTopic(Topic topic){
    _allTopics.remove(topic);
    notifyListeners();
  }

  void resetAllData(){
    _allTopics.clear();
  }
}
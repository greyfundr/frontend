import 'dart:io';
import 'dart:math';
import 'participants_model.dart';
import 'budget_model.dart';
// import 'dart:convert';

class Campaign {
  int id = 0;
  String title = '';
  String description = '';
  File? imageUrl; 
  String startDate = '';
  String endDate = '';
  String sharetitle = '';
  double amount = 0.0;
  String category = '';

  List<Participant> participants = [];
  List<File> images = []; 
  List<Map<String, String>> buget = [];
  List<Map<String, String>> savedAutoOffers = [];
  List<Map<String, String>> savedManualOffers = [];
  DateTime? createdAt;
  double currentAmount = 0.0;
  List<Expense> budgets = [];

  Campaign(String name, String desc, String aCategory, List<Map<String, String>> mOffers, List<Map<String, String>> aOffers) {
    title = name;
    description = desc;
    category = aCategory;
    savedAutoOffers = aOffers;
    savedManualOffers = mOffers;
  }

  // NEW: Copy constructor — THIS FIXES YOUR ERROR
  Campaign.from(Campaign other)
      : id = other.id,
        title = other.title,
        description = other.description,
        imageUrl = other.imageUrl,
        startDate = other.startDate,
        endDate = other.endDate,
        amount = other.amount,
        category = other.category,
        participants = other.participants.map((p) => Participant.from(p)).toList(),
        images = List<File>.from(other.images),
        savedAutoOffers = List<Map<String, String>>.from(other.savedAutoOffers),
        savedManualOffers = List<Map<String, String>>.from(other.savedManualOffers),
        createdAt = other.createdAt,
        currentAmount = other.currentAmount;

  // Your existing setter methods (kept all of them)
  void setName(String newName) => title = newName;

  void setId(int id) => this.id = id;

  void setCurrentAmount(double currentAmount) => this.currentAmount = currentAmount;

  void setCampaignDetails(
    String startDate, 
    String endDate, 
    File mainImage, 
    double amount, 
    
    List<Participant> participant, 
    List<File> image,
    List<Expense> budget) {
      
    this.startDate = startDate;
    this.endDate = endDate;
    imageUrl = mainImage;
    this.amount = amount;
    participants = participant;
    images = image;
    sharetitle = generateRandomStringFromChars(10,title);
    budgets = budget;
  }

  void setCreationTime(DateTime createdAt) => this.createdAt = createdAt;

  void setImages(List<File> image) => images = image;

  void setParticipants(List<Participant> participant) => participants = participant;

  String generateRandomStringFromChars(int length, String characterSet) {
    final Random random = Random();
    final StringBuffer result = StringBuffer();

    for (int i = 0; i < length; i++) {
      final int randomIndex = random.nextInt(characterSet.length);
      result.write(characterSet[randomIndex]);
    }
    return result.toString();
  }

  // Fixed: You had a wrong method named setStartDate that was setting images!
  // Removed it — use setCampaignDetails instead

  Map<String, dynamic> toJson() {
    return {
      'name': title,
      'value': description,
      'budgets' : budgets[0].toJson(),
      // Add more fields when sending to backend
    };
  }
}
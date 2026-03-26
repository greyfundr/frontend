// To parse this JSON data, do
//
//     final placeAutocompleteModel = placeAutocompleteModelFromJson(jsonString);

import 'dart:convert';

PlaceAutocompleteModel placeAutocompleteModelFromJson(String str) =>
    PlaceAutocompleteModel.fromJson(json.decode(str));

String placeAutocompleteModelToJson(PlaceAutocompleteModel data) =>
    json.encode(data.toJson());

class PlaceAutocompleteModel {
  List<Prediction>? predictions;

  PlaceAutocompleteModel({
    this.predictions,
  });

  factory PlaceAutocompleteModel.fromJson(Map<String, dynamic> json) =>
      PlaceAutocompleteModel(
        predictions: json["predictions"] == null
            ? []
            : List<Prediction>.from(
                json["predictions"]!.map((x) => Prediction.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "predictions": predictions == null
            ? []
            : List<dynamic>.from(predictions!.map((x) => x.toJson())),
      };
}

class Prediction {
  String? description;
  String? placeId;

  Prediction({
    this.description,
    this.placeId,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) => Prediction(
        description: json["description"],
        placeId: json["place_id"],
      );

  Map<String, dynamic> toJson() => {
        "description": description,
        "place_id": placeId,
      };
}

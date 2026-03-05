// class ProductResponse {
//   List<Data>? data;
//
//   ProductResponse({this.data});
//
//   ProductResponse.fromJson(Map<String, dynamic> json) {
//     if (json['Data'] != null) {
//       data = <Data>[];
//       json['Data'].forEach((v) {
//         data!.add(new Data.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.data != null) {
//       data['Data'] = this.data!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class Data {
//   int? pKID;
//   String? productName;
//   String? iconURL;
//   int? unReadCount;
//   int? fKOpenLeadID;
//   String? leadID;
//
//   Data(
//       {this.pKID,
//         this.productName,
//         this.iconURL,
//         this.unReadCount,
//         this.fKOpenLeadID,
//         this.leadID});
//
//   Data.fromJson(Map<String, dynamic> json) {
//     pKID = json['PKID'];
//     productName = json['ProductName'];
//     iconURL = json['IconURL'];
//     unReadCount = json['UnReadCount'];
//     fKOpenLeadID = json['FKOpenLeadID'];
//     leadID = json['LeadID'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['PKID'] = this.pKID;
//     data['ProductName'] = this.productName;
//     data['IconURL'] = this.iconURL;
//     data['UnReadCount'] = this.unReadCount;
//     data['FKOpenLeadID'] = this.fKOpenLeadID;
//     data['LeadID'] = this.leadID;
//     return data;
//   }
// }

class ProductResponse {
  List<ProductData> data;

  ProductResponse({required this.data});

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      data: json['Data'] != null
          ? List<ProductData>.from(
          json['Data'].map((x) => ProductData.fromJson(x)))
          : [],
    );
  }
}

class ProductData {
  final int pKID;
  final String productName;
  final String iconURL;
  int unReadCount;
  final int fKOpenLeadID;
  final String leadID;

  ProductData({
    required this.pKID,
    required this.productName,
    required this.iconURL,
    required this.unReadCount,
    required this.fKOpenLeadID,
    required this.leadID,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      pKID: json['PKID'] ?? 0,
      productName: json['ProductName'] ?? "",
      iconURL: json['IconURL'] ?? "",
      unReadCount: json['UnReadCount'] ?? 0,
      fKOpenLeadID: json['FKOpenLeadID'] ?? 0,
      leadID: json['LeadID'] ?? "",
    );
  }
}
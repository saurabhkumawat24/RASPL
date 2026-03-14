class LeadReopenModel {
  List<Data>? data;

  LeadReopenModel({this.data});

  LeadReopenModel.fromJson(Map<String, dynamic> json) {
    if (json['Data'] != null) {
      data = <Data>[];
      json['Data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['Data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  dynamic result;
  dynamic msg;
  dynamic pKID;
  dynamic fKUserID;

  Data({this.result, this.msg, this.pKID, this.fKUserID});

  Data.fromJson(Map<String, dynamic> json) {
    result = json['Result'];
    msg = json['Msg'];
    pKID = json['PKID'];
    fKUserID = json['FKUserID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Result'] = this.result;
    data['Msg'] = this.msg;
    data['PKID'] = this.pKID;
    data['FKUserID'] = this.fKUserID;
    return data;
  }
}

class LoginResponse {
  List<Data>? data;

  LoginResponse({this.data});

  LoginResponse.fromJson(Map<String, dynamic> json) {
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
  int? result;
  String? msg;
  String? userToken;
  String? deviceToken;
  int? pKUserID;
  String? roleType;
  String? name;
  String? loginID;
  int? fKRoleGroupID;
  int? fKCompanyID;
  int? fKRoleGroupID1;
  String? websiteURL;
  String? photoURL;
  String? companyName;
  String? dateForStr;
  int? pKCurrencyID;
  String? symbol;
  String? orgTypeID;
  String? orgType;
  int? fKDashboardID;

  Data(
      {this.result,
        this.msg,
        this.userToken,
        this.deviceToken,
        this.pKUserID,
        this.roleType,
        this.name,
        this.loginID,
        this.fKRoleGroupID,
        this.fKCompanyID,
        this.fKRoleGroupID1,
        this.websiteURL,
        this.photoURL,
        this.companyName,
        this.dateForStr,
        this.pKCurrencyID,
        this.symbol,
        this.orgTypeID,
        this.orgType,
        this.fKDashboardID});

  Data.fromJson(Map<String, dynamic> json) {
    result = json['Result'];
    msg = json['Msg'];
    userToken = json['UserToken'];
    deviceToken = json['DeviceToken'];
    pKUserID = json['PKUserID'];
    roleType = json['RoleType'];
    name = json['Name'];
    loginID = json['LoginID'];
    fKRoleGroupID = json['FKRoleGroupID'];
    fKCompanyID = json['FKCompanyID'];
    fKRoleGroupID1 = json['FKRoleGroupID1'];
    websiteURL = json['WebsiteURL'];
    photoURL = json['PhotoURL'];
    companyName = json['CompanyName'];
    dateForStr = json['DateForStr'];
    pKCurrencyID = json['PKCurrencyID'];
    symbol = json['Symbol'];
    orgTypeID = json['OrgTypeID'];
    orgType = json['OrgType'];
    fKDashboardID = json['FKDashboardID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Result'] = this.result;
    data['Msg'] = this.msg;
    data['UserToken'] = this.userToken;
    data['DeviceToken'] = this.deviceToken;
    data['PKUserID'] = this.pKUserID;
    data['RoleType'] = this.roleType;
    data['Name'] = this.name;
    data['LoginID'] = this.loginID;
    data['FKRoleGroupID'] = this.fKRoleGroupID;
    data['FKCompanyID'] = this.fKCompanyID;
    data['FKRoleGroupID1'] = this.fKRoleGroupID1;
    data['WebsiteURL'] = this.websiteURL;
    data['PhotoURL'] = this.photoURL;
    data['CompanyName'] = this.companyName;
    data['DateForStr'] = this.dateForStr;
    data['PKCurrencyID'] = this.pKCurrencyID;
    data['Symbol'] = this.symbol;
    data['OrgTypeID'] = this.orgTypeID;
    data['OrgType'] = this.orgType;
    data['FKDashboardID'] = this.fKDashboardID;
    return data;
  }
}

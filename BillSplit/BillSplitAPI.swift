//
//  BillSplitAPI.swift
//  BillSplit
//
//  Created by Chijioke on 5/24/20.
//  Copyright © 2020 Chijioke. All rights reserved.
//

import Moya

struct AuthParameter: RequestParam {
  var name: String?
  let email: String
  let password: String
}

struct GroupRequest: RequestParam {
  let name: String
}

struct FriendRequest: RequestParam {
  let name: String
  let groupId: Int
}

struct ExpenseRequest: RequestParam {
  let amount: Double
  let payerId: Int
  let groupId: Int
  let participants: [Int]
}

protocol RequestParam: Codable {}

extension RequestParam {
  var JSON: [String: Any] {
    guard let data = try? JSONEncoder().encode(self),
      let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    else { return [:] }

    return json
  }
}

enum BillSplitAPI {
  case signup(AuthParameter)
  case logIn(AuthParameter)
  case signOut

  // Groups
  case getGroup(Int)
  case allGroups
  case createGroup(GroupRequest)
  case addFriendToGroup(FriendRequest)

  // Expense
  case addExpense(ExpenseRequest)
}

extension BillSplitAPI: TargetType {
  var path: String {
    switch self {
    case .signup:
      return "/users/signup"
    case .logIn:
      return "/users/login"
    case .signOut:
      return "/users/signout"

    // Groups
    case let .getGroup(id):
      return "/groups/\(id)"
    case .allGroups, .createGroup:
      return "/groups"
    case let .addFriendToGroup(request):
      return "/groups/\(request.groupId)"

    // Expense
    case .addExpense:
      return "/bills"
    }
  }

  var method: Method {
    switch self {
    case .signup, .logIn, .signOut, .createGroup, .addFriendToGroup, .addExpense:
      return .post
    case .getGroup, .allGroups:
      return .get
    }
  }

  var sampleData: Data {
    return Data()
  }

  var task: Task {
    switch self {
    case let .signup(request as RequestParam),
         let .logIn(request as RequestParam),
         let .addFriendToGroup(request as RequestParam),
         let .createGroup(request as RequestParam),
         let .addExpense(request as RequestParam):
      return .requestParameters(parameters: request.JSON, encoding: JSONEncoding())

    case .getGroup, .allGroups, .signOut:
      return .requestPlain
    }
  }

  var headers: [String: String]? {
    guard let token = UserDefaults.standard.string(forKey: "auth_token") else {
      return [:]
    }
    switch self {
    case .signup, .logIn: return [:]
    default:
      return [
        "Authorization": "Bearer \(token)",
      ]
    }
  }

  public var baseURL: URL { return URL(string: Natrium.Config.apiEndpoint)! }
}

let loggerPlugin = NetworkLoggerPlugin(
  configuration: .init(formatter: .init(responseData: { (data) -> (String) in
    do {
      let dataAsJSON = try JSONSerialization.jsonObject(with: data)
      let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
      return String(data: prettyData, encoding: .utf8)!
    } catch {
      // fallback to original data if it can't be serialized.
      return String(data: data, encoding: .utf8)!
    }
  }),
                       logOptions: .verbose)
)

let billApi = MoyaProvider<BillSplitAPI>(plugins: [loggerPlugin])

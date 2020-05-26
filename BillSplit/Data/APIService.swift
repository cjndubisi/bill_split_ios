//
//  APIService.swift
//  BillSplit
//
//  Created by Chijioke on 5/25/20.
//  Copyright © 2020 Chijioke. All rights reserved.
//

import Moya
import RxSwift

protocol AuthService {
  func signUp(params: AuthParameter) -> Single<AuthResponse>
  func login(params: AuthParameter) -> Single<AuthResponse>
}

protocol GroupRequest: AnyObject {
  func all() -> Single<[Group]>
  func add(expense: ExpenseRequest) -> Single<Bill>
  func add(member: MemberRequest) -> Single<[User]>
  func get(group: Int) -> Single<Group>
}

// MARK: BillAPIService

class BillAPIService {}

public extension PrimitiveSequence where Trait == SingleTrait, Element == Response {
  func mapServerError() -> Single<Element> {
    return flatMap { response in
      guard let json = try? response.mapJSON(failsOnEmptyData: true) else {
        return .just(response)
      }
      guard (try? response.filterSuccessfulStatusCodes()) != nil else {
        if let res = json as? [String: Any], let message = res["message"] {
          throw NSError(domain: "API", code: 33, userInfo: [NSLocalizedDescriptionKey: message])
        }
        return .just(response)
      }
      return .just(response)
    }
  }
}

extension BillAPIService: AuthService {
  func signUp(params: AuthParameter) -> Single<AuthResponse> {
    return billApi.rx.request(.signup(params)).mapServerError()
      .map(AuthResponse.self)
  }

  func login(params: AuthParameter) -> Single<AuthResponse> {
    return billApi.rx.request(.login(params)).mapServerError().map(AuthResponse.self)
  }
}

extension BillAPIService: GroupRequest {
  func all() -> Single<[Group]> {
    billApi.rx.request(.allGroups).mapServerError().map([Group].self)
  }

  func get(group: Int) -> Single<Group> {
    billApi.rx.request(.getGroup(group)).mapServerError().map(Group.self)
  }

  func add(member: MemberRequest) -> Single<[User]> {
    billApi.rx.request(.addFriendToGroup(member)).mapServerError().map(Group.self).map({ $0.users })
  }

  func add(expense: ExpenseRequest) -> Single<Bill> {
    billApi.rx.request(.addExpense(expense)).mapServerError().map(Bill.self)
  }
}

protocol ListableService {
  associatedtype Item
  func list(page: Int) -> Single<[Item]>
}

class ListableClosureService<Item>: ListableService {
  let provider: () -> Single<[Item]>
  init(provider: @escaping () -> Single<[Item]>) {
    self.provider = provider
  }

  func list(page _: Int) -> Single<[Item]> {
    return provider()
  }
}

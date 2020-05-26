//
//  APIService.swift
//  BillSplit
//
//  Created by Chijioke on 5/25/20.
//  Copyright © 2020 Chijioke. All rights reserved.
//

import RxSwift

protocol AuthService {
  func signUp(params: AuthParameter) -> Single<AuthResponse>
  func login(params: AuthParameter) -> Single<AuthResponse>
}

protocol GroupRequest: AnyObject {
  func all() -> Single<[Group]>
  func add(expense: ExpenseRequest) -> Single<Group>
  func get(group: Int) -> Single<Group>
}

// MARK: BillAPIService

class BillAPIService {}

extension BillAPIService: AuthService {
  func signUp(params: AuthParameter) -> Single<AuthResponse> {
    return billApi.rx.request(.signup(params)).map(AuthResponse.self)
  }

  func login(params: AuthParameter) -> Single<AuthResponse> {
    return billApi.rx.request(.login(params)).map(AuthResponse.self)
  }
}

extension BillAPIService: GroupRequest {
  func all() -> Single<[Group]> {
    billApi.rx.request(.allGroups).map([Group].self)
  }

  func get(group: Int) -> Single<Group> {
    billApi.rx.request(.getGroup(group)).map(Group.self)
  }

  func add(expense: ExpenseRequest) -> Single<Group> {
    billApi.rx.request(.addExpense(expense)).map(Group.self)
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

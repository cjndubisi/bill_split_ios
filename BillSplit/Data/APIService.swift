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

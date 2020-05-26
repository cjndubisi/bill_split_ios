//
//  Model+RxDataSource.swift
//  BillSplit
//
//  Created by Chijioke on 5/26/20.
//  Copyright © 2020 Chijioke. All rights reserved.
//

import RxDataSources

extension Group: IdentifiableType {
  typealias Identity = Int

  var identity: Int {
    return id
  }
}

extension Bill: IdentifiableType {
  typealias Identity = Int

  var identity: Int {
    return id
  }
}

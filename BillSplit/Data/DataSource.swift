//
//  DataSource.swift
//  BillSplit
//
//  Created by Chijioke on 5/25/20.
//  Copyright © 2020 Chijioke. All rights reserved.
//

import RxCocoa
import RxSwift

class DataSource<S: ListableService> {
  let provider: S

  // State
  var isFetching: Bool { return fetching.value }
  var data: [S.Item] { return dataRelay.value }
  var isEmpty: Bool { return !isFetching && data.isEmpty }

  // RX
  let reload: AnyObserver<Void>
  let errors = PublishSubject<Error>()
  private(set) var disposable: CompositeDisposable!

  let fetching: BehaviorRelay<Bool>
  private var dataRelay: BehaviorRelay<[S.Item]>!
  private(set) var value: Observable<[S.Item]>!
  private let loadNext: AnyObserver<Void>

  init(source: S, initial: [S.Item] = []) {
    provider = source

    let request = PublishSubject<Void>()
    let reloader = PublishSubject<Void>()
    let relay = BehaviorRelay<[S.Item]>(value: [])

    // Initialze Self
    fetching = BehaviorRelay(value: false)
    loadNext = request.asObserver()
    reload = reloader.asObserver()

    weak var this = self

    let pagingRequest = request
      .observeOn(MainScheduler.instance)
      .flatMapLatest({ this?.load() ?? .just([]) })

    let reloadRequest = reloader
      .observeOn(MainScheduler.instance)
      .flatMapLatest({ this?.load() ?? .just([]) })

    let reloadToken = Observable.merge(reloadRequest, pagingRequest)
      .observeOn(MainScheduler.instance)
      .do(onNext: { _ in this?.fetching.accept(false) })
      .bind(to: relay)

    dataRelay = relay
    value = relay
      .share(replay: 1, scope: .whileConnected)
      .do(onSubscribed: { [weak self] in
        guard let self = self else { return }
        if self.data.isEmpty, !self.isFetching {
          self.reload.onNext(())
        }
      })

    dataRelay.accept(initial)
    disposable = CompositeDisposable(disposables: [reloadToken])
  }

  private func request(reload _: Bool) -> Single<[S.Item]> {
    return provider.list(page: 1)
      .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
      .do(onError: { [weak self] in self?.errors.onNext($0) })
      .catchErrorJustReturn([])
  }

  private func load(willReload reload: Bool = false) -> Single<[S.Item]> {
    fetching.accept(true)
    return request(reload: reload).do(onError: { [weak errors, weak fetching] in
      fetching?.accept(false)
      errors?.on(.next($0))
    })
  }
}

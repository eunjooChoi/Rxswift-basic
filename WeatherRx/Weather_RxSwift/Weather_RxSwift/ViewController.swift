//
//  ViewController.swift
//  Weather_RxSwift
//
//  Created by 최은주 on 6/18/24.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    @IBOutlet weak var searchCityName: UITextField!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 화면이 로드되고 난 이후에 subscribe
        // 나중에 구독하면 이벤트를 놓치거나 데이터 바인딩 전에 UI의 일부가 표시될 수 있음
        
        // flatMapLatest: 가장 최근에 생성한 Observable의 값만 받아 처리
        // share: Subscribe()할때마다 새로운 Observable 시퀀스가 생성되지 않고, 하나의 시퀀스에서 방출되는 아이템을 공유해 사용할 수 있습니다. (https://jusung.github.io/shareReplay/)
        
        let searchInput = searchCityName.rx.controlEvent(.editingDidEndOnExit).asObservable()
            .map { self.searchCityName.text }
            .filter { ($0 ?? "").count > 0 }
        
        // search로 선언하면 모든 label의 값을 subscribe로 한번에 관리하는 것이 아니라 아래처럼 각 라벨별로 분리해서 관리가 가능하다. (코드가 길지 않아 가독성에도 좋음)
        let search = searchInput.flatMap { text in
                return APIController.shared.currentWeather(city: text ?? "Error")
                    .catchAndReturn(APIController.Weather.empty)
            }
            .asDriver(onErrorJustReturn: APIController.Weather.empty)
        
        search.map { "\($0.temp)°C" }
            .drive(temperatureLabel.rx.text)
            .disposed(by: bag)
        
        search.map { $0.icon }
            .drive(iconLabel.rx.text)
            .disposed(by: bag)
        
        search.map { "\($0.humidity)%" }
            .drive(humidityLabel.rx.text)
            .disposed(by: bag)
        
        search.map { $0.cityName }
            .drive(cityNameLabel.rx.text)
            .disposed(by: bag)
        
        let running = Observable.from([
            searchInput.map { _ in true },
            search.map { _ in false }.asObservable()
        ])
            .merge()
            .startWith(true)
            .asDriver(onErrorJustReturn: false)
        
        running
            .skip(1)
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: bag)
        
        running
            .drive(temperatureLabel.rx.isHidden)
            .disposed(by: bag)
        
        running
            .drive(iconLabel.rx.isHidden)
            .disposed(by: bag)
        
        running
            .drive(humidityLabel.rx.isHidden)
            .disposed(by: bag)
        
        running
            .drive(cityNameLabel.rx.isHidden)
            .disposed(by: bag)
    }
    
    
}

//
//  MockWeatherService.swift
//  NewsTests
//
//  Created by QBUser on 16/07/22.
//  Copyright © 2022 Алексей Воронов. All rights reserved.
//

import Combine
import Foundation
@testable import News

class MockWeatherService: WeatherServiceProtocol {

    var givenAnyPublisher: AnyPublisher<Data, Error>?
    var givenCity: String?

    func getCityName(completion: @escaping (LocationNameResultType) -> Void) {
        if let city = givenCity {
            completion(.success(city))
        }
        else {
            fatalError("Insufficient data")
        }
    }

    func requestCurrentWeather() -> AnyPublisher<Data, Error> {
        if let givenAnyPublisher = givenAnyPublisher {
            return givenAnyPublisher
        }
        else {
            fatalError("Insufficient data")
        }
    }
}

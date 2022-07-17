//
//  WeatherViewModelTest.swift
//  NewsTests
//
//  Created by QBUser on 16/07/22.
//  Copyright © 2022 Алексей Воронов. All rights reserved.
//


import XCTest
import Combine
@testable import News

class WeatherViewModelTest: XCTestCase {

    var sut: WeatherViewModel!
    var weatherService: MockWeatherService!
    var cancellable: Set<AnyCancellable>!

    override func setUpWithError() throws {
        weatherService = MockWeatherService()
        sut = WeatherViewModel(weatherService: weatherService)
        cancellable = []
    }

    override func tearDownWithError() throws {
        sut = nil
        weatherService = nil
        cancellable = nil
    }

    func test_getCityName() {
        //Give
        let expectedCity = "japan"
        weatherService.givenCity = expectedCity

        //Act
        sut.getCityName()

        //Check
        XCTAssert(expectedCity == sut.locationName, "Expecting \(expectedCity) but got \(sut.locationName) instead")
    }

    func test_requestCurrentWeather_with_Valid_weatherRespnse_NoError() {
        // Prepare - Fake Weather Data
        let dummyWeather = Weather(time: Date.now, icon: WeatherIcon.clearDay, temperature: 120)
        let dummyHWD = HourlyWeatherData(summary: "This is a dummy summary", data: [dummyWeather])
        let dummyDWD = DailyWeatherData(data: [DailyWeather(time: Date.now, icon: .clearDay, temperatureHigh: 100, temperatureLow: 100)])

        let expectedWeatherResponse = WeatherResponse(currently: dummyWeather, hourly: dummyHWD, daily: dummyDWD)

        let data = try! JSONEncoder().encode(expectedWeatherResponse)

        weatherService.givenAnyPublisher = CurrentValueSubject(data).eraseToAnyPublisher()

        // Before Act
        XCTAssertNil(sut?.weather, "weather has value instead of nil before calling weather service")

        // Act
        sut.getCurrentWeather()

        let expectation = expectation(description: "k")
        RunLoop.main.run(mode: .default, before: .distantPast)

        //Check
        sut.$weather
            .sink(receiveCompletion: { _ in },
                  receiveValue: { actualWeatherResponse in

                XCTAssertNotNil(actualWeatherResponse, "weather found nil after calling weatherService")
                XCTAssertEqual(expectedWeatherResponse.currently.temperature, actualWeatherResponse!.currently.temperature)
                expectation.fulfill()
            })
            .store(in: &cancellable)
        waitForExpectations(timeout: 10)
    }

    func test_requestCurrentWeather_with_Invalid_weatherRespnse_Error() {
        // Prepare - Fake Weather Data
        let dummyWeather = Weather(time: Date.now, icon: WeatherIcon.clearDay, temperature: 120)

        let data = try! JSONEncoder().encode(dummyWeather)

        weatherService.givenAnyPublisher = CurrentValueSubject(data).eraseToAnyPublisher()

        // Before Act
        XCTAssertNil(sut?.weather, "weather has value instead of nil before calling weather service")

        // Act
        sut.getCurrentWeather()

        let expectation = expectation(description: "k")
        RunLoop.main.run(mode: .default, before: .distantPast)

        //Check
        sut.$weather
            .sink(receiveCompletion: { _ in },
                  receiveValue: { actualWeatherResponse in
                XCTAssertNil(actualWeatherResponse, "weather should be nil after calling weatherService with invalid weather")
                expectation.fulfill()
            })
            .store(in: &cancellable)
        waitForExpectations(timeout: 10)
    }

}

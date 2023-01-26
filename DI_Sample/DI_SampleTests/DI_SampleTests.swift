//
//  DI_SampleTests.swift
//  DI_SampleTests
//
//  Created by sdk on 29.09.2021.
//

import XCTest
import Swinject

@testable import DI_Sample

extension RepoResponse {
    init(model: RepoModel) {
        name = model.name
        description = model.description
    }
}
extension Response {
    init(modelNetworking: RepoResponse) {
        reposes = [modelNetworking]
        errorMessage = nil
    }
}

class DI_SampleTests: XCTestCase {
    
    private let container = Container()
    
    private let testReposName = "ReposName"
    private let testReposDescription = "ReposDescription"

    override func setUp() {
        super.setUp()
        container.register(RepoModel.self) { resolver in
            return RepoModel(name: self.testReposName, description: self.testReposDescription)
        }
        container.register(RepoResponse.self) { resolver in
            let model = resolver.resolve(RepoModel.self)!
            return RepoResponse(model: model)
        }
        container.register(Response.self) { resolver in
          let modelNetworking = resolver.resolve(RepoResponse.self)!
          return Response(modelNetworking: modelNetworking)
        }
    }

    override func tearDown() {
        super.tearDown()
        container.removeAll()
    }

    func testResponse() {
        let response = container.resolve(Response.self)!
        XCTAssertNotNil(response.reposes)
        XCTAssertEqual(response.reposes![0].name, testReposName)
        XCTAssertEqual(response.reposes![0].description, testReposDescription)
    }
}

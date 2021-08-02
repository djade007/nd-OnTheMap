//
//  ApiClient.swift
//  OnMap
//
//  Created by Olajide Afeez on 01/08/2021.
//

//
//  NetworkClient.swift
//  OnTheMap
//
//  Created by Arno Seidel on 15.12.20.
//

import Foundation

class ApiClient {
    
    struct Auth {
        static var sessionId = ""
        static var userKey = ""
        
        static var firstName = ""
        static var lastName = ""

        static var location: Student? = nil

    }
    
    enum Endpoints {
        
        static let baseUrl = "https://onthemap-api.udacity.com/v1"
        static let limit = 100
        
        case session
        case userData
        case getLocations
        case saveLocation
        case updateLocation(String)
        
        var stringValue: String {
            switch self {
            case .session:
                return Endpoints.baseUrl + "/session"
            case .userData:
                return Endpoints.baseUrl + "/users/" + Auth.userKey
            case .getLocations:
                return Endpoints.baseUrl + "/StudentLocation?limit=\(Endpoints.limit)&order=-updatedAt"
            case .saveLocation:
                return Endpoints.baseUrl + "/StudentLocation"
            case .updateLocation(let id):
                return Endpoints.baseUrl + "/StudentLocation/" + id
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func taskForGETRequest<ResponseType:Decodable>(url: URL, isUdacityAPI: Bool, responseType: ResponseType.Type, completion: @escaping (ResponseType?, StatusResponse?, Error?) -> Void) {

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, nil, error)
                }
                return
            }

            let decoder = JSONDecoder()
            let items = isUdacityAPI ? data.subdata(in: 5..<data.count) : data

            do {
                let responseBody = try decoder.decode(ResponseType.self, from: items)
                DispatchQueue.main.async {
                    completion(responseBody, nil, nil)
                }
            } catch {
                // handle api error
                do {
                    let responseBody = try decoder.decode(StatusResponse.self, from: items)
                    DispatchQueue.main.async {
                        completion(nil, responseBody, error)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, nil, error)
                    }
                }
            }
        }
        task.resume()
    }

    class func taskForPOSTRequest<RequestType:Encodable, ResponseType:Decodable>(url: URL, isUdacityAPI: Bool, body: RequestType, responseType: ResponseType.Type, completion: @escaping (ResponseType?, StatusResponse?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if isUdacityAPI {
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            let items = isUdacityAPI ? data.subdata(in: 5..<data.count) : data
            
            do {
                let responseBody = try decoder.decode(ResponseType.self, from: items)
                DispatchQueue.main.async {
                    completion(responseBody, nil, nil)
                }
            } catch {
                // handle api error
                do {
                    let responseBody = try decoder.decode(StatusResponse.self, from: items)
                    DispatchQueue.main.async {
                        completion(nil, responseBody, error)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, nil, error)
                    }
                }
            }
        }
        task.resume()
    }
    
    class func login(username: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        let body = SessionRequest(udacity: UdacityCredentials(username: username, password: password))
        taskForPOSTRequest(url: Endpoints.session.url, isUdacityAPI: true, body: body, responseType: SessionResponse.self) { (responseObj, status, error) in
            if error == nil {
                Auth.sessionId = responseObj?.session.id ?? ""
                Auth.userKey = responseObj?.account?.key ?? ""
                completion(true, nil)
            } else {
                if let status = status {
                    completion(false, status.message)
                } else {
                    completion(false, error?.localizedDescription)
                }
            }
        }
    }

    class func deleteSession(completion: @escaping (Bool, Error?) -> Void) {
        var request = URLRequest(url: Endpoints.session.url)
        request.httpMethod = "DELETE"
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // clear auth info
            Auth.sessionId = ""
            Auth.userKey = ""
            Auth.firstName = ""
            Auth.lastName = ""
            Auth.location = nil
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            let items = data.subdata(in: 5..<data.count)
            
            do {
                _ = try decoder.decode(SessionResponse.self, from: items)
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
        task.resume()
    }
    
    class func getUserData(completion: @escaping (Bool, String?) -> Void) {
        taskForGETRequest(url: Endpoints.userData.url, isUdacityAPI: true, responseType: UserData.self) { (responseObj, status, error) in
            if error == nil {
                Auth.firstName = responseObj?.firstName ?? ""
                Auth.lastName = responseObj?.lastName ?? ""
                completion(true, nil)
            } else {
                if let status = status {
                    completion(false, status.message)
                } else {
                    completion(false, error?.localizedDescription)
                }
            }
        }
    }

    class func getLocations(completion: @escaping (Bool, String?) -> Void) {
        taskForGETRequest(url: Endpoints.getLocations.url, isUdacityAPI: false, responseType: GetLocationsResponse.self) { (responseObj, status, error) in
            if error == nil {
                MapService.students = responseObj?.results ?? []
                completion(true, nil)
            } else {
                if let status = status {
                    completion(false, status.message)
                } else {
                    completion(false, error?.localizedDescription)
                }
            }
        }
    }

    class func saveLocation(geoLocation: GeoData, completion: @escaping (Bool, String?) -> Void) {
        let body = Student(geoData: geoLocation, firstName: Auth.firstName, lastName: Auth.lastName, uniqueKey: Auth.userKey)
        
        taskForPOSTRequest(url: Endpoints.saveLocation.url, isUdacityAPI: false, body: body, responseType: SaveLocationResponse.self) { (responseObj, status, error) in
            if error == nil {
                print("---------------")
                print(responseObj ?? "Bad")
                Auth.location = Student(baseObj: body, objectId: responseObj?.objectId ?? "", createdAt: responseObj?.createdAt ?? "", updatedAt: nil)
                completion(true, nil)
            } else {
                if let status = status {
                    completion(false, status.message)
                } else {
                    completion(false, error?.localizedDescription)
                }
            }
        }
    }

    class func updateLocation(geoLocation: GeoData, completion: @escaping (Bool, String?) -> Void) {
        var request = URLRequest(url: Endpoints.updateLocation(Auth.location!.objectId!).url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let res = Student(geoData: geoLocation, firstName: Auth.firstName, lastName: Auth.lastName, uniqueKey: Auth.userKey, objectId: Auth.location!.objectId!, createdAt: Auth.location!.createdAt!)
        
        request.httpBody = try! JSONEncoder().encode(res)

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false, error?.localizedDescription)
                }
                return
            }

            let decoder = JSONDecoder()

            do {
                let responseBody = try decoder.decode(PutLocationResponse.self, from: data)
                Auth.location = res
                Auth.location?.updatedAt = responseBody.updatedAt
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch {
                do { // catch HTTP Error response
                    let responseBody = try decoder.decode(StatusResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(false, responseBody.message)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(false, error.localizedDescription)
                    }
                }
            }
        }
        task.resume()
    }
}

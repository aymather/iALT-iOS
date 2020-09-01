//
//  File.swift
//  iALT
//
//  Created by Alec Mather on 8/7/20.
//  Copyright © 2020 Alec Mather. All rights reserved.
//

import Foundation

class NetworkManager {
    
    static let shared = NetworkManager()
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    func createParticipant(data: [String: String], completion: @escaping (Result<ParticipantData, Error>) -> ()) {
        guard let url = URL(string: "http://192.168.1.75:5000/p/new") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: data, options: []) else { return }
        request.httpBody = httpBody
        URLSession.shared.dataTask(with: request) { (data, response, err) in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            do {
                guard let data = data else { return }
                let d = try self.decoder.decode(ParticipantData.self, from: data)
                completion(.success(d))
            } catch {
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }.resume()
    }
    
    func updateParticipant(participant: ParticipantData, sequence: [[Double]], completion: @escaping (Result<UpdateParticipant, Error>) -> ()) {
        guard let url = URL(string: "http://192.168.1.75:5000/p/save") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let p = try self.encoder.encode(participant)
            let data: [String: Any] = [
                "participant": p,
                "sequence": sequence
            ]
            guard let httpBody = try? JSONSerialization.data(withJSONObject: data, options: []) else { return }
            request.httpBody = httpBody
            URLSession.shared.dataTask(with: request) { (data, response, err) in
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
                do {
                    guard let data = data else { return }
                    let d = try self.decoder.decode(UpdateParticipant.self, from: data)
                    completion(.success(d))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
        } catch {
            print(error.localizedDescription)
            completion(.failure(error))
        }
        
    }
    
}

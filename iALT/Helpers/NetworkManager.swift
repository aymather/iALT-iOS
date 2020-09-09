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
    let baseUrl = "https://ialt.alecneuro.com"
    
    func getParticipants(completion: @escaping (Result<[ParticipantData], Error>) -> ()) {
        guard let url = URL(string: self.baseUrl + "/p/all") else { return }
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            if let err = err {
                print(err.localizedDescription)
                completion(.failure(err))
            }
            
            do {
                guard let data = data else { return }
                let d = try self.decoder.decode([ParticipantData].self, from: data)
                completion(.success(d))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func createParticipant(data: [String: String], completion: @escaping (Result<ParticipantData, Error>) -> ()) {
        guard let url = URL(string: self.baseUrl + "/p/new") else { return }
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
        guard let url = URL(string: self.baseUrl + "/p/save") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let data = try self.encoder.encode(UpdateParticipant(participant: participant, sequence: sequence))
            request.httpBody = data
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
            }.resume()
        } catch {
            print(error.localizedDescription)
            completion(.failure(error))
        }
        
    }
    
}

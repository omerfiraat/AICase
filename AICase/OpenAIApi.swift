import Foundation

class ChatService {
    let session: URLSession
    let baseURL = "https://api.openai.com"
    let apiVersion = "v1"
    let apiKey = "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"

    init(session: URLSession = .shared) {
        self.session = session
    }

    func getCompletion(prompt: String, model: String = "davinci:ft-personal:test-02-2023-05-21-11-21-39", completion: @escaping (Result<String, Error>) -> Void) {
        let endpoint = "/completions"
        guard let url = URL(string: baseURL + "/" + apiVersion + endpoint) else {
            print("Invalid URL.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "model": model,
            "prompt": prompt,
            "max_tokens": 100,
            "temperature": 0.4,
            "n": 1,
            "stop": ".\n",
            "stream": false,
            "top_p": 1,
            "presence_penalty": 0,
            "frequency_penalty": 0,
            "best_of": 1,
            "user": "unique_user_id"
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])

        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                let choices = json?["choices"] as? [[String: Any]]
                let text = choices?.first?["text"] as? String

                completion(.success(text ?? ""))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}

//
//  RemoteImageView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 8/25/21.
//

import SwiftUI
import MyDataHelpsKit

class RemoteImageCache: ObservableObject {
    typealias ImageResult = Result<UIImage, MyDataHelpsError>
    
    private var images: [URL: ImageResult]
    private let queue: DispatchQueue
    
    init() {
        self.images = [:]
        self.queue = DispatchQueue(label: "RemoteImageCache")
    }
    
    func load(url: URL, completion: @escaping (ImageResult) -> Void) {
        queue.async {
            self.loadOnQueue(url: url, completion: completion)
        }
    }
    
    private func loadOnQueue(url: URL, completion: @escaping (ImageResult) -> Void) {
        if let existing = images[url] {
            return complete(result: existing, completion: completion)
        }
        do {
            let data = try Data(contentsOf: url)
            guard let image = UIImage(data: data) else {
                throw MyDataHelpsError.unknown(nil)
            }
            let result = store(result: .success(image), for: url)
            complete(result: result, completion: completion)
        } catch {
            let result = store(result: .failure(.decodingError(error)), for: url)
            complete(result: result, completion: completion)
        }
    }
    
    private func store(result: ImageResult, for url: URL) -> ImageResult {
        images[url] = result
        return result
    }
    
    private func complete(result: ImageResult, completion: @escaping (ImageResult) -> Void) {
        DispatchQueue.main.async {
            completion(result)
        }
    }
}

struct RemoteImageView: View {
    @EnvironmentObject private var cache: RemoteImageCache
    
    let url: URL
    let placeholderImageName: String
    @State private var loadedImage: RemoteImageCache.ImageResult? = nil
    
    init(url: URL, placeholderImageName: String) {
        self.url = url
        self.placeholderImageName = placeholderImageName
    }
    
    var body: some View {
        if case let .success(image) = loadedImage {
            Image(uiImage: image)
                .resizable()
        } else {
            Image(placeholderImageName)
                .resizable()
                .onAppear(perform: load)
        }
    }
    
    func load() {
        guard loadedImage == nil else { return }
        cache.load(url: url) {
            loadedImage = $0
        }
    }
}

struct RemoteImageView_Previews: PreviewProvider {
    static var previews: some View {
        RemoteImageView(url: URL(string: "https://developer.mydatahelps.org/assets/images/mydatahelps-logo.png")!, placeholderImageName: "providerLogoPlaceholder")
            .environmentObject(RemoteImageCache())
            .aspectRatio(contentMode: .fit)
            .previewLayout(.fixed(width: 48, height: 48))
    }
}

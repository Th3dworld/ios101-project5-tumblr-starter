//
//  ViewController.swift
//  ios101-project5-tumbler
//

import UIKit
import Nuke
import NukeExtensions

class ViewController: UIViewController, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create the cell
        
        // Configure the cell (i.e. update UI elements like labels, image views, etc.)
        // Get the row where the cell will be placed using the `row` property on the passed in `indexPath` (i.e., `indexPath.row`)
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        
        let post = posts[indexPath.row]
        
        if let photo = post.photos.first {
            let url = photo.originalSize.url
            // Load the photo in the image view via NukeExtensions library...
            NukeExtensions.loadImage(with: url, into: cell.postImageView)
        }
        
        cell.captionLabel?.text = post.summary
        
        // Return the cell for use in the respective table view row
        return cell
    }
    


    @IBOutlet weak var tableView: UITableView!
    
    private var posts: [Post] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        fetchPosts()
    }



    func fetchPosts() {
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork/posts/photo?api_key=1zT8CiXGXFcQDyMFG7RtcfGLwTdDjFUJnZzKJaWTmgyK4lKGYk")!
        let session = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200...299).contains(statusCode) else {
                print("❌ Response error: \(String(describing: response))")
                return
            }

            guard let data = data else {
                print("❌ Data is NIL")
                return
            }

            do {
                let blog = try JSONDecoder().decode(Blog.self, from: data)

                DispatchQueue.main.async { [weak self] in

                    let posts = blog.response.posts
                    self?.posts = posts
                    self?.tableView.reloadData()

                    print("✅ We got \(posts.count) posts!")
                    for post in posts {
                        print("🍏 Summary: \(post.summary)")
                    }
                }

            } catch {
                print("❌ Error decoding JSON: \(error.localizedDescription)")
            }
        }
        session.resume()
    }
}

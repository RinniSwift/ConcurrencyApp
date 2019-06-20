/// Copyright (c) 2019 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

class TiltShiftTableViewController: UITableViewController {
  private let context = CIContext()
  
  private var urls: [URL] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    guard let plist = Bundle.main.url(forResource: "Photos",
                                      withExtension: "plist"),
      let contents = try? Data(contentsOf: plist),
      let serial = try? PropertyListSerialization.propertyList(
        from: contents,
        format: nil),
      let serialUrls = serial as? [String] else {
        print("Something went horribly wrong!")
        return
    }
    urls = serialUrls.compactMap(URL.init)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 50
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "normal", for: indexPath) as! PhotoCell
    
    //let operation = TiltShiftOperation(image: inputImage)
    let operation = NetworkImageOperation(url: urls[indexPath.row])
    operation.completionBlock = {
      DispatchQueue.main.async {
        guard let cell = tableView.cellForRow(at: indexPath) as? PhotoCell else { return }
        cell.isLoading = false
        cell.display(image: operation.image)
      }
    }
    
    let opQueue = OperationQueue()
    opQueue.addOperation(operation)
    let downloadOp = NetworkImageOperation(url: urls[indexPath.row])
    let tiltShiftOp = TiltShiftOperation()
    tiltShiftOp.addDependency(downloadOp)
    tiltShiftOp.completionBlock = {
      DispatchQueue.main.async {
        guard let cell = tableView.cellForRow(at: indexPath)
          as? PhotoCell else { return }
        cell.isLoading = false
        cell.display(image: tiltShiftOp.image)
      }
    }
    
    

    
    
    
//    guard let filter = TiltShiftFilter(image:inputImage, radius:3), let output = filter.outputImage else{
//      print("Failed to generate image")
//      cell.display(image: nil)
//      return cell
//    }
//    let fromRect = CGRect (origin: .zero, size: inputImage.size)
//    guard let cgImage = context.createCGImage(output, from: fromRect) else{
//      print("Image generation failed")
//      cell.display(image:nil)
//      return cell
//    }
//    cell.display(image: UIImage(cgImage:cgImage))
//
    return cell
  }
}

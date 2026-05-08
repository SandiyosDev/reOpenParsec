import UIKit
import MetalKit

class ParsecMetalViewController: ParsecPlayground {

	var metalView: MTKView!
	var metalDevice: MTLDevice!
	var commandQueue: MTLCommandQueue!
	var metalRenderer: ParsecMetalRenderer!
	let updateImage: () -> Void

	let viewController: UIViewController

	required init(viewController: UIViewController, updateImage: @escaping () -> Void) {
		self.viewController = viewController
		self.updateImage = updateImage
	}

	func viewDidLoad() {
		guard let device = MTLCreateSystemDefaultDevice() else { return }
		metalDevice = device
		commandQueue = device.makeCommandQueue()

		metalView = MTKView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
		metalView.device = device
		metalView.colorPixelFormat = .bgra8Unorm
		metalView.framebufferOnly = false
		metalView.isPaused = false
		metalView.enableSetNeedsDisplay = false

		let fps = SettingsHandler.preferredFramesPerSecond
		if fps == 0 {
			metalView.preferredFramesPerSecond = UIScreen.main.maximumFramesPerSecond
		} else {
			metalView.preferredFramesPerSecond = fps
		}

		metalRenderer = ParsecMetalRenderer(metalView, commandQueue, updateImage)
		metalView.delegate = metalRenderer

		viewController.view.addSubview(metalView)
	}

	func cleanUp() {
		metalView?.removeFromSuperview()
	}

	func updateSize(width: CGFloat, height: CGFloat) {
		metalView.frame.size = CGSize(width: width, height: height)
	}
}

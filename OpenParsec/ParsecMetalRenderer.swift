import MetalKit
import ParsecSDK

class ParsecMetalRenderer: NSObject, MTKViewDelegate {
	let commandQueue: MTLCommandQueue
	let updateImage: () -> Void
	var lastWidth: CGFloat = 1.0
	var renderTexture: MTLTexture?

	init(_ view: MTKView, _ commandQueue: MTLCommandQueue, _ updateImage: @escaping () -> Void) {
		self.commandQueue = commandQueue
		self.updateImage = updateImage
		super.init()
	}

	func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
	}

	func draw(in view: MTKView) {
		guard let drawable = view.currentDrawable else { return }
		if CParsec.getStatus() != PARSEC_OK { return }

		let deltaWidth = view.frame.size.width - lastWidth
		if deltaWidth > 0.1 || deltaWidth < -0.1 {
			CParsec.setFrame(view.frame.size.width, view.frame.size.height, view.contentScaleFactor)
			lastWidth = view.frame.size.width
		}

		let fps = SettingsHandler.preferredFramesPerSecond == 0
			? UIScreen.main.maximumFramesPerSecond
			: SettingsHandler.preferredFramesPerSecond
		let timeout = UInt32(max(1000 / fps, 8))

		renderTexture = drawable.texture
		let _ = CParsec.renderMetalFrame(commandQueue, &renderTexture, timeout: timeout)

		guard let cb = commandQueue.makeCommandBuffer() else { return }
		cb.present(drawable)
		cb.commit()

		updateImage()
	}
}

import QuartzCore

extension CAImageCanvasManager: OutBoundsMaskSwitcher {
    func on() {
        CADisableAnimations {
            canvas.masksToBounds = false
            workspace.mask = outBoundsMask
        }
    }

    func off() {
        CADisableAnimations {
            canvas.masksToBounds = true
            workspace.mask = nil
        }
    }
}

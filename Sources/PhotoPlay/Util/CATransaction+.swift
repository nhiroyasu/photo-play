import QuartzCore

func CADisableAnimations(_ block: () -> Void) {
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    block()
    CATransaction.commit()
}

func CAAnimate(
    duration: TimeInterval = 0.3,
    timingFunction: CAMediaTimingFunction = CAMediaTimingFunction(name: .default),
    _ block: () -> Void
) {
    CATransaction.begin()
    CATransaction.setAnimationDuration(duration)
    CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .default))
    block()
    CATransaction.commit()
}

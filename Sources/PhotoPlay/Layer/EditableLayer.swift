import QuartzCore

protocol EditableLayer: Hashable, Identifiable, Equatable {
    var id: UUID { get }
    var isSelectable: Bool { get }
    var isTransformable: Bool { get }
    func drawSelectionFrame(in frame: CGRect)
    func deleteSelectionFrame()
}

import UIKit
import Foundation

/// Draws a color behind the current sentence and word being spoken. Will size the the hightlighting to fit the lines without overlap and removes and extra spacing at the end of the line.
final class HighlightLayoutManager: NSLayoutManager {
    var origin = CGPoint()
    
    override func fillBackgroundRectArray(_ rectArray: UnsafePointer<CGRect>,
                                          count rectCount: Int,
                                          forCharacterRange charRange: NSRange,
                                          color: UIColor) {
        let scale = UIScreen.main.scale
        color.setFill()
        let path = UIBezierPath()
        
        var trimmedRects = [CGRect]()
        
        let currentGlyphRange = glyphRange(forCharacterRange: charRange, actualCharacterRange: nil)
        enumerateLineFragments(forGlyphRange: currentGlyphRange) { rect, usedRect, textContainer, lineGlyphRange, stop in
            
            // Remove the last space from the line
            let trimmedLineRange = {
                let characterRange = self.characterRange(forGlyphRange: lineGlyphRange, actualGlyphRange: nil)
                if let nsString = self.textStorage?.string as NSString? {
                    let sub = nsString.substring(with: characterRange)
                    if sub.last == " " {
                        return NSRange(location: characterRange.location, length: characterRange.length - 1)
                    }
                }
                
                return characterRange
            }()
            
            let intersectionRange = NSIntersectionRange(charRange, trimmedLineRange)
            
            if intersectionRange.length > 0 {
                trimmedRects.append(self.boundingRect(
                    forGlyphRange: self.glyphRange(forCharacterRange: intersectionRange, actualCharacterRange: nil),
                    in: textContainer)
                    .offsetBy(dx: self.origin.x, dy: self.origin.y))
            }
        }
        
        for i in 0..<trimmedRects.count {
            var rect = trimmedRects[i]

            // snap top and bottom to whole device pixels
            let top = snap(rect.minY, scale: scale)
            let bottom = snap(rect.maxY, scale: scale)
            rect.origin.y = top
            rect.size.height = bottom - top

            path.append(UIBezierPath(rect: rect))
        }
        
        path.fill()
    }
    
    override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        self.origin = origin
        super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
    }
    
    private func snap(_ v: CGFloat, scale: CGFloat) -> CGFloat { (v * scale).rounded() / scale }
}

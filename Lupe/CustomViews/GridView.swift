//
//  GridView.swift
//  Infinite-Grid-Swift
//
//  Created by Dave Poirier for ID Fusion Software Inc on 2018-08-10.
//  This is free and unencumbered software released into the public domain.
//
//  For countries not supporting unlicensed code:
//  Copyright (C) 2018 ID Fusion Software Inc. All rights reserved
//  Distributed under the MIT License: https://opensource.org/licenses/MIT

import UIKit
class GridView: UIView {
    @IBOutlet weak var hostScrollView: UIScrollView?
    @IBOutlet weak var topConstraint: NSLayoutConstraint?
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint?
    @IBOutlet weak var leftConstraint: NSLayoutConstraint?
    @IBOutlet weak var rightConstraint: NSLayoutConstraint?

    // arbitraryLargeOffset defines how much user can scroll before hitting the
    // edges of the scrollview and bounce/stop
    var arbitraryLargeOffset: CGFloat = 10000000.0
    //private let arbitraryLargeOffset: CGFloat = 10000000.0

    private(set) var referenceCoordinates: (Int, Int) = (0, 0)
    private(set) var tileSize: CGFloat = 50.0
    private(set) var centreCoordinates: (Int, Int) = (Int.max, Int.max)

    private(set) var observingScrollview: Bool = false

    private var allocatedTiles: [GridTile] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        initializeEngine()
    }
    
    func setTile(amount: CGFloat){
        tileSize = 100 * (amount/arbitraryLargeOffset)
        setNeedsDisplay()
    }
    
    func initializeEngine(){
        defineScrollableArea()
        //centreOurReferenceView()
        allocateInitialTiles()
        observeScrollview()
    }

    deinit {
        if observingScrollview {
            hostScrollView?.removeObserver(self, forKeyPath: "contentOffset")
        }
    }
    
    var shouldSetupConstraints = true
    
    override func updateConstraints() {
        if(shouldSetupConstraints) {
          // AutoLayout constraints
          shouldSetupConstraints = false
        }
        super.updateConstraints()
      }

    private func defineScrollableArea() {
        guard let scrollview = hostScrollView else { return }
        topConstraint?.constant = arbitraryLargeOffset
        bottomConstraint?.constant = arbitraryLargeOffset
        leftConstraint?.constant = arbitraryLargeOffset
        rightConstraint?.constant = arbitraryLargeOffset
        scrollview.layoutIfNeeded()
    }

    private func centreOurReferenceView()
    {
        guard let scrollview = hostScrollView else { return }
        let xOffset = arbitraryLargeOffset - ((scrollview.frame.size.width - self.frame.size.width) * 0.5)
        let yOffset = arbitraryLargeOffset - ((scrollview.frame.size.height - self.frame.size.height) * 0.5)
        scrollview.setContentOffset(CGPoint(x: xOffset, y: yOffset), animated: false)
    }

    private func allocateInitialTiles() {
        if let scrollview = hostScrollView {
            adjustGrid(for: scrollview)
        }
    }

    private func populateGridInBounds(lowerX: Int, upperX: Int, lowerY: Int, upperY: Int) {
        guard upperX > lowerX, upperY > lowerY else { return }
        var coordX = lowerX
        while coordX <= upperX {
            var coordY = lowerY
            while coordY <= upperY {
                allocateTile(at: (coordX, coordY))
                coordY += 1
            }
            coordX += 1
        }
    }

    private func clearGridOutsideBounds(lowerX: Int, upperX: Int, lowerY: Int, upperY: Int) {
        let tilesToProcess = allocatedTiles
        for tile in tilesToProcess {
            let tileX = tile.coordinates.0
            let tileY = tile.coordinates.1
            if tileX < lowerX || tileX > upperX || tileY < lowerY || tileY > upperY {
                //print("Deallocating grid tile: \(tile.coordinates)")
                tile.removeFromSuperview()
                if let index = allocatedTiles.firstIndex(of: tile) {
                    allocatedTiles.remove(at: index)
                }
            }
        }
    }

    private func tileExists(at tileCoordinates: (Int, Int)) -> Bool {
        for tile in allocatedTiles where tile.coordinates == tileCoordinates {
            return true
        }
        return false
    }

    private func allocateTile(at tileCoordinates: (Int, Int)) {
        guard tileExists(at: tileCoordinates) == false else { return }
        let tile = GridTile(frame: frameForTile(at: tileCoordinates), coordinates: tileCoordinates)
        allocatedTiles.append(tile)
        self.addSubview(tile)
        //print("We allocated a new tile at \(tileCoordinates)")
    }

    private func frameForTile(at coordinates: (Int, Int)) -> CGRect {
        let xIntOffset = coordinates.0 - referenceCoordinates.0
        let yIntOffset = coordinates.1 - referenceCoordinates.1
        let xOffset = self.bounds.size.width * 0.5 + (tileSize * (CGFloat(xIntOffset) - 0.5))
        let yOffset = self.bounds.size.height * 0.5 + (tileSize * (CGFloat(yIntOffset) - 0.5))
        return CGRect(x: xOffset, y: yOffset, width: tileSize, height: tileSize)
    }

    private func observeScrollview() {
        guard observingScrollview == false,
            let scrollview = hostScrollView
            else { return }
        scrollview.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
        //scrollview.delegate = self
        observingScrollview = true
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let scrollview = object as? UIScrollView else { return }
        adjustGrid(for: scrollview)
    }

    private func adjustGrid(for scrollview: UIScrollView) {
        let centre = computedCentreCoordinates(scrollview)
        guard centre != centreCoordinates else { return }
        self.centreCoordinates = centre
        print("centre is now at coordinates: \(centre)")
        guard tileSize > 0 else { return }
        let xTilesRequired = Int(UIScreen.main.bounds.size.width / tileSize)
        let yTilesRequired = Int(UIScreen.main.bounds.size.height / tileSize)
        let lowerBoundX = centre.0 - xTilesRequired
        let upperBoundX = centre.0 + xTilesRequired
        let lowerBoundY = centre.1 - yTilesRequired
        let upperBoundY = centre.1 + yTilesRequired
        populateGridInBounds(lowerX: lowerBoundX, upperX: upperBoundX,
                             lowerY: lowerBoundY, upperY: upperBoundY)
        clearGridOutsideBounds(lowerX: lowerBoundX, upperX: upperBoundX,
                               lowerY: lowerBoundY, upperY: upperBoundY)
    }


    private func computedCentreCoordinates(_ scrollview: UIScrollView) -> (Int, Int) {
        guard tileSize > 0 else { return centreCoordinates }
        let contentOffset = scrollview.contentOffset
        let scrollviewSize = scrollview.frame.size
        let xOffset = -(self.center.x - (contentOffset.x + scrollviewSize.width * 0.5))
        let yOffset = -(self.center.y - (contentOffset.y + scrollviewSize.height * 0.5))
        let xIntOffset = Int((xOffset / tileSize).rounded())
        let yIntOffset = Int((yOffset / tileSize).rounded())
        return (xIntOffset + referenceCoordinates.0, yIntOffset + referenceCoordinates.1)
    }

}

extension GridView: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard decelerate == false else { return }
        self.readjustOffsets()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.readjustOffsets()
    }

    private func readjustOffsets() {
        guard
            centreCoordinates != referenceCoordinates,
            let scrollview = hostScrollView,
            tileSize > 0
            else { return }
        let xOffset = CGFloat(centreCoordinates.0 - referenceCoordinates.0) * tileSize
        let yOffset = CGFloat(centreCoordinates.1 - referenceCoordinates.1) * tileSize
        referenceCoordinates = centreCoordinates
        for tile in allocatedTiles {
            var frame = tile.frame
            frame.origin.x -= xOffset
            frame.origin.y -= yOffset
            tile.frame = frame
        }
        var newContentOffset = scrollview.contentOffset
        newContentOffset.x -= xOffset
        newContentOffset.y -= yOffset
        scrollview.setContentOffset(newContentOffset, animated: false)
    }
}

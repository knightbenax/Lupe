//
//  StringemojilessStringWithSubstitution+.swift
//  Lupe
//
//  Created by Bezaleel Ashefor on 17/02/2021.
//

import Foundation

extension String {
  func stringByRemovingEmoji() -> String {
    return String(self.filter { !$0.isEmoji() })
  }
}

extension Character {
  fileprivate func isEmoji() -> Bool {
    return Character(UnicodeScalar(UInt32(0x1d000))!) <= self && self <= Character(UnicodeScalar(UInt32(0x1f77f))!)
      || Character(UnicodeScalar(UInt32(0x2100))!) <= self && self <= Character(UnicodeScalar(UInt32(0x26ff))!)
  }
}
